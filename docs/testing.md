# 测试与复现

使用 MoonBit 20261028 工具链（moonc 0.10.18），执行 `moon info`、`moon fmt --check`，再对 wasm-gc、wasm、js、native 分别执行 `moon check --target TARGET --deny-warn`、`moon build --target TARGET --deny-warn`、`moon test --target TARGET --deny-warn`，并运行三个 examples。native 链接需要 C 工具链；Windows 本地缺少时由 Linux CI 完成运行证明。

独立 oracle 是固定版本 `astropy-healpix==1.1.3`，完整 Python 依赖冻结在 `requirements-oracle.txt`。在独立虚拟环境安装依赖后运行：

```sh
python tools/generate_oracle.py --output tests-data/oracle.json
python tools/oracle_to_moonbit.py --check
```

固定种子 20261109。1,792 条角度样本和 700 条独立排序样本覆盖 nside 1、2、4、8、16、64、8192，生成 40 个测试批次、12,152 次断言：检查方向编号、两种像素中心和双向编号转换。中心容差为球面夹角严格小于 1e-10 弧度。JSON 另含 380 条 NUNIQ 参考条目；目前不把这些未接入 MoonBit 的条目计作差分断言。生成文件与资料均不计生产代码量。

| 功能 | 独立预期与实际测试 |
|---|---|
| 网格与整数范围 | 球面积恒等式、边界值、溢出边界 |
| 球面坐标 | 单位范数、反向与反极点，极大有限向量 |
| RING/NESTED | astropy 独立 oracle；小网格全像素双射 |
| 区间与覆盖 | 逐像素布尔真值表；压缩后逐像素相同 |
| NUNIQ | 等级、偏移公式及末端标识；父子范围等价 |
| 区域查询 | 对所有小网格像素中心直接计算，检查极点、接缝及半开经度 |
| 目录查询 | 对原始源逐个计算精确球面夹角，确保像素边缘源不漏检 |
| 地图与加权统计 | 手算小样本、缺失值、零权重、非有限数拒绝与总量守恒 |
| 三类工作流 | examples/catalog、observations、simulation 内包含结果断言 |

生产 API 没有运行时 Python 或外部数据依赖。CI 使用已提交资料，不在每次检查时从浮动上游抓取数值。重新生成参考资料是维护操作，更新应审查来源、依赖版本及资料差异。
