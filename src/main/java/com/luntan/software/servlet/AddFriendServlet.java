package com.luntan.software.servlet;

import com.luntan.software.dao.FriendDao;
import com.luntan.software.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/AddFriendServlet")
public class AddFriendServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");

        // 详细日志
        System.out.println("=== AddFriendServlet被调用 ===");
        // 1. 获取Session
        HttpSession session = request.getSession(false); // 不创建新Session
        if (session == null) {
            System.out.println("Session不存在");
            response.getWriter().write("请先登录");
            return;
        }
        // 2. 从Session获取用户
        User currentUser = (User) session.getAttribute("currentUser");
        System.out.println("Session中的用户: " + (currentUser != null ? currentUser.getUsername() : "null"));
        if (currentUser == null) {
            System.out.println("Session中无用户信息");
            response.getWriter().write("请先登录");
            return;
        }
        int userId = currentUser.getUserId();
        // 3. 获取friendId参数
        String friendIdStr = request.getParameter("friendId");
        System.out.println("接收到的friendId参数: " + friendIdStr);
        System.out.println("接收到的所有参数:");
        request.getParameterMap().forEach((k, v) ->
                System.out.println(k + " = " + String.join(",", v)));
        if (friendIdStr == null || friendIdStr.isEmpty()) {
            System.out.println("friendId参数为空");
            response.getWriter().write("参数错误");
            return;
        }
        try {
            int friendId = Integer.parseInt(friendIdStr);
            // 4. 检查不能添加自己为好友
            if (userId == friendId) {
                response.getWriter().write("不能添加自己为好友");
                return;
            }
            // 5. 调用DAO
            FriendDao friendDao = new FriendDao();
            boolean success = friendDao.addFriendRequest(userId, friendId);
            System.out.println("添加好友请求结果: " + success);
            response.getWriter().write(success ? "success" : "fail");
        } catch (NumberFormatException e) {
            System.out.println("friendId格式错误: " + friendIdStr);
            response.getWriter().write("参数格式错误");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("服务器错误");
        }
    }
}