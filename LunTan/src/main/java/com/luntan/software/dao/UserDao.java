package com.luntan.software.dao;
//package com.yourcompany.luntan.dao;
import com.luntan.software.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
public class UserDao {
    // 原有方法保留，新增以下方法
    public User getUserById(int userId) {
        String sql = "SELECT user_id, user_code, username, identity, create_time FROM user WHERE user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUserCode(rs.getString("user_code"));
                user.setUsername(rs.getString("username"));
                user.setIdentity(rs.getString("identity"));
//                user.setCreateTime(rs.getString("create_time"));
                // 直接获取Timestamp类型（无需转为String）
                user.setCreateTime(rs.getTimestamp("create_time"));
                return user;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // UserDao.java中新增方法
    public boolean deleteUserById(int userId) {
        String sql = "DELETE FROM user WHERE userId = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // UserDao.java中新增方法
    public List<User> searchUserByKeyword(String keyword) {
        List<User> userList = new ArrayList<>();
        String sql = "SELECT * FROM user WHERE userCode LIKE ? OR username LIKE ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            // 模糊查询的通配符
            String likeKeyword = "%" + keyword + "%";
            pstmt.setString(1, likeKeyword);
            pstmt.setString(2, likeKeyword);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("userId"));
                user.setUserCode(rs.getString("userCode"));
                user.setUsername(rs.getString("username"));
                user.setIdentity(rs.getString("identity"));
                userList.add(user);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return userList;
    }
    // 新增：根据用户编号、密码、身份查询用户
    public User login(String userCode, String password, String identity) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DatabaseUtil.getConnection();
            String sql = "SELECT * FROM user WHERE user_code = ? AND password = ? AND identity = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userCode);
            pstmt.setString(2, password);
            pstmt.setString(3, identity);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUserCode(rs.getString("user_code"));
                user.setUsername(rs.getString("username"));
                user.setIdentity(rs.getString("identity"));
                return user;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DatabaseUtil.close(conn, pstmt, rs);
        }
        return null;
    }


        public List<User> searchUsers(String keyword, int excludeUserId) {
            List<User> users = new ArrayList<>();

            String sql = "SELECT user_id, user_code, username, identity FROM user " +
                    "WHERE (username LIKE ? OR user_code LIKE ?) AND user_id != ?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setString(2, "%" + keyword + "%");
                pstmt.setInt(3, excludeUserId);
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUserCode(rs.getString("user_code"));
                    user.setUsername(rs.getString("username")); // 确保映射user表的username
                    user.setIdentity(rs.getString("identity"));
                    users.add(user);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return users;
        }

    public boolean deleteUser(int userId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DatabaseUtil.getConnection();
            // SQL：删除用户（根据实际表名和字段调整）
            String sql = "DELETE FROM user WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            // 执行删除，返回影响的行数（1表示成功，0表示用户不存在）
            return pstmt.executeUpdate() > 0;
        } finally {
            DatabaseUtil.close(conn, pstmt, null); // 关闭资源
        }
    }

        // 插入新用户到数据库
        public boolean registerUser(User user) {
            String sql = "INSERT INTO user (user_code, username, password, identity, create_time) " +
                    "VALUES (?, ?, ?, ?, NOW())"; // create_time由数据库自动生成
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                // 设置参数（与SQL中?的顺序一致）
                pstmt.setString(1, user.getUserCode()); // user_code
                pstmt.setString(2, user.getUsername()); // username
                pstmt.setString(3, user.getPassword()); // password
                pstmt.setString(4, user.getIdentity()); // identity

                // 执行插入，返回受影响的行数（1表示成功，0表示失败）
                int rows = pstmt.executeUpdate();
                return rows > 0;

            } catch (SQLException e) {
                // 打印异常信息，快速定位问题（比如字段不匹配、连接错误）
                System.out.println("入库失败原因：" + e.getMessage());
                e.printStackTrace();
                return false;
            }
        }

    public boolean isUserCodeExist(String userCode) {
        String sql = "SELECT COUNT(1) FROM user WHERE user_code = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userCode);
            ResultSet rs = pstmt.executeQuery();
            // 打印关键信息：当前数据库、查询的用户编号、结果数量
            System.out.println("当前数据库：" + conn.getCatalog());
            System.out.println("查询编号：" + userCode);
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("编号存在数量：" + count);
                return count > 0;
            }
            rs.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    }
