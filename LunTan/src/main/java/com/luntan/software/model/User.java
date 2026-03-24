package com.luntan.software.model;

import java.sql.Timestamp;

public class User {
    private int userId;
    private String userCode;
    private String username;
    private String password;
    private String identity;
    private Timestamp createTime;
//    private String createTime; // 新增：匹配user表的create_time
    // 无参构造器（必须保留）
    public User() {}
    // 带参构造器（根据需要添加）
    public User(String userCode, String username, String password, String identity, Timestamp createTime) {
        this.userCode = userCode;
        this.username = username;
        this.password = password;
        this.identity = identity;
        this.createTime = createTime; // 补充createTime参数
    }

// 所有字段的getter和setter（必须与字段类型匹配）
public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUserCode() { return userCode; }
    public void setUserCode(String userCode) { this.userCode = userCode; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getIdentity() { return identity; }
    public void setIdentity(String identity) { this.identity = identity; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public Timestamp getCreateTime() { return createTime; }
    public void setCreateTime(Timestamp createTime) { this.createTime = createTime; }
}