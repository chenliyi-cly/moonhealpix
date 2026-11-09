# MoonHEALPix

MoonHEALPix 是一个用 MoonBit 实现的 HEALPix 球面像素库，提供 RING / NESTED 索引、坐标与像素中心转换、层级单元、区间集合、像素中心区域查询、稀疏目录检索及稠密标量地图。它适用于天球目录检索、观测分箱和球面模拟数据处理。

- 模块：`chenliyi-cly/moonhealpix@0.1.0`
- 项目仓库：[chenliyi-cly/moonhealpix](https://github.com/chenliyi-cly/moonhealpix)
- 编译器要求：`moonc >= 0.10.20`。本次验证工具链为 `moonc v0.10.20+65efd5b93`（2026-11-05）与 `moon 0.1.20261104`。比赛基线为不低于 0.10.16；本项目使用稳定版的 `#derive` 语法，因此安装时需使用 0.10.20 或更新版本。
- 示例及验证命令使用 `js` 和 `wasm-gc` 目标；模块默认目标为 `wasm-gc`。
- 许可证：BSD-3-Clause。

本说明以 [公开接口](pkg.generated.mbti) 和实现源码为依据。设计与复杂度见 [架构说明](docs/architecture.md)，输入、资源和漏洞报告边界见 [安全说明](SECURITY.md)。

## 安装与入口

在使用方的 MoonBit 模块目录中添加固定版本依赖：

```sh
moon add chenliyi-cly/moonhealpix@0.1.0
```

在使用方包的 `moon.pkg` 中导入；如果该包是可执行入口，增加 `options(is_main: true)`：

```moonbit
import {
  "chenliyi-cly/moonhealpix" @hp,
}

options(is_main: true)
```

将以下内容保存为使用方包的 `main.mbt`，运行 `moon run . --target js`：


```moonbit
fn main {
  try {
    let grid = @hp.Grid::new(8)
    let direction = @hp.LonLat::degrees(120.0, 30.0)
    let nested = grid.lonlat_to_nested(direction)
    let ring = grid.nested_to_ring(nested)
    assert_eq(grid.ring_to_nested(ring), nested)
    println("nside=8 pixels=\{grid.npix()} nested=\{nested} ring=\{ring}")
  } catch {
    error => abort("MoonHEALPix example failed: \{error}")
  }
}
```
可执行源码使用 `fn main { ... }`。许多 API 会 `raise HealpixError`，入口应在 `try { ... } catch { ... }` 中处理错误；完整写法直接参见三个示例的 `main.mbt`，不要在入口上套用未经核对的顶层 `raise` 声明。示例额外使用数学库，其导入以各目录的 `moon.pkg` 为准。

先确认终端使用的是符合要求的工具链，再从项目根目录运行包目录：

```sh
moonc -v
moon version
moon run examples/catalog --target js
moon run examples/catalog --target wasm-gc
moon run examples/observations --target js
moon run examples/observations --target wasm-gc
moon run examples/simulation --target js
moon run examples/simulation --target wasm-gc
```

`examples/catalog`、`examples/observations` 和 `examples/simulation` 是可执行包目录；运行参数不是某个 `.mbt` 文件，也不是带 `@` 的依赖包别名。

## 使用前必须确定的约定

| 项目 | 当前实现的约定 |
| --- | --- |
| 分辨率 | `Grid::new(nside)` 只接受 `1..8192` 中的二次幂；`Grid::from_level(level)` 接受 `0..13`，且 `nside = 2^level`。 |
| 像素编号 | 从零开始，范围为 `[0, npix)`，其中 `npix = 12 * nside * nside`。编号类型为 `Int32`。 |
| 角度 | `LonLat::new(lon, lat)` 接收弧度；`LonLat::degrees(lon, lat)` 接收度。经度归一化到 `[0, 2π)`，纬度必须在 `[-π/2, π/2]`，不自动夹取越界纬度。 |
| 距离与面积 | `separation`、查询半径及 `SourceHit::distance()` 使用弧度；像素面积使用球面度。`resolution()` 是像素面积平方根，不是边长或像素包围半径。 |
| 编号顺序 | API 枚举为 `@hp.Ring`、`@hp.Nested`。同一个整数在两种顺序下通常表示不同像素，转换必须显式进行。 |
| 层级单元 | `Cell`、`FaceXY` 对应 NESTED；`Cell::new` 的编号是 NESTED 编号。 |
| 区间 | `PixelRange` 是半开区间 `[start, end)`；`PixelSet` 自带网格和顺序，规范化后区间有序、非空且互不相接。 |
| 缺失值 | `ScalarMap` 使用 `None` 表示缺失；有效数值为有限的 `Some(Double)`。NaN 和正负无穷不能充当缺失值。 |
| 坐标系 | 经纬度只描述球面方向；库不变换天球参考系、历元、赤道坐标或银道坐标。输入必须由调用方统一参考系。 |

## 工作流一：目录锥形检索与计数地图

完整程序：[examples/catalog/main.mbt](examples/catalog/main.mbt)。

1. 创建 `nside = 8` 的网格，用 `LonLat::degrees` 读入三个源：经度 `359.8°` 和 `0.2°` 附近的两个源，以及一个远处源。`Catalog::new(grid, sources, max_sources)` 建立稀疏 NESTED 索引，并保留输入数组下标作为源标识。
2. 对 `(0°, 0°)` 调用 `query_cone(center, radius, max_hits, max_work)`。示例将 `1°` 转为弧度，以 `100` 限制命中数，以 `1000` 限制工作计数，检查跨经度接缝的两个源均命中。
3. 结果是 `Array[SourceHit]`，按角距离升序排列，相同距离按原始输入下标排列。通过 `index()` 关联业务数据，通过 `distance()` 读取弧度距离；`catalog.source(index)` 可取回原坐标。
4. 使用 `count_map(1000)` 生成 NESTED 稠密计数地图，检查全图计数之和为 `3`。未占用像素的计数是 `Some(0.0)`。
5. 使用 `lonlat_to_nested`、`nested_to_ring` 和 `ring_to_nested` 验证同一方向的编号转换。

目录检索使用**实际源的包围圆**：每个占用桶以像素中心为圆心，以桶内真实源到圆心的最大角距为半径。查询先保守排除不相交的桶，再逐源检查闭锥条件 `distance <= radius`。它不会仅因桶的像素中心位于查询圆外就排除桶，也不会用 `resolution()` 猜测像素半径，因而避免这类预筛导致的像素边界附近源漏检。浮点计算及阈值比较仍受 `Double` 精度限制。

`max_work` 计入每次占用桶访问和每次候选源检查；筛选阶段最坏为 `O(occupied + sources)`，最后还需对命中结果排序。预算耗尽会抛出错误，不返回截断后伪装成完整的结果。

## 工作流二：观测加权分箱、汇总与区域筛选

完整程序：[examples/observations/main.mbt](examples/observations/main.mbt)。

1. 创建 `nside = 4` 的目录；每条坐标对应一个观测值和一个权重，两个数组长度都必须等于目录源数。
2. 调用 `bin_values(values, weights, max_pixels)`。示例输入值为 `10、14、20`，权重为 `1、3、2`，前两条观测位于同一方向。该像素加权均值为 `(10×1 + 14×3) / 4 = 13`。
3. 从 `BinnedStats` 读取 `counts()`、`weights()`、`sums()`、`means()`、`variances()` 五张 NESTED 地图。`sums()` 是加权和 `Σ(wv)`；示例全图加权和为 `92`。
4. 对 `sums()` 使用 `resample(Grid::new(1), Sum, max_pixels)` 聚合到粗网格，检查加权总量保持为 `92`。
5. 用 `LonLatBox::degrees(0, 90, -90, 90)` 定义区域，经度含西边界、不含东边界，纬度含两端。`query_box` 返回 RING 像素中心集合，先 `reorder(Nested, max_pixels)`，再用于 NESTED 均值地图的 `masked`。
6. 对区域地图调用 `summary()`；有有效像素时读取统计，完全缺失时处理 `None`。

加权分箱的数值含义如下：

| 输出 | 有效观测像素 | 无有效观测像素 |
| --- | --- | --- |
| `counts()` | 值存在且权重大于零的观测条数 | `Some(0.0)` |
| `weights()` | 有效观测的 `Σw` | `Some(0.0)` |
| `sums()` | `Σ(wv)` | `None` |
| `means()` | `Σ(wv) / Σw` | `None` |
| `variances()` | 按权重计算的总体方差，分母为 `Σw` | `None` |

权重必须有限且非负。零权重和 `None` 观测不参与统计，但所有权重和所有 `Some` 值仍须通过有效性检查。`count_map()` 计数全部目录源；`bin_values().counts()` 只计数参与统计的有效观测，二者含义不同。

不要直接平均各像素的 `means()` 来代替原观测的整体加权均值。保留权重并聚合加权和、权重后求比值，才能保留相应的观测权重语义。

## 工作流三：模拟场重采样、区域选取与显示几何

完整程序：[examples/simulation/main.mbt](examples/simulation/main.mbt)。

1. 在 `nside = 4` 的每个 NESTED 像素中心计算 `2 + sin(latitude)`，用 `ScalarMap::new(grid, Nested, data, max_pixels)` 构造稠密模拟场。
2. 使用 `Mean` 降采样到 `nside = 2`，再升采样回原网格，最后 `reorder(Ring)`。示例检查全图均值在容差内为 `2`；升采样不会恢复降采样已丢失的细节。
3. 调用 `query_disc`，按闭球面圆选取像素中心。结果为 RING `PixelSet`，可直接用于同网格 RING 地图的 `masked`。
4. 将集合转为 NESTED，再用 `compact_cells(max_cells)` 压缩为混合层级单元；需要统一网格区间时可调用 `Grid::cover_cells(cells, max_ranges)`。这些操作表达离散像素集合，不生成标准 MOC 文件。
5. 对一个 `Cell` 调用 `boundary(8, 32)`，生成 `32` 个曲边采样点，用于显示。返回数组不重复首点，需要闭合折线时由调用方补上。

重采样保留输入地图的编号顺序，按 NESTED 父子关系进行：

| 模式 | 降采样 | 升采样 | 适用数值 |
| --- | --- | --- | --- |
| `Mean` | 对非缺失子像素求算术平均 | 将父像素值复制给每个后代 | 温度、强度等场值 |
| `Sum` | 对非缺失子像素求和 | 将父像素值均分给所有后代 | 每像素积分量、累计量 |

降采样时全部子像素都缺失，结果为 `None`；升采样时缺失父像素的后代也都是 `None`。`Mean` 不按缺失像素补零，不估计未观测覆盖；`Sum` 的守恒含义是已存储有效数值的总量，不推断缺失区域的真实总量。这里没有任意方向插值或球谐重采样。

## API 导航

以下名称均来自当前公开接口；详细参数类型与 `raise` 声明以 [pkg.generated.mbti](pkg.generated.mbti) 为准。

| 用途 | 主要接口 |
| --- | --- |
| 坐标和向量 | `LonLat::new/degrees`，弧度与度访问器，`vector`、`separation`；`Vector::new/components/lonlat/dot/separation` |
| 网格 | `Grid::new/from_level/nside/level/npix/pixel_area/resolution/validate_pixel` |
| 索引和中心 | `Grid::index/center/convert`，`lonlat_to_ring/lonlat_to_nested/vector_to_nested`，`ring_center/nested_center/ring_to_nested/nested_to_ring` |
| 面坐标和纬圈 | `FaceXY::new/components`，`Grid::pixel_face/face_pixel/pixel_position/ring_count/ring_info/pixel_ring`，`RingInfo` 的编号、起点、数量及角度访问器 |
| 层级 | `Cell::new/from_uniq/uniq/parent/children/descendant_range/contains/center/area/boundary` |
| 区间集合 | `PixelRange::new/start/end/length`；`PixelSet::new/ranges/count/contains/pixels/union/intersection/difference/complement/reorder/at_level/compact_cells`；`Grid::cover_cells` |
| 区域 | `LonLatBox::new/degrees/contains`，`Grid::query_disc/query_box` |
| 目录 | `Catalog::new/grid/length/occupied_pixels/source/pixel_sources/query_cone/count_map/bin_values`；`SourceHit::index/distance` |
| 地图 | `ScalarMap::new/filled/grid/ordering/values/get/sample/with_value/reorder/masked/coalesce/resample/summary`；`BinnedStats`、`Summary` 的统计访问器 |

`ScalarMap::sample` 返回方向所在像素的值，不做插值。`with_value` 返回新地图；`coalesce` 只用另一张同网格、同顺序地图填补缺失值。`summary` 跳过缺失值，返回有效数、缺失数、和、均值、总体方差、最小值和最大值；全缺失返回 `None`，总体方差不是无偏样本方差。

## 查询、层级与数值边界

- `query_disc` 和 `query_box` 都是 **pixel-center 查询**，不计算像素 footprint 与区域的相交，也不保证返回覆盖连续区域的全部相交像素。圆半径须为有限的 `[0, π]`；半径 `π` 返回全图。
- `LonLatBox` 的经度是从 `west` 开始、宽度为 `width` 的环绕半开区间，纬度为闭区间。宽度零表示空区域，`2π`（度构造器为 `360`）表示全部经度。
- `Cell::uniq()` 使用 NUNIQ 整数 `4*nside² + nested_pixel`，支持范围 `4..1073741823`。NUNIQ 编码、混合层级单元和区间压缩不等于标准 MOC 实现或 MOC 合规性。
- `children(level, max_cells)` 的 `level` 是目标绝对层级；允许与当前层级相同，也可展开多层。`at_level` 降低集合分辨率时必须完整覆盖父单元，否则抛出 `InvalidRange`，不自动外扩。
- `boundary` 的 `steps` 范围为 `1..4096`，每边取 `steps` 点，共 `4*steps` 点；它是曲边显示采样，不是精确球面多边形求交。
- 统计使用补偿求和及 Welford 类方差更新，并检查非有限结果。输入即使全部有限，中间累积或结果溢出也可能抛出 `InvalidData`；有限输入不保证计算成功，也不保证任意精度。

## 资源预算

预算是调用方提供的元素数量或操作计数，不是内存字节限额。超限通常抛出 `HealpixError::ResourceLimit`；不能依靠它捕获运行时内存耗尽。

| 参数 | 约束对象 |
| --- | --- |
| `Catalog::new` 的 `max_sources` | 输入源数 |
| `pixel_sources` 的 `max_sources` | 单个桶的输出源数 |
| `query_cone` 的 `max_hits` / `max_work` | 命中数 / 占用桶访问与候选源检查总次数 |
| `query_disc/query_box` 的 `max_pixels` / `max_work` | 选中像素数 / 纬圈访问与候选中心检查次数 |
| 地图构造、计数、分箱、重采样的 `max_pixels` | 输出网格的完整 `npix`，不是有效值数量 |
| `PixelSet::pixels/reorder` 的 `max_pixels` | 展开或转换顺序时的像素数；同顺序 `reorder` 走复制规范化路径，不展开像素 |
| `children` / `compact_cells` 的 `max_cells` | 输出单元数 |
| `cover_cells` 的 `max_ranges` | 输入单元数，检查发生在区间合并之前 |
| `boundary` 的 `max_points` | 输出边界采样点数 |

`ScalarMap` 是 dense 表示。`nside = 8192` 时有 **805,306,368** 个像素：即使仅按每像素 8 字节浮点值计算，也需 **6 GiB**；实际 `Array[Double?]` 表示、数组开销和副本会使内存需求更高。分箱一次生成五张地图；重采样还有工作数组。支持该网格编号范围，不表示普通进程能够构造该分辨率的地图。调用者必须制定可承受的 dense 预算。

`values()`、`with_value()`、地图 `reorder()`、`masked()`、`coalesce()` 会分配或复制整图，且这些方法没有新的 `max_pixels` 参数。区间集合的一些代数操作也没有显式预算。`query_disc` 的候选和纬圈预算不覆盖所有排序、分配和运行时成本，更不构成硬内存或时间沙箱；服务端仍应限制并发、输入规模、运行时间和进程内存。

## 验证与当前状态

本地使用 moonc 0.10.20 完成了严格检查及 wasm-gc、wasm、js 的构建、65 个测试和三个示例运行。Windows native 构建缺少 MSVC 与 Windows SDK；native 的运行验证由 Linux CI 执行，具体结果见仓库 Actions。

独立离线 oracle 来自 `astropy-healpix 1.1.3`，数据保存在 [tests-data/oracle.json](tests-data/oracle.json)，转换为 [oracle_wbtest.mbt](oracle_wbtest.mbt) 中的静态测试：

- `1792` 个角度样本，每个执行 `6` 个断言；`700` 个独立编号转换样本，每个执行 `2` 个断言，合计 **12,152 个断言**。
- 测试按 **40 个 oracle 批次**组织，涉及 `nside = 1, 2, 4, 8, 16, 64, 8192`。
- 像素编号和顺序转换比较整数相等；中心位置比较角距严格小于 `1e-10` 弧度。
- oracle 角度采样主动避开像素边界、极点及分区过渡附近，不能单独证明所有边界行为；另有本地往返、穷举、暴力查询对照、缺失值和资源边界测试。
- JSON 中的 NUNIQ 数据没有纳入这 40 个 oracle 批次或 12,152 个断言；NUNIQ 层级行为由本地测试检查。

测试总数会随回归测试增加，不在本文固定。CI 工作流包含 `check`、`build`、`test` 和三个目录示例的 `examples` 验证，覆盖 `js` / `wasm-gc` / `wasm` / `native`；具体配置与执行状态以仓库工作流及运行日志为准。发布和 CI 状态见仓库 Actions、Release 与精确版本的 MoonCakes 页面。没有进行跨库性能基准比较。

对应的本地验证命令为：

```sh
moon check --target js
moon build --target js
moon test --target js
moon check --target wasm-gc
moon build --target wasm-gc
moon test --target wasm-gc
python tools/oracle_to_moonbit.py --check
```

随后运行前述六条 `moon run examples/...` 命令。oracle 一致性检查需要 Python 和可用的 `moonfmt`，可用 `--moonfmt` 显式指定格式化器；它不重新计算 oracle，也不写入生成文件。重建 oracle 的脚本及 Python 依赖分别见 [tools/generate_oracle.py](tools/generate_oracle.py) 和 [requirements-oracle.txt](requirements-oracle.txt)。普通 MoonBit 测试消费已生成的静态数据，不需要 Python、Astropy 或网络。

## 当前未实现的功能

当前没有 FITS 读写、球谐分析或变换、像素邻接查询、标准 MOC 序列化或标准 MOC 操作，也没有像素 footprint 求交、任意多边形覆盖或任意方向插值。边界点采样、NUNIQ 和区间集合不能替代这些功能。

## 许可与归属

项目采用 **BSD-3-Clause**。第三方算法、参考资料及 oracle 的归属与许可见 [THIRD_PARTY.md](THIRD_PARTY.md)；AI 辅助使用说明见 [AI_USAGE.md](AI_USAGE.md)。这些说明与项目许可证一起构成发布时应保留的归属材料；运行时依赖与离线 oracle 生成依赖应分别理解。
