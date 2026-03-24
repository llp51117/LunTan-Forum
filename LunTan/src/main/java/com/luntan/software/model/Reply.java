package com.luntan.software.model;

public class Reply {
    private int id;
    private int userId;
    private int targetMsgId; // 关联的消息ID
    private String content;
    private String createTime;
    private String username; // 回复者用户名（关联user表）

    // Getter和Setter方法
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getTargetMsgId() { return targetMsgId; }
    public void setTargetMsgId(int targetMsgId) { this.targetMsgId = targetMsgId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }
    public String getTime() { return createTime; }
    public void setTime(String time) { this.createTime = time; }  // 关键：setTime方法

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
}