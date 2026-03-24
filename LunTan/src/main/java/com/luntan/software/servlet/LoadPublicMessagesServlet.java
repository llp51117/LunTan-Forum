//
//package com.luntan.software.servlet;
//
//import com.luntan.software.dao.MessageDao;
//import com.luntan.software.dao.LikeDao;
//import com.luntan.software.dao.CollectDao;
//import com.luntan.software.dao.ReplyDao;
//import com.luntan.software.model.Message;
//import com.luntan.software.model.Reply;
//import com.luntan.software.model.User;
//import com.alibaba.fastjson.JSONObject;
//import com.alibaba.fastjson.JSONArray;
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import jakarta.servlet.http.HttpSession;
//
//import java.io.IOException;
//import java.util.List;
//
///**
// * 加载公共消息Servlet（简化版）
// * 包含：消息列表、点赞/收藏状态、回复列表
// */
//@WebServlet("/LoadPublicMessagesServlet")
//public class LoadPublicMessagesServlet extends HttpServlet {
//    @Override
//    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
//        // 1. 基础配置：解决中文乱码 + 获取当前登录用户ID
//        response.setContentType("application/json;charset=UTF-8");
//        HttpSession session = request.getSession();
//        User currentUser = (User) session.getAttribute("currentUser");
//        int currentUserId = currentUser != null ? currentUser.getUserId() : -1; // 未登录为-1
//
//        // 2. 核心：查询公共消息列表（先查消息，再处理其他数据）
//        MessageDao messageDao = new MessageDao();
//        List<Message> publicMessages = messageDao.getPublicMessages();
//        if (publicMessages == null || publicMessages.isEmpty()) {
//            response.getWriter().write("[]"); // 无消息返回空数组
//            return;
//        }
//
//        // 3. 实例化各DAO（只实例化一次，避免循环内重复创建）
//        LikeDao likeDao = new LikeDao();
//        CollectDao collectDao = new CollectDao();
//        ReplyDao replyDao = new ReplyDao();
//
//
//
//
//        // 4. 构建返回的JSON数组（使用FastJSON简化拼接，避免手动拼字符串）
//        JSONArray messageArray = new JSONArray();
//        for (Message msg : publicMessages) {
//            JSONObject msgJson = new JSONObject();
//            // 消息基础信息
//            msgJson.put("id", msg.getId());
//            msgJson.put("content", msg.getContent());
//            msgJson.put("username", msg.getUsername());
//
//            // 点赞相关：点赞数 + 当前用户点赞状态
//            msgJson.put("likeCount", likeDao.getLikeCountByMessageId(msg.getId()));
//            msgJson.put("isLiked", likeDao.isLiked(currentUserId, msg.getId()));
//
//            // 收藏相关：收藏数 + 当前用户收藏状态
//            msgJson.put("collectCount", collectDao.getCollectCountByMessageId(msg.getId()));
//            msgJson.put("isCollected", collectDao.isCollected(currentUserId, msg.getId()));
//
//            // 回复相关：查询并添加回复列表（解决刷新后回复消失的核心）
//            List<Reply> replies = replyDao.getRepliesByMsgId(msg.getId());
//            msgJson.put("replies", replies); // 直接把回复列表转JSON
//            msgJson.put("replyCount", replies.size()); // 回复数量（前端可直接用）
//
//            // 将单条消息加入数组
//            messageArray.add(msgJson);
//        }
//
//        // 5. 返回最终的JSON数据给前端
//        response.getWriter().write(messageArray.toJSONString());
//    }
//
//    // POST请求复用GET逻辑（前端用POST请求时也能正常返回）
//    @Override
//    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
//        doGet(request, response);
//    }
//}
package com.luntan.software.servlet;

import com.luntan.software.dao.MessageDao;
import com.luntan.software.dao.LikeDao;
import com.luntan.software.dao.CollectDao;
import com.luntan.software.dao.ReplyDao;
import com.luntan.software.model.Message;
import com.luntan.software.model.Reply;
import com.luntan.software.model.User;
import com.alibaba.fastjson.JSONObject;
import com.alibaba.fastjson.JSONArray;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * 加载公共消息Servlet（最终修复版）
 * 包含：补全userId/time字段、标准返回格式、点赞/收藏/回复数据
 */
@WebServlet("/LoadPublicMessagesServlet")
public class LoadPublicMessagesServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
//        const contextPath = '/LunTan'; // 从Tomcat启动日志中找"Context path"
//        const url = contextPath + '/LoadPublicMessagesServlet';
        // 1. 基础配置：解决中文乱码 + 获取当前登录用户ID
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        int currentUserId = currentUser != null ? currentUser.getUserId() : -1; // 未登录为-1

        // 最终返回的结果对象（标准格式：success + messages + msg）
        JSONObject result = new JSONObject();

        try {
            // 2. 核心：查询公共消息列表
            MessageDao messageDao = new MessageDao();
            List<Message> publicMessages = messageDao.getPublicMessages();

            // 新增：打印Servlet接收到的消息数量
            System.out.println("【Servlet】接收到的消息数量：" + publicMessages.size());

            // 3. 构建消息JSON数组
            JSONArray messageArray = new JSONArray();
            if (publicMessages != null && !publicMessages.isEmpty()) {
                // 实例化各DAO（只创建一次，提升性能）
                LikeDao likeDao = new LikeDao();
                CollectDao collectDao = new CollectDao();
                ReplyDao replyDao = new ReplyDao();

                for (Message msg : publicMessages) {
                    // 直接使用上面创建的DAO对象，而非每次new
                    JSONObject msgJson = new JSONObject();
                    // ========== 关键修复：补全前端必需的字段 ==========
                    msgJson.put("id", msg.getId()); // 消息ID
                    msgJson.put("userId", msg.getUserId()); // 发布者ID（前端isSelf判断的核心）
                    msgJson.put("content", msg.getContent()); // 消息内容
                    msgJson.put("username", msg.getUsername()); // 发布者用户名
                    // 容错：如果time为null，赋值为空字符串，避免前端undefined
                    msgJson.put("time", msg.getTime() == null ? "" : msg.getTime());
//                    msgJson.put("time", msg.getTime()); // 发布时间（前端排序的核心）
                    msgJson.put("userCode", msg.getUserCode()); // 保留你原有字段（如果有）

                    // 点赞相关
                    msgJson.put("likeCount", likeDao.getLikeCountByMessageId(msg.getId()));
                    msgJson.put("isLiked", likeDao.isLiked(currentUserId, msg.getId()));

                    // 收藏相关
                    msgJson.put("collectCount", collectDao.getCollectCountByMessageId(msg.getId()));
                    msgJson.put("isCollected", collectDao.isCollected(currentUserId, msg.getId()));

                    // 回复相关
                    List<Reply> replies = replyDao.getRepliesByMsgId(msg.getId());
                    msgJson.put("replies", replies); // 回复列表
                    msgJson.put("replyCount", replies.size()); // 回复数
//                    msgJson.put("userCode", msg.getUserCode()); // 保留你原有字段

                    messageArray.add(msgJson);
                }
            }

            // 4. 设置返回结果（标准格式，适配前端）
            result.put("success", true);
            result.put("messages", messageArray);
            result.put("msg", "加载成功");

        } catch (Exception e) {
            // 异常处理：返回失败状态
            result.put("success", false);
            result.put("messages", new JSONArray());
            result.put("msg", "加载失败：" + e.getMessage());
            e.printStackTrace();
        }

        // 5. 发送最终的JSON数据给前端
        response.getWriter().write(result.toJSONString());
    }

    // POST请求复用GET逻辑
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        doGet(request, response);
    }
}