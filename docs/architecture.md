# MoonHEALPix 架构与实现边界

本文描述 `chenliyi-cly/moonhealpix@0.1.0` 当前源码与 [pkg.generated.mbti](../pkg.generated.mbti) 暴露的实现。项目采用 BSD-3-Clause，面向 `moonc >= 0.10.20`；本次核对工具链为 `moonc 0.10.20` / `moon 0.1.20261104`。CI 覆盖 js、wasm、wasm-gc 和 native；执行状态以公开 Actions 日志为准。

## 1. 模块划分与数据流

生产代码位于同一个公开包中，内部按文件分工。运行时使用 MoonBit 核心数学、浮点及调试设施；离线 Python oracle 工具不属于运行时依赖。

| 实现文件 | 职责 |
| --- | --- |
| `model.mbt` | `HealpixError`、网格合法性、分辨率与面积 |
| `angles.mbt` | 经纬度、单位向量、球面角距、有限数验证 |
| `faces.mbt`、`nested.mbt` | 十二基面、Morton 位交错、NESTED 索引及面投影 |
| `ring.mbt`、`ordering.mbt` | 纬圈、RING 索引和中心、编号顺序转换 |
| `geometry.mbt`、`hierarchy.mbt` | 像素内部位置、曲边采样、NESTED 父子关系及 NUNIQ |
| `ranges.mbt`、`coverage.mbt` | 半开区间集合、集合运算、层级变换和压缩 |
| `query.mbt`、`regions.mbt` | 闭圆和环绕经纬框的像素中心选择 |
| `catalog.mbt` | 稀疏源目录、占用桶、真实源包围圆、锥形检索和计数图 |
| `maps.mbt`、`map_order.mbt` | 稠密可缺失标量图、统计、顺序置换、掩膜和缺失填补 |
| `binning.mbt`、`resample.mbt` | 加权观测统计、层级重采样 |

数据从经纬度进入 `Grid` 索引，可形成 NESTED `Catalog`，也可进入 `ScalarMap`。区域查询输出 RING `PixelSet`；集合用于地图掩膜前须与地图的网格和顺序一致。NESTED 集合可压缩为混合层级 `Cell`，这些单元又可展开为指定网格的 NESTED 区间。

## 2. 基础不变量

### 网格与编号

`Grid::new(nside)` 要求 `nside` 为 `1..8192` 内的二次幂。`level = log2(nside)`，范围为 `0..13`；`npix = 12*nside²`，像素编号是零基 `Int32`。最大网格有 `805,306,368` 个像素。此上限保证当前像素编号和 NUNIQ 编码可在有符号 32 位整数中表示，并不保证对应的稠密地图能放入内存。

`pixel_area()` 返回 `4π/npix` 球面度；`resolution()` 返回其平方根，单位弧度。后者不是精确边长，也不能当作保守的像素包围半径。

RING 按纬圈排列，NESTED 按基面及四叉层级排列。`Grid::index/center/convert` 接受显式 `Ordering`；专用方法直接表明顺序。`Cell`、面坐标和目录桶固定使用 NESTED。

### 坐标与精度

`LonLat::new` 接收弧度，`degrees` 接收度；经度环绕归一化，纬度越界或非有限角度抛出 `InvalidAngle`。该类型不记录天球参考系、历元或单位标签，参考系统一由调用者负责。

`Vector::new` 拒绝零向量和非有限分量，先按最大绝对分量缩放再归一化，以避免直接平方巨大分量。球面角距基于叉积长度和点积的 `atan2` 计算。实现使用 `Double`；浮点边界比较不等于精确实数几何。

### 所有权与缺失值

构造器负责建立合法状态；外部调用者应通过公开构造器和访问器使用类型。`Catalog::new` 复制输入源数组，`ScalarMap::new` 复制输入值，`PixelSet::new` 复制并规范化区间。`ScalarMap::values` 和 `PixelSet::ranges` 返回副本。

地图数据类型为 `Array[Double?]`：`None` 表示缺失，`Some(v)` 必须有限。更新、顺序转换和掩膜返回新地图，没有公开的原地修改接口。副本隔离有助于维持状态不变量，但会增加峰值内存。

## 3. 像素索引与显示几何

NESTED 索引根据球面方向所属的赤道带或极区确定基面及整数面坐标，随后交错 `x`、`y` 的位生成 Morton 编号。`FaceXY::new` 验证基面为 `0..11`、两个坐标为 `[0, nside)`；`pixel_face` 和 `face_pixel` 互为面坐标与 NESTED 编号的转换。

RING 有 `4*nside - 1` 个纬圈，纬圈编号从 `1` 开始。`RingInfo` 给出纬圈首个 RING 像素、像素数、纬度、首经度及经度步长。`pixel_ring` 通过 RING 编号定位纬圈。

当前 `nested_to_ring` 经由 NESTED 像素中心再进行 RING 索引，`ring_to_nested` 经由 RING 中心再进行 NESTED 索引。实现不是独立的纯整数排列公式，因此中心计算和角度索引都需要 oracle、往返与边界验证。

`pixel_position(pixel, dx, dy)` 接收 NESTED 像素及有限的 `[0,1]` 面内坐标。`Cell::boundary(steps, max_points)` 沿面坐标中的四条边依次采样，要求 `1 <= steps <= 4096`，返回 `4*steps` 点，每个角点出现一次，末尾不重复首点。曲线经连续 HEALPix 面投影映射到球面；用途是显示采样，不提供精确像素 footprint 求交。

## 4. 层级、NUNIQ 与区间集合

`Cell` 的 `grid` 和 `pixel` 描述某层级的 NESTED 单元。`parent(level)` 的参数是目标绝对层级；`descendant_range(level)` 通过移位取得后代的连续半开区间。`children(level, max_cells)` 展开该区间，数量为 `4^(目标层级-当前层级)`，先检查输出预算再生成数组。`contains` 通过层级对齐后的整数编号判断包含。

NUNIQ 编码为 `4*nside² + nested_pixel`，解码范围为 `4..1073741823`。该实现只提供单元整数编码和层级关系，没有标准 MOC 文件格式、标准 MOC 导入导出或标准 MOC 兼容性认证。

`PixelRange` 只存储 `[start,end)`；网格与顺序由所在 `PixelSet` 持有。集合构造时验证端点、排序、去掉空区间，合并相交或相接区间。成员检查采用二分搜索，集合交差运算扫描规范化区间。

- `union/intersection/difference` 要求相同网格与顺序，否则抛出 `IncompatibleGrid`；`complement` 相对于整个网格。
- `pixels(max_pixels)` 显式展开编号，先检查展开元素数。
- `reorder(ordering, max_pixels)` 改变顺序时展开全部选中像素、逐个转换、重新排序并合并。相同顺序直接复制规范化，不走展开预算检查。
- `at_level` 仅接受 NESTED 集合。升层级扩展区间；降层级要求区间端点与目标父单元对齐，不完整父单元抛出 `InvalidRange`。
- `compact_cells(max_cells)` 以对齐的最大四叉块压缩 NESTED 区间，保持精确离散集合，不跨十二基面合并。
- `Grid::cover_cells(cells, max_ranges)` 接受不比目标网格更细的单元，并生成其后代区间。`max_ranges` 限制输入单元数，发生在合并之前；此方法无需逐像素展开。

压缩单元只是所选像素的层级表示，不把像素中心查询自动升级成连续区域的覆盖算法。

## 5. 区域查询与目录查询

### 像素中心查询

`query_disc(center, radius, max_pixels, max_work)` 选择中心位于闭圆内的像素，结果顺序为 RING。半径必须为有限的 `[0,π]`。一般路径访问纬圈，按纬度和经度范围产生候选，再用角距进行最终判断，形成区间集合。半径为 `π` 时走全图单区间快速路径，检查输出像素数后直接返回，不逐纬圈消耗 `max_work`。

`query_box` 使用 `LonLatBox`：经度为从 `west` 起宽度 `width` 的环绕半开区间，纬度为闭区间。宽度零直接返回空集；全经度宽度可以整圈加入；其他情况检查候选中心。输出仍为 RING。

这两种查询都不求像素 footprint 与区域的交集。一个像素可能与圆或框相交而中心在外，因此不能把它们的结果作为任意源检索的无遗漏候选覆盖。

`max_work` 计入纬圈访问及候选中心检查，`max_pixels` 限制最终选中像素数。区间数组构造、排序、内存分配、三角函数实际耗时和运行时开销不被等价计数。候选和环数预算不是硬内存或时间沙箱。

### 目录索引与闭锥过滤

`Catalog::new` 为每个源计算 NESTED 像素，按像素编号排序 `(pixel, input_index)` 对，然后将相同像素的连续条目组织成占用桶。源的业务标识是原始数组下标，排序不会改变这一标识。索引规模与源数和占用桶数相关，不预分配全图桶数组。

每桶保存像素中心方向以及该中心到桶内**真实源**的最大角距。筛选查询桶时比较查询中心与桶中心的距离和两个半径之和，并留出小量浮点余量；剩余候选逐源检查闭锥条件。这避免了使用猜测像素半径或仅选像素中心带来的边界漏源。最终输出 `SourceHit`，按距离、输入下标排序。

`pixel_sources` 二分定位占用桶并返回输入下标。`query_cone` 的工作计数包含桶访问与逐源距离检查；命中数超过 `max_hits` 或工作超过 `max_work` 时抛出 `ResourceLimit`。失败调用不返回部分结果。

设 `B = occupied`、`S = sources`、`H = hits`：**查询筛选最坏为 `O(B + S)`**，不保证对数查询；完整返回过程还含 `O(H log H)` 的命中排序。`max_work` 没有计算排序比较次数。目录分桶能减少部分查询的逐源检查，但不构成性能比较结论。

## 6. 标量地图与统计

`ScalarMap` 始终有 `npix` 个槽位。`sample(point)` 先索引再取值，不做邻域插值。`reorder` 置换数据，不平均或填补缺失值。`masked` 保留选中位置并将其余位置置为 `None`。`coalesce` 只填补接收方的缺失位置，两个输入必须同网格、同顺序。

`summary` 跳过缺失值，使用补偿求和和 Welford 方差更新；输出包含有效数、缺失数、和、均值、总体方差、最小值及最大值。全缺失时返回 `None`。总体方差分母为有效像素数，不是样本数减一；统计对象是像素，不自动继承原观测权重。

`bin_values` 要求值与权重数组长度均等于目录源数，权重有限且非负，所有 `Some` 值有限。零权重或缺失值不参与更新。每桶累计有效观测数、权重和、加权和、加权均值和加权总体方差，输出五张 NESTED dense 地图。无有效观测时，计数和权重为零，和、均值及方差缺失。

有限输入的乘法、累加或方差计算仍可能溢出；统计路径将非有限计算作为 `InvalidData` 错误报告。调用者不能将错误解释为零值、缺失观测或成功的部分统计，也不能认为补偿求和保证任意数据范围下成功。

### Mean / Sum 重采样

`resample(target, mode, max_pixels)` 通过 NESTED 父子编号汇总或分配，最终保留输入顺序。目标与源网格相同时返回副本。

| 方向 | `Mean` | `Sum` |
| --- | --- | --- |
| 降采样 | 非缺失子像素算术平均 | 非缺失子像素求和 |
| 升采样 | 每个后代复制父值 | 父值除以后代数量，再给每个后代 |

全缺失子树降采样为 `None`；缺失父单元升采样仍全部缺失。`Mean` 用于强度类值，`Sum` 用于每像素积分量。重采样不恢复丢失细节、不估计缺失覆盖比例、不执行球谐分析，也不进行任意球面方向插值。对观测均值地图作 `Mean` 是按像素平均，并非按原观测权重平均。

## 7. 时间、空间与预算模型

下表是当前实现的算法量级，不是基准测试。记 `L=level<=13`，`P=npix`，`R=区间数`，`K=选中像素数`，`S=源数`，`B=占用桶数`，`C=候选中心数`，`T=目标网格像素数`。空间列指主要额外存储，不包含所有运行时对象开销。

| 操作 | 时间量级 | 主要额外空间与限制 |
| --- | --- | --- |
| RING 索引和中心 | `O(1)` | 固定规模临时量 |
| 面位交错、NESTED 索引及顺序转换 | `O(L)` | 固定规模临时量；`L` 最多 13 |
| `PixelSet::new` | `O(R log R)` | 复制、排序、合并区间，`O(R)` |
| `PixelSet::contains` | `O(log R)` | `O(1)` |
| 集合交、差 | `O(Ra + Rb)` | 输出区间数组 |
| 集合并 | `O((Ra+Rb) log(Ra+Rb))` | 当前实现重新规范化合并数组 |
| 集合顺序转换 | `O(K*L + K log K)` | 像素及单像素区间，`O(K)` |
| `query_disc/query_box` 一般路径 | 筛选 `O(nside + C)`，另有结果区间排序 | 区间输出；工作预算约束圈访问与候选检查 |
| 目录构造 | `O(S*L + S log S + B*L)` | 源副本、排序索引与桶，`O(S+B)` |
| `pixel_sources` | `O(log B + 输出数)` | 输出下标数组 |
| `query_cone` | 筛选最坏 `O(B+S)`，另有 `O(H log H)` 排序 | `O(H)` 命中输出 |
| 目录计数图 / 加权分箱 | `O(P+B)` / `O(P+S+B)` | 一张 / 五张 dense 地图 |
| 地图统计、复制、更新、缺失填补 | `O(P)` | 统计固定存储，复制类操作 `O(P)` |
| 地图顺序转换 | 改变顺序时 `O(P*L)` | 新 dense 数组；同顺序仍复制 |
| 地图掩膜 | `O(P+K)` | 新 dense 数组 |
| 地图重采样 | 上界 `O((P+T)*L)` | 输出、降采样工作数组和最终顺序副本，`O(T)` |

预算约束具体数组元素或算法计数：`max_sources` 约束目录输入或单桶输出；`max_hits` 约束命中；`max_pixels` 约束 dense 输出或集合展开；`max_cells` 和 `max_points` 约束展开的单元与边界点；`cover_cells` 的 `max_ranges` 在合并前检查输入单元数。

这些参数不是统一的全调用内存额度。尤其需要注意：

1. `nside=8192` 的 `ScalarMap` 有 805,306,368 个槽位，仅按每槽 8 字节估计已达 6 GiB；`Double?` 的实际布局、数组元数据和副本会增加成本。由调用者负责决定可接受的 dense 网格预算。
2. `bin_values` 的 `max_pixels` 是每张图的像素数，不能理解为五张图的总槽位数。重采样还会分配计数、和、补偿等工作数组。
3. `values/with_value/reorder/masked/coalesce` 没有新的预算参数，可能分配整图。若外层连续保留结果，多份整图会同时存活。
4. `PixelSet` 构造和部分集合代数没有显式资源参数。压缩区间可以很小，但改变顺序或导出编号可能把它展开成巨大数组。
5. 快速路径并不一定消耗逐元素工作预算；例如半径为 `π` 的圆查询及全经度框的整圈加入。`ResourceLimit` 是算法限额错误，不承诺捕获运行时 OOM 或超时。

面对不可信请求，应在 API 参数预算之外配置请求大小、并发、进程内存及时间限制，参见 [SECURITY.md](../SECURITY.md)。

## 8. 错误契约

| `HealpixError` 分支 | 典型原因 |
| --- | --- |
| `InvalidNside(Int32)` | 网格边长不在允许范围或不是二次幂 |
| `InvalidPixel(Int32)` | 像素编号越界 |
| `InvalidOrder(Int32)` | 非法目标层级或父子方向不合法；此处 order 指层级 |
| `InvalidAngle` | 非有限角度、非法纬度、半径、经纬框或面内位置 |
| `InvalidVector` | 零向量或非有限向量分量 |
| `InvalidFace` | 面编号或面内整数坐标越界 |
| `InvalidRange` | 非法区间、NUNIQ、源下标、纬圈、边界步数，或集合降层级不对齐 |
| `ResourceLimit` | 负预算或相关元素数、工作计数超限 |
| `IncompatibleGrid` | 网格或顺序不匹配，或对 RING 集合使用仅支持 NESTED 的层级操作 |
| `InvalidData` | 数组长度、权重或值不合法，或统计计算出现非有限结果 |

以公开接口中每个方法的 `raise HealpixError` 声明为准。应用入口使用 `fn main { try { ... } catch { ... } }` 处理失败；完整示例见 `examples/catalog`、`examples/observations` 和 `examples/simulation`。错误不表示成功的空查询或有效的零值结果。

## 9. 验证证据与边界

静态 oracle 文件来自独立 `astropy-healpix 1.1.3`，由 `tools/generate_oracle.py` 生成 JSON，再由 `tools/oracle_to_moonbit.py` 转换为 MoonBit 测试；普通测试无需 Python 或网络。

当前 oracle 包含 1792 个角度样本和 700 个独立编号转换样本，进入 40 个测试批次，共 `1792*6 + 700*2 = 12152` 个断言。采样分辨率为 `1,2,4,8,16,64,8192`；编号要求相等，中心角距要求严格小于 `1e-10` 弧度。JSON 中另有 NUNIQ 数据，但生成的 oracle 测试明确不消费这些记录。

oracle 角度样本避开边界，因此还需要本地的小网格穷举、中心往返、集合真值表、查询暴力对照、极点和接缝回归、统计溢出、缺失值及预算测试。测试数量继续变化，不固定总数。`python tools/oracle_to_moonbit.py --check` 只校验生成文件可重复性，不替代 `moon test`。

CI 工作流包含 check、build、test 和 examples；具体执行结果以运行日志为准。本文不声称标准 MOC 合规、FITS 支持、球谐功能、邻接接口或相对于其他库的性能优势。

第三方与 oracle 归属见 [THIRD_PARTY.md](../THIRD_PARTY.md)，AI 辅助使用说明见 [AI_USAGE.md](../AI_USAGE.md)。
