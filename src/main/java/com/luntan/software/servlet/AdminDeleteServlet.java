import com.luntan.software.dao.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/AdminDeleteServlet")
public class AdminDeleteServlet extends HttpServlet {
    // 初始化所有需要的DAO
    private UserDao userDao = new UserDao();
    private MessageDao messageDao = new MessageDao(); // 评论DAO
    private ReplyDao replyDao = new ReplyDao();     // 回复DAO
    private LikeDao likeDao = new LikeDao();       // 点赞DAO
    private CollectDao collectDao = new CollectDao(); // 收藏DAO
    // AdminDeleteServlet.java
    private FriendRelationDao friendRelationDao = new FriendRelationDao(); // 新增这行

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");

        // 1. 获取前端传递的参数（与前端保持一致：id=删除目标ID，type=删除类型，userId=管理员ID）
        String targetIdStr = request.getParameter("id");       // 要删除的目标ID（评论/回复/点赞/收藏/用户ID）
        String adminIdStr = request.getParameter("userId");    // 管理员ID（前端必传）
        String type = request.getParameter("type");            // 删除类型：message/reply/like/collect/user

        // 2. 基础参数验证
        if (targetIdStr == null || targetIdStr.trim().isEmpty()) {
            response.getWriter().print("删除失败：目标ID不能为空");
            return;
        }
        if (adminIdStr == null || adminIdStr.trim().isEmpty()) {
            response.getWriter().print("删除失败：管理员ID不能为空");
            return;
        }
        if (type == null || type.trim().isEmpty()) {
            response.getWriter().print("删除失败：删除类型不能为空");
            return;
        }

        // 3. 转换ID为数字
        int targetId; // 要删除的目标ID
        int adminId;  // 管理员ID
        try {
            targetId = Integer.parseInt(targetIdStr.trim());
            adminId = Integer.parseInt(adminIdStr.trim());
        } catch (NumberFormatException e) {
            response.getWriter().print("删除失败：ID格式错误（必须是数字）");
            return;
        }

        // 4. 执行删除逻辑（保留用户删除，新增其他类型）
        boolean success = false;
        try {
            switch (type) {
                case "user":
                    // ========== 新增：先删除该用户的所有关联数据 ==========
                    // ========== 新增：先删该用户的好友关系 ==========
                    friendRelationDao.deleteByUserId(targetId);
                    // 1. 删除该用户发布的所有评论
                    messageDao.deleteMessagesByUserId(targetId);
                    // 2. 删除该用户发布的所有回复
                    replyDao.deleteRepliesByUserId(targetId);
                    // 3. 删除该用户的所有点赞记录
                    likeDao.deleteLikesByUserId(targetId);
                    // 4. 删除该用户的所有收藏记录
                    collectDao.deleteCollectsByUserId(targetId);
                    // ========== 原有逻辑：最后删除用户 ==========
                    success = userDao.deleteUser(targetId);
                    break;
                case "message":
                    // 新增：删除评论（调用MessageDao的删除方法）
                    success = messageDao.deleteMessage(targetId);
                    break;
                case "reply":
                    // 新增：删除回复（调用ReplyDao的删除方法）
                    success = replyDao.deleteReply(targetId);
                    break;
                case "like":
                    // 新增：删除点赞（调用LikeDao的删除方法）
//                    success = likeDao.deleteLike(targetId);
                    success = likeDao.adminDeleteLike(targetId);
                    break;
                case "collect":
                    // 新增：删除收藏（调用CollectDao的删除方法）
//                    success = collectDao.deleteCollect(targetId);
                    // 管理员删除收藏：调用按收藏ID删除的方法
//                    success = collectDao.deleteCollectById(targetId);
                    success = collectDao.adminDeleteCollect(targetId);
                    break;
                default:
                    response.getWriter().print("删除失败：暂不支持该类型的删除");
                    return; // 不支持的类型直接返回，无需后续处理
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().print("删除失败：服务器内部错误（" + e.getMessage() + "）");
            return;
        }

        // 5. 返回删除结果
        if (success) {
            response.getWriter().print("删除成功");
        } else {
            response.getWriter().print("删除失败：目标不存在或已被删除");
        }
    }
}