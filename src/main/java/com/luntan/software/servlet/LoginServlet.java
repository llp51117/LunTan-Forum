package com.luntan.software.servlet;

//import com.google.gson.Gson; // 新增：导入Gson
import com.luntan.software.dao.UserDao;
import com.luntan.software.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

// 映射路径：表单提交的action需对应此路径（与login.jsp中的<form action>一致）
@WebServlet("/pages/login") // 或在web.xml中配置<url-pattern>/pages/login</url-pattern>
public class LoginServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();// 初始化用户数据访问层
//    private final Gson gson = new Gson(); // 新增：创建Gson对象（用于转JSON）
    // 处理POST请求：验证登录逻辑（表单提交时触发）
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        // 1. 获取表单提交的参数
        String userCode = request.getParameter("userCode"); // 用户编号
        String password = request.getParameter("password"); // 密码
        String identity = request.getParameter("identity"); // 身份（个人/游客）

        // 2. 管理员登录逻辑（特殊处理）
        if ("admin".equals(identity)) {
            // 管理员身份查询逻辑
//            user = userDao.login(userCode, password, "admin");
            if ("管理员".equals(userCode) && "741852".equals(password)) {
                User admin = new User();
                admin.setUserCode("管理员");
                admin.setUsername("管理员");
                admin.setIdentity("admin"); // 标记为管理员身份
                admin.setUserId(1); // 新增：给管理员设置非空ID，解决前端登录判断
                // 存储管理员信息到Session
                request.getSession().setAttribute("currentUser", admin);
                // 修改：重定向改为转发，保留request参数
                request.getRequestDispatcher("/pages/admin_main.jsp").forward(request, response);
                return;
                // 跳转到管理员主页面（注意页面命名与实际文件名一致，建议用admin_main.jsp）
//                response.sendRedirect(request.getContextPath() + "/pages/admin_main.jsp");
//                return; // 结束方法，避免执行后续普通用户逻辑+
            } else {
                // 新增：管理员密码错误的提示（可选）
                request.setAttribute("errorMessage", "管理员账号或密码错误！");
                request.getRequestDispatcher("/pages/login.jsp").forward(request, response);
                return;
            }
        }
        // 3. 普通用户登录逻辑（需验证身份匹配）
        // 从数据库查询用户（通过编号和密码）
//        User user = userDao.findByCodeAndPassword(userCode, password);
            User user = userDao.login(userCode, password, identity);
        // 调试信息（方便排查问题，上线后可删除）
        System.out.println("=== 登录调试 ===");
        System.out.println("用户编号: " + userCode);
        System.out.println("提交的身份: " + identity);
        System.out.println("数据库查询到的用户: " + (user != null ? user.getUsername() : "null"));

        // 验证条件：用户存在 + 身份匹配（表单选择的身份与数据库中用户身份一致）
        if (user != null && user.getIdentity().equals(identity)) {
            // 登录成功：存储用户信息到Session（供后续页面使用）
            request.getSession().setAttribute("currentUser", user);
            // 跳转到普通用户主页面（确保main.jsp存在于/pages目录下）
            response.sendRedirect(request.getContextPath() + "/pages/main.jsp");
        } else {
            // 登录失败：返回登录页并提示错误
            if (user == null) {
                // 用户不存在或密码错误
                request.setAttribute("errorMessage", "用户编号或密码错误！");
            } else {
                // 身份不匹配（比如表单选了"个人"，但数据库中是"游客"）
                request.setAttribute("errorMessage", "身份选择与账号不符！");
            }
            // 转发回登录页（保留错误信息）
            request.getRequestDispatcher("/pages/login.jsp").forward(request, response);
        }
    }
}