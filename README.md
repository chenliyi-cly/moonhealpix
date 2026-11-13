# MoonHEALPix

MoonHEALPix 是用 MoonBit 实现的 HEALPix 球面像素库。**0.2.0** 版本提供 RING / NESTED 索引、标准八邻域、双线性插值、层级单元与区间集合、球面区域查询、保守像素覆盖、ICRS 空间 MOC、稀疏目录树和可缺失标量地图，适用于天球目录检索、观测分箱及球面模拟数据处理。

- 模块：`chenliyi-cly/moonhealpix`；许可证：BSD-3-Clause。
- 工具链要求：`moonc >= 0.10.20`；验证工具链为 `moonc v0.10.20+65efd5b93` 与 `moon 0.1.20261104`，模块默认目标为 `wasm-gc`。
- 接口以 [公开声明](pkg.generated.mbti) 为准；另见 [架构](docs/architecture.md)、[安全边界](SECURITY.md)、[第三方来源](THIRD_PARTY.md) 和 [更新日志](CHANGELOG.md)。

## 安装、运行与导入

在使用方的 MoonBit 模块目录中添加固定版本依赖：

```sh
moon add chenliyi-cly/moonhealpix@0.2.0
```

开发和验证本项目时，从源码根目录运行以下命令。示例参数是包目录，不是单个源文件。

```sh
moonc -v
moon version
moon check
moon test --target js
moon test --target wasm
moon test --target wasm-gc
moon run examples/catalog --target js
moon run examples/observations --target js
moon run examples/simulation --target js
moon run examples/spatial --target js
```

在使用方包的 `moon.pkg` 中导入模块；可执行包同时声明 `options(is_main: true)`：

```moonbit
import {
  "chenliyi-cly/moonhealpix" @hp,
}

options(is_main: true)
```

可执行入口采用 `fn main { ... }`。多数构造与查询会抛出 `HealpixError`，完整示例如下：

```moonbit
fn main {
  try {
    let grid = @hp.Grid::new(8)
    let point = @hp.LonLat::degrees(120.0, 30.0)
    let pixel = grid.index(point, @hp.Nested)
    let ring = grid.convert(pixel, @hp.Nested, @hp.Ring)
    assert_eq(grid.convert(ring, @hp.Ring, @hp.Nested), pixel)
    let adjacent = grid.neighbours(pixel, @hp.Nested)
    assert_eq(adjacent.length(), 8)
    let field = @hp.ScalarMap::filled(grid, @hp.Nested, Some(2.0), 1000)
    let value = field.interpolate_bilinear(point).unwrap()
    assert_true((value - 2.0).abs() < 1.0e-12)
    println("像素编号：\{pixel}，插值：\{value}")
  } catch {
    error => abort("示例失败：\{error}")
  }
}
```

## 数据约定

| 项目 | 约定 |
| --- | --- |
| 分辨率 | `Grid::new(nside)` 接受 `1..8192` 内的二次幂；`Grid::from_level` 接受 `0..13`，`nside = 2^level`。 |
| 编号 | 零基 `Int32`，范围 `[0, 12*nside*nside)`；RING 与 NESTED 必须显式转换。`Cell` 和目录桶使用 NESTED。 |
| 角度 | `LonLat::new` 使用弧度，`LonLat::degrees` 使用度；经度环绕到 `[0, 2π)`，非法纬度与非有限值报错。查询半径和命中距离均为弧度。 |
| 面积与尺度 | 面积单位是球面度；`resolution()` 是像素面积平方根，不能当作像素包围半径。 |
| 区间 | `PixelRange` 为半开区间 `[start, end)`；`PixelSet` 保存网格和顺序，规范化为有序、不重叠且不相接的区间。 |
| 缺失值 | `None` 表示缺失，`Some(0.0)` 是有效零；有效值必须有限，不能用 NaN 充当缺失值。 |
| 参考系 | 普通经纬度不带参考系转换能力。MOC 约定为 ICRS，调用者必须先统一坐标系与历元。 |

## 标准八邻域与双线性插值

`Grid::neighbours(pixel, ordering)` 返回固定八个槽位，顺序为 **西南、西、西北、北、东北、东、东南、南（SW、W、NW、N、NE、E、SE、S）**。不存在的邻居使用 **`-1`**，不能直接拿这个哨兵读取地图。输入与输出编号均遵循指定的 RING 或 NESTED 顺序。

`Grid::bilinear_interpolation_weights(point, ordering)` 返回四个像素编号及四个权重。前两个槽位位于锚定纬圈，后两个位于相邻纬圈，槽位不是上述方位顺序。极区向最北或最南四个像素的平均值过渡；极点处四个权重均为 `1/4`。计算权重无需构造稠密地图，可用于 `nside=8192`。

`ScalarMap::interpolate_bilinear(point)` 应用这组权重；**四个槽位中任何一个是 `None`，即使其权重恰为零，也返回 `None`**，不会重归一化有效邻居。浮点边界附近，不同实现可能选择不同的零权重角点，因此缺失值结果也可能受角点选择影响。`sample(point)` 仍是读取所在像素，不进行插值。

## 工作流一：目录锥形检索与计数地图

完整程序：[目录示例](examples/catalog/main.mbt)。在 `nside=8` 的网格上索引三个源，其中两个位于经度 `359.8°`、`0.2°` 附近。以 `(0°, 0°)` 为中心查询半径 `1°` 的闭圆，返回跨接缝的两个源；计数图总和为三。

`Catalog::new(grid, sources, max_sources)` 复制输入并保留原始下标作为源标识。目录按 NESTED 占用桶组织，在真实源包围圆上构建树，查询剪枝后逐源验证角距离；命中结果按距离升序、原始下标作为同距离次序。

`query_cone(center, radius, max_hits, max_work)` 保留原有签名。**0.2.0 的 `max_work` 改为访问的树节点数加逐项检查的源数**，旧版本的预算值应重新评估。`search_cone` 返回 `CatalogSearch`，可通过 `hits()`、`visited_nodes()`、`tested_sources()` 同时取得结果和计数；桶包围圆检查、分配和排序不单独计入该预算。树不保证所有输入下都有对数复杂度。

## 工作流二：观测分箱、加权统计与区域掩膜

完整程序：[观测示例](examples/observations/main.mbt)。将同一方向的观测 `10、14` 按权重 `1、3` 合并，像素加权均值为 `13`；加上值 `20`、权重 `2` 的另一观测，加权和为 `92`，使用 `Sum` 降采样仍保持这个总和。

`bin_values` 返回计数、权重、加权和、均值和总体方差五张图。空桶的计数与权重为有效零；没有有效观测时，和、均值及方差为缺失。缺失观测和零权重不参与统计，非法输入或计算溢出会报错。

`LonLatBox::degrees(west, width, south, north)` 第二个参数是经度宽度。经度西端包含、东端不包含，纬度两端包含。`query_box` 返回 RING 中心集合，示例先转 NESTED 再掩膜。不要将像素均值的普通平均误认为源级加权均值；汇总观测应保留权重和加权和。

## 工作流三：球面模拟场、重采样与层级压缩

完整程序：[模拟示例](examples/simulation/main.mbt)。构造 `2 + sin(latitude)` 的 `nside=4` 标量场，以 `Mean` 降采样到 `nside=2`，再升采样并转 RING，检查全图平均值在容差内保持为二。

`Mean` 降采样取有效子像素平均，升采样复制父值；`Sum` 降采样累加有效子像素，升采样把父量均分到子像素。二者均保留地图编号顺序，不会补回缺失观测。

示例还用 `query_disc` 选取圆内像素中心，转 NESTED 后用 `compact_cells` 压缩层级单元；`Cell::boundary(8, 32)` 返回曲边上的 32 个采样点，不重复首点。曲边采样适合显示，不是解析相交判定。0.2.0 可再通过 `Moc::from_pixel_set` 将 NESTED 集合显式转换为空间 MOC。

## 工作流四：球面多边形、保守覆盖与空间 MOC

完整程序：[空间示例](examples/spatial/main.mbt)。它组合八邻域、常量场插值、跨经度接缝的多边形覆盖、MOC 序列化、高分辨率中心查询及目录树检索。

**多边形仅支持位于某个开半球内、以短大圆弧为边的凸球面多边形**。`SphericalPolygon::new(vertices, max_vertices)` 接受两种绕序，拒绝退化、重复或对跖边及不符合凸性或半球约束的输入。不支持任意凹多边形、孔洞或长大圆弧边。

| 调用 | 输出顺序 | 几何含义 |
| --- | --- | --- |
| `query_disc`、`query_box` | RING | 区域内的像素中心集合，沿纬圈查询。 |
| `query_polygon` | NESTED | 多边形内的像素中心集合。 |
| `search_disc`、`search_polygon` | NESTED | 层级剪枝后的中心集合，另有 `visited()` 访问计数。 |
| `cover_disc`、`cover_polygon` | NESTED | 与区域可能相交的曲边像素覆盖候选，通过 `RegionCover` 返回。 |

**`cover_*` 是保守的像素实际覆盖范围候选，可含误报；不是解析精确相交。** `pixels()` 包含全部候选，`interior()` 保证所列像素的整个覆盖范围在区域内；`boundary()` 是两者之差，表示尚未判定的候选，不能解释为已证明相交的边界像素。

覆盖参数依次为区域、`refine_levels`、`max_pixels`、`max_work`。加深细分可排除部分误报，仍不会成为解析精确相交算法。额外细分层数范围为 `0..13-grid.level()`，`refinement_level()` 返回绝对停止层级；输出始终位于调用网格。工作预算与 `visited()` 包含层级访问及细分工作。`cover_cells` 则是离散层级单元的并集展开，与上述连续区域覆盖不同。

以下代码可放入前述 `try` 块，调用方式与空间示例一致：

```moonbit
let grid = @hp.Grid::new(16)
let polygon = @hp.SphericalPolygon::new([
  @hp.LonLat::degrees(350.0, -10.0),
  @hp.LonLat::degrees(15.0, -10.0),
  @hp.LonLat::degrees(15.0, 12.0),
  @hp.LonLat::degrees(350.0, 12.0),
], 16)
let cover = grid.cover_polygon(polygon, 3, grid.npix(), 200000)
let limits = @hp.MocLimits::default()
let moc = @hp.Moc::from_pixel_set(cover.pixels(), grid.level(), limits)
let text = moc.to_ascii(limits)
assert_true(@hp.Moc::from_ascii(text, limits).equals(moc))
```

MOC 保存的是输入的离散像素覆盖。将保守候选转换成 MOC，不会消除候选的误报。

该示例在 `js` 目标下的操作计数如下。这些是固定输入下的算法计数，**不是耗时、吞吐量或跨库性能基准**。

| 示例输入 | 结果及计数 |
| --- | --- |
| `nside=16`，上述多边形，额外细分三层 | 候选 65，全内 13，未决 52，访问 902 次。 |
| `nside=8192`，编号 `268435456` 的像素中心，零半径查询 | 命中该中心，访问 352 次；网格共有 805306368 个像素，无需创建全图数组。 |
| `nside=64` 目录，12000 个确定性分布源，以第 6000 个源为中心、半径 `0.02` 弧度 | 命中 1，访问树节点 249，逐项检查源 1；工作计数为 250，结果与逐源暴力检查一致。 |

## 空间 MOC 的格式范围

本实现支持 **IVOA MOC 2.0 的 ICRS 空间子集，层级仅为 `0..13`**。提供规范第 4.3.2 节的 ASCII 编码，以及**附录 F 的信息性 JSON 编码**。不支持 FITS、时间、频率或时空 MOC，也不声称覆盖 MOC 2.0 的全部格式与能力。

- 构造：`from_cells`、`from_uniq`、`from_pixel_set`；后者要求 NESTED，并检查声明层级是否能无损表达输入覆盖。
- 运算：并、交、差、补集；`equals` 比较覆盖，忽略声明最大层级的差异。
- 表示：内部使用 order 13 的规范区间，另存声明的 `max_order`，兄弟合并与空集仍保留该元数据。
- ASCII：按层级及编号递增，编号范围两端包含，与 `PixelRange` 的半开区间不同；允许可选的 `s` 前缀，分隔符为普通空格、回车及换行，不接受制表符。
- JSON：接收层级到编号数组的对象，或仅含 `s` 的空间包装对象；输出为不带包装的层级对象，编号逐项列出。解析器拒绝重复键、重叠单元、非整数编号和额外维度等非法内容。
- `MocLimits::new(max_ranges, max_cells, max_chars)` 分别限制规范化前的候选区间、物化单元和文本 UTF-16 代码单元数；默认值也是硬上限：`100000、100000、4194304`。允许零预算，超限抛出 `ResourceLimit`，不会静默截断。

## 验证、资源与支持边界

2026-11-13 的本地质量门禁已通过：`wasm-gc`、`wasm`、`js` 三个目标各通过 **763 项测试**，四个示例也在每个目标上全部通过。验证包括单元测试、数学不变量、暴力查询对照及独立上游资料。普通 MoonBit 测试使用静态资料，无需 Python 或联网。独立参考包括 `astropy-healpix 1.1.3` 的索引、八邻域和插值，`spherical-geometry 1.3.3` 的多边形包含判定，以及 `mocpy 0.21.0` 对空间 MOC 覆盖和最大层级的核验。邻域和插值覆盖 `nside=1、2、4、16、8192`。具体来源、许可证和生成器见 [第三方说明](THIRD_PARTY.md)。往返测试与独立参考分别承担不同验证职责，有限样本不等于对所有输入的证明。

网格索引上限不等于稠密地图可用上限。最大网格若仅按每像素八字节计算已需 6 GiB，实际可选值布局、统计工作数组及副本会增加内存。资源预算不是超时或字节沙箱；应用仍需限制输入、并发和宿主资源。

[持续集成工作流](.github/workflows/verify.yml) 配置了 `wasm-gc`、`wasm`、`js`、`native` 四个目标，执行接口与格式检查、严格检查、构建、测试及四个示例。这里描述工作流配置，远端执行结果以实际运行记录为准；上述本地门禁结果仅覆盖列出的三个目标。

本库使用浮点几何，不提供精确实数求交、坐标参考系转换、FITS 读写、球谐变换或完整 healpy 接口。
