//package com.luntan.software.servlet;
//
//import com.luntan.software.dao.ReplyDao;
//import com.alibaba.fastjson.JSONObject;
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import java.io.IOException;
//
//@WebServlet("/SendReplyServlet")
//public class SendReplyServlet extends HttpServlet {
//    @Override
//    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
//        response.setContentType("application/json;charset=UTF-8");
//        JSONObject result = new JSONObject();
//
//        try {
//            String content = request.getParameter("content");
//            String targetMsgIdStr = request.getParameter("targetMsgId");
//            String userIdStr = request.getParameter("userId");
//
//            if (content == null || targetMsgIdStr == null || userIdStr == null) {
//                result.put("success", false);
//                result.put("msg", "参数不完整");
//                response.getWriter().write(result.toString());
//                return;
//            }
//
//            int targetMsgId = Integer.parseInt(targetMsgIdStr);
//            int userId = Integer.parseInt(userIdStr);
//
//            ReplyDao replyDao = new ReplyDao();
//            boolean isSuccess = replyDao.saveReply(userId, targetMsgId, content);
//
//            result.put("success", isSuccess);
//            result.put("msg", isSuccess ? "回复成功" : "回复失败");
//        } catch (NumberFormatException e) {
//            result.put("success", false);
//            result.put("msg", "ID格式错误");
//            e.printStackTrace();
//        } catch (Exception e) {
//            result.put("success", false);
//            result.put("msg", "服务器错误");
//            e.printStackTrace();
//        }
//
//        response.getWriter().write(result.toString());
//    }
//}
package com.luntan.software.servlet;

import com.luntan.software.dao.ReplyDao;
import com.luntan.software.dao.UserDao; // 新增：导入用户DAO
import com.luntan.software.model.User; // 新增：导入用户模型
import com.alibaba.fastjson.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // 新增：导入Session
import java.io.IOException;
import java.text.SimpleDateFormat; // 新增：导入时间格式化
import java.util.Date; // 新增：导入日期类

@WebServlet("/SendReplyServlet")
public class SendReplyServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        JSONObject result = new JSONObject();
        HttpSession session = request.getSession(); // 新增：获取Session
        User currentUser = (User) session.getAttribute("currentUser"); // 新增：从Session获取当前用户

        try {
            String content = request.getParameter("content");
            String targetMsgIdStr = request.getParameter("targetMsgId");
            String userIdStr = request.getParameter("userId");

            if (content == null || targetMsgIdStr == null || userIdStr == null || currentUser == null) { // 补充currentUser判空
                result.put("success", false);
                result.put("msg", "参数不完整或未登录");
                response.getWriter().write(result.toString());
                return;
            }

            int targetMsgId = Integer.parseInt(targetMsgIdStr);
            int userId = Integer.parseInt(userIdStr);

            // 新增：1. 生成回复的创建时间（格式化）
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            String createTime = sdf.format(new Date());

            // 新增：2. 获取当前用户的昵称/编号（从Session直接取，无需查库，更高效）
            String username = currentUser.getUsername();
            String userCode = currentUser.getUserCode();

            ReplyDao replyDao = new ReplyDao();
            boolean isSuccess = replyDao.saveReply(userId, targetMsgId, content);

            if (isSuccess) {
                result.put("success", true);
                result.put("msg", "回复成功");
                // 新增：3. 构造新回复的完整数据，返回给前端
                JSONObject newReply = new JSONObject();
                newReply.put("content", content);
                newReply.put("username", username);
                newReply.put("userCode", userCode);
                newReply.put("time", createTime);
                newReply.put("targetMsgId", targetMsgId); // 关联的主消息ID
                result.put("newReply", newReply); // 将新回复数据放入返回结果
            } else {
                result.put("success", false);
                result.put("msg", "回复失败");
            }
        } catch (NumberFormatException e) {
            result.put("success", false);
            result.put("msg", "ID格式错误");
            e.printStackTrace();
        } catch (Exception e) {
            result.put("success", false);
            result.put("msg", "服务器错误");
            e.printStackTrace();
        }

        response.getWriter().write(result.toString());
    }
}