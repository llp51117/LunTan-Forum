package com.luntan.software.dao;

import com.luntan.software.model.FriendRequest;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FriendDao {

    // ============ 好友申请相关方法 ============

    /**
     * 添加好友申请
     */
    public boolean addFriendRequest(int userId, int friendId) {
        System.out.println("=== FriendDao.addFriendRequest()开始 ===");
        System.out.println("用户ID: " + userId + " → 好友ID: " + friendId);

        // 检查是否在添加自己
        if (userId == friendId) {
            System.out.println("❌ 不能添加自己为好友");
            return false;
        }

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();

            // 检查是否已经是好友
            String checkFriendSql = "SELECT COUNT(*) FROM friend_relation WHERE user_id = ? AND friend_user_id = ?";
            System.out.println("检查好友关系SQL: " + checkFriendSql);

            try (PreparedStatement checkStmt = conn.prepareStatement(checkFriendSql)) {
                checkStmt.setInt(1, userId);
                checkStmt.setInt(2, friendId);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    System.out.println("❌ 已经是好友关系");
                    return false;
                }
            }

            // 检查是否已经发送过请求
            String checkSql = "SELECT COUNT(*) FROM friend_request WHERE user_id = ? AND friend_id = ? AND status = 0";
            System.out.println("检查重复请求SQL: " + checkSql);

            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, userId);
                checkStmt.setInt(2, friendId);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    System.out.println("❌ 已经向该用户发送过好友请求");
                    return false;
                }
            }

            // 检查对方是否已经向你发送过请求（互相发送，直接建立好友关系）
            String mutualCheckSql = "SELECT COUNT(*) FROM friend_request WHERE user_id = ? AND friend_id = ? AND status = 0";
            System.out.println("检查互相请求SQL: " + mutualCheckSql);

            try (PreparedStatement mutualStmt = conn.prepareStatement(mutualCheckSql)) {
                mutualStmt.setInt(1, friendId);
                mutualStmt.setInt(2, userId);
                ResultSet rs = mutualStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    System.out.println("✅ 检测到互相发送请求，直接建立好友关系");

                    // 删除对方的请求
                    String deleteSql = "DELETE FROM friend_request WHERE user_id = ? AND friend_id = ?";
                    try (PreparedStatement deleteStmt = conn.prepareStatement(deleteSql)) {
                        deleteStmt.setInt(1, friendId);
                        deleteStmt.setInt(2, userId);
                        int deleted = deleteStmt.executeUpdate();
                        System.out.println("已删除对方的请求，影响行数: " + deleted);
                    }

                    // 直接建立好友关系
                    boolean result = addFriendRelation(userId, friendId);
                    System.out.println("直接建立好友关系结果: " + result);
                    return result;
                }
            }

            // 原始插入逻辑
            String sql = "INSERT INTO friend_request (user_id, friend_id, status, request_time) " +
                    "VALUES (?, ?, 0, NOW())";
            System.out.println("插入好友请求SQL: " + sql);

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, userId);
                pstmt.setInt(2, friendId);
                int result = pstmt.executeUpdate();
                System.out.println("插入好友请求结果，影响行数: " + result);
                return result > 0;
            }

        } catch (SQLException e) {
            System.out.println("❌ 数据库错误: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            System.out.println("=== FriendDao.addFriendRequest()结束 ===");
            DatabaseUtil.close(conn, null, null);
        }
    }

    /**
     * 加载好友申请列表
     */
    public List<FriendRequest> getFriendRequests(int userId, String type) {
        List<FriendRequest> requests = new ArrayList<>();
        String sql = "";

        if ("pending".equals(type)) {
            // 我发送的请求：显示目标用户的信息
            sql = "SELECT fr.*, u.username, u.user_code " +
                    "FROM friend_request fr " +
                    "JOIN user u ON fr.friend_id = u.user_id " +  // 关联目标用户
                    "WHERE fr.user_id = ? AND fr.status = 0";
        } else if ("received".equals(type)) {
            // 我收到的请求：显示发送请求的用户信息
            sql = "SELECT fr.*, u.username, u.user_code " +
                    "FROM friend_request fr " +
                    "JOIN user u ON fr.user_id = u.user_id " +  // 关联发送者用户
                    "WHERE fr.friend_id = ? AND fr.status = 0";
        } else {
            return requests;
        }

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                FriendRequest req = new FriendRequest();
                req.setId(rs.getInt("id"));
                req.setUserId(rs.getInt("user_id"));
                req.setFriendId(rs.getInt("friend_id"));
                req.setUsername(rs.getString("username"));      // 显示关联用户的用户名
                req.setUserCode(rs.getString("user_code"));     // 显示关联用户的编号
                req.setRequestTime(rs.getString("request_time"));
                req.setStatus(rs.getInt("status"));
                requests.add(req);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return requests;
    }

    /**
     * 处理好友请求（同意/拒绝）
     */
    public boolean handleFriendRequest(int requestId, int status) {
        System.out.println("=== FriendDao.handleFriendRequest() ===");
        System.out.println("requestId: " + requestId + ", status: " + status + " (1=同意, 2=拒绝)");

        String sql = "UPDATE friend_request SET status = ? WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, status);
            pstmt.setInt(2, requestId);
            int result = pstmt.executeUpdate();
            System.out.println("更新结果，影响行数: " + result);
            return result > 0;
        } catch (SQLException e) {
            System.out.println("❌ 数据库错误: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 删除好友请求
     */
    public boolean deleteFriendRequest(int requestId) {
        System.out.println("=== FriendDao.deleteFriendRequest() ===");
        System.out.println("删除好友请求ID: " + requestId);

        String sql = "DELETE FROM friend_request WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, requestId);
            int result = pstmt.executeUpdate();
            System.out.println("删除结果，影响行数: " + result);
            return result > 0;
        } catch (SQLException e) {
            System.out.println("❌ 删除好友请求失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 检查用户是否已经发送过好友请求（用于前端判断）
     */
    public boolean hasSentFriendRequest(int userId, int friendId) {
        String sql = "SELECT COUNT(*) FROM friend_request WHERE user_id = ? AND friend_id = ? AND status = 0";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, friendId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 获取已处理的好友请求（同意或拒绝的）
     */
    public List<FriendRequest> getProcessedFriendRequests(int userId) {
        List<FriendRequest> requests = new ArrayList<>();
        String sql = "SELECT fr.*, u.username, u.user_code " +
                "FROM friend_request fr " +
                "JOIN user u ON fr.user_id = u.user_id " +
                "WHERE fr.friend_id = ? AND fr.status IN (1, 2) " +
                "ORDER BY fr.request_time DESC";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                FriendRequest req = new FriendRequest();
                req.setId(rs.getInt("id"));
                req.setUserId(rs.getInt("user_id"));
                req.setFriendId(rs.getInt("friend_id"));
                req.setUsername(rs.getString("username"));
                req.setUserCode(rs.getString("user_code"));
                req.setRequestTime(rs.getString("request_time"));
                req.setStatus(rs.getInt("status"));
                requests.add(req);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return requests;
    }

    // ============ 好友关系相关方法 ============

    /**
     * 建立好友关系（双向）
     */
    public boolean addFriendRelation(int userId, int friendId) {
        System.out.println("建立好友关系: 用户" + userId + " ↔ 用户" + friendId);

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false); // 开启事务

            // 插入双向好友关系
            String sql1 = "INSERT INTO friend_relation (user_id, friend_user_id, friend_code, friend_name) " +
                    "SELECT ?, ?, user_code, username FROM user WHERE user_id = ?";
            String sql2 = "INSERT INTO friend_relation (user_id, friend_user_id, friend_code, friend_name) " +
                    "SELECT ?, ?, user_code, username FROM user WHERE user_id = ?";

            try (PreparedStatement pstmt1 = conn.prepareStatement(sql1);
                 PreparedStatement pstmt2 = conn.prepareStatement(sql2)) {

                // 用户A的好友记录
                pstmt1.setInt(1, userId);
                pstmt1.setInt(2, friendId);
                pstmt1.setInt(3, friendId);
                int result1 = pstmt1.executeUpdate();
                System.out.println("用户" + userId + "添加好友结果: " + (result1 > 0));

                // 用户B的好友记录
                pstmt2.setInt(1, friendId);
                pstmt2.setInt(2, userId);
                pstmt2.setInt(3, userId);
                int result2 = pstmt2.executeUpdate();
                System.out.println("用户" + friendId + "添加好友结果: " + (result2 > 0));

                conn.commit();
                boolean success = (result1 > 0 && result2 > 0);
                System.out.println("好友关系建立" + (success ? "成功" : "失败"));
                return success;
            }
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    System.out.println("事务回滚");
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            System.out.println("建立好友关系异常: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    /**
     * 删除好友关系（双向删除）
     */
    public boolean deleteFriendRelation(int userId, int friendId) {
        System.out.println("删除好友关系: 用户" + userId + " ↔ 用户" + friendId);

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false); // 开启事务

            // 删除双向好友关系
            String sql1 = "DELETE FROM friend_relation WHERE user_id = ? AND friend_user_id = ?";
            String sql2 = "DELETE FROM friend_relation WHERE user_id = ? AND friend_user_id = ?";

            try (PreparedStatement pstmt1 = conn.prepareStatement(sql1);
                 PreparedStatement pstmt2 = conn.prepareStatement(sql2)) {

                // 删除用户A的好友记录
                pstmt1.setInt(1, userId);
                pstmt1.setInt(2, friendId);
                int result1 = pstmt1.executeUpdate();
                System.out.println("删除用户" + userId + "的好友记录结果: " + (result1 > 0));

                // 删除用户B的好友记录
                pstmt2.setInt(1, friendId);
                pstmt2.setInt(2, userId);
                int result2 = pstmt2.executeUpdate();
                System.out.println("删除用户" + friendId + "的好友记录结果: " + (result2 > 0));

                conn.commit();
                boolean success = (result1 > 0 || result2 > 0); // 只要有一边删除成功就算成功
                System.out.println("好友关系删除" + (success ? "成功" : "失败"));
                return success;
            }
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    System.out.println("事务回滚");
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            System.out.println("删除好友关系异常: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    /**
     * 检查两个用户是否已经是好友
     */
    public boolean isFriend(int userId, int friendId) {
        String sql = "SELECT COUNT(*) FROM friend_relation WHERE user_id = ? AND friend_user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, friendId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 获取用户的好友数量
     */
    public int getFriendCount(int userId) {
        String sql = "SELECT COUNT(*) FROM friend_relation WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * 批量删除用户的所有好友关系（用于删除用户时清理数据）
     */
    public boolean deleteAllFriendRelations(int userId) {
        System.out.println("删除用户" + userId + "的所有好友关系");

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            // 删除用户作为发起方的所有好友关系
            String sql1 = "DELETE FROM friend_relation WHERE user_id = ?";
            // 删除用户作为被添加方的所有好友关系
            String sql2 = "DELETE FROM friend_relation WHERE friend_user_id = ?";

            try (PreparedStatement pstmt1 = conn.prepareStatement(sql1);
                 PreparedStatement pstmt2 = conn.prepareStatement(sql2)) {

                pstmt1.setInt(1, userId);
                int result1 = pstmt1.executeUpdate();
                System.out.println("删除发起方关系影响行数: " + result1);

                pstmt2.setInt(1, userId);
                int result2 = pstmt2.executeUpdate();
                System.out.println("删除被添加方关系影响行数: " + result2);

                conn.commit();
                System.out.println("用户所有好友关系删除完成");
                return true;
            }
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            System.out.println("删除用户所有好友关系异常: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    /**
     * 批量删除用户的所有好友请求（用于删除用户时清理数据）
     */
    public boolean deleteAllFriendRequests(int userId) {
        System.out.println("删除用户" + userId + "的所有好友请求");

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            // 删除用户发出的所有请求
            String sql1 = "DELETE FROM friend_request WHERE user_id = ?";
            // 删除用户收到的所有请求
            String sql2 = "DELETE FROM friend_request WHERE friend_id = ?";

            try (PreparedStatement pstmt1 = conn.prepareStatement(sql1);
                 PreparedStatement pstmt2 = conn.prepareStatement(sql2)) {

                pstmt1.setInt(1, userId);
                int result1 = pstmt1.executeUpdate();
                System.out.println("删除发出请求影响行数: " + result1);

                pstmt2.setInt(1, userId);
                int result2 = pstmt2.executeUpdate();
                System.out.println("删除收到请求影响行数: " + result2);

                conn.commit();
                System.out.println("用户所有好友请求删除完成");
                return true;
            }
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            System.out.println("删除用户所有好友请求异常: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // ============ 辅助方法 ============

    /**
     * 获取数据库连接（复用DatabaseUtil）
     */
    private Connection getConnection() throws SQLException {
        return DatabaseUtil.getConnection();
    }

    /**
     * 关闭数据库资源
     */
    private void closeResources(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        DatabaseUtil.close(conn, pstmt, rs);
    }
}