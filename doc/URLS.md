# 网页与接口地址备忘（URL bookmark）

本地默认端口以仓库为准；若 `PORT` 环境变量或启动日志显示占用迁端口，请改用实际端口。

## 本地开发（`pnpm dev`，默认）

| 用途 | 地址 |
|------|------|
| 看板 / UI（与 API 同源） | `http://localhost:3100/` |
| 同上（IPv4 显式） | `http://127.0.0.1:3100/` |
| 健康检查 | `http://localhost:3100/api/health` |
| 公司列表（需董事会上下文） | `http://localhost:3100/api/companies` |

## 公开站点

| 用途 | 地址 |
|------|------|
| 产品文档 | `https://paperclip.ing/docs` |
| 源码仓库 | `https://github.com/paperclipai/paperclip` |
| Discord | `https://discord.gg/m4HZY7xNG3` |

## Tailscale / 私网访问

使用 `pnpm dev --tailscale-auth` 时，服务可能绑定在 `0.0.0.0`；在另一台机器上请把主机名换成你的 Tailscale 主机或 LAN IP，端口仍以启动日志为准（默认 `3100`）。
