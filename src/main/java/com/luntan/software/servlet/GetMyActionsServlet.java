package com.luntan.software.servlet; // 确保包名与其他Servlet一致

import com.alibaba.fastjson.JSON;
import com.luntan.software.dao.LikeDao;
import com.luntan.software.dao.CollectDao;
import com.luntan.software.dao.MessageDao;
import com.luntan.software.model.Message;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/GetMyActionsServlet") // 必须与前端请求的URL一致
public class GetMyActionsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 设置响应格式为JSON（避免前端解析错误）
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        // 1. 获取前端传递的参数：操作类型（like/collect）和用户ID
        String type = req.getParameter("type"); // "like" 或 "collect"
        String userIdStr = req.getParameter("userId");

        // 参数校验
        if (type == null || userIdStr == null || userIdStr.isEmpty()) {
            out.write("[]"); // 参数错误时返回空列表
            return;
        }
        int userId = Integer.parseInt(userIdStr);

        // 2. 根据类型查询用户的点赞/收藏记录
        List<Message> actionMessages = null;
        if ("like".equals(type)) {
            // 查询用户点赞过的消息
            LikeDao likeDao = new LikeDao();
            actionMessages = likeDao.getMyLikedMessages(userId);
        } else if ("collect".equals(type)) {
            // 查询用户收藏过的消息
            CollectDao collectDao = new CollectDao();
            actionMessages = collectDao.getMyCollectedMessages(userId);
        }

        // 3. 将结果转为JSON返回给前端
        String json = JSON.toJSONString(actionMessages);
        out.write(json);
    }
}