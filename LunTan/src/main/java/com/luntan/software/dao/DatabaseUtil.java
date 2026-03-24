package com.luntan.software.dao;

//package com.yourcompany.luntan.dao;

import java.sql.*;

public class DatabaseUtil {
    private static final String URL = "jdbc:mysql://localhost:3306/luntan_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false";
    private static final String USER = "root"; // 替换为你的MySQL用户名
    private static final String PASSWORD = "1234"; // 替换为你的MySQL密码

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("✅ MySQL驱动加载成功");
        } catch (ClassNotFoundException e) {
            System.out.println("❌ MySQL驱动加载失败: " + e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        System.out.println("🔗 尝试连接数据库...");
        System.out.println("📝 URL: " + URL);
        System.out.println("👤 User: " + USER);
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("✅ 数据库连接成功");
            return conn;
        } catch (SQLException e) {
            System.out.println("❌ 数据库连接失败: " + e.getMessage());
            throw e;
        }
    }

    public static void testConnection() {
        try (Connection conn = getConnection()) {
            System.out.println("数据库连接成功！");
        } catch (SQLException e) {
            System.out.println("数据库连接失败：" + e.getMessage());
        }
    }


    // 关闭连接（核心！必须调用）
    public static void close(Connection conn) {
        if (conn != null) {
            try {
                if (!conn.isClosed()) {
                    conn.close(); // 释放连接
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // 关闭资源的工具方法（重载，支持不同参数）
    public static void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        try {
            if (rs != null) rs.close(); // 先关结果集
            if (pstmt != null) pstmt.close(); // 再关语句
            if (conn != null) conn.close(); // 最后关连接
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
