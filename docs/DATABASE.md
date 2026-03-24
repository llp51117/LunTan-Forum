# 莫兰迪论坛 - 数据库设计文档
## 数据库基础信息
- 数据库名：`luntan_db`
- 字符集：UTF-8
- 适配MySQL版本：8.0+
- 核心表数量：8张（用户/消息/回复/点赞/收藏/好友相关）

## 完整表结构&建表SQL
### 1. 用户表 `user`
存储系统用户账号、身份、登录信息
| 字段名     | 类型     | 说明                     | 约束         |
|------------|----------|--------------------------|--------------|
| user_id    | INT      | 主键，用户唯一ID         | 自增、非空   |
| user_code  | VARCHAR  | 用户编码                 | 唯一、非空   |
| username   | VARCHAR  | 用户名                   | 非空         |
| password   | VARCHAR  | 登录密码                 | 非空         |
| identity   | VARCHAR  | 用户身份（admin/普通用户）| 非空         |
| create_time| DATETIME | 用户创建时间             | 非空         |

### 2. 消息表 `message`
存储用户发布的公共/私聊消息
| 字段名     | 类型     | 说明                     | 约束         |
|------------|----------|--------------------------|--------------|
| id         | INT      | 主键，消息唯一ID         | 自增、非空   |
| user_id    | INT      | 发布者用户ID             | 非空         |
| content    | VARCHAR  | 消息内容                 | 非空         |
| type       | VARCHAR  | 消息类型（公共/私聊）    | 非空         |
| create_time| DATETIME | 发布时间                 | 非空         |
| friend_id  | INT      | 私聊好友ID（公共消息为NULL）| 可为空      |

### 3. 回复表 `reply`
存储用户对消息的回复内容
| 字段名     | 类型     | 说明                     | 约束         |
|------------|----------|--------------------------|--------------|
| id         | INT      | 主键，回复唯一ID         | 自增、非空   |
| user_id    | INT      | 回复者用户ID             | 非空         |
| target_msg_id | INT  | 被回复的消息ID           | 非空         |
| content    | VARCHAR  | 回复内容                 | 非空         |
| create_time| DATETIME | 回复时间                 | 非空         |

### 4. 点赞表 `tb_like`
记录用户对消息的点赞操作
| 字段名     | 类型     | 说明                     | 约束         |
|------------|----------|--------------------------|--------------|
| like_id    | INT      | 主键，点赞唯一ID         | 自增、非空   |
| user_id    | INT      | 点赞者用户ID             | 非空         |
| message_id | INT      | 被点赞的消息ID           | 非空         |
| create_time| DATETIME | 点赞时间                 | 默认当前时间 |

### 5. 收藏表 `tb_collect`
记录用户对消息的收藏操作
| 字段名     | 类型     | 说明                     | 约束         |
|------------|----------|--------------------------|--------------|
| collect_id | INT      | 主键，收藏唯一ID         | 自增、非空   |
| user_id    | INT      | 收藏者用户ID             | 非空         |
| message_id | INT      | 被收藏的消息ID           | 非空         |
| collect_time | DATETIME | 收藏时间               | 默认当前时间 |

### 6. 好友表 `friend`
存储用户的好友基础信息
| 字段名         | 类型     | 说明                     | 约束         |
|----------------|----------|--------------------------|--------------|
| id             | INT      | 主键，记录唯一ID         | 自增、非空   |
| user_id        | INT      | 主用户ID                 | 非空         |
| friend_user_id | INT      | 好友用户ID               | 非空         |
| friend_code    | VARCHAR  | 好友用户编码             | 非空         |
| friend_name    | VARCHAR  | 好友用户名               | 非空         |

### 7. 好友请求表 `friend_request`
存储用户间的好友申请及处理状态
| 字段名     | 类型     | 说明                     | 约束         |
|------------|----------|--------------------------|--------------|
| id         | INT      | 主键，请求唯一ID         | 自增、非空   |
| user_id    | INT      | 发起申请者ID             | 非空         |
| friend_id  | INT      | 被申请者ID               | 非空         |
| status     | INT      | 请求状态（待处理/通过/拒绝）| 非空       |
| request_time| DATETIME | 申请时间               | 非空         |

### 8. 好友关系表 `friend_relation`
存储用户的好友列表及好友信息（核心好友表）
| 字段名         | 类型     | 说明                     | 约束         |
|----------------|----------|--------------------------|--------------|
| id             | INT      | 主键，关系唯一ID         | 自增、非空   |
| user_id        | INT      | 主用户ID                 | 非空         |
| friend_user_id | INT      | 好友用户ID               | 非空         |
| friend_code    | VARCHAR  | 好友用户编码             | 非空         |
| friend_name    | VARCHAR  | 好友用户名               | 非空         |
| status         | INT      | 好友状态（1正常/0删除）| 默认1        |

## 完整建表&初始化SQL（可直接复制执行）
```sql
-- 1. 用户表
CREATE TABLE user (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  user_code VARCHAR(20) NOT NULL UNIQUE,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(50) NOT NULL,
  identity VARCHAR(20) NOT NULL,
  create_time DATETIME NOT NULL
);

-- 2. 消息表
CREATE TABLE message (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  content VARCHAR(255) NOT NULL,
  type VARCHAR(20) NOT NULL,
  create_time DATETIME NOT NULL,
  friend_id INT
);

-- 3. 回复表
CREATE TABLE reply (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  target_msg_id INT NOT NULL,
  content VARCHAR(255) NOT NULL,
  create_time DATETIME NOT NULL
);

-- 4. 点赞表
CREATE TABLE tb_like (
  like_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  message_id INT NOT NULL,
  create_time DATETIME DEFAULT NOW()
);

-- 5. 收藏表
CREATE TABLE tb_collect (
  collect_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  message_id INT NOT NULL,
  collect_time DATETIME DEFAULT NOW()
);

-- 6. 好友表
CREATE TABLE friend (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  friend_user_id INT NOT NULL,
  friend_code VARCHAR(20) NOT NULL,
  friend_name VARCHAR(50) NOT NULL
);

-- 7. 好友请求表
CREATE TABLE friend_request (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  friend_id INT NOT NULL,
  status INT NOT NULL,
  request_time DATETIME NOT NULL
);

-- 8. 好友关系表（含状态字段）
CREATE TABLE friend_relation (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  friend_user_id INT NOT NULL,
  friend_code VARCHAR(20) NOT NULL,
  friend_name VARCHAR(50) NOT NULL,
  status INT DEFAULT 1 -- 1:正常, 0:已删除
);

-- 初始化超级管理员账号
INSERT INTO user (user_id, user_code, username, password, identity, create_time)
VALUES (1, '管理员', '管理员', '741852', 'admin', NOW());

-- 添加索引（提升查询效率）
CREATE INDEX idx_friend_relation_user ON friend_relation(user_id);
CREATE INDEX idx_friend_relation_friend ON friend_relation(friend_user_id);
CREATE INDEX idx_friend_request_user ON friend_request(user_id);
CREATE INDEX idx_friend_request_friend ON friend_request(friend_id);

-- 授权数据库访问（替换为你的数据库密码）
GRANT ALL PRIVILEGES ON luntan_db.* TO 'root'@'10.111.%' IDENTIFIED BY '你的数据库密码';
FLUSH PRIVILEGES; -- 刷新权限
