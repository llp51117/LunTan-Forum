package com.luntan.software.dao;

import com.luntan.software.model.Like;
import com.luntan.software.dao.DatabaseUtil;
import com.luntan.software.model.Message;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class LikeDao {
    // 按用户ID删除该用户的所有点赞（空实现，保证编译通过）
    public boolean deleteLikesByUserId(int userId) {
        String sql = "DELETE FROM tb_like WHERE user_id = ?"; // 你的点赞表是tb_like
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    // 新增：按点赞记录的主键ID删除（供管理员删除）
    public boolean adminDeleteLike(int likeId) {
//    public boolean deleteLike(int likeId) {
//        String sql = "DELETE FROM likes WHERE id = ?"; // 假设点赞表主键是id
        String sql = "DELETE FROM tb_like WHERE like_id = ?"; // 表名+字段名匹配实际数据库
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, likeId); // 仅需点赞记录ID
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteLike(int userId, int messageId) {
        // 假设点赞表名为 likes，通过 user_id 和 message_id 关联
        String sql = "DELETE FROM tb_like WHERE user_id = ? AND message_id = ?";
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
        // 保留你已有的方法（正确且符合项目规范）
        public int getLikeCountByMessageId(int messageId) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = DatabaseUtil.getConnection();
                String sql = "SELECT COUNT(*) FROM tb_like WHERE message_id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, messageId);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    return rs.getInt(1); // 无数据时返回0，正确
                }
                return 0; // 无结果时返回0
            } catch (SQLException e) {
                e.printStackTrace();
                return 0; // 异常时返回0，避免前端NaN
            } finally {
                DatabaseUtil.close(conn, pstmt, rs); // 手动关闭资源（符合你的项目习惯）
            }
        }

        // 其他已有方法（isLiked、addLike、deleteLike）继续保留
        // LikeDao.java中isLiked方法的正确实现
        public boolean isLiked(int userId, int messageId) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = DatabaseUtil.getConnection();
                String sql = "SELECT COUNT(*) FROM tb_like WHERE user_id = ? AND message_id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, userId);
                pstmt.setInt(2, messageId);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    return rs.getInt(1) > 0; // 有记录则返回true（已点赞）
                }
                return false;
            } catch (SQLException e) {
                e.printStackTrace();
                return false;
            } finally {
                DatabaseUtil.close(conn, pstmt, rs);
            }
        }

    // LikeDao.java中addLike方法的正确实现
    public boolean addLike(int userId, int messageId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DatabaseUtil.getConnection();
            String sql = "INSERT INTO tb_like (user_id, message_id, create_time) VALUES (?, ?, NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, messageId);
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DatabaseUtil.close(conn, pstmt, null);
        }
    }


    public List<Like> getLikesByUserId(int userId) {
        List<Like> likes = new ArrayList<>();
        String sql = "SELECT like_id, user_id, message_id, create_time FROM tb_like WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Like like = new Like();
                like.setLikeId(rs.getInt("like_id"));
                like.setUserId(rs.getInt("user_id"));
                like.setMessageId(rs.getInt("message_id"));
                like.setCreateTime(rs.getString("create_time"));
                likes.add(like);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return likes;
    }

    // 查询用户点赞过的所有消息
    public List<Message> getMyLikedMessages(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Message> messages = new ArrayList<>();
        try {
            conn = DatabaseUtil.getConnection();
            // 关联查询：从点赞表获取消息ID，再从消息表获取消息详情
            String sql = "SELECT m.* FROM message m " +
                    "JOIN tb_like l ON m.message_id = l.message_id " +
                    "WHERE l.user_id = ? " +
                    "ORDER BY l.create_time DESC"; // 按点赞时间排序
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            // 遍历结果集，封装为Message对象（根据你的Message类字段调整）
            while (rs.next()) {
                Message msg = new Message();
                msg.setMessageId(rs.getInt("message_id"));
                msg.setContent(rs.getString("content"));
                msg.setUsername(rs.getString("username")); // 假设消息表有username字段
                msg.setTime(rs.getString("create_time")); // 消息发布时间
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