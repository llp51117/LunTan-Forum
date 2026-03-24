//package com.luntan.software.servlet;
//
//import com.luntan.software.dao.UserActionDao;
//import com.alibaba.fastjson.JSON;
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import java.io.IOException;
//import java.util.HashMap;
//import java.util.Map;
//
//@WebServlet("/GetUserActionsServlet") // 路径必须和前端请求一致
//public class GetUserActionsServlet extends HttpServlet {
//    private UserActionDao actionDao = new UserActionDao();
//
//    @Override
//    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
//        request.setCharacterEncoding("UTF-8");
//        response.setContentType("application/json;charset=UTF-8");
//
//
//        String userIdStr = request.getParameter("userId");
//        if (userIdStr == null || userIdStr.trim().isEmpty()) {
//            response.getWriter().print(JSON.toJSONString(new HashMap<>()));
//            return;
//        }
//        int userId = Integer.parseInt(userIdStr.trim());
//
//        // 从数据库查询用户的帖子、回复、点赞、收藏
//        Map<String, Object> actions = new HashMap<>();
//        actions.put("messages", actionDao.getMessagesByUserId(userId)); // 评论（对应message表）
//        actions.put("replies", actionDao.getRepliesByUserId(userId));
//        actions.put("likes", actionDao.getLikesByUserId(userId));
//        actions.put("collects", actionDao.getCollectsByUserId(userId));
//
//        // 返回JSON给前端
//        response.getWriter().print(JSON.toJSONString(actions));
//    }
//}





package com.luntan.software.servlet;

import com.luntan.software.dao.UserActionDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.alibaba.fastjson.JSON; // 确保导入fastjson包
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/GetUserActionsServlet")
public class GetUserActionsServlet extends HttpServlet {
    private UserActionDao actionDao = new UserActionDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String userIdStr = request.getParameter("userId");
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            out.print(JSON.toJSONString(new HashMap<>()));
            out.close();
            return;
        }

        int userId = Integer.parseInt(userIdStr.trim());
        // 从数据库查询最新数据（无缓存）
        Map<String, Object> actions = new HashMap<>();
        actions.put("messages", actionDao.getMessagesByUserId(userId)); // 评论
        actions.put("replies", actionDao.getRepliesByUserId(userId));   // 回复
        actions.put("likes", actionDao.getLikesByUserId(userId));       // 点赞
        actions.put("collects", actionDao.getCollectsByUserId(userId)); // 收藏

        // 返回最新JSON数据
        out.print(JSON.toJSONString(actions));
        out.close();
    }
}