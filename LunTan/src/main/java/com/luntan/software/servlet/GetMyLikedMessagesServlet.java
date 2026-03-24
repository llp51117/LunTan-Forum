package com.luntan.software.servlet;

import com.luntan.software.dao.LikeDao;
import com.luntan.software.model.Message;
import com.alibaba.fastjson.JSON;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/GetMyLikedMessagesServlet")
public class GetMyLikedMessagesServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        // 1. 获取当前登录用户ID（关键！必须从Session中获取用户信息）
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId"); // 假设登录时已将userId存入Session
        if (userId == null) {
            // 未登录时返回空列表
            response.getWriter().write("[]");
            return;
        }

        // 2. 调用LikeDao查询该用户点赞过的消息列表
        LikeDao likeDao = new LikeDao();
        List<Message> myLikedMessages = likeDao.getMyLikedMessages(userId);

        // 3. 返回JSON给前端
        String json = JSON.toJSONString(myLikedMessages);
        response.getWriter().write(json);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        doGet(request, response);
    }
}