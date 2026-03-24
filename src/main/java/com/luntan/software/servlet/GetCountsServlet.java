package com.luntan.software.servlet;

import com.luntan.software.dao.LikeDao;
import com.luntan.software.dao.CollectDao;
import com.alibaba.fastjson.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/GetCountsServlet")
public class GetCountsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String msgIdsStr = req.getParameter("msgIds");
        if (msgIdsStr == null || msgIdsStr.isEmpty()) {
            resp.getWriter().write("{}");
            return;
        }

        String[] msgIdArr = msgIdsStr.split(",");
        JSONObject result = new JSONObject();
        LikeDao likeDao = new LikeDao();
        CollectDao collectDao = new CollectDao();

        for (String idStr : msgIdArr) {
            try {
                int msgId = Integer.parseInt(idStr);
                // 查询点赞数
                int likeCount = likeDao.getLikeCountByMessageId(msgId);
                // 查询收藏数
                int collectCount = collectDao.getCollectCountByMessageId(msgId);
                // 封装结果
                JSONObject counts = new JSONObject();
                counts.put("like", likeCount);
                counts.put("collect", collectCount);
                result.put(idStr, counts);
            } catch (NumberFormatException e) {
                continue; // 忽略无效ID
            }
        }

        resp.getWriter().write(result.toString());
    }
}