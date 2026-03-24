package com.luntan.software.servlet;

import com.luntan.software.dao.LikeDao;
import com.luntan.software.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/LikeMessageServlet")
public class LikeMessageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            resp.getWriter().write("{\"success\":false,\"action\":\"\"}");
            return;
        }

        // 1. 获取msgId并增加格式校验（核心修正）
        String msgIdStr = req.getParameter("msgId");
        if (msgIdStr == null || msgIdStr.isEmpty()) {
            resp.getWriter().write("{\"success\":false,\"action\":\"\"}");
            return;
        }

        int messageId;
        try {
            messageId = Integer.parseInt(msgIdStr);
        } catch (NumberFormatException e) {
            resp.getWriter().write("{\"success\":false,\"action\":\"\"}");
            return;
        }

        // 2. 校验ID有效性（防止负数/0）
        int userId = currentUser.getUserId();
        if (userId <= 0 || messageId <= 0) {
            resp.getWriter().write("{\"success\":false,\"action\":\"\"}");
            return;
        }

        LikeDao likeDao = new LikeDao();
        // 3. 点赞/取消点赞核心逻辑
        if (likeDao.isLiked(userId, messageId)) {
            // 取消点赞：仅当deleteLike返回true时，才返回成功
            boolean cancelResult = likeDao.deleteLike(userId, messageId);
            if (cancelResult) {
                resp.getWriter().write("{\"success\":true,\"action\":\"cancel\"}");
            } else {
                // 若删除失败，手动打印异常（方便排查）
                System.out.println("取消点赞失败：用户ID=" + userId + "，消息ID=" + messageId);
                resp.getWriter().write("{\"success\":false,\"action\":\"\"}");
            }
        } else {
            // 点赞：仅当addLike返回true时，才返回成功
            boolean addResult = likeDao.addLike(userId, messageId);
            if (addResult) {
                resp.getWriter().write("{\"success\":true,\"action\":\"like\"}");
            } else {
                System.out.println("点赞失败：用户ID=" + userId + "，消息ID=" + messageId);
                resp.getWriter().write("{\"success\":false,\"action\":\"\"}");
            }
        }
    }
}