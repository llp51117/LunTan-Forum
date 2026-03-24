package com.luntan.software.servlet;


import com.luntan.software.dao.LikeDao;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/GetLikeCountServlet")
public class GetLikeCountServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 设置响应格式（JSON）
        response.setContentType("application/json;charset=utf-8");
        // 2. 获取前端传的messageId
        String msgIdStr = request.getParameter("messageId");
        if (msgIdStr == null || msgIdStr.isEmpty()) {
            PrintWriter out = response.getWriter();
            out.write("{\"code\":-1, \"msg\":\"消息ID不能为空\", \"count\":0}");
            out.close();
            return;
        }
        int messageId = Integer.parseInt(msgIdStr);

        // 3. 调用LikeDao查点赞数
        LikeDao likeDao = new LikeDao();
        int likeCount = likeDao.getLikeCountByMessageId(messageId);

        // 4. 返回给前端
        PrintWriter out = response.getWriter();
        out.write("{\"code\":0, \"msg\":\"成功\", \"count\":" + likeCount + "}");
        out.close();
    }
}