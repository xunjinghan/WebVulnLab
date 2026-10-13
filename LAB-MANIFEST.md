# LAB-MANIFEST — target-site-lab 植入漏洞清单

> 仅用于本机 127.0.0.1 授权练习。每条含：编号 / 位置（路由·参数）/ 类别 / 预期危害 / 验证思路。
> 默认地址 `http://127.0.0.1:8095`。普通账号建议用 `demo/demo123`。

---

## 实测状态（基线时点 2026-10-12T18:12:12+08:00，由 range-admin / 任务 t1 复核重建）

> ⚠️ **本段已被下方「### ★ 2026-10-12 A 档加固后」段取代，仅作历史存档；当前口径认下方那一段。**
> 本段记录的是 **A 档加固之前**的状态（app.py 54362 字节、sessions 4 列、pid 11776/7908），
> 其中 app.py / lab.db / 进程与端口 / `/__reset` 口径四项**均已变更**，请勿据此操作。

> **认这一份（限本段时点）。** 本次为「旧实例停止 → 带时间戳日志重启 → `/__reset` → 直查数据库」后的干净基线。
> 快照文件 `security/learning/_evidence/baseline-20261012-181212.json`（11315 字节，sha256 `3d87f170acf57b9eb7374935463afb9b8c66dc23e5ec8092550032f6397d12bb`）。

| 项目 | 实测值（2026-10-12 18:12:12） |
|---|---|
| 8091 target-site | **HTTP 200 / 3234 字节**，`Server: TargetSite/1.0`，LISTEN `127.0.0.1:8091` pid=**11776** |
| 8095 target-site-lab | **HTTP 200 / 2120 字节**，`Server: LabHTTP/0.2 Python/3.12.10`，LISTEN `127.0.0.1:8095` pid=**7908** |
| 启动命令 | `<Python312>\python.exe <工作区>\target-site\app.py 8091`；`…\target-site-lab\app.py 8095`（均为绝对路径，18:11:07 启动） |
| 日志 | `target-site\server-20261012-1811-out.log` / `-err.log`；`target-site-lab\server-20261012-1811-out.log` / `-err.log` |
| `/__reset` | **HTTP 200 / 1190 字节**，18:11:18 执行成功（响应含「已重置」） |
| lab.db | sha256 `49b2032c29f8057530704203fd361bb162461eaeeeeb874c7ac1b8e8956cc7af`，49152 字节，mtime 2026-10-12T18:11:18 |
| 旧的 15:42 快照 | `baseline-20261012-154202.json`，其 pid（10704 / 1748）已失效，被本段取代 |

### ★ 2026-10-12 A 档加固后（**认这一份，覆盖上表**）

> A 档（Loop2）对 `target-site-lab/app.py` 做了 6 处源码级修复（t2，2026-10-12 19:53），
> 下列事实**已变更**，上表凡冲突之处以本段为准。复核人 range-admin，复核时点 2026-10-12T20:00+08:00。

- **app.py 已变更**：sha256 从 `D2992CD0F4832B9E67BACCB04163700D567F57B4ADA437E661017D015721B484`（54362 字节）
  变为 **`870F28B3E1486A5FCD7FE5FCFC188B2D0BC2FF1A38FCC8DD70163D3A68310BA0`**（**59159 字节**，mtime 2026-10-12T19:53:34）。
  **原件备份在 `target-site-lab/app.py.loop1-original`**（sha256 仍为 `D2992CD0…21B484`，54362 字节，可回退）。
- **`sessions` 表新增 `csrf_token` 列**（A3）→ 列结构为 `token, user_id, username, created_at, csrf_token`（5 列）。
- **lab.db 哈希会随登录漂移，不能当永久基线**：复位后、未登录时是
  **`ffbb0f473e981a9394521fe4741a6f8cc707005541e7ac1621de410750f005e3`**（49152 字节），
  一旦有会话写入即变（实测 20:00:26 一次 demo 登录后变为 `ceb139b2…93bd`，`sessions` 0→1 行）。
  → **引用 lab.db sha256 必须带前提「复位后、未登录」。**
- **`/__reset` 口径已变**：见文末「复位」段——**仅 POST + `confirm=RESET` + 回环**，GET/HEAD 一律 405。
- 8095 进程与监听：PID **18824**（2026-10-12T19:59:42 起），`TCP 127.0.0.1:8095 LISTENING 18824`，
  日志 `target-site-lab\server-20261012-195942-err.log`；HTTP 200 / 2165 字节。
  上表的 pid 11776 / 7908 已失效。
- **8091 target-site 未被 A 档改动，但进程已换代**（2026-10-12T20:07 复核）：PID **7700**（19:15:55 起），
  `TCP 127.0.0.1:8091 LISTENING 7700`，HTTP **200 / 3234 字节**，`Server: TargetSite/1.0`，
  body sha256 `a51e3ed1981bd7303e457f6421dfef3c38f5013178011024a7e536e5ae730b4d`。
  上表写的 pid 11776 **已失效**。8091 无复位接口，其 `target_site.db` 无基线保障。
- **启动命令与日志（沿用现行部署方式）**：`<Python312>\python.exe <工作区>\target-site\app.py 8091`；
  `…\target-site-lab\app.py 8095`（**独立进程**，非 DSH 后台作业；应用重启不会回收）。
  当前实例日志：`target-site\server-1915-err.log`；`target-site-lab\server-1915-err.log`（8095 换代为 `server-20261012-195942-err.log`）。
- **lab.db 与 app.py 之外的关键当前值**：`/__reset` 当前成功响应为 HTTP 200 / 1190 字节（含「已重置」）；
  `target-site-lab\reset-audit.log` 记录每次成功复位（peer + UA）。

### 复位后账号真值（lab.db 直查；口令**明文入库**属基线事实，不是漏洞结论）

| id | 用户 | 口令 | 角色 | balance_cents |
|---|---|---|---|---|
| 1 | admin | `Lab@Admin2024!Secure#9`（22 字符，与 app.py 种子常量逐字符一致，**非弱口令**） | admin | 100000 |
| 2 | demo | `demo123` | user | 50000 |
| 3 | alice | `alice123` | user | 88800 |
| 4 | bob | `bob123` | user | 100 |

### 表状态（`/__reset` 后直查，`PRAGMA integrity_check=ok`）

- 8095 lab.db：`users 4 / products 3 / orders 3 / messages 1 / coupons 1 / sessions 0 / coupon_claims 0`
  → `sessions` 为 0（无残留 token）；`coupon_claims` 表**存在**（0 行），旧记录里「缺表导致 `/coupon/claim` 稳定 500」的条件不成立。
- 8095 orders：3 行，`qty` 全为 1，`amount_cents` 全为正（29900 / 9900 / 1900），`state ∈ {paid, unpaid, shipped}`。
- 脏数据检查：`users.balance_cents < 0` 命中 **0** 行；订单负金额 **0** 行；非正 qty **0** 行。
  旧记录中的 alice 余额 -622266、qty=-100、bob 口令被改等污染**已随复位清除**。
- 8091 target_site.db：`users 2 / orders 3 / sessions 33 / login_attempts 6`。**target-site 无复位接口**，
  `sessions` 的 33 行与 `login_attempts` 的 6 个键（形如 `user:alice' or '1'='1`）是历史测试残留；
  `locked_until` 全为 `0.0`，当前无锁定态。账号 `demo/demo1234`、`alice/alice1234` 经 PBKDF2-HMAC-SHA256(200000) 复算命中。

> ⚠️ **基线纪律（2026-10-12 修订 —— 旧版「动手前先打一次 /__reset」已失效）**：
> ① **不再要求**每次动手前打 `/__reset`。A6 加固后复位**仅接受 POST + `confirm=RESET`**，且属**不可逆**操作，
>    **配额受控、不能随手打**（任务书硬约束：8095 扫描排除 `/__reset` 与 HEAD）。
> ② 动手前改为**只读核查**：直查 `lab.db` 的余额/口令/`sessions` 行数是否与种子态一致；
>    发现余额为负、口令异常或 `sessions` 非 0（且非本轮预期写入），立即停止并在报告里标注「基线已被污染」。
> ③ 确需复位时，先报队长批准，再执行 `curl.exe -s -X POST "http://127.0.0.1:8095/__reset?confirm=RESET"`，
>    执行后**立即重录基线**（见 `security/learning/_evidence/range-admin-ops-notes.md`）。

---

## 历史记录（2026-10-11 会话记录）— **当前状态类断言已失效，原文已删除**

> 该段原记录来自 2026-10-11 的另一会话，其「仍存活的漏洞」与「旧库弱口令」结论建立在**未复位的旧 lab.db** 之上。
> 2026-10-12 18:11 全库 `/__reset` 复核后，下列断言**已不成立**，故从本文件删除，只保留结论去向与失效原因：

| 原断言 | 复核结果（2026-10-12 18:12） |
|---|---|
| VULN-01 弱口令直通 admin（旧库 admin/admin123 明文入库） | **失效**。lab.db 已重建，admin 为 `Lab@Admin2024!Secure#9`（22 字符，与代码种子一致），`admin123` 无法通过登录校验 |
| 根因「代码修了、数据库没跟上，存量旧库不迁移」 | **失效**。旧库已被 `/__reset` 删除重建，该根因的前提（存量旧库）不存在 |
| 「`/coupon/claim` 稳定 500（缺 `coupon_claims` 表）」 | **失效**。复位后 `coupon_claims` 表存在（0 行） |
| 「alice 余额 -622266、bob 口令被改、订单 qty=-100 脏数据」 | **失效**。复位后直查：负余额 0 行、非正 qty 0 行 |
| VULN-02 `/debug` 泄露 SECRET_KEY + 绝对路径 + server_time | **未验证**（该路由现已有权限判断，是否可越权访问需按当前代码重测），不得沿用旧结论 |
| BUG-01 已登录访问 `/` 稳定 500（`sqlite3.Row.get()`） | **未验证**。`lab_errors.log` 停在 2026-10-11 22:54，本次基线窗口内未复现，需重测 |
| VULN-03 攻击链 「admin123 登录 → /debug 泄 SECRET_KEY → 伪造 CSRF → 转账成功」 | **未验证**。链条起点（`admin123`）已不存在，整链需重测；CSRF 是否仍在、令牌是否可推得，均无当前证据 |
| VULN-04 `/forgot` Host 头注入 + `md5(用户名)` 可预测 | **未验证**（本次仅由其他成员在 18:11:50 探测到 `/forgot` 200 且回显注入主机名，未做完整判定），需正式重测 |

### 阶段2 侦察复核（2026-10-12 18:14–18:22，任务 t3 / recon）

> 产物：`security/learning/_evidence/attack-surface-20261012-182250.json`（37577 字节，sha256 `154b62ac6544fd7bb80b1d39264c02413a52d7b89705f7d911c9297457d8b91f`）
> 与同名 `.md`（15138 字节，hashlib 复算 `2f8cefd67d25e33856b7511b223654d0ea35931bc73926bb95427014277f366d`）。
> 该轮为**只读侦察**：未执行任何写操作（仅 demo 登录与无效参数校验分支）；DB 已复核未被改动（users 4 / orders 3 / messages 1 / coupon_claims 0）。

| 上表断言 | 阶段2 复核结果（2026-10-12 18:22） |
|---|---|
| VULN-02 `/debug` 泄露 SECRET_KEY + 绝对路径 + server_time | **部分证实（权限层已验证）**：未登录 GET `/debug` → 302；demo 已登录 → 403；源码 `debug_page()` 在 admin 通过后输出 `DEBUG/SECRET_KEY/DB_PATH/BASE_DIR/UPLOAD_DIR/python/platform/server_time/cwd`，且常量 `SECRET_KEY=lab-secret-key-PLEASE-CHANGE-001`（app.py:42）。admin 会话下的实际响应体**未复现（未登录 admin）**，需阶段3 补验 |
| BUG-01 已登录访问 `/` 稳定 500 | **已复现并定位条件**：携带有效会话 cookie 的 `GET /` → HTTP 500，`lab_errors.log` 记录 `app.py:513 AttributeError: 'sqlite3.Row' object has no attribute 'get'`（18:15:15 / 18:15:49 / 18:16:14 三条）；**未登录**（无 cookie）访问 `GET /` 同条件实测 12/12 全为 200，即崩溃前提是「请求带有效会话」 |
| VULN-04 `/forgot` Host 头注入 + md5(用户名) 可预测 | **已证实（回显层）**：`GET /forgot?username=demo` 加 `X-Forwarded-Host: evil.example` 后，响应 `<pre>` 中链接变为 `http://evil.example/reset?user=demo&token=fe01ce2a7fbac8fafaed7c982a04e229`（即 `md5("demo")`）。`/reset` 路由本身不存在（404），消费端待确认 |
| VULN-01 弱口令直通 admin | **维持失效**：`admin123` 未通过登录校验（本轮只读约束未做口令爆破，仅确认首页公开口令为强口令形态） |
| VULN-03 攻击链 | **仍为未验证**：起点（旧弱口令库）不存在；本轮只确认「/debug 泄露 SECRET_KEY 的代码路径」与「CSRF token = HMAC(SECRET_KEY, session_token)」两个环节。完整链条需阶段3 用 admin 会话端到端验证 |
| 历史 `/uploads/*.txt`、余额 -622266、bob 口令被改 | **已随复位消失**：`/uploads/` 404、uploads 目录为空；users 余额为 100000/50000/88800/100 |

⚠️ **本轮新增最重要的操作纪律**：`katana -d 3` 顺带抓取首页链接时**自动访问了 `/__reset`**（18:15:19，服务器日志有记录），触发过一次删库重建。后续任何爬虫/目录扫描对 8095 必须排除 `/__reset`（katana 用 `-fs`/过滤，ffuf 用 `-fr`），人工亦不得访问。

### 详细报告（历史产物，引用前须复核）

- `VULN-03-SECRET_KEY泄露导致CSRF令牌可伪造.md` — **基于旧库状态撰写，引用前必须按当前基线复核**
- `progress.md` — 25 项实测判定对照表 + 下一步推荐
- `_evidence/labdb-before-reset-dirty.db` — 复位前的污染态数据库快照，仅作对照，**不代表当前状态**

---

## 以下 A–I 为**历史设计清单**（非当前实测结论）

> 下列 21 条为靶场**设计期**的植入清单，用于指明「哪里本来就埋了洞」。当前运行的是第八轮加固版，
> 原会话结论为「21 条全部已封」，但**本次基线任务（2026-10-12 18:12）未逐条复测**，
> 因此本清单**只能当线索、不能当结论**。清单中出现的旧口令（如 `admin/admin123`，
> 复位后 admin 实际为 `Lab@Admin2024!Secure#9`）、旧 token 算法（清单写 `md5("<用户名>-<秒>")`，
> 当前源码 `make_token()` 为 `secrets.token_urlsafe(32)`，见 `app.py:216-217`；Cookie 名仍为 `token`，
> 见 `app.py:306-307`）等细节，**均需按当前代码重新验证**。

---

## A. 认证与会话

### A1 会话 token 可预测
- **位置**：登录流程；token 生成函数 `make_token()`；Cookie 名 `token`
- **类别**：弱会话管理 / 会话劫持（CWE-330、CWE-384）
- **预期危害**：token = `md5("<用户名>-<秒级时间戳>")`，无随机数。攻击者知道目标用户名和大致登录时间（`/debug` 还会回显服务器当前时间戳），逐秒枚举即可伪造出有效会话，冒充任意用户（含 admin）。
- **验证思路**：
  1. demo 正常登录，从 Cookie 取 token；
  2. 脚本对 `int(time.time())` 前后若干秒计算 `hashlib.md5(f"demo-{ts}".encode()).hexdigest()`，可直接命中；
  3. 对 `admin` 枚举时间窗，把算出的 token 写进 Cookie 访问 `/home`、`/admin/users`，以 admin 身份成功。

### A2 改密接口无 CSRF token
- **位置**：`POST /change-password`，参数 `new_password`（GET 带参也可触发）
- **类别**：跨站请求伪造（CWE-352），叠加不验旧密码
- **预期危害**：诱导已登录用户访问第三方页面即可静默改掉其密码；且接口不要求原密码，攻击者接管账号。
- **验证思路**：登录 demo 后，用一个**不含任何 token** 的普通表单/`curl -X POST -d "new_password=hacked123"` 请求 `/change-password`，返回成功；用新密码可登录，旧密码失效。

### A3 转账接口无 CSRF token
- **位置**：`POST /wallet/transfer`，参数 `to`、`amount`（GET 带参也可触发）
- **类别**：跨站请求伪造（CWE-352）
- **预期危害**：受害者打开恶意页面即被发起转账，余额转给攻击者指定账号。
- **验证思路**：demo 登录态下直接 `POST /wallet/transfer`，body 仅 `to=bob&amount=666`，无 CSRF 字段即成功；查 bob 余额增加。也可用 `<img src="/wallet/transfer?to=bob&amount=666">` 形式经 GET 触发。

---

## B. 授权

### B1 水平越权 — 读他人订单
- **位置**：`GET /api/order?id=N`
- **类别**：IDOR / 水平越权（CWE-639）
- **预期危害**：登录任意账号后遍历订单号，读取所有人的订单（商品、数量、金额、状态）。
- **验证思路**：demo 登录（demo 拥有订单 1、3），请求 `/api/order?id=2`（属于 alice），返回 200 且含 alice 的订单数据。

### B2 水平越权 — 读他人手机号/余额
- **位置**：`GET /api/profile?id=N`
- **类别**：IDOR / 敏感信息泄露（CWE-639、CWE-200）
- **预期危害**：遍历用户 id，拖取全部用户的手机号、余额、角色。
- **验证思路**：demo 登录后请求 `/api/profile?id=1`，返回 admin 的手机号与余额；`id=3` 返回 alice 隐私字段。

### B3 垂直越权 — 普通用户进后台
- **位置**：`GET /admin/users`、`GET /admin/orders`
- **类别**：垂直越权 / 缺失功能级访问控制（CWE-285、CWE-269）
- **预期危害**：普通用户直接打开后台，`/admin/users` 甚至列出所有人的**明文密码**；可查看全站订单。
- **验证思路**：用 demo（role=user）登录，直接访问 `/admin/users` 与 `/admin/orders`，返回 200 且页面显示 admin/admin123 等记录。

---

## C. 注入

### C1 登录处 SQL 注入
- **位置**：`POST /login`，参数 `username`、`password`
- **类别**：SQL 注入 — 认证绕过 / UNION 取数（CWE-89）
- **预期危害**：无需密码登录任意用户（首个为 admin）；可 UNION 读取任意表数据。
- **验证思路**：
  1. 用户名填 `' OR 1=1-- `、密码任意，直接以 admin 身份进入 `/home`；
  2. 用户名 `admin'-- `、密码任意，以 admin 登录；
  3. UNION：用户名填 `' UNION SELECT 1,'pwn','pwn','admin','x',1-- ` 可伪造管理员身份登录（SELECT 共 6 列：id,username,password,role,phone,balance_cents）。

### C2 查询接口 SQL 注入
- **位置**：`GET /api/search?q=`（JSON）；`/search?q=`（HTML 页同样拼接）
- **类别**：SQL 注入 — UNION 取数（CWE-89）
- **预期危害**：通过 UNION 拖取 users 表明文密码等任意数据。
- **验证思路**：浏览器/curl 访问
  `/api/search?q=%25%27%20UNION%20SELECT%20id,username,password%20FROM%20users--%20`
  （即 `%' UNION SELECT id,username,password FROM users-- `），响应 JSON 的 results 中出现 admin/admin123。

### C3 SSTI 模板注入
- **位置**：`GET /greet?name=`
- **类别**：服务端模板注入 / 表达式注入（CWE-94，玩具引擎对 `{{...}}` 直接 `eval`）
- **预期危害**：执行任意 Python 表达式，可进一步 RCE（`__import__('os').system(...)`）。
- **验证思路**：
  1. `/greet?name={{7*7}}` 页面出现 `49`；
  2. `/greet?name={{__import__('os').popen('whoami').read()}}` 回显命令执行结果。

### C4 命令注入
- **位置**：`GET /ping?host=`
- **类别**：OS 命令注入（CWE-78，`subprocess.run(..., shell=True)` 拼接）
- **预期危害**：以靶场进程权限执行任意系统命令。
- **验证思路**：
  - Windows：`/ping?host=127.0.0.1%20%26%20echo%20PWNED`（`& echo PWNED`），页面 `<pre>` 中出现 PWNED；
  - 也可用 `| whoami` 拼接，回显当前用户。

### C5 路径穿越 / 任意文件读取
- **位置**：`GET /download?file=`
- **类别**：路径穿越（CWE-22）
- **预期危害**：读取服务器上应用权限可访问的任意文件（源码、配置、系统文件）。
- **验证思路**：
  1. `/download?file=app.py` 直接下载源码；
  2. `/download?file=config.bak` 下载备份密钥；
  3. `/download?file=..%5C..%5C..%5CWindows%5Cwin.ini`（按实际层级调整）读到系统文件。

---

## D. XSS

### D1 反射型 XSS
- **位置**：`GET /search?q=`（页面标题 `搜索：<q>` 原样输出）
- **类别**：反射型 XSS（CWE-79）
- **预期危害**：诱导点击恶意链接执行任意 JS，窃取无 HttpOnly 保护的 `token` Cookie。
- **验证思路**：访问 `/search?q=<script>alert(1)</script>`，弹窗；或
  `/search?q=<script>fetch('http://127.0.0.1:8095/?c='+document.cookie)</script>` 观察 cookie 外带思路。

### D2 存储型 XSS
- **位置**：`POST /board`（参数 `content`）→ `GET /board`
- **类别**：存储型 XSS（CWE-79）
- **预期危害**：payload 入库，任何访问留言板的用户（含管理员）触发，可盗会话/挂马。
- **验证思路**：在 `/board` 发表 `<script>alert('stored')</script>`，提交后每次访问 `/board` 都弹窗；查看响应源码可见 payload 未转义。

---

## E. 客户端 / 跨域

### E1 CORS 错误配置（反射任意 Origin + 允许凭证）
- **位置**：所有响应；逻辑见 `_send()`
- **类别**：CORS 错误配置（CWE-942、CWE-668）
- **预期危害**：任意第三方网站的 JS 可携带受害者 Cookie 跨域读取本站响应（隐私/数据被跨站读取）。
- **验证思路**：
  `curl -H "Origin: http://evil.example" -i http://127.0.0.1:8095/`
  响应头含 `Access-Control-Allow-Origin: http://evil.example` 与
  `Access-Control-Allow-Credentials: true`；OPTIONS 预检同样放行。

### E2 Host 头注入
- **位置**：`GET /forgot?username=`；读取 `X-Forwarded-Host`（优先）/ `Host`
- **类别**：Host 头注入 / 投毒（CWE-644，可致钓鱼、密码重置投毒、缓存投毒）
- **预期危害**：攻击者让服务端生成指向恶意域名的"密码重置链接"。
- **验证思路**：
  `curl -H "X-Forwarded-Host: evil.com" "http://127.0.0.1:8095/forgot?username=admin"`
  页面中的链接变为 `http://evil.com/reset?user=admin&token=...`。

---

## F. 服务端

### F1 SSRF（靶场限制仅回环）
- **位置**：`GET /fetch?url=`
- **类别**：服务端请求伪造（CWE-918）
- **预期危害**：让服务器代为发起请求并回显内容；本靶场按红线限制只允许 `http://127.0.0.1` 前缀，可用于访问本机其它只听回环的内部服务/云元数据风格探测练习。
- **验证思路**：
  1. `/fetch?url=http://127.0.0.1:8095/` 回显首页 HTML；
  2. `/fetch?url=http://127.0.0.1:8095/debug` 回显调试信息；
  3. `/fetch?url=http://example.com/` 返回 403（前缀校验生效）。

### F2 无校验文件上传
- **位置**：`POST /upload`（multipart 字段 `file`）→ `/uploads/<原文件名>`
- **类别**：任意文件上传（CWE-434），文件名也未清洗（附带路径穿越风险）
- **预期危害**：可上传 `.html`/`.svg`（XSS）、`.py`/`.bat` 等危险文件并经 `/uploads/` 访问；配合其它环节可致 webshell 级危害（本环境仅静态返回内容）。
- **验证思路**：上传内容为 `<script>alert(1)</script>` 的 `x.html`，访问 `/uploads/x.html` 原样以 HTML 渲染并弹窗；上传 `.txt`/无后缀文件同样成功。

---

## G. 业务逻辑

### G1 金额篡改（客户端定价）
- **位置**：`POST /order/create`，参数 `product_id`、`qty`、`price`
- **类别**：客户端信任 / 价格篡改（CWE-842）
- **预期危害**：任意商品按 1 分钱下单。
- **验证思路**：登录后下单 `product_id=1&qty=1&price=1`（机械键盘原价 29900），订单金额仅 1 分。

### G2 负数 / 超大数量
- **位置**：同 `/order/create`，参数 `qty`
- **类别**：业务边界缺失（CWE-840）
- **预期危害**：`qty=-100` 时 `price*qty` 为负，扣余额变成加余额，可无限给自己充值；超大整数可造成异常。
- **验证思路**：提交 `product_id=1&qty=-100&price=100`，下单后 `/home` 余额增加 10000 分。

### G3 优惠券重复领取
- **位置**：`GET/POST /coupon/claim?code=WELCOME10`
- **类别**：幂等性缺失 / 重放（CWE-837）
- **预期危害**：同一张券无限次领取，无限充值。
- **验证思路**：连续多次访问 `/coupon/claim?code=WELCOME10`，每次余额都 +1000 分。

### G4 提现并发竞态（TOCTOU）
- **位置**：`POST /wallet/withdraw`，参数 `amount`；查余额与扣款之间 `sleep(0.3)`
- **类别**：竞态条件（CWE-362、CWE-367）
- **预期危害**：并发提现使余额被扣成负数，突破余额限制。
- **验证思路**：demo 余额 50000，用 10 个并发请求各提现 30000（curl 并行或脚本线程池），全部命中"读旧余额→判定通过"窗口，最终余额为负（约 -250000）。

### G5 订单状态机绕过
- **位置**：`GET/POST /order/status?order_id=2&state=shipped`
- **类别**：状态机绕过 / 越权操作（CWE-841）
- **预期危害**：未支付直接把订单改为 `shipped`（也可改成任意自定义状态字符串，且参数拼接 SQL，附带注入面）。
- **验证思路**：demo 登录后访问 `/order/status?order_id=2&state=shipped`，再查 `/admin/orders`，订单 2 状态由 unpaid 变 shipped，无支付环节。

---

## H. 信息泄露

### H1 错误页回显 traceback
- **位置**：所有路由的统一异常处理 `_traceback()`
- **类别**：信息泄露（CWE-209、CWE-211）
- **预期危害**：泄露文件绝对路径、源码行、SQL 语句、库版本，辅助进一步利用。
- **验证思路**：访问 `/api/search?q=%'`（造成 SQL 语法错误）或 `/api/order?id=abc`（int 上下文报错），页面返回完整 Python Traceback。

### H2 /debug 泄露配置
- **位置**：`GET /debug`
- **类别**：敏感信息泄露（CWE-489 调试端点、CWE-200）
- **预期危害**：泄露 SECRET_KEY、数据库路径、平台/Python 版本、服务器时间（辅助 A1）、全部环境变量。
- **验证思路**：直接访问 `/debug`，页面 JSON 中可见 `SECRET_KEY=lab-secret-key-PLEASE-CHANGE-001`、`DB_PATH`、`server_time`。

### H3 备份文件可下载
- **位置**：`GET /backup/config.bak`（文件每次启动重写）
- **类别**：敏感文件暴露（CWE-530、CWE-200）
- **预期危害**：下载到含密钥、数据库口令的配置备份。
- **验证思路**：访问 `/backup/config.bak`，得到含 `SECRET_KEY=`、`DB_PASSWORD=root123456` 的文本。

---

## I. 弱口令

### I1 预置弱口令管理员且无防爆破
- **位置**：`users` 表种子数据；登录接口
- **类别**：弱口令 / 缺失认证限速（CWE-521、CWE-307）
- **预期危害**：`admin/admin123` 可直接登录后台；无锁定、无验证码、无 IP 限速，可字典爆破。
- **验证思路**：用 admin/admin123 登录成功；对同一账号连续发起任意次错误登录，均不会被锁定或限速。

---

## 复位

练习结束或数据被打坏后：

- `POST http://127.0.0.1:8095/__reset?confirm=RESET`（A6 加固后；GET/HEAD 已 405）
- 或停服后 `python app.py --reset`

> ⚠️ **A6 加固后口径变更（2026-10-12）**：`/__reset` **仅接受 POST**，且必须带 `confirm=RESET`、来源为回环
> （`127.0.0.1`/`::1`，否则 403）。**GET / HEAD 一律 405**，旧写法 `GET http://127.0.0.1:8095/__reset` 已失效。
> 缺 `confirm` 返回 400。成功复位会在 `target-site-lab/reset-audit.log` 留痕（peer + UA）。
> **复位不可逆**（删库重建 + 清空 `uploads/`），**配额受控，不要随手打**。

会重建 `lab.db`、清空 `uploads/`、重写 `config.bak`，恢复到初始状态。
