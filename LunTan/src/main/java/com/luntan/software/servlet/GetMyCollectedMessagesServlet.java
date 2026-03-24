package com.luntan.software.servlet;

import com.luntan.software.dao.CollectDao;
import com.luntan.software.model.Message;
import com.alibaba.fastjson.JSON;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/GetMyCollectedMessagesServlet")
public class GetMyCollectedMessagesServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        int userId = Integer.parseInt(request.getParameter("userId"));

        CollectDao collectDao = new CollectDao();
        List<Message> myCollectedMessages = collectDao.getMyCollectedMessages(userId);

        String json = JSON.toJSONString(myCollectedMessages);
        response.getWriter().write(json);
    }
}