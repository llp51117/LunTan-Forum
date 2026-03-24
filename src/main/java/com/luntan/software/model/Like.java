package com.luntan.software.model;

public class Like {
    private int likeId;
    private int userId;       // 用户ID（关联用户表）
    private int messageId;    // 消息ID（关联消息表）
    private String createTime;

    // 必须包含以下 getter 方法（用于 LikeDao 调用）
    public int getUserId() {
        return userId;
    }

    public int getMessageId() {
        return messageId;
    }

    // 同时补全 setter 方法（用于设置属性值）
    public void setUserId(int userId) {
        this.userId = userId;
    }

    public void setMessageId(int messageId) {
        this.messageId = messageId;
    }

    // 其他字段的 getter/setter（可选，根据需要添加）
    public int getLikeId() {
        return likeId;
    }

    public void setLikeId(int likeId) {
        this.likeId = likeId;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }
}