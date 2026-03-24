package com.luntan.software.dao;

import com.luntan.software.model.Collect;
import com.luntan.software.dao.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.luntan.software.model.Message;
import java.util.ArrayList;
import java.util.List;
public class CollectDao {
    // 按用户ID删除该用户的所有收藏（空实现，保证编译通过）
    public boolean deleteCollectsByUserId(int userId) {
        String sql = "DELETE FROM tb_collect WHERE user_id = ?"; // 你的收藏表是tb_collect
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    // 新增：根据收藏记录的主键ID删除（供管理员删除）
//    public boolean deleteCollectById(int collectId) {
//        String sql = "DELETE FROM collect WHERE id = ?"; // 假设收藏表主键是id
    public boolean adminDeleteCollect(int collectId) {
        String sql = "DELETE FROM tb_collect WHERE collect_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, collectId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    public boolean deleteCollect(int userId, int messageId) {
        String sql = "DELETE FROM tb_collect WHERE user_id = ? AND message_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId); // 第一个参数：用户ID
            ps.setInt(2, messageId); // 第二个参数：消息ID
            return ps.executeUpdate() > 0; // 影响行数>0表示删除成功
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    // 新增：删除收藏

    public List<Collect> getCollectsByUserId(int userId) {
        List<Collect> collects = new ArrayList<>();
        String sql = "SELECT collect_id, user_id, message_id, collect_time FROM tb_collect WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Collect collect = new Collect();
                collect.setCollectId(rs.getInt("collect_id"));
                collect.setUserId(rs.getInt("user_id"));
                collect.setMessageId(rs.getInt("message_id"));
                collect.setCollectTime(rs.getString("collect_time"));
                collects.add(collect);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return collects;
    }
    // 新增收藏（适配 user 表和 message 表）
    public boolean addCollect(Collect collect) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DatabaseUtil.getConnection();
            // SQL 中直接使用 user 表和 message 表（你的实际表名）
            String sql = "INSERT INTO tb_collect (user_id, message_id, collect_time) VALUES (?, ?, NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, collect.getUserId());
            pstmt.setInt(2, collect.getMessageId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DatabaseUtil.close(conn, pstmt, null);
        }
    }

    public int getCollectCountByMessageId(int messageId) {
        String sql = "SELECT COUNT(*) FROM tb_collect WHERE message_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, messageId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1); // 正常返回计数（>=0）
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0; // 异常时返回0，避免负数
    }

    // 检查用户是否已收藏某条消息（避免重复收藏）
    public boolean isCollected(int userId, int messageId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DatabaseUtil.getConnection();
            String sql = "SELECT * FROM tb_collect WHERE user_id = ? AND message_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, messageId);
            rs = pstmt.executeQuery();
            return rs.next(); // 有记录则已收藏
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DatabaseUtil.close(conn, pstmt, rs);
        }
    }

    // 查询用户收藏过的所有消息
    public List<Message> getMyCollectedMessages(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Message> messages = new ArrayList<>();
        try {
            conn = DatabaseUtil.getConnection();
            // 关联查询：从收藏表获取消息ID，再从消息表获取消息详情
            String sql = "SELECT m.* FROM message m " +
                    "JOIN tb_collect c ON m.message_id = c.message_id " +
                    "WHERE c.user_id = ? " +
                    "ORDER BY c.collect_time DESC"; // 按收藏时间排序
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            // 遍历结果集，封装为Message对象（与点赞逻辑一致）
            while (rs.next()) {
                Message msg = new Message();
                msg.setMessageId(rs.getInt("message_id"));
                msg.setContent(rs.getString("content"));
                msg.setUsername(rs.getString("username"));
                msg.setTime(rs.getString("create_time"));
                messages.add(msg);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DatabaseUtil.close(conn, pstmt, rs);
        }
        return messages;
    }

}