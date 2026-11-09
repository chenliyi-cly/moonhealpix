# 第三方来源与许可

MoonHEALPix 的原创 MoonBit 实现采用 BSD-3-Clause。索引与连续面坐标公式参考 astropy-healpix 的 BSD 实现；保留 Astropy 与其内部 Astrometry.net 两份原始通知，见 [LICENSES](LICENSES/)。这些来源允许修改和再分发，不代表上游认可本项目。

| 来源 | 参考范围 | 许可证与边界 |
|---|---|---|
| [astropy/astropy-healpix](https://github.com/astropy/astropy-healpix) | `cextern/astrometry.net/healpix.c` 的球面分区、面坐标映射与 RING/NESTED 算法；官方 API、测试作为行为参考 | BSD-3-Clause，通知完整保存在 LICENSES；未嵌入 C、Python 或二进制上游库 |
| Astrometry.net（由 astropy-healpix 维护的内部实现） | 同一 C 文件内的基础 HEALPix 数学实现 | BSD-3-Clause，保留原版权、条件和免责条款 |
| astropy-healpix 1.1.3 | 离线测试生成器的独立执行参考 | 仅开发依赖；生成固定种子的数值资料，不是生产代码 |
| moonbitlang/core | 数学函数、基础容器与测试支持 | Apache-2.0，随 MoonBit 官方工具链提供 |

参考代码记录：研究时读取 `healpix.c` 的 Git blob SHA 为 `56165648baaaa4686b9bc1493b948e40a362b0c9`。该源码快照和用于执行的 Python 1.1.3 版本分别记录，不将 main 分支声称为固定 1.1.3。

本项目重写了有类型校验的 MoonBit API、资源预算、范围运算、NUNIQ 层级操作、稀疏目录、缺失值地图和加权统计。未复制 GPL HEALPix/healpy 实现，未加入 FITS、球谐变换或完整 MOC 文档实现。HEALPix 算法名称用于描述兼容的编号，不表示完整上游 API 兼容。

测试生成环境及依赖见 `requirements-oracle.txt`；依赖许可证在安装的分发包中保留，本仓库不再分发这些包。原始通知原样保存，根 LICENSE 只适用于本项目原创部分。
