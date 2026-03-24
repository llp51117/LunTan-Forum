package com.luntan.software.servlet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.alibaba.fastjson.JSON;
import com.luntan.software.dao.FriendRelationDao;
import com.luntan.software.model.FriendRelation;
import com.luntan.software.model.User;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/LoadFriendsServlet")
public class LoadFriendsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            User currentUser = (User) request.getSession().getAttribute("currentUser");
            if (currentUser == null) {
                System.out.println("LoadFriendsServlet: 用户未登录");
                out.write("[]");
                return;
            }

            int userId = currentUser.getUserId();
            System.out.println("=== LoadFriendsServlet ===");
            System.out.println("用户ID: " + userId);

            FriendRelationDao friendDao = new FriendRelationDao();
            List<FriendRelation> friends = friendDao.getFriendsByUserId(userId);

            System.out.println("Dao返回好友数量: " + friends.size());

            List<Map<String, Object>> friendList = new ArrayList<>();
            for (FriendRelation fr : friends) {
                Map<String, Object> friend = new HashMap<>();
                friend.put("friendId", fr.getFriendId());
                friend.put("username", fr.getUsername());
                friend.put("userCode", fr.getUserCode());
                friendList.add(friend);
            }

            String json = JSON.toJSONString(friendList);
            System.out.println("返回JSON: " + json);
            out.write(json);

        } catch (Exception e) {
            System.out.println("❌ LoadFriendsServlet 异常: " + e.getMessage());
            e.printStackTrace();
            out.write("[]");
        }
    }
}