package com.luntan.software.dao;

import com.luntan.software.dao.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.luntan.software.model.Reply;
public class ReplyDao {
    // 按用户ID删除该用户的所有回复（空实现，保证编译通过）
    public boolean deleteRepliesByUserId(int userId) {
        String sql = "DELETE FROM reply WHERE user_id = ?"; // 表名/字段名和数据库一致
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    // 新增：根据消息ID查询所有回复（核心修复！）
    public List<Reply> getRepliesByMsgId(int msgId) {
        List<Reply> replies = new ArrayList<>();
        // SQL查询：关联用户表获取回复者用户名，按时间排序
        String sql = "SELECT r.id, r.user_id, u.username, r.content, r.create_time " +
                "FROM reply r " +
                "JOIN user u ON r.user_id = u.user_id " +  // 关联用户表拿用户名
                "WHERE r.target_msg_id = ? " +  // 只查目标消息的回复
                "ORDER BY r.create_time ASC";  // 按时间升序，旧回复在前

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, msgId);  // 传入消息ID
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Reply reply = new Reply();
                reply.setId(rs.getInt("id"));
                reply.setUserId(rs.getInt("user_id"));
                reply.setUsername(rs.getString("username"));  // 回复者用户名
                reply.setContent(rs.getString("content"));    // 回复内容
                reply.setTime(rs.getString("create_time"));   // 回复时间（注意和实体类字段一致）
                replies.add(reply);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return replies;
    }
    // 新增：删除回复
    public boolean deleteReply(int replyId) {
        String sql = "DELETE FROM reply WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, replyId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    public List<Reply> getRepliesByUserId(int userId) {
        List<Reply> replies = new ArrayList<>();
        String sql = "SELECT id, user_id, target_msg_id, content, create_time FROM reply WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Reply reply = new Reply();
                reply.setId(rs.getInt("id"));
                reply.setUserId(rs.getInt("user_id"));
                reply.setTargetMsgId(rs.getInt("target_msg_id"));
                reply.setContent(rs.getString("content"));
                reply.setCreateTime(rs.getString("create_time"));
                replies.add(reply);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return replies;
    }
    public boolean saveReply(int userId, int targetMsgId, String content) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DatabaseUtil.getConnection();
            String sql = "INSERT INTO reply (user_id, target_msg_id, content, create_time) " +
                    "VALUES (?, ?, ?, NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, targetMsgId);
            pstmt.setString(3, content);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DatabaseUtil.close(conn, pstmt, null);
        }
    }
}