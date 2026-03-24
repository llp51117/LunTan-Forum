package com.luntan.software.servlet;

import com.luntan.software.dao.UserDao;
import com.luntan.software.model.User;
import com.alibaba.fastjson.JSON;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/GetUserDetailServlet")
public class GetUserDetailServlet extends HttpServlet {
    private UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String userIdStr = request.getParameter("userId");
        // 优化1：判断用户ID是否为空或非数字
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.getWriter().print(JSON.toJSONString(null));
            return;
        }
        int userId = 0;
        try {
            userId = Integer.parseInt(userIdStr.trim());
        } catch (NumberFormatException e) {
            // 优化2：捕获数字转换异常
            response.getWriter().print(JSON.toJSONString(null));
            return;
        }

        User user = userDao.getUserById(userId);
        // 优化3：如果查询不到用户，返回空JSON对象（前端更好处理）
        if (user == null) {
            response.getWriter().print("{}");
        } else {
            response.getWriter().print(JSON.toJSONString(user));
        }
    }
}