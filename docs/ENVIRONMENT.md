# 运行环境与网络要求（Environment & Network）

> **一句话结论**：这个靶场**只用 Python 标准库**，不需要 `pip install` 任何东西，**断网也能跑**。
> 中国大陆直连没有任何障碍（实测：不装依赖、不开代理，直接起服务访问成功）。

实测时间：2026-10-16 15:02（UTC+8）
测试机：Windows 11 x64 · Python 3.12
网络：上海 · 中国移动 AS9808 家庭宽带 · **未开任何代理**（开代理后复测同样正常）

---

## 1. 最低环境

| 组件 | 最低要求 | 我实测过的版本 | 说明 |
| --- | --- | --- | --- |
| 操作系统 | Windows 10 1809+ / Ubuntu 20.04+ / Debian 11+ / macOS 12+ | Windows 11 x64 | 只要有 Python 就能跑，无平台特定代码 |
| Python | 3.8+ | 3.12.7 | 只用标准库：`http.server` / `sqlite3` / `hashlib` / `hmac` 等 |
| pip 依赖 | **无** | — | 不需要虚拟环境，不需要装包 |
| 磁盘 | 10 MB | — | 单文件 + SQLite 库 |
| 端口 | 默认 8095 空闲 | — | 可传参换端口 |

已确认的导入清单（全部为标准库，无第三方）：
`hashlib / hmac / html / json / os / re / secrets / shutil / sqlite3 / subprocess / sys / threading / time / traceback / urllib.parse / urllib.request / http.cookies / http.server`

---

## 2. 启动

```bash
python app.py            # 默认 http://127.0.0.1:8095
python app.py 8091       # 换端口
python app.py --reset    # 一键重置（删库重建 + 清空 uploads）
```

自带 CI（`.github/workflows/ci.yml`）会在 Ubuntu + Python 3.12 上做**语法检查 + 起服务冒烟**，所以 Windows / Linux 都能跑。

---

## 3. 中国大陆网络实测（**未开代理**）

本靶场**运行时不需要联网**，这张表是给你排查别的问题时用的参考（同机同时段实测）：

| 域名 | 国内直连结果 | 延迟 | 与本项目的关系 |
| --- | --- | --- | --- |
| `pypi.org` / `mirrors.aliyun.com` | ✅ 可用 | 345 / 476 ms | 本项目**不需要**（零依赖） |
| `registry.npmjs.org` / `registry.npmmirror.com` | ✅ 可用 | 858 / 132 ms | 不需要 |
| `github.com`（网页 / HTTPS 克隆） | ⚠️ TLS 握手超时 | — | `git clone` 本仓库可能卡住 |
| `codeload.github.com`（Download ZIP） | ❌ 超时 | — | 「Download ZIP」会失败 |
| `raw.githubusercontent.com` | ❌ 连接被重置 | — | raw 直链不通 |
| `api.github.com` / `objects.githubusercontent.com` | ✅ 可用 | 331 / 389 ms | API、Release 附件可直连 |

> 也就是说：**跑项目没问题，只有"把代码弄到本地"这一步在国内可能卡住。**

---

## 4. 官方安装链接 + 直连不通时用官方 WARP

本项目零依赖，只需要 Python；下面这些链接是"把代码弄到本地"和"以后想装别的靶场"时用的。

| 工具 | 官方链接 | 国内直连（实测） |
| --- | --- | --- |
| Python 3.8+ | <https://www.python.org/downloads/> | ✅ 669 ms |
| Git | <https://git-scm.com/downloads> | 未实测（Windows 一般已自带） |
| Docker Desktop（以后想跑 DVWA 之类） | <https://www.docker.com/products/docker-desktop/> | 未实测 |

### 直连不通时：用**官方** WARP（别装第三方"加速器"）

| 官方入口 | 国内直连（实测） | 说明 |
| --- | --- | --- |
| `1.1.1.1`（WARP 官网） | ❌ **超时** | 官网在国内打不开，**这不是你的网络坏了** |
| `www.cloudflare.com` | ✅ 848 ms | 官网主页可开 |
| `developers.cloudflare.com` | ✅ 785 ms | 官方文档站，含各平台安装步骤 |
| `install.appcenter.ms` | ✅ 1583 ms | 官方安装包托管（Microsoft App Center） |

Windows 一条命令装（不需要翻墙）：

```powershell
winget install --id Cloudflare.Warp -e
```

> ⚠️ 别敲 `scoop install warp`：scoop 里那个 `warp` 是另一个不相干的工具（0.3.0）。

装完确认生效：

```powershell
& "C:\Program Files\Cloudflare\Cloudflare WARP\warp-cli.exe" status   # 期望 Connected
```

或打开 <https://www.cloudflare.com/cdn-cgi/trace> 看到 `warp=on`。

**注意**：本项目是本地靶场，开不开 WARP 都能用（回环地址不走隧道）；免费档出口可能绕远，只在 `git clone` 卡住时开即可。

---

## 5. 常见报错 → 处理

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| `git clone` 卡住 / `TLS handshake timeout` | `github.com` 握手被干扰 | 开代理（WARP 等）、改用 SSH、或从 `objects.githubusercontent.com` 直接下 Release 附件 |
| 「Download ZIP」失败 | `codeload.github.com` 不通 | 改用 `git clone`（配代理）后本地打包 |
| `Address already in use` | 8095 被占 | `python app.py 8091` |
| 浏览器打不开 `localhost:8095` | `localhost` 解析到 IPv6 `::1` | 用 `http://127.0.0.1:8095/` |
| 中文显示成乱码（Windows 控制台） | 控制台代码页是 GBK | `chcp 65001` 后再启动；文件本身已是 UTF-8 |

---

## 6. 谁能访问这个靶场

只监听 `127.0.0.1`：**连同一个局域网里的其他设备都访问不到**，这是刻意设计。
想让别人也练：把仓库发给他，让他自己在自己机器上跑（他不需要装任何依赖）。
不要改成 `0.0.0.0`，也不要做端口转发 / 内网穿透 —— 这是个故意带 15+ 个漏洞的站点。

---

## English summary

- Pure Python stdlib (`http.server` + `sqlite3`), **no pip install, no network needed at runtime**.
- Works on Windows / Linux / macOS with Python 3.8+ (tested on 3.12; CI runs 3.12 on Ubuntu).
- Mainland-China notes: the project itself has no network dependency; only *getting the code* may be affected — `codeload.github.com` (Download ZIP) and `raw.githubusercontent.com` are unreachable without a proxy, and `github.com` HTTPS clone can time out. `api.github.com` and `objects.githubusercontent.com` are reachable.
- The lab binds `127.0.0.1` on purpose: other machines on your LAN cannot reach it.
