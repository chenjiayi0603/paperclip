# DTC 独立站示例公司（Paperclip + Cursor）

本目录为可导入的 [Agent Companies](https://agentcompanies.io/specification) 包，对应「Paperclip + Cursor 独立站卖货」落地计划的可执行模板。

## 1. 选定路线与仓库（STORE_STACK.md）

打开并填写 [STORE_STACK.md](./STORE_STACK.md)，在 **路线 A（SaaS）** 与 **路线 B（自研）** 中做出选择，记下主仓库绝对路径（供 Cursor 适配器使用）。

## 2. 启动 Paperclip 并导入公司

```sh
pnpm dev
# 另一终端：
pnpm paperclipai company import ./examples/dtc-indie-store \
  --target new \
  --new-company-name "我的 DTC 独立站" \
  --include company,agents,projects,tasks \
  --yes
```

导入后：

- 若公司设置要求 **董事会批准新代理**，请先在 **Approvals** 中通过 CEO、`cursor-dev`、`ops-content` 的入职/配置项。
- 定时心跳默认关闭；请按需为各代理开启 **分配唤醒 / 按需唤醒**（见 [docs/agents-runtime.md](../../docs/agents-runtime.md)）。
- 若启用 **claude_local** 代理，在 UI 中绑定 `ANTHROPIC_API_KEY`（或通过 env inputs 填写）。

## 3. 创建目标层级（API）

导入完成后，在 UI 或 `pnpm paperclipai company list` 中查看 **company id**，然后执行（`local_trusted` 下通常无需 Cookie）：

```sh
pnpm bootstrap:dtc-goals <companyId>
# 等价于：node scripts/bootstrap-dtc-example-goals.mjs <companyId>
```

默认 API 地址为 `http://127.0.0.1:3100`，可通过 `PAPERCLIP_API_BASE` 覆盖。

然后在看板中将各 **issue** 关联到对应 **goal**（站点 MVP / 增长 / 内容）。

## 4. 配置 Cursor 工程代理（cursor-dev）

1. 打开 **Agents → cursor-dev → 适配器配置**。
2. 设置 **`cwd`** 为 [STORE_STACK.md](./STORE_STACK.md) 中的主代码仓库**绝对路径**。
3. （推荐）设置 **`instructionsFilePath`** 为该仓库内说明文件（如 `AGENTS.md`）的绝对路径。
4. 运行 **Test environment**，确认本机可执行 Cursor Agent CLI（参见 [packages/adapters/cursor-local](../../packages/adapters/cursor-local)）。
5. 若代理需调用 Paperclip API，为公司创建 **agent API key**，写入适配器 env 中的 `PAPERCLIP_API_KEY`（勿提交到 Git）。

## 5. 运营类代理（ops-content）

- 默认与 CEO 同为 **claude_local**；可在 UI 改为 `codex_local` 或 `http`（对接 n8n / 自建服务）。
- 运营 issue 描述可参考 [references/ISSUE_TEMPLATES.md](./references/ISSUE_TEMPLATES.md)。

## 6. 治理与合规（董事会）

- **预算**：`.paperclip.yaml` 中 `budgetMonthlyCents` 仅为示例；导入后在 **Costs / Budget** 中按实际调整（月度 UTC，硬停见 SPEC-implementation）。
- **审批**：示例公司开启 `requireBoardApprovalForNewAgents`；新代理与敏感策略仍按 V1 审批流走。
- **人类必须保留**：商户资质、收款合规、物流与退换货、广告账号与定价策略；勿将密钥或客户 PII 写入任务评论。
- **数据范围**：Paperclip V1 不内置营收账本；订单与营收在店铺后台或 BI 中查看。

## 相关文档

- [导入与导出](../../docs/guides/board-operator/importing-and-exporting.md)
- [Agent Runtime](../../docs/agents-runtime.md)
- [控制平面 CLI](../../docs/cli/control-plane-commands.md)
