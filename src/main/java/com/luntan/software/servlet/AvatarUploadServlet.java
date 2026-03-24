package com.luntan.software.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

// 改成简单好记的路径
@WebServlet("/AvatarUploadServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class AvatarUploadServlet extends HttpServlet {
    private static final String SAVE_DIR = "avatar";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        // 1. 创建保存文件夹
        String appPath = request.getServletContext().getRealPath("");
        String savePath = appPath + File.separator + SAVE_DIR;
        File fileSaveDir = new File(savePath);
        if (!fileSaveDir.exists()) {
            fileSaveDir.mkdir();
        }

        // 2. 获取上传文件
        Part part = request.getPart("avatar");
        if (part == null || part.getSize() == 0) {
            response.getWriter().write("{\"success\":false,\"msg\":\"请选择图片文件\"}");
            return;
        }

        // 3. 生成唯一文件名
        String fileName = part.getSubmittedFileName();
        String newFileName = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()) + "-" + fileName;

        // 4. 保存文件
        part.write(savePath + File.separator + newFileName);

        // 5. 返回结果
        String avatarUrl = request.getContextPath() + "/" + SAVE_DIR + "/" + newFileName;
        response.getWriter().write("{\"success\":true,\"msg\":\"上传成功\",\"avatarUrl\":\"" + avatarUrl + "\"}");
    }
}