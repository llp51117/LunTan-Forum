package com.luntan.software.servlet;

import com.luntan.software.dao.FriendDao;
import com.luntan.software.dao.FriendRelationDao;
import com.luntan.software.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/DeleteFriendServlet")
public class DeleteFriendServlet extends HttpServlet {
    private FriendDao friendDao = new FriendDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.getWriter().write("请先登录");
            return;
        }

        try {
            // 获取要删除的好友ID
            String friendIdStr = request.getParameter("friendId");
            if (friendIdStr == null || friendIdStr.isEmpty()) {
                response.getWriter().write("参数错误：friendId不能为空");
                return;
            }

            int friendId = Integer.parseInt(friendIdStr);
            int userId = currentUser.getUserId();

            // 打印调试信息
            System.out.println("=== DeleteFriendServlet 开始执行 ===");
            System.out.println("当前用户ID: " + userId);
            System.out.println("要删除的好友ID: " + friendId);

            // 检查是否试图删除自己
            if (userId == friendId) {
                response.getWriter().write("不能删除自己");
                return;
            }

            // 检查是否真的是好友关系
            boolean isFriend = friendDao.isFriend(userId, friendId);
            if (!isFriend) {
                response.getWriter().write("你们不是好友关系");
                return;
            }

            // 执行删除好友关系
            boolean success = friendDao.deleteFriendRelation(userId, friendId);

            if (success) {
                System.out.println("✅ 好友删除成功");
                response.getWriter().write("success");
            } else {
                System.out.println("❌ 好友删除失败");
                response.getWriter().write("删除失败");
            }

        } catch (NumberFormatException e) {
            System.out.println("❌ 参数格式错误");
            response.getWriter().write("参数格式错误");
        } catch (Exception e) {
            System.out.println("❌ 服务器错误: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("服务器错误");
        }
    }

    // 可选：添加GET方法用于测试
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        response.getWriter().write("<h3>DeleteFriendServlet 运行中</h3>");
        response.getWriter().write("<p>请使用POST方法删除好友</p>");
    }
}