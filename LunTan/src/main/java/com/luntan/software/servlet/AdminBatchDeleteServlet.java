//package com.luntan.software.servlet;
//
//import com.luntan.software.dao.ReplyDao;
//import com.luntan.software.dao.LikeDao;
//import com.luntan.software.dao.CollectDao;
//import com.luntan.software.dao.MessageDao; // 新增：导入MessageDao
//import com.luntan.software.dao.DatabaseUtil; // 确保导入数据库工具类（如果需要）
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import java.io.IOException;
//
//@WebServlet("/AdminBatchDeleteServlet")
//public class AdminBatchDeleteServlet extends HttpServlet {
//    private ReplyDao replyDao = new ReplyDao();
//    private LikeDao likeDao = new LikeDao();
//    private CollectDao collectDao = new CollectDao();
//
//    @Override
//    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
//        request.setCharacterEncoding("UTF-8");
//        response.setContentType("text/plain;charset=UTF-8");
//
//        String idsStr = request.getParameter("ids");
//        String type = request.getParameter("type");
//        String userId = request.getParameter("userId");
//
//        if (idsStr == null || idsStr.trim().isEmpty() || type == null) {
//            response.getWriter().print("批量删除失败：参数为空");
//            return;
//        }
//
//        String[] ids = idsStr.split(",");
//        int successCount = 0;
//
//        try {
//            switch (type) {
//                case "message": // 新增：支持批量删除评论
//                    for (String id : ids) {
//                        int msgId = Integer.parseInt(id.trim());
//                        // 假设MessageDao有deleteMessage方法（和单个删除一致）
//                        if (new com.luntan.software.dao.MessageDao().deleteMessage(msgId)) {
//                            successCount++;
//                        }
//                    }
//                    break;
//                case "reply":
//                    for (String id : ids) {
//                        if (replyDao.deleteReply(Integer.parseInt(id.trim()))) {
//                            successCount++;
//                        }
//                    }
//                    break;
//                case "like":
//                    for (String id : ids) {
//                        // 调用LikeDao中按点赞ID删除的方法（之前被注释）
//                        if (likeDao.deleteLike(Integer.parseInt(id.trim()))) {
//                            successCount++;
//                        }
//                    }
//                    break;
//                case "collect":
//                    for (String id : ids) {
//                        // 调用CollectDao中按收藏ID删除的方法（之前被注释）
//                        if (collectDao.deleteCollectById(Integer.parseInt(id.trim()))) {
//                            successCount++;
//                        }
//                    }
//                    break;
//                default:
//                    response.getWriter().print("批量删除失败：不支持的操作类型");
//                    return;
//            }
//            response.getWriter().print("批量删除成功：共删除" + successCount + "条记录（总计选择" + ids.length + "条）");
//        } catch (NumberFormatException e) {
//            response.getWriter().print("批量删除失败：ID格式错误");
//        } catch (Exception e) {
//            e.printStackTrace();
//            response.getWriter().print("批量删除失败：服务器内部错误（" + e.getMessage() + "）");
//        }
//    }
//}

package com.luntan.software.servlet;

import com.luntan.software.dao.ReplyDao;
import com.luntan.software.dao.LikeDao;
import com.luntan.software.dao.CollectDao;
import com.luntan.software.dao.MessageDao;
// 删掉无用的DatabaseUtil导入（标灰说明没用到）
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/AdminBatchDeleteServlet")
public class AdminBatchDeleteServlet extends HttpServlet {
    private ReplyDao replyDao = new ReplyDao();
    private LikeDao likeDao = new LikeDao();
    private CollectDao collectDao = new CollectDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");

        String idsStr = request.getParameter("ids");
        String type = request.getParameter("type");
        String userId = request.getParameter("userId");

        // 1. 基础参数校验（原有逻辑）
        if (idsStr == null || idsStr.trim().isEmpty() || type == null) {
            response.getWriter().print("批量删除失败：参数为空");
            return;
        }

        String[] ids = idsStr.split(",");
        int successCount = 0;
        // 新增：记录无效ID，方便排查
        StringBuilder invalidIds = new StringBuilder();

        try {
            switch (type) {
                case "message": // 评论删除
                    for (String id : ids) {
                        // 2. 新增：空ID/空白ID校验
                        String trimId = id.trim();
                        if (trimId.isEmpty()) {
                            invalidIds.append(id).append(",");
                            continue; // 跳过空ID
                        }
                        try {
                            int msgId = Integer.parseInt(trimId);
                            if (new MessageDao().deleteMessage(msgId)) { // 简化写法（已导入MessageDao）
                                successCount++;
                            }
                        } catch (NumberFormatException e) {
                            // 3. 新增：单个ID格式错误时，记录并继续（不中断批量删除）
                            invalidIds.append(id).append("(格式错误),");
                        }
                    }
                    break;

                case "reply": // 回复删除
                    for (String id : ids) {
                        String trimId = id.trim();
                        if (trimId.isEmpty()) {
                            invalidIds.append(id).append(",");
                            continue;
                        }
                        try {
                            if (replyDao.deleteReply(Integer.parseInt(trimId))) {
                                successCount++;
                            }
                        } catch (NumberFormatException e) {
                            invalidIds.append(id).append("(格式错误),");
                        }
                    }
                    break;

                case "like": // 点赞删除
                    for (String id : ids) {
                        String trimId = id.trim();
                        if (trimId.isEmpty()) {
                            invalidIds.append(id).append(",");
                            continue;
                        }
                        try {
//                            if (likeDao.deleteLike(Integer.parseInt(trimId))) {
                            // 调用管理员专用的删除方法
                            if (likeDao.adminDeleteLike(Integer.parseInt(trimId))) {
                                successCount++;
                            }
                        } catch (NumberFormatException e) {
                            invalidIds.append(id).append("(格式错误),");
                        }
                    }
                    break;

                case "collect": // 收藏删除
                    for (String id : ids) {
                        String trimId = id.trim();
                        if (trimId.isEmpty()) {
                            invalidIds.append(id).append(",");
                            continue;
                        }
                        try {
//                            if (collectDao.deleteCollectById(Integer.parseInt(trimId))) {
                            if (collectDao.adminDeleteCollect(Integer.parseInt(trimId))) {
                                successCount++;
                            }
                        } catch (NumberFormatException e) {
                            invalidIds.append(id).append("(格式错误),");
                        }
                    }
                    break;

                default:
                    response.getWriter().print("批量删除失败：不支持的操作类型[" + type + "]");
                    return;
            }

            // 4. 新增：返回更详细的结果（包含无效ID提示）
            String resultMsg = "批量删除成功：共删除" + successCount + "条记录（总计选择" + ids.length + "条）";
            if (invalidIds.length() > 0) {
                resultMsg += "；无效ID：" + invalidIds.substring(0, invalidIds.length() - 1);
            }
            response.getWriter().print(resultMsg);

        } catch (Exception e) {
            // 全局异常（非ID格式错误）
            e.printStackTrace();
            response.getWriter().print("批量删除失败：服务器内部错误（" + e.getMessage() + "）");
        }
    }
}