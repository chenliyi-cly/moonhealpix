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

## 邮件补充后的范围复核（2026-11-13）

本次是在原项目和原历史上完善基础能力，保留以上 2026-11-09 的选题比较记录。新增范围为 HEALPix 邻域、双线性插值、凸球面多边形、保守像素覆盖、层级检索和空间 MOC ASCII/JSON。下述复查专门针对这些新增语义；历史“不做 MOC/插值”的范围记录由本节更新，历史实现情况不倒改。

- MoonCakes / `moon search`：healpix、moc、bilinear_interpolation、query_polygon，各最多 100 条；分别返回自身既有模块、65 条模糊 MOC 词命中、11 条插值相关项、22 条多边形相关项。未触及该上限。并非所有模糊结果都做了源码审阅，不能将搜索噪声当成全部排除的证明。
- GitHub MoonBit 源码搜索：HEALPix 为已查过的 GRIB 模板标签；IVOA 的 5 个结果为数据、编码器测试或字符映射片段，未识别出可导入的空间 MOC 实现，但未声称逐一审查其全部仓库；精确 bilinear_interpolation_weights 无返回。检索使用已绑定账号，只读记录 total_count 与 incomplete_results。
- 读取永久注册表的相关完整指纹，保留 MoonHarmonics（球谐系数分析/合成）的已完成记录及其他保留选题；不把同为球面计算视作同一数据模型。MoonCite、MoonPhone 及所有历史保留条目仍受保护。

### 新相邻项目的源码比较

| 相邻项目 | 实际检查范围 | 数据模型和功能边界 |
| --- | --- | --- |
| LING71671/MoonSTRtree 0.2.4 | README；src/extensions/polygon/polygon.mbt；polygon_wbtest.mbt | 平面 Polygon2D、射线法和 Sutherland–Hodgman 裁剪，矩形打包索引；未在所查源码中发现 HEALPix 球面像素投影/邻接、NESTED 单元层级或空间 MOC 文档。源码 blob 分别 6fe213102a059a855be05c51df72d2101f3dfbbd（README）、4e8c7c4d0f71628885ec6c393e88d86a7e7d00bf、85fa3f4eead99652b62a0e0b69a0424947faf657。 |
| OrisGo/MOctree | README、公开接口、objects/query.mbt、query_test.mbt | 三维对象的 AABB/射线索引；不能用相同的核心单元/查询约定替代球面 HEALPix 邻域、曲边覆盖和 IVOA MOC。检索快照 blob：README e1d509fca56f50f372e490930ce8497ed9109d31、objects/query.mbt 1ad7ad9933f7fbed37e764a62e9a0f9468b2c772、query_test.mbt f3809b0090b72fd2dff9aa0e1c2226a81f61aa75。 |
| moonbit-geofield / moon-geometry | 沿用此前已读 API/源码/测试范围，未宣称本轮重新完整审计 | 规则经纬网双线性插值与通用平面/地理计算可组合使用；HEALPix 在相邻纬圈上的四点权重、面边界邻接和层级覆盖有独立约定。 |

源码 blob、完整检索输出和取得时间的本地证据保存在仓库外验收目录。只做过源码阅读的相邻项目不声称运行过其测试。

### 更新后的交付边界

新增能力以成熟 astropy-healpix 1.1.3 的邻域/插值行为，以及 IVOA MOC 2.0 空间编码为基线。多边形仅支持一个开半球内的凸、短大圆边多边形。区域覆盖输出保守候选，`interior` 保证全内，`boundary` 可以有误报；不宣称解析精确求交或与 healpy inclusive/fact 策略返回完全相同集合。MOC 限 ICRS 空间 order 0..13、标准 ASCII 与附录 F 的信息性 JSON，不实现 FITS、时间或频率 MOC。

天文目录查询、全球观测分箱、球面场重采样三个既有下游继续保留，并增加空间覆盖交换和任意方向采样。没有换题，也未复用相邻项目的代码或提交历史。受公开索引、模糊搜索及未发布代码限制，复查结论仅为：**在已记录检索范围内未发现成熟直接替代**。
