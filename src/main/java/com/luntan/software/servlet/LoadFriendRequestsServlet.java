package com.luntan.software.servlet;

import com.luntan.software.dao.FriendDao;
import com.luntan.software.model.FriendRequest;
import com.alibaba.fastjson.JSON;
import com.luntan.software.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/LoadFriendRequestsServlet")
public class LoadFriendRequestsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        // ============ 修改这里：从Session获取当前用户ID ============
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            System.out.println("LoadFriendRequestsServlet: 用户未登录");
            response.getWriter().write("[]");
            return;
        }

        int userId = currentUser.getUserId(); // 使用Session中的用户ID
        String type = request.getParameter("type"); // pending 或 received

        System.out.println("LoadFriendRequestsServlet: 用户ID=" + userId + ", 类型=" + type);

        FriendDao friendDao = new FriendDao();
        List<FriendRequest> requests = friendDao.getFriendRequests(userId, type);

        System.out.println("LoadFriendRequestsServlet: 查询到 " + requests.size() + " 条记录");

        response.getWriter().write(JSON.toJSONString(requests));
    }
}