# Xray VLESS+WS+TLS on Railway（边缘 TLS 模式）

这是为 Railway 准备的最小部署包，不是已部署的节点。部署后才有真实域名，拨测通过后才能出二维码。

## 关键原理（已核查 2026-11-24）

- Railway 每个服务只暴露一个公网端口，`*.up.railway.app:443` 的 TLS 由 Railway 边缘终止。
- 所以 Xray 内部必须用 `security=none` + `ws`，客户端再用 `security=tls` + `sni=你的 Railway 域名`。
- 如果在 Xray 内部再开 TLS，会握手失败。
- Railway 免费试用：新账号一次性 $5（30 天），之后免费计划每月 $1，不需要信用卡。
- 但完整试用需要验证 GitHub 账号（看账号年龄/活跃度）。未验证是 Limited Trial，出站网络受限、端口受限，代理拨测很可能失败。
- Railway 明确说验证是为了防止多人注册刷试用、防止违反 ToS 的部署。

## 部署步骤（用你自己的 GitHub / Railway 账号）

1. 把本目录推到你自己的 GitHub 仓库，根目录保留 Dockerfile + start.sh。
2. 登录 railway.com → New Project → Deploy from GitHub repo → 选这个仓库。
3. Settings → Networking → Generate Domain，得到如 `xxx.up.railway.app`。
4. Variables 设置：
   - `VLESS_UUID` = `2bf20ab5-bbd6-40d6-9d23-b5a6ef676a19`（示例，已生成，可换成你自己的 uuidgen）
   - `VLESS_WS_PATH` = `ws`
   - `PORT` 由 Railway 自动注入，不用手动设。
5. 看 Deployments → Logs，出现 `listening on port ...` 即启动成功。

## 客户端链接格式（部署成功后替换域名）

```
vless://2bf20ab5-bbd6-40d6-9d23-b5a6ef676a19@xxx.up.railway.app:443?encryption=none&security=tls&sni=xxx.up.railway.app&type=ws&host=xxx.up.railway.app&path=%2Fws#Railway-VLESS
```

- `sni` / `host` 必须等于 Railway 域名，不能填假 SNI，否则边缘会拒绝。
- 小火箭：扫 vless:// 链接的二维码即可导入单节点；要做订阅链接，需把上面这行 base64 后放到一个可公开访问的 URL（/sub），再把订阅 URL 生成二维码。

## 拨测（部署后做）

1. `curl -I https://xxx.up.railway.app/` 应返回 Railway 边缘响应（Xray 本身不回 HTTP，不代表失败）。
2. 用小火箭导入链接，打开开关，访问 `http://example.com/` 或 `https://www.google.com/`，能打开即通过。
3. 失败先看 Railway 日志：端口、UUID、WS 路径是否一致。

## 费用提醒

- 试用 $5 用完或 30 天后变免费计划 $1/月，流量/时长不够节点会停。
- 要长期稳定用，Hobby 是 $5/月（含 $5 用量），需要绑卡。
