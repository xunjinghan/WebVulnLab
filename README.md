# VulnLab — 自研 Web 漏洞靶场

> 一个用 Python 标准库写的、故意充满真实可利用漏洞的 Web 靶场。零依赖、单文件、一键启动，专为安全学习者和自动化挖掘工具测试而设计。

![Python](https://img.shields.io/badge/python-3.8+-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![漏洞类型](https://img.shields.io/badge/漏洞类型-15+-orange)
![零依赖](https://img.shields.io/badge/零依赖-标准库-only)

---

## 为什么需要这个靶场？

市面上的靶场（DVWA、bWAPP、Vulhub）要么需要 LAMP 环境，要么需要 Docker，要么漏洞太老。VulnLab 的设计目标是：

- **零依赖**：只用 Python 标准库，`python app.py` 直接跑
- **单文件**：所有漏洞在一个 `app.py` 里，方便读源码学原理
- **真实可利用**：不是模拟漏洞，是真的能打进去的
- **可重置**：一键恢复干净状态，方便反复练习
- **安全沙箱**：只监听 `127.0.0.1`，SSRF 出站也被限制，不会误伤
- **双版本对比**：包含原版和加固版，学习"漏洞长什么样"和"怎么修"

---

## 一分钟上手

```bash
# 启动靶场（默认端口 8095）
python app.py

# 换端口
python app.py 9001

# 一键重置（删库重建 + 清空上传目录）
python app.py --reset
# 或 HTTP 方式（仅回环来源 + POST + confirm=RESET）
curl -X POST "http://127.0.0.1:8095/__reset?confirm=RESET"
```

启动后打开浏览器访问 `http://127.0.0.1:8095`，首页有全部入口链接。

首次启动自动建库、写种子数据、生成 `config.bak` 与 `uploads/`。

---

## 种子账号

| 用户名 | 密码 | 角色 | 余额(分) |
|---|---|---|---|
| admin | `Lab@Admin2024!Secure#9` | admin | 100000 |
| demo | demo123 | user | 50000 |
| alice | alice123 | user | 88800 |
| bob | bob123 | user | 100 |

优惠券：`WELCOME10`（面值 1000 分，可无限领取）。

---

## 漏洞清单（15+ 类）

完整清单和逐条验证思路见 **[LAB-MANIFEST.md](LAB-MANIFEST.md)**（练习时建议先别看，打完再对照）。

| 类别 | 漏洞 | 位置 |
|---|---|---|
| 认证 | 弱口令 / 明文存储 | 登录接口 |
| 认证 | 会话固定 / 可预测 token | sessions 表 |
| 授权 | 越权访问（IDOR） | /api/orders/{id} |
| 授权 | 业务接口漏接 CSRF | /api/* |
| 注入 | SQL 注入 | /api/search |
| 注入 | 命令注入 | /api/ping |
| 注入 | SSTI 模板注入 | /render |
| 注入 | XXE | /api/import |
| 上传 | 任意文件上传 | /upload |
| 穿越 | 路径穿越 | /download |
| XSS | 存储型 XSS | /board |
| XSS | 反射型 XSS | /search |
| CSRF | 敏感操作无 token | /wallet/transfer |
| SSRF | 服务端请求伪造 | /fetch |
| 逻辑 | 并发竞态（TOCTOU） | /coupon/claim |
| 逻辑 | 整数溢出 | /withdraw |
| 信息泄露 | /debug 泄露 SECRET_KEY | /debug |
| 信息泄露 | 错误回显堆栈 | 全局异常 |

---

## 两个版本对比

本仓库包含两个版本，方便学习"加固前后"的差异：

| 文件 | 版本 | 说明 |
|---|---|---|
| `app.py` | 加固版（第八轮） | 6 处源码级修复后的版本 |
| `app.py.loop1-original` | 原版 | 充满漏洞的初始版本 |

对比两个版本的 diff，可以学习：
- SQL 注入如何用参数化查询修复
- CSRF 如何用 HMAC 令牌防护
- 路径穿越如何用白名单校验
- 会话固定如何用随机 token 修复
- 命令注入如何用参数数组替代字符串拼接

---

## 项目结构

```
VulnLab/
├── app.py                  # 主程序（加固版，单文件 ~60KB）
├── app.py.loop1-original   # 原版（用于对比学习）
├── LAB-MANIFEST.md         # 漏洞清单 + 验证思路
├── README.md               # 本文件
├── lab.db                  # 运行时自动生成（SQLite，已加入 .gitignore）
├── uploads/                # 运行时自动生成（上传目录）
└── config.bak              # 运行时自动生成（配置备份）
```

---

## 安全边界

本靶场在设计上做了严格的沙箱限制：

1. **只监听 `127.0.0.1`**：不会暴露到局域网或公网
2. **SSRF 出站限制**：`/fetch` 只允许访问 `http://127.0.0.1` 前缀
3. **复位接口保护**：`/__reset` 仅接受 POST + `confirm=RESET` + 回环来源，GET/HEAD 一律 405
4. **只写本目录**：数据库、上传文件、配置备份都在项目目录内

> ⚠️ **严禁联网部署、严禁用于非授权目标。** 本程序故意充满真实可利用漏洞，仅用于本机授权安全练习。

---

## 适合谁用

- **安全初学者**：读源码理解漏洞原理，动手练习利用
- **自动化工具开发者**：测试漏洞扫描器、AI 挖掘工具的效果
- **CTF 选手**：练习常见 Web 漏洞的利用技巧
- **开发者**：学习"漏洞长什么样"和"怎么修"

---

## 与其他靶场的对比

| 特性 | VulnLab | DVWA | bWAPP | Vulhub |
|---|---|---|---|---|
| 零依赖 | ✅ 纯标准库 | ❌ 需要 LAMP | ❌ 需要 LAMP | ❌ 需要 Docker |
| 单文件 | ✅ | ❌ | ❌ | ❌ |
| 一键重置 | ✅ | ❌ | ❌ | 部分 |
| 源码可读 | ✅ 单文件易读 | ✅ | ✅ | 部分 |
| 业务逻辑漏洞 | ✅ 丰富 | 少 | 少 | 少 |
| 加固版对比 | ✅ 双版本 | ❌ | ❌ | ❌ |

---

## 相关项目

- [bounty-forge](https://github.com/xunjinghan/bounty-forge) — AI 驱动漏洞挖掘知识库与实战工具集
- [VulnHunt](https://github.com/xunjinghan/VulnHunt) — AI 自动化漏洞挖掘工具集

---

## 许可证

[MIT License](LICENSE)
