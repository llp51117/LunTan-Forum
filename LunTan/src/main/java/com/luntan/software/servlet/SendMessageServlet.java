package com.luntan.software.servlet;
import java.net.URLDecoder; // 新增
import com.luntan.software.dao.MessageDao;
import com.alibaba.fastjson.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * 处理消息发送请求（支持公共消息和私聊消息）
 */
@WebServlet("/SendMessageServlet") // 前端请求路径，必须与前端fetch的路径一致
public class SendMessageServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 确保 SendMessageServlet 插入 message 表时，只使用表中存在的字段：
        String sql = "INSERT INTO message (user_id, content, type, create_time) " +
                "VALUES (?, ?, 'public', NOW())";
// 字段对应：user_id, content, type, create_time（与表结构一致）
        // 设置响应格式为JSON，解决中文乱码
        response.setContentType("application/json;charset=UTF-8");
        JSONObject result = new JSONObject(); // 用于返回结果给前端

        try {
            // 1. 获取前端传递的参数
            String content = request.getParameter("content"); // 消息内容
            String userIdStr = request.getParameter("userId"); // 发送者ID
            String friendIdStr = request.getParameter("friendId"); // 接收者ID（私聊时需要）

            // ===== 新增修改1：对content进行URL解码（适配前端的encodeURIComponent）=====
            if (content != null) {
                // 解码前端编码后的内容，避免特殊字符/中文乱码，同时保留用户输入的空格
                content = URLDecoder.decode(content, "UTF-8");
            }

            // 2. 参数校验
            if (content == null || content.trim().isEmpty()) {
                result.put("success", false);
                result.put("msg", "消息内容不能为空");
                response.getWriter().write(result.toString());
                return;
            }

            if (userIdStr == null || userIdStr.trim().isEmpty()) {
                result.put("success", false);
                result.put("msg", "发送者ID不存在，请重新登录");
                response.getWriter().write(result.toString());
                return;
            }

            // 转换用户ID为整数
            int userId = Integer.parseInt(userIdStr);
            Integer friendId = null;
            if (friendIdStr != null && !friendIdStr.trim().isEmpty()) {
                friendId = Integer.parseInt(friendIdStr); // 私聊时才解析接收者ID
            }

            // 3. 保存消息到数据库（通过MessageDao）
            MessageDao messageDao = new MessageDao();
            boolean isSuccess;

            if (friendId != null) {
                // 私聊消息（type为"private"）
                isSuccess = messageDao.savePrivateMessage(userId, friendId, content);
            } else {
                // 公共消息（type为"public"）
                isSuccess = messageDao.savePublicMessage(userId, content);
            }

            // 4. 返回结果给前端
            if (isSuccess) {
                result.put("success", true);
                result.put("msg", "消息发送成功");
            } else {
                result.put("success", false);
                result.put("msg", "消息发送失败，请重试");
            }

        } catch (NumberFormatException e) {
            // 处理ID格式错误（非数字）
            result.put("success", false);
            result.put("msg", "用户ID格式错误");
            e.printStackTrace();
        } catch (Exception e) {
            // 处理其他异常（如数据库连接失败）
            result.put("success", false);
            result.put("msg", "服务器错误，请稍后再试");
            e.printStackTrace();
        }

        // 发送JSON结果给前端
        response.getWriter().write(result.toString());
    }

    // 允许GET请求（可选，实际开发中建议用POST，这里仅为兼容）
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        doPost(request, response);

    }
}