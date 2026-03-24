package com.luntan.software.servlet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/ReplyMessageServlet") // 确保路径与前端请求一致
public class ReplyMessageServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 1. 获取参数
        int targetMsgId = Integer.parseInt(request.getParameter("targetMsgId"));
        String content = request.getParameter("content");
        int userId = Integer.parseInt(request.getParameter("userId"));

        // 2. 业务逻辑（示例：此处需调用DAO插入回复数据）
        // 假设已实现回复插入逻辑，此处简化处理
        response.getWriter().write("success"); // 模拟回复成功
    }
}