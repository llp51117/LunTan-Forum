package com.luntan.software.servlet;

import com.luntan.software.dao.DatabaseUtil;
import com.luntan.software.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/CheckMyRequestStatusServlet")
public class CheckMyRequestStatusServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.getWriter().write("{\"status\":\"error\",\"message\":\"用户未登录\"}");
            return;
        }

        int userId = currentUser.getUserId();

        try {
            System.out.println("=== CheckMyRequestStatusServlet 开始执行 ===");
            System.out.println("查询用户ID: " + userId);

            // 查询我发送的好友请求状态（只查已同意或已拒绝的）
            String sql = "SELECT fr.*, u.username, u.user_code " +
                    "FROM friend_request fr " +
                    "JOIN user u ON fr.friend_id = u.user_id " +
                    "WHERE fr.user_id = ? AND fr.status IN (1, 2) " +
                    "ORDER BY fr.request_time DESC";

            System.out.println("执行SQL: " + sql);

            List<Map<String, Object>> results = new ArrayList<>();

            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, userId);
                ResultSet rs = pstmt.executeQuery();

                int count = 0;
                while (rs.next()) {
                    count++;
                    Map<String, Object> result = new HashMap<>();
                    result.put("id", rs.getInt("id"));
                    result.put("friendId", rs.getInt("friend_id"));
                    result.put("username", rs.getString("username"));
                    result.put("userCode", rs.getString("user_code"));
                    result.put("status", rs.getInt("status")); // 1=同意, 2=拒绝
                    result.put("requestTime", rs.getString("request_time"));
                    results.add(result);

                    System.out.println("找到请求 #" + count + ": ID=" + rs.getInt("id") +
                            ", 状态=" + rs.getInt("status") +
                            ", 目标用户=" + rs.getString("username"));
                }

                System.out.println("总共找到 " + count + " 条已处理的请求");
            }

            // 使用 FastJSON 转换
            String jsonData = com.alibaba.fastjson.JSON.toJSONString(results);
            String jsonResponse = "{\"status\":\"success\",\"data\":" + jsonData + "}";
            System.out.println("返回数据: " + jsonResponse.substring(0, Math.min(100, jsonResponse.length())) + "...");
            response.getWriter().write(jsonResponse);

        } catch (Exception e) {
            System.out.println("❌ CheckMyRequestStatusServlet 异常: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("{\"status\":\"error\",\"message\":\"服务器错误\"}");
        }
    }
}