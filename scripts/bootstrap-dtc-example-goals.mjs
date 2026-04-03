#!/usr/bin/env node
/**
 * Create a three-level goal tree (company -> team goals) for the DTC example company.
 *
 * Usage (Paperclip API must be running; local_trusted needs no cookie):
 *   node scripts/bootstrap-dtc-example-goals.mjs <companyId>
 *
 * Env:
 *   PAPERCLIP_API_BASE — default http://127.0.0.1:3100
 */

const base = (process.env.PAPERCLIP_API_BASE ?? "http://127.0.0.1:3100").replace(/\/$/, "");
const companyId = process.argv[2];

if (!companyId) {
  console.error("Usage: node scripts/bootstrap-dtc-example-goals.mjs <companyId>");
  process.exit(1);
}

async function postJson(path, body) {
  const res = await fetch(`${base}${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Accept: "application/json" },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`${res.status} ${res.statusText}: ${text}`);
  }
  return text ? JSON.parse(text) : null;
}

const children = [
  {
    title: "站点与结账 MVP",
    description: "对应示例项目 store-mvp：最小可下单路径（见 examples/dtc-indie-store）",
  },
  {
    title: "增长与投放",
    description: "对应示例项目 growth：像素、落地页与可度量实验",
  },
  {
    title: "内容与 SEO",
    description: "对应示例项目 content-seo：文案、元数据与集合策略",
  },
];

async function main() {
  const root = await postJson(`/api/companies/${encodeURIComponent(companyId)}/goals`, {
    title: "独立站卖货：公司级目标",
    description: "与 examples/dtc-indie-store/STORE_STACK.md 中的路线、支付与履约决策对齐",
    level: "company",
    status: "active",
  });

  console.log("Created root goal:", root.id, root.title);

  for (const c of children) {
    const g = await postJson(`/api/companies/${encodeURIComponent(companyId)}/goals`, {
      title: c.title,
      description: c.description,
      level: "team",
      status: "active",
      parentId: root.id,
    });
    console.log("Created child goal:", g.id, g.title);
  }

  console.log("Done. Link issues to these goals in the board UI as needed.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
