package com.luntan.software.servlet;
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

//public class MainPagesServlet {
//}
//public  class MainPagesServlet extends HttpServlet {
@WebServlet("/pages/main")
// 主页Servlet：处理跳转主页请求，映射路径为 /MainPagesServlet
public class MainPagesServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 检查用户是否登录
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            System.out.println("用户未登录，重定向到登录页");
            response.sendRedirect(request.getContextPath() + "/pages/login.jsp");
            return;
        }
        // 已登录，转发到主界面JSP
//        request.getRequestDispatcher("/pages/main.jsp").forward(request, response);
        request.getRequestDispatcher("/pages/main.jsp").forward(request, response);
    }
}