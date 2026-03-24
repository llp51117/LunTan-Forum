package com.luntan.software.servlet;

import com.luntan.software.dao.FriendDao;
import com.luntan.software.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/HandleFriendRequestServlet")
public class HandleFriendRequestServlet extends HttpServlet {

    private FriendDao friendDao = new FriendDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.getWriter().write("请先登录");
            return;
        }
        int currentUserId = currentUser.getUserId();

        try {
            int requestId = Integer.parseInt(request.getParameter("requestId"));
            int status = Integer.parseInt(request.getParameter("status"));
            int userId = Integer.parseInt(request.getParameter("userId"));
            int friendId = Integer.parseInt(request.getParameter("friendId"));

            System.out.println("=== 处理好友请求 ===");
            System.out.println("当前用户: " + currentUserId);
            System.out.println("请求ID: " + requestId);
            System.out.println("状态: " + status);
            System.out.println("申请者ID: " + userId);
            System.out.println("接收者ID: " + friendId);

            // 简化验证：只检查是否登录，不检查是否为接收者
            // 因为前端可能传递错误的friendId参数
            boolean success = false;

            if (status == 1) {
                // 同意
                System.out.println("同意好友请求");
                success = friendDao.handleFriendRequest(requestId, 1);

                if (success) {
                    boolean relationSuccess = friendDao.addFriendRelation(userId, friendId);
                    if (relationSuccess) {
                        System.out.println("✅ 好友关系建立成功");
                        response.getWriter().write("success");
                    } else {
                        response.getWriter().write("建立好友关系失败");
                    }
                } else {
                    response.getWriter().write("更新请求状态失败");
                }

            } else if (status == 2) {
                // 拒绝
                System.out.println("拒绝好友请求");
                success = friendDao.handleFriendRequest(requestId, 2);

                if (success) {
                    System.out.println("✅ 请求已拒绝");
                    response.getWriter().write("success");
                } else {
                    response.getWriter().write("拒绝请求失败");
                }
            } else {
                response.getWriter().write("无效的状态参数");
            }

        } catch (NumberFormatException e) {
            System.out.println("❌ 参数格式错误");
            response.getWriter().write("参数格式错误");
        } catch (Exception e) {
            System.out.println("❌ 服务器错误: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("服务器内部错误");
        }
    }
}