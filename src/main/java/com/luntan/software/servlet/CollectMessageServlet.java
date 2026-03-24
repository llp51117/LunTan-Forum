//package com.luntan.software.servlet;
//
//import com.luntan.software.dao.CollectDao;
//import com.luntan.software.model.Collect;
//import com.luntan.software.model.User;
//
//import jakarta.servlet.ServletException;
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import jakarta.servlet.http.HttpSession;
//
//import java.io.IOException;
//
//@WebServlet("/CollectMessageServlet")
//public class CollectMessageServlet extends HttpServlet {
//    @Override
//    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
//        req.setCharacterEncoding("UTF-8");
//        resp.setCharacterEncoding("UTF-8");
//        resp.setContentType("application/json;charset=UTF-8");
//
//        HttpSession session = req.getSession();
//        User currentUser = (User) session.getAttribute("currentUser");
//        if (currentUser == null) {
//            resp.getWriter().write("{\"success\":false,\"msg\":\"请先登录\"}");
//            return;
//        }
//
//        String msgIdStr = req.getParameter("msgId");
//        if (msgIdStr == null || msgIdStr.isEmpty()) {
//            resp.getWriter().write("{\"success\":false,\"msg\":\"消息ID不能为空\"}");
//            return;
//        }
//        int messageId = Integer.parseInt(msgIdStr);
//        int userId = currentUser.getUserId();
//
//        CollectDao collectDao = new CollectDao();
//        // 检查是否已收藏
//        if (collectDao.isCollected(userId, messageId)) {
//            resp.getWriter().write("{\"success\":false,\"msg\":\"已收藏，不能重复操作\"}");
//            return;
//        }
//
//        Collect collect = new Collect();
//        collect.setUserId(userId);
//        collect.setMessageId(messageId);
//        boolean result = collectDao.addCollect(collect);
//
//        if (result) {
//            resp.getWriter().write("{\"success\":true,\"msg\":\"收藏成功\"}");
//        } else {
//            resp.getWriter().write("{\"success\":false,\"msg\":\"收藏失败\"}");
//        }
//    }
//}
package com.luntan.software.servlet;

import com.luntan.software.dao.CollectDao;
import com.luntan.software.model.Collect;
import com.luntan.software.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/CollectMessageServlet")
public class CollectMessageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            resp.getWriter().write("{\"success\":false,\"msg\":\"请先登录\",\"action\":\"\"}");
            return;
        }

        String msgIdStr = req.getParameter("msgId");
        if (msgIdStr == null || msgIdStr.isEmpty()) {
//            resp.getWriter().write("{\"success\":false,\"msg\":\"消息ID不能为空\",\"action\":\"\"}");
            resp.getWriter().write("{\"success\":false}"); // 只返回失败，不带msg
            return;
        }
        int messageId = Integer.parseInt(msgIdStr);
        int userId = currentUser.getUserId();

        CollectDao collectDao = new CollectDao();
        // 核心修改：判断已收藏时执行取消，未收藏时执行添加
        if (collectDao.isCollected(userId, messageId)) {
            // 已收藏 → 执行取消收藏操作
            boolean cancelResult = collectDao.deleteCollect(userId, messageId);
            if (cancelResult) {
                // 返回取消成功，标记action为cancel
                resp.getWriter().write("{\"success\":true,\"msg\":\"取消收藏成功\",\"action\":\"cancel\"}");
            } else {
                resp.getWriter().write("{\"success\":false,\"msg\":\"取消收藏失败\",\"action\":\"\"}");
            }
        } else {
            // 未收藏 → 执行添加收藏操作
            Collect collect = new Collect();
            collect.setUserId(userId);
            collect.setMessageId(messageId);
            boolean addResult = collectDao.addCollect(collect);
            if (addResult) {
                // 返回收藏成功，标记action为collect
                resp.getWriter().write("{\"success\":true,\"msg\":\"收藏成功\",\"action\":\"collect\"}");
            } else {
                resp.getWriter().write("{\"success\":false,\"msg\":\"收藏失败\",\"action\":\"\"}");
            }
        }
    }
}