# 第三方来源与许可

MoonHEALPix 原创 MoonBit 代码采用 BSD-3-Clause，根目录 [LICENSE](LICENSE) 适用于原创部分。索引、连续面投影、邻域和插值参考了 BSD 许可的上游实现；原始版权、许可条件和免责通知完整保存在 [Astropy 通知](LICENSES/astropy-healpix-BSD-3-Clause.txt) 与 [Astrometry.net 通知](LICENSES/astrometry-BSD-3-Clause.txt)。上游名称用于说明来源与行为参考，不表示上游认可本项目。

## 生产实现与规范来源

| 来源 | 参考范围 | 许可与使用边界 |
| --- | --- | --- |
| [astropy-healpix](https://github.com/astropy/astropy-healpix) | HEALPix 编号、球面分区、连续面坐标、标准邻域，以及双线性插值行为 | BSD-3-Clause；保留 Astropy Developers 版权及通知。以 MoonBit 实现公开 API，未嵌入上游 C、Python 或二进制运行库。 |
| astropy-healpix 内含的 Astrometry.net 实现 | `cextern/astrometry.net/healpix.c` 的基础数学、面邻接及 RING/NESTED 算法 | BSD-3-Clause；保留 Astrometry.net Developers 版权及通知，不能仅用本项目版权替代。 |
| [IVOA MOC 2.0，2022-07-27 推荐标准](https://www.ivoa.net/documents/MOC/20220727/REC-moc-2.0-20220727.pdf) | 第 4.3.2 节规范 ASCII 和附录 F 信息性 JSON；仅 ICRS 空间 order 0..13 | 用作格式规范引用，不把规范文本作为本项目原创代码重新许可。MOC 实现为本项目代码，不声称支持标准全部维度与格式。 |
| moonbitlang/core | 数学、容器和测试基础设施 | Apache-2.0，由官方 MoonBit 工具链提供；其许可独立于本项目 BSD-3-Clause。 |

项目自行实现有类型校验的 API、预算、区间集合、目录树、凸球面多边形与保守覆盖、地图和统计，以及受限空间 MOC 的解析与集合运算。未复制 GPL HEALPix/healpy 实现，也不以 healpy 作为本次已经执行的独立验证来源。没有加入 FITS、球谐、时间或频率 MOC 实现。

## 固定源码记录

早期研究时读取的 `healpix.c` Git blob 为 `56165648baaaa4686b9bc1493b948e40a362b0c9`。这个快照与执行 oracle 的版本分别记录，不将该快照误称为固定的 1.1.3 发布源码。

0.2.0 邻域与插值来源固定为 [astropy-healpix v1.1.3](https://github.com/astropy/astropy-healpix/tree/v1.1.3)，记录在独立生成器中：

| 对象 | SHA-256 |
| --- | --- |
| PyPI 1.1.3 源码分发包 | `f520d83abe8215d3e8e1a37b2bd91171ee36a6f55f110d5a2db863d75d81b3b7` |
| `cextern/astrometry.net/healpix.c` | `254bdd3181f36606f9c5c92c2d14c478155cb0cd393b67f345e6a639d2a5bbd9` |
| `astropy_healpix/interpolation.c` | `54150c2a32a95083a3aa4aa3578813f95892ef7b1c825a810a9a21096396da06` |

对应通知记载 Astropy Developers（2016–2018）及 Astrometry.net Developers（2006–2015）；完整条款以仓库保留的原文为准。

## 独立 oracle 的版本与许可证

以下包仅用于开发期独立执行、生成或核验参考资料，不是 MoonHEALPix 运行时依赖。本仓库不再分发这些包的源码、轮子或二进制；安装包保留各自许可证。若未来打包再分发，须另行保留各依赖完整通知。

| 独立参考 | 固定版本 | 许可证 | 验证职责 |
| --- | --- | --- | --- |
| astropy-healpix | 1.1.3 | BSD-3-Clause | 索引、像素中心、邻域、双线性权重与缺失值行为；几何参考中的独立中心和圆覆盖候选。 |
| Astropy | 8.0.2 | BSD-3-Clause | 单位转换和独立球面角距离。 |
| NumPy | 2.5.4 | BSD-3-Clause | 数组、确定性抽样及测试生成；随分发包附带的其他通知仍适用。 |
| spherical-geometry | 1.3.3 | BSD-3-Clause | 独立凸球面多边形包含判定。 |
| mocpy | 0.21.0 | BSD-3-Clause，CDS 2018 | 空间 MOC 覆盖、最大层级和实际序列化结果互操作核验；没有复制其生产实现。 |

生成与核验入口：

- [tools/generate_oracle.py](tools/generate_oracle.py) 与 [tools/oracle_to_moonbit.py](tools/oracle_to_moonbit.py)：原有索引、中心和转换资料。
- [scripts/generate_neighbours_interpolation_oracle.py](scripts/generate_neighbours_interpolation_oracle.py)：由 astropy-healpix 编译实现生成预期，固定种子 `20261113`，覆盖 `nside=1、2、4、16、8192`；`--check` 校验现有资料并容忍格式化差异。科学计数法输出包含浮点尾数小数点。
- [tools/generate_region_oracle.py](tools/generate_region_oracle.py)：Astropy、astropy-healpix 与 spherical-geometry 的圆、多边形和连续面采样参考。候选包含与采样检查不等价于解析相交证明。
- [scripts/generate_moc_oracle.py](scripts/generate_moc_oracle.py)：mocpy 参考；`--verify-moon-output PATH` 读取 MoonBit 实际输出并检查覆盖及最大层级。多边形产生的集合由区间独立重建后核验序列化，验证对象是 MOC 转换，不是两个几何算法相同。

Python 环境固定项见 [requirements-oracle.txt](requirements-oracle.txt)，其中已列出原有索引依赖以及新增的 spherical-geometry、mocpy。按所需生成器准备对应固定版本；普通 MoonBit 测试使用已生成资料，不需要安装这些 Python 依赖或连接网络。

格式解析拒绝策略依据所声明的标准子集和预算约束，不照搬 oracle 对非法文本的宽容行为。独立参考与不变量测试互补，均不构成完整标准认证或对任意输入的正确性证明。
