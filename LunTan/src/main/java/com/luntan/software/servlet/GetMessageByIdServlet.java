package com.luntan.software.servlet; // 确保包路径正确

import com.luntan.software.dao.MessageDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.alibaba.fastjson.JSON; // 需导入fastjson依赖（或用其他JSON工具）

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/GetMessageByIdServlet")
public class GetMessageByIdServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        String messageIdStr = request.getParameter("messageId");

        // 处理messageId转换失败的情况
        if (messageIdStr == null || !messageIdStr.matches("\\d+")) {
            out.write("{\"content\":\"[参数错误]\",\"username\":\"未知用户\",\"userCode\":\"未知编号\"}");
            return;
        }

        int messageId = Integer.parseInt(messageIdStr);
        MessageDao messageDao = new MessageDao();
        // 调用查询评论+用户信息的方法（关键：之前调用的是getMessageById，只返回评论内容）
        Map<String, Object> messageInfo = messageDao.getMessageWithUser(messageId);

        // 确保返回的JSON包含所有必要字段
        if (messageInfo != null) {
            out.write(JSON.toJSONString(messageInfo));
        } else {
            // 空值兜底：避免前端字段缺失
            Map<String, String> defaultInfo = new HashMap<>();
            defaultInfo.put("content", "[该评论已删除]");
            defaultInfo.put("username", "未知用户");
            defaultInfo.put("userCode", "未知编号");
            out.write(JSON.toJSONString(defaultInfo));
        }
    }
}