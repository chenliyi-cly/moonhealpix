# MoonHEALPix 选题与语义查重

检索日期：2026-11-09。使用 moonbit-hackathon-builder 与 osc2026-guide 的 Project Research Guide；沿用固定比赛要求和用户提供的 moonc >=0.10.16 验收标准，不重新解释章程。当前已超过原定 10 月 30 日截止日期，本记录不证明参赛资格或官方验收。

## 需求依据与候选

|方向|真实任务与成熟依据|三类下游与完整输入输出|判定|
|---|---|---|---|
|CPIO 归档|GNU cpio/libarchive 已有成熟格式语义；软件包、启动镜像、备份工具需读取/生成归档|构建系统把目录条目生成 initramfs；包管理器解码归档清单和载荷；备份系统校验并恢复成员|淘汰，已有直接实现|
|单位表达式/UCUM|UCUM、Pint、UDUNITS 成熟；跨系统处理测量值需要量纲和换算语义|FHIR 数量转为统一单位；实验数据解析组合单位并比较；传感数据转换后聚合|淘汰，已有直接实现|
|HEALPix 球面索引|HEALPix 等面积分区和 astropy-healpix 已有确定几何语义；经纬度规则网格不具等面积和四叉层级性质|天文目录输入坐标形成像素桶并查圆域内源；全球观测样本按等面积单元计算统计；球面模拟/可视化输入栅格和区域生成重采样数据与像素几何|通过有限范围查重，自动选择|

未声称参赛者有天文或地理工作经验；需求来自可核验的跨生态实践。不是对已有项目改名，不引用旧项目源代码、提交或测试结果。

## 检索执行与局限

- 使用 moon 0.1.20261028 / moonc 0.10.18，逐项实际运行 `moon search <词> --limit 100`。CPIO 扩展：cpio/newc/odc/initramfs/archive；单位：ucum/units/udunits/pint/dimensional；HEALPix：HEALPix/healpix/spherical/nside/pix2ang/equal area/skymap/lonlat_to_healpix/nested_to_ring。完整输出在仓库外证据目录。
- 单位和 archive 的泛词达到 100 结果上限，不能视为穷尽；精确行为词和直接近邻另行核对。HEALPix、pix2ang 的 MoonCakes 精确检索未返回模块。
- GitHub repository、README 和 code 检索 `per_page=100`：healpix、cpio、ucum、LunarUnits 加 language:MoonBit；反查 pix2ang/ang2pix/HEALPix/nested_to_ring。HEALPix 仓库/README 0 命中；code 两个命中均为 grib2 常量标签。通用 `nside pixel` 返回 536 条，仅检查第一页 100 条，存在非单词匹配 inside 的噪声，此项不作为不存在的证明。API incomplete_results=false 只表示查询本身未被服务器截断，不表示全生态已穷尽。
- 检查官方 [awesome-moonbit](https://github.com/moonbitlang/awesome-moonbit) 的 README；社区同名路径 404，改用官方仓库。没有把路径 404 当作能力不存在。
- MoonCakes 对直接近邻打开 docs 页面、公开精确版本 manifest，检查 README、接口、源码和测试。CPIO GitHub 仓库 404，改用已发布源码 ZIP，不以缺失仓库直接放行。
- 搜索完整永久注册表能力词，阅读相关完整指纹，永久保留 MoonBench、MoonContract、MoonRecur、MoonShard、MoonCite、MoonPhone，以及 SunCalc、Topo 等项目。HEALPix 不求历法事件、天体位置、拓扑复形或通用几何布尔运算。
- 未执行第三方项目测试，不以源码中有测试就声称其 CI 通过。不覆盖私有、未发布或尚未被索引的项目，不构成官方查重意见。

## 实际近邻对照

|项目及证据|输入—核心语义—输出|重合等级及处理|
|---|---|---|
|[oilleelssq-wq/moon-cpio 0.1.0](https://mooncakes.io/docs/oilleelssq-wq/moon-cpio)|newc/crc/odc/binary 字节归档；解析、零复制 streaming、安全路径、确定性 writer；条目与载荷|CPIO 直接替代，淘汰该候选。公开 ZIP checksum f039cbcdd5871cbb79a5600bbec0240bffd08e742976765608462cba37adc209；检查 pkg.generated.mbti、newc_writer.mbt、stream_test.mbt|
|[Xpeng/linuxpkg 0.5.0](https://github.com/pxgt/linuxpkg)|Linux 软件包，含 archive/cpio newc/crc 读写|CPIO 附加直接重合；此项仅查元数据和包检索能力，不声称审完源码|
|[LunarUnits 0.1.9](https://github.com/FrozenLemonTee/LunarUnits)|Quantity、量纲、单位组合、affine/logarithmic 换算|单位候选直接重合；检查 README、core/quantity/quantity.mbt、quantity_test.mbt、目录及公开 manifest|
|[impart563/moonucum](https://github.com/impart563/moonucum)|UCUM 2.2 代码解析、等价、数值转换，FHIR/传感/结构化数据场景|UCUM 候选直接重合；实际 README、pkg.generated.mbti 检查。精确 0.1.0 公开 manifest 不可用，不推断其发布状态|
|[moonbit-geofield 0.2.0](https://github.com/2515050243qyf/moonbit-geofield)|规则经纬度网格、地球物理计算、双线性插值、剖面|同方向不同核心数据模型；实际 README、grid.mbt、advanced_test.mbt、manifest 检查。规则经纬网格与 HEALPix 等面积四叉索引不兼容|
|[moon-geometry 0.251.0](https://github.com/walkzzz/moon-geometry)|通用计算几何、球面/椭球距离与投影|相邻基础数学，检查 README、geodesic 源码和接口；未发现受检范围内的 HEALPix 编号/层级能力。无代码复制，无优越性宣称|
|[trkbt10/grib2_mbt](https://github.com/trkbt10/grib2_mbt)|GRIB 格式解析，HEALPix grid 模板名、diamond ordering 的 flag 名|HEALPix 命中仅为 code_tables_section3.mbt 与 wgrib2/inventory.mbt 中格式标签；不是可导入的通用 RING/NESTED 引擎。检查 commit 00c30ee9a31adca0a15157f1b93ac7269415b9d3 的命中源码|
|永久注册表 SunCalc/Topo/Fluent/ARFF 等|分别是天体位置、拓扑数据、翻译运行时和表格交换|与球面像素编号、层级和栅格聚合工作流不同，不复用其实现或历史|

## 评分与决策

各项 1–5 分，维度依次为生态广度、用户多样性、复用、重合风险（越低风险分越高）、实现深度、验证、可完成性、维护。

- CPIO：5/4/5/1/4/5/4/4，总 32；直接重复是硬失败，分数不予抵消。
- 单位/UCUM：5/5/5/1/5/5/3/3，总 32；直接重复是硬失败。
- HEALPix：4/4/5/4/5/5/4/4，总 35；选定。

独立建设的理由是 HEALPix 的球面等面积编号、Morton 交织、RING 纬圈和层级区间构成独立的数据模型；不是给经纬度网格加一层接口。下游可将地理库转换出的坐标交给本库，两者互补。

## 交付边界与客观完成条件

核心：nside 为 1..8192 的二次幂；零起始编号；RING/NESTED 与经纬角（弧度）互换；球面向量；父子层级及 NUNIQ 标识；集合范围；圆域/经纬域的像素中心筛选；有界目录索引、标量栅格的分桶、统计及升降采样。输入验证、越界/非有限数、分配预算和退化情况必须测试。

不做：FITS、地图投影数据库、球谐变换、仪器控制、天体星历、完整 healpy API、MOC 标准兼容或所有与圆域相交像素的精确覆盖。区域查询按像素中心选择，不能冒充 footprint overlap。

使用固定 astropy-healpix 1.1.3 独立计算的向量验证索引、中心、排序与层级；用独立几何暴力真值复核区域查询；各后端验证算法不变量、错误和三个实际下游流程。参考资料及 BSD 声明保存在 THIRD_PARTY.md 和 licenses/。

检索局限如上。结论仅为：**在已记录检索范围内未发现成熟直接替代**。发布前重查核心行为词及注册表，并记录日期和差异。

## 发布前复查（2026-11-09）

在完整实现之后重新执行 `moon search healpix/pix2ang/nested_to_ring --limit 100`、GitHub MoonBit 源码搜索 HEALPix/pix2ang/nested_to_ring，以及永久注册表能力检索。前两个 Moon 搜索无结果；nested_to_ring 的模糊结果为 totto2727/x、Juwan-Hwang/moon-certified、bobzhang/games、gmlewis/step、prowk/mooncql。额外读取这五个精确版本的公开 manifest 和仓库 README，分别是工具集合、通用算法、游戏、STEP 建模和 Cassandra 驱动；未据模糊搜索的命中本身判定重复。没有声称完整审阅这五个项目的所有源码和测试。GitHub 精确行为搜索仍无 pix2ang/nested_to_ring 实现命中；HEALPix 两处仍是此前核对过的 grib2 标签。注册表仅有本项目预留记录与已记录近邻，没有新直接候选。

本次复查公开输出保存在仓库外验收证据目录；不覆盖私有、未发布和未索引代码。最终结论仍限于：**在已记录检索范围内未发现成熟直接替代**。
