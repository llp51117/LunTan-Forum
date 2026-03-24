package com.luntan.software.model;

public class FriendRequest {
    private int id;
    private int userId;
    private int friendId;
    private String username;
    private String userCode;
    private String requestTime;
    private int status; // 添加状态字段

    // Getter 和 Setter 方法
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getFriendId() { return friendId; }
    public void setFriendId(int friendId) { this.friendId = friendId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getUserCode() { return userCode; }
    public void setUserCode(String userCode) { this.userCode = userCode; }

    public String getRequestTime() { return requestTime; }
    public void setRequestTime(String requestTime) { this.requestTime = requestTime; }

    // 新增status字段的getter和setter
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
}