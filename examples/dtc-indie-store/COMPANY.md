---
name: DTC 独立站（Paperclip + Cursor）
description: 用 Paperclip 编排 AI 公司：Cursor 负责工程实现，其他代理负责内容与运营；独立站支付与履约在 Paperclip 外完成。
slug: dtc-indie-store
schema: agentcompanies/v1
version: 0.1.0
license: MIT
authors:
  - name: Paperclip Example
goals:
  - 在可控预算内上线可下单的独立站（MVP）
  - 建立可复用的内容与增长节奏
  - 工程变更通过 Cursor 在目标代码仓库落地
---

本示例公司用于「Paperclip 控制平面 + Cursor 开发 + AI 员工运营」的独立站卖货场景。

- **控制平面**：任务、评论、心跳、预算、审批均在 Paperclip。
- **工程**：`cursor-dev` 代理使用 **cursor** 适配器，在导入后必须在 UI 中填写 **`cwd`（店铺/站点仓库绝对路径）** 与可选的 **`instructionsFilePath`**。
- **运营**：`ops-content` 使用 **claude_local**（可改为 codex_local / http），负责文案、上架说明、SEO 结构等 issue。
- **战略协调**：`ceo` 负责分解工作、对齐目标；敏感动作遵守公司董事会审批设置。

详细步骤见同目录 [README.md](./README.md)。
