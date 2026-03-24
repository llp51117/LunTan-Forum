package com.luntan.software.model;

public class Message {
    private int messageId;
    private String content;
    private String username;
    private String time;
    private int id;
    private int userId;

    private String createTime;

    private String userCode;
    private int friendId; // 私聊接收者ID（可选）
    private int likeCount;

    private boolean isLiked; // 是否被当前用户点赞
    private boolean isCollected; // 是否被当前用户收藏

    // getter和setter
    public boolean isLiked() {
        return isLiked;
    }
    public void setLiked(boolean liked) {
        isLiked = liked;
    }

    public boolean isCollected() {
        return isCollected;
    }
    public void setCollected(boolean collected) {
        isCollected = collected;
    }

    public int getLikeCount() {
        return likeCount;
    }

    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }
    // 新增：收藏数字段
    private int collectCount;
    // 必须添加的getter/setter方法

    public int getCollectCount() {
        return collectCount;
    }
    public void setCollectCount(int collectCount) {
        this.collectCount = collectCount;
    }


    // 必须包含的 getter/setter 方法
    public int getMessageId() {
        return messageId;
    }
    public void setMessageId(int messageId) {
        this.messageId = messageId;
    }


    public String getTime() {
        return time;
    }
    public void setTime(String time) {
        this.time = time;
    }

    // 所有字段的getter和setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }




    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getUserCode() { return userCode; }
    public void setUserCode(String userCode) { this.userCode = userCode; }

    public int getFriendId() { return friendId; }
    public void setFriendId(int friendId) { this.friendId = friendId; }
}