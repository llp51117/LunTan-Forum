package com.luntan.software.dao;


import com.luntan.software.model.Reply; // 导入Reply类
import com.luntan.software.model.Message;
import com.luntan.software.dao.DatabaseUtil; // 确保数据库工具类路径正确
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MessageDao {

    // 先加空实现，保证编译通过，后续补SQL逻辑
    public boolean deleteMessagesByUserId(int userId) {
        String sql = "DELETE FROM message WHERE user_id = ?"; // 注意：表名和字段名要和你的数据库一致
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0; // 执行SQL并返回是否删除成功
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    /**
     * 查询所有公共消息（按时间倒序，最新的在前）
     */
    // 新增：删除评论（参数为评论ID）
//    public boolean deleteMessage(int messageId) {
//        String sql = "DELETE FROM message WHERE id = ?";
//        try (Connection conn = DatabaseUtil.getConnection();
//             PreparedStatement ps = conn.prepareStatement(sql)) {
//            ps.setInt(1, messageId);
//            return ps.executeUpdate() > 0;
//        } catch (SQLException e) {
//            e.printStackTrace();
//            return false;
//        }
//    }
    public boolean deleteMessage(int messageId) {
        String deleteReplySql = "DELETE FROM reply WHERE target_msg_id = ?"; // 先删关联回复
        String deleteMessageSql = "DELETE FROM message WHERE id = ?"; // 再删评论
        Connection conn = null;
        PreparedStatement replyPs = null;
        PreparedStatement messagePs = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false); // 开启事务

            // 步骤1：删除关联回复（解决外键约束）
            replyPs = conn.prepareStatement(deleteReplySql);
            replyPs.setInt(1, messageId);
            replyPs.executeUpdate();

            // 步骤2：删除评论
            messagePs = conn.prepareStatement(deleteMessageSql);
            messagePs.setInt(1, messageId);
            int affectedRows = messagePs.executeUpdate();

            conn.commit(); // 提交事务
            return affectedRows > 0;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // 回滚事务
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            DatabaseUtil.close(conn, replyPs, null);
            DatabaseUtil.close(null, messagePs, null);
        }
    }

    public Map<String, Object> getMessageWithUser(int messageId) {
        // 修复SQL：u.user_code 后添加空格，避免语法错误
        String sql = "SELECT m.content, u.username, u.user_code " +
                "FROM message m LEFT JOIN user u ON m.user_id = u.user_id " +
                "WHERE m.id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, messageId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Map<String, Object> info = new HashMap<>();
                info.put("content", rs.getString("content"));
                // 确保字段名与user表一致：若user表昵称是nickname，需改为rs.getString("nickname")
                info.put("username", rs.getString("username") == null ? "未知用户" : rs.getString("username"));
                // 确保user表的编号字段是user_code（若不是，改为实际字段名，如user_id）
                info.put("userCode", rs.getString("user_code") == null ? "未知编号" : rs.getString("user_code"));
                return info;
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("查询评论+用户信息失败：" + e.getMessage());
        }
        return null;
    }

//    public Message getMessageById(int messageId) {
//        String sql = "SELECT content FROM message WHERE id = ?";
//        try (Connection conn = DatabaseUtil.getConnection();
//             PreparedStatement ps = conn.prepareStatement(sql)) {
//            ps.setInt(1, messageId);
//            ResultSet rs = ps.executeQuery();
////            if (rs.next()) {
////                Message msg = new Message();
////                msg.setContent(rs.getString("content"));
////                return msg;
////            }
//            if (rs.next()) {
//                Message message = new Message();
//                message.setId(rs.getInt("id"));
//                message.setContent(rs.getString("content"));
//                message.setCreateTime(rs.getString("create_time"));
//                return message;
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return null;
//    }
public Message getMessageById(int messageId) {
    // 修复SQL：查询所有需要的字段
    String sql = "SELECT id, content, create_time FROM message WHERE id = ?";
    try (Connection conn = DatabaseUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, messageId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            Message message = new Message();
            message.setId(rs.getInt("id"));
            message.setContent(rs.getString("content"));
            message.setCreateTime(rs.getString("create_time"));
            return message;
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}
    public List<Message> getPublicMessages() {
        List<Message> messages = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();
            // 只查询message表中存在的字段
//            String sql = "SELECT id, user_id, content, create_time FROM message WHERE type='public' ORDER BY create_time ASC";
            // 核心：通过 LEFT JOIN 关联 user 表，获取对应的 username
            String sql = "SELECT " +
                    "m.id, m.user_id, m.content, m.create_time, " +
                    "u.username, u.user_code  " +  // 关键：用u.user_code（匹配数据库字段）
                    "FROM message m " +
                    "LEFT JOIN user u ON m.user_id = u.user_id " +  // 关联user表
                    "WHERE m.type='public' " +  // 只查公共消息
                    "ORDER BY m.create_time ASC";
            // 打印SQL，确认条件是否正确
            System.out.println("【MessageDao】执行SQL：" + sql);

            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            int count = 0;
            while (rs.next()) {
                Message msg = new Message();
                msg.setId(rs.getInt("id"));
                msg.setUserId(rs.getInt("user_id"));
                msg.setTime(rs.getString("create_time"));
                // 从user表获取用户名
                msg.setUsername(rs.getString("username"));  // 用户名（匹配u.username）
                // 从user表获取用户编号（新增这行）
                msg.setUserCode(rs.getString("user_code"));  // 用户编号（匹配u.user_code）
                // 1. 给Message对象赋值content（必须写，对应SQL的m.content）
                msg.setContent(rs.getString("content"));
                // 可补充其他字段：如点赞数、回复数等
                messages.add(msg);
            }
            System.out.println("【MessageDao】查询到公共消息数量：" + count);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DatabaseUtil.close(conn, pstmt, rs); // 关闭资源
        }
        return messages;
    }

    // 若需要消息发送功能，补充以下方法（参考之前的完整代码）
//    公共聊天
    public boolean savePublicMessage(int userId, String content) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            // 获取数据库连接
            conn = DatabaseUtil.getConnection();
            // 插入字段与message表完全一致：user_id, content, type, create_time
            String sql = "INSERT INTO message (user_id, content, type, create_time) " +
                    "VALUES (?, ?, 'public', NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);       // 绑定发送者ID
            pstmt.setString(2, content);   // 绑定消息内容
            // 执行插入，返回是否成功（受影响行数>0则成功）
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false; // 异常时返回失败
        } finally {
            // 关闭数据库资源
            DatabaseUtil.close(conn, pstmt, null);
        }
    }

//    私人聊天
    /**
     * 保存私聊消息到数据库
     * @param userId 发送者ID
     * @param friendId 接收者ID
     * @param content 消息内容
     * @return 是否保存成功
     */
public boolean savePrivateMessage(int userId, int friendId, String content) {
    Connection conn = null;
    PreparedStatement pstmt = null;
    try {
        conn = DatabaseUtil.getConnection();
        String sql = "INSERT INTO message (user_id, friend_id, content, type, create_time) " +
                "VALUES (?, ?, ?, 'private', NOW())";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        pstmt.setInt(2, friendId);
        pstmt.setString(3, content);
        return pstmt.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    } finally {
        DatabaseUtil.close(conn, pstmt, null);
    }
}

    // 在MessageDao中新增
    public List<Reply> getRepliesByMsgId(int msgId) {
        List<Reply> replies = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DatabaseUtil.getConnection();
//            String sql = "SELECT r.*, u.username " +
//                    "FROM reply r " +
//                    "JOIN user u ON r.user_id = u.user_id " +
//                    "WHERE r.target_msg_id = ? " +
//                    "ORDER BY r.create_time ASC";
            // 1. SQL中绝对不能包含user_code（表中没有这个字段）
            String sql = "SELECT id, user_id, content, create_time " +
                    "FROM message " +
                    "WHERE type='public' " +
                    "ORDER BY create_time ASC";

            pstmt = conn.prepareStatement(sql);
//            pstmt.setInt(1, msgId);
            int count = 0; // 用于计数，验证是否查询到数据
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Reply reply = new Reply();
                reply.setId(rs.getInt("id"));
                reply.setUserId(rs.getInt("user_id"));
                reply.setTargetMsgId(rs.getInt("target_msg_id"));
                reply.setContent(rs.getString("content"));
                reply.setCreateTime(rs.getString("create_time"));

//                reply.setUsername(rs.getString("username"));
                replies.add(reply);
            }
            System.out.println("【MessageDao】查询到公共消息数量：" + conn); // 关键日志
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DatabaseUtil.close(conn, pstmt, rs);
        }
        return replies;
    }

}