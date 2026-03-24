//package com.luntan.software.servlet;
//import com.luntan.software.dao.UserDao;
//import com.luntan.software.model.User;
//import jakarta.servlet.ServletException;
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import java.io.IOException;
//import java.io.PrintWriter;
//import java.util.List;
//@WebServlet("/pages/admin/search")
//public class AdminSearchUserServlet extends HttpServlet {
//    private UserDao userDao = new UserDao();
//    @Override
//    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//        // 设置响应格式为JSON
//        response.setContentType("application/json;charset=UTF-8");
//        PrintWriter out = response.getWriter();
//        String keyword = request.getParameter("keyword");
//        if (keyword == null) keyword = "";
//
//        // 获取当前登录用户的ID（用于排除自身）
//        User currentUser = (User) request.getSession().getAttribute("currentUser");
//        int excludeUserId = currentUser.getUserId();
//
//        // 从数据库查询用户列表（传入两个参数）
//        UserDao userDao = new UserDao();
//        List<User> users = userDao.searchUsers(keyword, excludeUserId);
//
//
//        // 手动拼接JSON字符串（替代Jackson的序列化）
//        StringBuilder json = new StringBuilder("[");
//        for (int i = 0; i < users.size(); i++) {
//            User user = users.get(i);
//            json.append("{");
//            json.append("\"userId\":").append(user.getUserId()).append(",");
//            json.append("\"userCode\":\"").append(escapeJson(user.getUserCode())).append("\",");
//            json.append("\"username\":\"").append(escapeJson(user.getUsername())).append("\",");
//            json.append("\"identity\":\"").append(escapeJson(user.getIdentity())).append("\"");
//            json.append("}");
//            if (i < users.size() - 1) {
//                json.append(",");
//            }
//        }
//        json.append("]");
//
//        out.write(json.toString());
//        out.close();
//    }
//
//    // 辅助方法：转义JSON中的特殊字符（如双引号、换行等）
//    private String escapeJson(String str) {
//        if (str == null) return "null";
//        return str.replace("\"", "\\\"")
//                .replace("\n", "\\n")
//                .replace("\r", "\\r")
//                .replace("\t", "\\t");
//    }
//}
package com.luntan.software.servlet;

import com.luntan.software.dao.UserDao;
import com.luntan.software.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * 管理员搜索用户Servlet
 * 路径：/pages/admin/search
 * 功能：按关键词（编号/昵称）搜索用户，排除管理员自身，返回JSON格式用户列表
 */
@WebServlet("/pages/admin/search")
public class AdminSearchUserServlet extends HttpServlet {
    // 全局DAO实例，避免每次请求重复创建
    private UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 设置请求和响应的编码，避免中文乱码
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 2. 获取前端传入的搜索关键词（为空则赋值空字符串）
        String keyword = request.getParameter("keyword");
        // 打印关键词到控制台，确认参数是否正确接收
        System.out.println("管理员搜索关键词：" + keyword);

//        List<User> userList = userDao.searchUserByKeyword(keyword);
        // 打印查询结果数量，确认数据库是否有匹配数据

        if (keyword == null || keyword.trim().isEmpty()) {
            keyword = "";
        } else {
            keyword = keyword.trim(); // 去除首尾空格
        }

        // 3. 获取当前登录的管理员用户，用于排除自身（避免搜索到自己）
        User currentAdmin = (User) request.getSession().getAttribute("currentUser");
        int excludeUserId = -1; // 默认-1（未登录时无排除）
        if (currentAdmin != null) {
            excludeUserId = currentAdmin.getUserId();
            // 控制台打印调试信息（可选，方便开发排查）
            System.out.println("管理员ID：" + excludeUserId + "，搜索关键词：" + keyword);
        }

        // 4. 调用DAO层方法，查询符合条件的用户列表
        List<User> userList = userDao.searchUsers(keyword, excludeUserId);
        System.out.println("搜索到的用户数量：" + userList.size());
        // 5. 手动拼接JSON字符串（无需依赖FastJSON，避免jar包问题）
        StringBuilder jsonBuilder = new StringBuilder("[");
        for (int i = 0; i < userList.size(); i++) {
            User user = userList.get(i);
            jsonBuilder.append("{");
            // 拼接用户属性，注意转义特殊字符
            jsonBuilder.append("\"userId\":").append(user.getUserId()).append(",");
            jsonBuilder.append("\"userCode\":\"").append(escapeJson(user.getUserCode())).append("\",");
            jsonBuilder.append("\"username\":\"").append(escapeJson(user.getUsername())).append("\",");
            jsonBuilder.append("\"identity\":\"").append(escapeJson(user.getIdentity())).append("\"");
            jsonBuilder.append("}");
            // 最后一个元素后不加逗号，避免JSON格式错误
            if (i < userList.size() - 1) {
                jsonBuilder.append(",");
            }
        }
        jsonBuilder.append("]");

        // 6. 将JSON结果返回给前端

        out.print(jsonBuilder.toString());
        // 7. 关闭流（释放资源）
        out.flush();
        out.close();
    }

    /**
     * 辅助方法：转义JSON中的特殊字符，避免JSON格式错误
     * @param str 原始字符串
     * @return 转义后的字符串
     */
    private String escapeJson(String str) {
        if (str == null) {
            return ""; // 空值返回空字符串，避免JSON显示"null"
        }
        return str.replace("\"", "\\\"")
                .replace("\\", "\\\\")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}