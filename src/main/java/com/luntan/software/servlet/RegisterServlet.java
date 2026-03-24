package com.luntan.software.servlet;

//package com.yourcompany.luntan.servlet;

import com.luntan.software.dao.UserDao;
import com.luntan.software.model.User;
//import javax.servlet.ServletException;
//import javax.servlet.annotation.WebServlet;
//import javax.servlet.http.HttpServlet;
//import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;
//import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;


// 注册Servlet：处理注册请求，映射路径为 /RegisterServlet
@WebServlet("/pages/register")
public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 解决中文乱码
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // 2. 获取表单参数（与表单name属性完全一致）
        String userCode = request.getParameter("userCode");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String identity = request.getParameter("identity");
        System.out.println("接收参数：userCode=" + userCode + ", username=" + username + ", password=" + password + ", identity=" + identity);

        // 3. 基础校验（密码不一致则返回注册页）
        if (userCode == null || username == null || password == null || !password.equals(confirmPassword)) {
            request.setAttribute("error", "参数错误或密码不一致");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // 4. 调用DAO层插入数据
        UserDao userDao = new UserDao();
        User newUser = new User();
        newUser.setUserCode(userCode);
        newUser.setUsername(username);
        newUser.setPassword(password); // 若加密：BCrypt.hashpw(password, BCrypt.gensalt())
        newUser.setIdentity(identity);

        boolean isInsertSuccess = userDao.registerUser(newUser); // 执行入库操作

        // 5. 根据入库结果跳转
        if (isInsertSuccess) {
            // 注册成功→跳登录页，路径需与login.jsp的实际位置一致
            response.sendRedirect(request.getContextPath() + "/pages/login.jsp");

        } else {
            // 注册失败→返回注册页
            request.setAttribute("error", "注册失败，请重试");
            request.getRequestDispatcher("/pages/register.jsp").forward(request, response);
        }
    }
}

