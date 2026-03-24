# 莫兰迪论坛 - 傻瓜式部署操作手册
### 💡 温馨提示：以下部署步骤是我在个人安装过程中总结的常见问题与解决方案。由于开发环境多样，实际部署时可能会遇到更多未知问题，欢迎借助搜索引擎或团队协作工具进一步排查解决。本手册仅在有限环境下测试，若存在疏漏，还请多多包涵～

## 📌 环境要求（必须一致！）
- **开发工具**：IntelliJ IDEA
- **Tomcat版本**：10.0.23（版本不符会爆红）
- **JDK版本**：1.8+
- **MySQL版本**：8.0+
- **依赖管理**：Maven（建议配置阿里云镜像）

---

## 🔧 第一步：IDEA 项目初始化
### 1. 导入项目
将论坛源码导入 IDEA，打开项目根目录即可。

### 2. 解决 Tomcat 依赖爆红
Tomcat 10+ 包名变化，需手动添加依赖：
1. 打开 `File → Project Structure → Modules`
2. 切换到 `Dependencies` 标签，点击 **+ → Library → Java**
3. 找到你的 Tomcat 安装目录，选择 `lib` 下的 `jsp-api.jar` 和 `servlet-api.jar`
4. 点击 OK，完成依赖导入

### 3. 解决 Maven 依赖爆红（FastJSON/jakarta）
- **方案A**：右键项目 → `Maven → Reload Project`，自动下载依赖
- **方案B**：配置阿里云镜像（网络问题时用）
  1. 打开 `File → Settings → Build, Execution, Deployment → Maven`
  2. 找到 `User settings file`，将源码中 `settings.txt` 复制到该路径并重命名为 `settings.xml`
  3. 重启 IDEA，重新刷新 Maven

---

## 🗄️ 第二步：数据库配置（核心！）
### 1. 创建数据库
1. 打开 MySQL，新建连接（命名为 `LunTan`），测试连接成功
2. 新建数据库，命名为 **`luntan_db`**（必须和代码一致），字符集选 `UTF-8`
3. 右键 `luntan_db` → 打开「命令行界面」
4. 复制 `docs/DATABASE.md` 里的**完整建表 SQL**，粘贴执行，自动创建所有表和初始数据

### 2. 修改数据库连接密码
打开 `src/main/java/com/luntan/software/DatabaseUtil.java`，修改以下两处：

// 1. 数据库密码（替换为你的 MySQL 登录密码）
private static final String PASSWORD = "你的MySQL密码";

// 2. 访问方式（二选一）
// 方式1：本地访问（推荐单人开发）
private static final String URL = "jdbc:mysql://localhost:3306/luntan_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false";

// 方式2：局域网访问（小组开发用，替换为你的电脑IP）
// private static final String URL = "jdbc:mysql://192.168.xxx.xxx:3306/luntan_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false";

### 3. 局域网访问配置（小组开发）
1. 放行 8080 端口：Win+R 输入 cmd，执行 netstat -ano | findstr 8080，确保 Tomcat 8080 端口已放行
2. 修改 Tomcat 配置：
   打开 Tomcat/conf/server.xml，找到 8080 端口配置，添加 address="0.0.0.0"：
   <Connector port="8080" protocol="HTTP/1.1"
              connectionTimeout="20000"
              redirectPort="8443" 
              address="0.0.0.0"/>
3. 重启 Tomcat 生效

---

## 🚀 第三步：Tomcat 配置与运行
### 1. 配置 Tomcat 10.0.23
1. IDEA 右上角点击 **Add Configuration → + → Tomcat Server → Local**
2. 选择你的 Tomcat 10.0.23 安装目录
3. 切换到 `部署` 标签，点击 **+ → Artifact**，选择你的论坛项目
4. 点击 `Apply → OK` 保存

### 2. 启动项目
- 点击 IDEA 右上角 Tomcat 的 **运行按钮 ▶️**
- 等待启动完成，无报错即成功
- 访问地址：
  - 本地：`http://localhost:8080/LunTan`
  - 局域网：`http://你的电脑IP:8080/LunTan`（小组成员需连同一 WiFi）

---

## ❌ 常见问题解决
1. **Tomcat 版本爆红**：必须用 10.0.23，其他版本会报错
2. **数据库连接失败**：检查 URL、用户名、密码是否正确，MySQL 服务是否启动
3. **局域网无法访问**：检查电脑 IP、8080 端口是否放行、`server.xml` 是否配置 `address="0.0.0.0"`
4. **Maven 依赖下载慢**：切换到阿里云镜像，重启 IDEA 后重试

---

## 👥 小组开发注意事项
- 所有成员统一使用 **Tomcat 10.0.23 + JDK 1.8**，避免环境不一致
- 数据库由一人部署，其他人通过局域网 IP 访问
- 初始管理员账号：`用户名：管理员`，`密码：741852`，建议使用后修改
