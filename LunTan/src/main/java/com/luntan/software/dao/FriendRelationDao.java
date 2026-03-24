package com.luntan.software.dao;

import com.luntan.software.model.FriendRelation;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FriendRelationDao {

        // 根据user_id删除friend_relation中的关联记录
        // 核心：删除该用户在friend_relation表中的所有关联记录
        public void deleteByUserId(int userId) {
            String sql = "DELETE FROM friend_relation WHERE user_id = ? OR friend_user_id = ?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, userId);  // 删除“该用户作为发起者”的关系
                pstmt.setInt(2, userId);  // 删除“该用户作为被添加者”的关系
                pstmt.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }


    // 查询当前用户的所有好友
    public List<FriendRelation> getFriendsByUserId(int userId) {
        List<FriendRelation> friends = new ArrayList<>();

        System.out.println("=== FriendRelationDao.getFriendsByUserId() ===");
        System.out.println("查询用户ID: " + userId);

        // 修正SQL
        String sql = "SELECT fr.id, fr.user_id, fr.friend_user_id, " +
                "u.username, u.user_code " +
                "FROM friend_relation fr " +
                "JOIN user u ON fr.friend_user_id = u.user_id " +
                "WHERE fr.user_id = ?";

        System.out.println("执行SQL: " + sql);

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();

            int count = 0;
            while (rs.next()) {
                count++;
                FriendRelation fr = new FriendRelation();
                fr.setId(rs.getInt("id"));
                fr.setUserId(rs.getInt("user_id"));
                fr.setFriendId(rs.getInt("friend_user_id"));
                fr.setUsername(rs.getString("username"));
                fr.setUserCode(rs.getString("user_code"));
                friends.add(fr);

                System.out.println("找到好友 #" + count + ": ID=" + fr.getFriendId() +
                        ", 用户名=" + fr.getUsername());
            }

            System.out.println("总共找到 " + count + " 个好友");

        } catch (SQLException e) {
            System.out.println("❌ FriendRelationDao SQL错误: " + e.getMessage());
            e.printStackTrace();
        }

        return friends;
    }
}