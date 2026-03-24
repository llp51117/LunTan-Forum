package com.luntan.software.servlet;

//package com.luntan.software.servlet;

import com.luntan.software.dao.UserDao;
import com.luntan.software.model.User;
import com.alibaba.fastjson.JSON;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
//普通用户用于接收前端搜索请求并返回数据库查询结果
@WebServlet("/SearchUserServlet")
public class SearchUserServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 解决中文乱码
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        // 2. 获取前端参数
        String keyword = request.getParameter("keyword");
        int excludeUserId = Integer.parseInt(request.getParameter("excludeSelf"));

        // 3. 调用DAO层查询
        UserDao userDao = new UserDao();
        List<User> users = userDao.searchUsers(keyword, excludeUserId);

        // 打印查询结果，确认是否有数据
        System.out.println("搜索到的用户数量：" + users.size());
        for (User u : users) {
            System.out.println("用户信息：" + u.getUsername() + "，" + u.getUserCode());
        }


        // 4. 结果转为JSON返回
        response.getWriter().write(JSON.toJSONString(users));
    }
}