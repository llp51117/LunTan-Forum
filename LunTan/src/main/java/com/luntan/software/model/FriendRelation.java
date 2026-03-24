package com.luntan.software.model;

public class FriendRelation {
    private int id;
    private int userId;     // 发起方用户ID
    private int friendId;   // 接收方用户ID
    private int status;     // 0:申请中, 1:已通过, 2:已拒绝
    private String requestTime; // 请求时间
    private String username;   // 好友用户名
    private String userCode;   // 好友用户编号
    // 构造方法、getter和setter
    public FriendRelation() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getFriendId() { return friendId; }
    public void setFriendId(int friendId) { this.friendId = friendId; }
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
    public String getRequestTime() { return requestTime; }
    public void setRequestTime(String requestTime) { this.requestTime = requestTime; }

    // 新增的username和userCode的getter/setter
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getUserCode() { return userCode; }
    public void setUserCode(String userCode) { this.userCode = userCode; }



}