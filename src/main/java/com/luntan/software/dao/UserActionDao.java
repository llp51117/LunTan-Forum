package com.luntan.software.dao;

import com.luntan.software.model.Message; // 评论实体类
import com.luntan.software.model.Reply;  // 回复实体类
import com.luntan.software.model.Like;    // 点赞实体类
import com.luntan.software.model.Collect; // 收藏实体类
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

// 工具类：数据库连接（需确保项目中已存在）

public class UserActionDao {
    /**
     * 查询用户的评论（对应message表）
     */
    public List<Message> getMessagesByUserId(int userId) {
        List<Message> messages = new ArrayList<>();
        String sql = "SELECT id, content, create_time FROM message WHERE user_id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Message message = new Message();
                message.setId(rs.getInt("id"));
                message.setContent(rs.getString("content"));
                message.setCreateTime(rs.getString("create_time"));
                messages.add(message);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return messages;
    }

    /**
     * 查询用户的回复（对应reply表）
     */
    public List<Reply> getRepliesByUserId(int userId) {
        List<Reply> replies = new ArrayList<>();
        String sql = "SELECT id, target_msg_id, content, create_time FROM reply WHERE user_id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Reply reply = new Reply();
                reply.setId(rs.getInt("id"));
                reply.setTargetMsgId(rs.getInt("target_msg_id"));
                reply.setContent(rs.getString("content"));
                reply.setCreateTime(rs.getString("create_time"));
                replies.add(reply);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return replies;
    }

    /**
     * 查询用户的点赞（对应tb_like表）
     */
    public List<Like> getLikesByUserId(int userId) {
        List<Like> likes = new ArrayList<>();
        String sql = "SELECT like_id, message_id, create_time FROM tb_like WHERE user_id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Like like = new Like();
                like.setLikeId(rs.getInt("like_id"));
                like.setMessageId(rs.getInt("message_id"));
                like.setCreateTime(rs.getString("create_time"));
                likes.add(like);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return likes;
    }

    /**
     * 查询用户的收藏（对应tb_collect表）
     */
    public List<Collect> getCollectsByUserId(int userId) {
        List<Collect> collects = new ArrayList<>();
        String sql = "SELECT collect_id, message_id, collect_time FROM tb_collect WHERE user_id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Collect collect = new Collect();
                collect.setCollectId(rs.getInt("collect_id"));
                collect.setMessageId(rs.getInt("message_id"));
                collect.setCollectTime(rs.getString("collect_time"));
                collects.add(collect);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return collects;
    }
}