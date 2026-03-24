// Collect.java（实体类）
package com.luntan.software.model;

public class Collect {
    private int collectId;
    private int userId;
    private int messageId;  // 消息ID字段
    private String collectTime;

    // 必须包含 messageId 的 getter 方法
    public int getMessageId() {
        return messageId;
    }

    // 其他字段的 getter/setter 也要补全
    public int getCollectId() {
        return collectId;
    }
    public void setCollectId(int collectId) {
        this.collectId = collectId;
    }
    public int getUserId() {
        return userId;
    }
    public void setUserId(int userId) {
        this.userId = userId;
    }
    public void setMessageId(int messageId) {
        this.messageId = messageId;
    }
    public String getCollectTime() {
        return collectTime;
    }
    public void setCollectTime(String collectTime) {
        this.collectTime = collectTime;
    }
}