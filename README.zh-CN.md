# MoonSTN：数值时间约束检查工具

给定“构建后 10～20 分钟开始测试”“测试后 5～15 分钟发布”，MoonSTN 计算
发布允许落在哪个范围；如果再加一条冲突的截止要求，则给出可核验的规则环。
它是 MoonBit 原生库和离线命令行工具，核心不依赖 JavaScript 算法或外部求解器。

当前为 **0.1.0 源码候选版**，未发布 Mooncakes。
公开仓库：[JingLan0v0/MoonSTN](https://github.com/JingLan0v0/MoonSTN)。CI 实际结果见验收记录。

## 三个完整场景

| 场景 | 输入 | 输出及用途 |
|---|---|---|
| 构建发布流程 | `examples/deployment.json` 的阶段耗时范围 | 发布相对起点的紧确范围为 15～35，供流水线预算核对 |
| 配送时间窗口 | `examples/delivery.json` 的取件窗口、运输耗时和截止要求 | 返回满足全部约束的安排，并计算取件到到达的范围 20～40 |
| 冲突截止时间 | `examples/conflict.json` 中最早开始 10、至少耗时 30、最晚结束 35 | 返回由原始规则组成、总权重为负的闭环，定位矛盾来源 |

在项目目录运行：

```powershell
./scripts/moon.ps1 run cmd/main --target js -- examples/deployment.json
./scripts/moon.ps1 run cmd/main --target js -- examples/delivery.json
./scripts/moon.ps1 run cmd/main --target js -- examples/conflict.json
./scripts/moon.ps1 run examples/library --target js
node scripts/verify.mjs
./scripts/powershell-smoke.ps1
```

本机脚本能找到桌面 `MoonBit黑客松/.tools/moonstn-toolchain` 中的独立工具链。
其他机器需安装 `toolchain.json` 指定版本，或设置 `MOON_HOME` / `MOON_BIN`。
Node 验证版本为 24.14.0。

## 输入与结果

输入对象含 `timepoints`、`constraints`，可选 `queries`、`max_steps`。
每条规则含 `id`、`from`、`to`、`lower`/`upper`，含义为：

`lower ≤ time[to] − time[from] ≤ upper`

上下界可省略一侧或写 null；至少存在一侧。规则编号不能重复，节点须预先声明。
时间单位由调用方统一选择，只接受整数偏移，不解析日期、时区和夏令时。
返回安排以首个节点为零点；不默认要求其他节点非负，也不承诺安排最优。

- `feasible`：一个合法安排和请求的紧确上下界。null 表示该方向无界。
- `inconsistent`：带规则编号、方向、上下界来源及权重的负环。可独立验证，
  但不宣称是最少条数冲突集或自动修复建议。
- 输入错误或预算耗尽：单项调用抛 `StnError`；批处理该项返回 `error`。
  预算不足绝不冒充“无解”。

`--batch 文件名` 接受最多 64 个请求；`-` 表示标准输入。
单个错误不会丢失前后正常结果。整份 JSON 无效、过深或过大时整体退出 2。
正常可行/不可行结果与已解码批处理退出 0，必须检查每项 `status`。
输出失败可能产生部分输出，应检查退出码。

库提供 `network`、`solve`、`Solution::bounds/assignment`、`verify_assignment`、
`verify_conflict`、`parse_json`、`analyze`、`analyze_batch`；完整示例在
`examples/library/`，正式签名见 `pkg.generated.mbti`。

## 工程与边界

采用 Bellman–Ford 检测全图负环并生成见证，再对可行网络做 Floyd–Warshall 闭包。
Int64 精确整数运算；最大 64 时间点、512 规则、边界绝对值不超过 100 万。
逐次求解独立工作预算；解析、批量大小和查询数量另有限制。
不处理人员/机器资源分配、关系析取、不确定时长可控性、日历或任务执行。

验证包括两种构建模式的单元、完整三场景、4,096 个网络的独立穷举对照、
批次隔离、数值/规模边界、输入与结果可变数组隔离、伪造证据以及进程 I/O。
这些是有限范围工程证据，不是比赛终审保证。

[验收证据](docs/acceptance.md) · [实现说明](docs/architecture.md) ·
[资源限制](docs/resource-limits.md) · [同类项目比较](docs/ecosystem.md) ·
[比赛要求与待办](docs/competition.md) · [恢复工作](docs/progress.md)

代码 Apache-2.0。AI 参与设计、实现、测试与文档；参赛者须理解并能解释成果。
参考及复用关系见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
