<%--&lt;%&ndash;--%>
<%--      Created by IntelliJ IDEA.--%>
<%--      User: HP--%>
<%--      Date: 2025/11/1--%>
<%--      Time: 14:43--%>
<%--      To change this template use File | Settings | File Templates.--%>
<%--&ndash;%&gt;--%>
<%--<%@ page contentType="text/html;charset=UTF-8" language="java" %>--%>
<%--<%@ page import="com.luntan.software.model.User" %>--%>
<%--<%@ page import="com.alibaba.fastjson.JSON" %>--%>

<%--<%@ page contentType="text/html;charset=UTF-8" language="java" %>--%>
<%--<%@ page import="com.luntan.software.model.User" %>--%>
<%--<%@ page import="com.alibaba.fastjson.JSON" %>--%>
<%--<%@ page isELIgnored="false" %>--%>


<%--<body>--%>
<%--<%--%>
<%--    User currentUser = (User) session.getAttribute("currentUser");--%>
<%--//    if (currentUser == null) {--%>
<%--//        response.sendRedirect(request.getContextPath() + "/pages/login.jsp");--%>
<%--//        return;--%>
<%--//    }--%>
<%--%>--%>


<%--
  Created by IntelliJ IDEA.
  User: HP
  Date: 2025/11/1
  Time: 14:43
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.luntan.software.model.User" %>
<%@ page import="com.alibaba.fastjson.JSON" %>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>管理员主页面</title>
    <!-- 在admin_main.jsp的<head>中修改 -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/admin_main.css">

</head>
<body>
<%
    // 1. 先获取当前用户（必须放在最前面）
    User currentUser = (User) session.getAttribute("currentUser");
    // 3. 定义userJson变量（放在引用它的JS代码之前）
    String userJson = JSON.toJSONString(currentUser); // 转换为JSON字符串
%>
<!-- 顶部导航栏 -->
<div class="shang1"><h1>论坛管理员系统</h1></div>
<div class="zhong1">
    <!-- 左侧好友界面 -->
    <div class="friend-panel" id="friendPanel">
        <div class="friend-header">
            <input type="text" class="search-friend" id="searchFriend" placeholder="搜索好友（名称/编号）">
            <button class="delete-friend-btn" id="deleteFriendBtn">删除</button>
        </div>
        <!-- 搜索结果区域 -->
        <div class="search-result" id="searchResult">
            <!-- 搜索结果会动态插入这里 -->
        </div>
        <!-- 好友列表 -->
        <div class="friend-list" id="friendList">
            <!-- 好友会通过搜索添加动态插入这里 -->
        </div>
    </div>

    <!-- 中间聊天/管理界面 -->
    <div class="chat-panel" id="chatPanel">
        <!-- 聊天头部 -->
        <div class="chat-header">
            <div class="chat-title" id="chatTitle">公共界面</div>
        </div>
        <!-- 消息列表（默认显示） -->
        <div class="message-list" id="messageList"></div>
        <!-- 查询用户页面（默认隐藏） -->
        <div class="search-user-page" id="searchUserPage">
            <button class="back-btn" id="backToPublicBtn">返回公共界面</button>
            <div class="search-user-input-container">
                <input type="text" class="search-user-input" id="searchUserInput" placeholder="输入用户编号或昵称进行搜索...">
            </div>
            <!-- 用户列表会动态生成 -->
            <div class="user-list" id="userList"></div>
        </div>
        <!-- 用户详情页面（默认隐藏） -->
        <div class="user-detail-page" id="userDetailPage">
            <button class="back-btn" id="backToSearchBtn">返回用户列表</button>
            <div class="user-detail-header">
                <div class="user-detail-avatar" id="detailAvatar">用户</div>
                <div id="detailIdentity" style="margin: 5px 0;"></div> <!-- 用户身份 -->
                <div id="detailCreateTime" style="margin: 5px 0;"></div> <!-- 注册时间 -->
                <div class="user-detail-info" id="detailId">编号：</div>
                <div class="user-detail-info" id="detailName">昵称：</div>
                <button class="delete-btn" id="deleteUserBtn" style="display: none;">删除该用户</button>
            </div>
            <!-- 用户详情页标签栏（只保留这段，删除其他标签栏代码） -->
            <div class="user-detail-tabs">
                <div class="detail-tab active" data-tab="messages">发表评论</div>
                <div class="detail-tab" data-tab="replies">回复</div>
                <div class="detail-tab" data-tab="likes">点赞</div>
                <div class="detail-tab" data-tab="collects">收藏</div>
            </div>
            <!-- 1. 评论容器（核心：message对应messagesContent） -->
            <div id="messagesContent" class="detail-content active">
                    <!-- 删：style="display: none;" -->

                    <!-- 删：style="display: none;"，加margin-left让按钮和全选框分开 -->

            </div>

            <!-- 2. 回复容器 -->
            <div id="repliesContent" class="detail-content">
                    <!-- 删：style="display: none;" -->

                    <!-- 删：style="display: none;"，加margin-left -->
            </div>

            <!-- 3. 点赞容器 -->
            <div id="likesContent" class="detail-content">

                    <!-- 删：style="display: none;" -->

                    <!-- 删：style="display: none;"，加margin-left -->

            </div>

            <!-- 4. 收藏容器 -->
            <div id="collectsContent" class="detail-content">

                    <!-- 删：style="display: none;" -->

                    <!-- 删：style="display: none;"，加margin-left -->

           </div>

            <!-- 输入栏 -->
            <div class="input-area" id="inputArea">
                <input type="text" class="message-input" id="messageInput" placeholder="请输入消息..."/>
                <button class="send-btn" id="sendBtn">发送</button>
            </div>
        </div>
</div>
    <!-- 右侧功能栏 -->
    <div class="right-panel">
        <div class="user-info">
            <div class="user-avatar" id="userAvatar">管</div>
            <div>编号：管理员</div>
            <div>昵称：管理员</div>
        </div>
        <!--
        <button class="action-btn" id="changeAvatarBtn">换头像</button>
        <button class="action-btn" id="changeBgBtn">换背景</button>
        <button class="action-btn" id="collectBtn">我的收藏</button>
        <button class="action-btn" id="likeBtn">我的点赞</button>
        -->
        <!-- 157行附近插入退出登录按钮 -->
        <button class="action-btn" id="logoutBtn">退出登录</button>
        <button class="action-btn" id="adminActionBtn">管理员操作</button>
        <input type="text" class="action-btn" id="queryInput"  placeholder="查询（编号/昵称）" disabled/>
        <button class="action-btn" id="deleteActionBtn" disabled>删除（帖子/用户）</button>
        <div  class="password-group"   style="display: flex; gap: 5px;">
            <input type="password" class="action-btn" id="passwordInput" placeholder="输入密码执行" disabled/>
            <button class="action-btn" id="confirmBtn" disabled>确认</button>
        </div>
        <button class="action-btn" id="exitActionBtn" style="display: none;">返回公共界面</button>
    </div>
</div>
<!-- 评论查看弹窗 -->
<div class="modal" id="replyModal">
    <div class="modal-content">
        <div class="modal-title">全部评论</div>
        <div id="modalReplyList"></div>
        <div class="modal-btn-group">
            <button class="modal-btn modal-close" id="closeReplyModal">关闭</button>
        </div>
    </div>
</div>
<!-- 我的收藏/点赞弹窗 -->
<div class="modal" id="actionModal">
    <div class="modal-content">
        <div class="modal-title" id="actionModalTitle">我的收藏</div>
        <div id="actionModalContent"></div>
        <div class="modal-btn-group">
            <button class="modal-btn modal-close" id="closeActionModal">关闭</button>
        </div>
    </div>
</div>
</body>

<script type="text/javascript">
    // 全局DOM元素引用 - 修复：补充缺失的messageListPage/searchUserPage/userDetailPage等关键元素
    const elements = {
        friendList: document.getElementById('friendList'),
        searchFriend: document.getElementById('searchFriend'),
        searchResult: document.getElementById('searchResult'),
        deleteFriendBtn: document.getElementById('deleteFriendBtn'),

        messageInput: document.getElementById('messageInput'),
        sendBtn: document.getElementById('sendBtn'),
        collectBtn: document.getElementById('collectBtn'),
        likeBtn: document.getElementById('likeBtn'),
        adminActionBtn: document.getElementById('adminActionBtn'),
        queryInput: document.getElementById('queryInput'),
        deleteActionBtn: document.getElementById('deleteActionBtn'),
        passwordInput: document.getElementById('passwordInput'),
        confirmBtn: document.getElementById('confirmBtn'),
        searchUserInput: document.getElementById('searchUserInput'),
        userList: document.getElementById('userList'),
        backToPublicBtn: document.getElementById('backToPublicBtn'),
        backToSearchBtn: document.getElementById('backToSearchBtn'),
        detailAvatar: document.getElementById('detailAvatar'),
        detailId: document.getElementById('detailId'),
        detailName: document.getElementById('detailName'),
        deleteUserBtn: document.getElementById('deleteUserBtn'),
        detailTabs: document.querySelectorAll('.detail-tab'),
        detailContents: document.querySelectorAll('.detail-content'),
        // 删：postsContent（不存在）
        repliesContent: document.getElementById('repliesContent'),
        likesContent: document.getElementById('likesContent'),
        collectsContent: document.getElementById('collectsContent'),
        passwordModal: document.getElementById('passwordModal'),
        modalPasswordInput: document.getElementById('modalPasswordInput'),
        modalConfirmBtn: document.getElementById('modalConfirmBtn'),
        modalCancelBtn: document.getElementById('modalCancelBtn'),
        inputArea: document.getElementById('inputArea'),
        messageList: document.getElementById('messageList'),
        searchUserPage: document.getElementById('searchUserPage'),
        userDetailPage: document.getElementById('userDetailPage'),
        actionModal: document.getElementById('actionModal'),
        actionModalTitle: document.getElementById('actionModalTitle'),
        actionModalContent: document.getElementById('actionModalContent'),
        closeActionModal: document.getElementById('closeActionModal'),
        // 删：repliesSelectAll等无效引用（不存在）
    };

    // 全局状态 - 修复：修正JSON注入语法、补充默认值
    const state = {
        isAdminMode: false, // 是否管理员模式
        isDeleteMode: false, // 是否删除模式
        currentUserId: null, // 当前查看用户ID
        deleteTarget: null, // 待删除目标
        basePath: '<%= request.getContextPath() %>', // 项目根路径
        currentUser: <%
            Object user = session.getAttribute("currentUser");
            out.print(user != null ? "{\"userId\":1, \"userCode\":\"管理员\", \"username\":\"管理员\", \"identity\":\"admin\"}" : "{}");
        %>
    };

    // 初始化函数 - 修复：增加DOM元素检查、容错处理
    function init() {
        if (!state.currentUser || !state.currentUser.userId) {
            alert('请先登录');
            window.location.href = state.basePath + '/pages/login.jsp';
            return;
        }
        // 核心检查：关键DOM元素是否存在
        const criticalElements = [
            elements.adminActionBtn, elements.queryInput, elements.deleteActionBtn,
            elements.messageList, elements.searchUserPage, elements.userList
        ];
        const missingElement = criticalElements.find(el => el === null || el === undefined);
        if (missingElement) {
            console.error('关键DOM元素缺失，功能无法正常运行！请检查HTML中的ID是否正确');
            alert('页面加载失败：关键元素缺失，请检查控制台日志');
            return;
        }

        // 登录状态检查
        if (!state.currentUser || !state.currentUser.userId) {
            alert('请先登录');
            window.location.href = state.basePath + '/pages/login.jsp';
            return;
        }

        // 加载初始数据--不存在
        // loadFriends().catch(err => console.error('加载好友失败:', err));
        // loadMessages().catch(err => console.error('加载消息失败:', err));
        // 绑定事件
        bindEvents();
        console.log('页面初始化完成，管理员模式状态：', state.isAdminMode);
    }

    // 管理员搜索用户 - 优化：增加加载提示、空值处理
    function adminSearchUser(keyword) {
        keyword = keyword.trim();
        if (!keyword) {
            elements.userList.innerHTML = '<div style="text-align: center; padding: 20px;">请输入搜索关键词</div>';
            return;
        }
        // 加载提示
        elements.userList.innerHTML = '<div style="text-align: center; padding: 20px;">正在搜索...</div>';

        // 修复后
        fetch(state.basePath + '/pages/admin/search?keyword=' + encodeURIComponent(keyword))
            .then(res => {
                if (!res.ok) throw new Error(`请求失败：${res.status}`);
                return res.json();
            })
            // .then(users => renderUserList(users))
            .then(users => {
                // 新增：打印后端返回的用户列表（调试用）
                console.log("后端返回的用户数据：", users);
                renderUserList(users); // 渲染列表
            })
            .catch(err => {
                console.error('管理员搜索用户失败:', err);
                elements.userList.innerHTML = '<div style="text-align: center; padding: 20px; color: red;">搜索失败，请重试</div>';
            });
    }

    // 渲染管理员用户列表 - 修复：删除按钮显示逻辑、增加空值处理
    function renderUserList(users) {
        elements.userList.innerHTML = '';
        if (!users || users.length === 0) {
            elements.userList.innerHTML = '<div style="text-align: center; padding: 20px;">未找到匹配的用户</div>';
            return;
        }

        users.forEach(user => {
            // 1. 正确定义identityLabel（根据你的数据库身份字段值调整）
            let identityLabel = '';
            if (user.identity === 'admin') {
                identityLabel = '管理员';
            } else if (user.identity === 'geren') {
                identityLabel = '个人用户';
            } else if (user.identity === 'youke') {
                identityLabel = '游客';
            } else {
                identityLabel = '未知身份'; // 兜底，避免空值
            }
            // 2. 创建用户项（使用定义好的identityLabel）
            const userItem = document.createElement('div');
            userItem.className = 'user-item';
            // 拼接用户信息（用+号避免模板字符串冲突）
            userItem.innerHTML =
                '<div class="user-info">' +
                '<span>编号：' + user.userCode + '</span>' +
                '<span>昵称：' + user.username + '</span>' +
                '<span>身份：' + identityLabel + '</span>' +
                // '<span>身份：' + user.identity + '</span>' +
                '</div>' +
                // '<button class="delete-btn" onclick="confirmDelete(' + user.userId + ', \'user\')">删除用户</button>';
                // 新增style="display: none;"，默认隐藏
                '<button class="delete-btn user-delete-btn" onclick="confirmDelete(' + user.userId + ', \'user\')" style="display: none;">删除用户</button>';
            elements.userList.appendChild(userItem);
            // 新增：点击用户条目进入详情页
            userItem.addEventListener('click', () => {
                if (!event.target.classList.contains('delete-btn')) { // 点击非删除按钮时触发
                    viewUserDetail(user.userId);
                }
            });
            elements.userList.appendChild(userItem);

        });
    }

    // 查看用户详情
    function viewUserDetail(userId) {
        state.currentUserId = userId;

        elements.messageList.style.display = 'none';
        elements.searchUserPage.style.display = 'none';
        elements.userDetailPage.style.display = 'block';
        document.getElementById('chatTitle').textContent = '用户详情';
        // 调用后端接口查询用户详情

        fetch(state.basePath + '/GetUserDetailServlet?userId=' + userId)
            .then(res => res.json())
            .then(user => {
                // 核心修复：给每个元素添加存在性判断
                if (elements.detailAvatar) {
                    elements.detailAvatar.textContent = user?.username?.charAt(0) || '用';
                }
                if (elements.detailId) {
                    elements.detailId.textContent = '编号：' + (user?.userCode || '未知');
                }
                if (elements.detailName) {
                    elements.detailName.textContent = '昵称：' + (user?.username || '未知');
                }
                // 修复身份和注册时间的元素判断
                if (elements.detailIdentity) {
                    elements.detailIdentity.textContent = '身份：' + (user?.identity === 'admin' ? '管理员' : user?.identity === 'geren' ? '个人用户' : '游客');
                }
                if (elements.detailCreateTime) {
                    elements.detailCreateTime.textContent = '注册时间：' + (user?.createTime || '未知');
                }

                if (elements.deleteUserBtn) {
                    elements.deleteUserBtn.style.display = state.isDeleteMode ? 'block' : 'none';
                }
                loadUserActions(userId);
            })
            .catch(err => console.error('获取用户详情失败:', err));
    }

    // 新增：确认删除的函数（密码弹窗触发）
    function confirmDelete(id, type) {

        // 1. 验证id是否有效（必须是数字且不为空）
        if (id === undefined || id === null || isNaN(id) || id <= 0) {
            alert('用户ID无效（' + id + '），无法删除');
            console.error("无效的用户ID：", id);
            return;
        }
        // 2. 验证当前管理员是否登录（避免state.currentUser为空）
        if (!state.currentUser || !state.currentUser.userId) {
            alert('请先登录管理员账号');
            return;
        }
        // 验证userId是否有效（不为空且为数字）

        // 3. 存储删除目标信息（关键：确保id被正确赋值）
        state.deleteTarget = {id: id, type: type, userId: state.currentUser.userId};

        // 4. 聚焦到右侧密码框（提示用户输入）
        document.getElementById('passwordInput').focus();

        // 4. 显示密码弹窗
        // elements.passwordModal.style.display = 'block';
        // elements.modalPasswordInput.value = '';
        // elements.modalPasswordInput.focus();

    }

    // 加载用户行为数据
    function loadUserActions(userId) {

        if (!userId || isNaN(userId)) {
            alert('用户ID无效');
            return;
        }

        // 清空容器（保留）
        const messagesContainer = document.getElementById('messagesContent');
        const repliesContainer = document.getElementById('repliesContent');
        const likesContainer = document.getElementById('likesContent');
        const collectsContainer = document.getElementById('collectsContent');

        if (messagesContainer) messagesContainer.innerHTML = '<div style="text-align:center; padding:20px;">加载中...</div>';
        if (repliesContainer) repliesContainer.innerHTML = '<div style="text-align:center; padding:20px;">加载中...</div>';
        if (likesContainer) likesContainer.innerHTML = '<div style="text-align:center; padding:20px;">加载中...</div>';
        if (collectsContainer) collectsContainer.innerHTML = '<div style="text-align:center; padding:20px;">加载中...</div>';

        // 只保留随机参数，删除设置响应头的代码
        const randomParam = Math.random();
        fetch(state.basePath + '/GetUserActionsServlet?userId=' + userId + '&t=' + randomParam)
            .then(res => res.json())
            .then(actions => {
                console.log('最新用户行为数据:', actions);
                const messages = Array.isArray(actions?.messages) ? actions.messages : [];
                const replies = Array.isArray(actions?.replies) ? actions.replies : [];
                const likes = Array.isArray(actions?.likes) ? actions.likes : [];
                const collects = Array.isArray(actions?.collects) ? actions.collects : [];

                if (messagesContainer) renderActionList(messagesContainer, messages, 'message', userId);
                if (repliesContainer) renderActionList(repliesContainer, replies, 'reply', userId);
                if (likesContainer) renderActionList(likesContainer, likes, 'like', userId);
                if (collectsContainer) renderActionList(collectsContainer, collects, 'collect', userId);
            })
            .catch(err => {
                console.error('加载失败:', err);
                // 恢复显示
                if (messagesContainer) messagesContainer.innerHTML = '<div style="text-align:center; padding:20px;">加载失败，请刷新重试</div>';
                if (repliesContainer) repliesContainer.innerHTML = '<div style="text-align:center; padding:20px;">加载失败，请刷新重试</div>';
                if (likesContainer) likesContainer.innerHTML = '<div style="text-align:center; padding:20px;">加载失败，请刷新重试</div>';
                if (collectsContainer) collectsContainer.innerHTML = '<div style="text-align:center; padding:20px;">加载失败，请刷新重试</div>';
            });
    }


    // 渲染行为列表（完整版，确保内容不缺失）    // 渲染行为列表适配不同行为
    function renderActionList(container, items, type, userId) {

        // ========== 1. 先创建批量操作栏（不再克隆，直接创建，避免被清空） ==========
        const batchBar = document.createElement('div');
        batchBar.className = 'batch-actions';
        batchBar.id = type + 'BatchActions'; // 给批量栏加唯一ID
        // batchBar.style.display = state.isDeleteMode ? 'flex' : 'none';
        batchBar.style.display = state.isDeleteMode ? 'inline-flex' : 'none'; // 关键：flex→inline-flex（行内布局）
        batchBar.style.alignItems = 'center';
        batchBar.style.padding = '10px 0';
        batchBar.style.color = '#333'; // 文字黑色，避免和白色背景融合
        batchBar.style.marginRight = '10px'; // 新增：和统计文字拉开间距

        // 全选框
        const selectAll = document.createElement('input');
        selectAll.type = 'checkbox';
        selectAll.id = type + 'SelectAll';
        selectAll.className = 'select-all-checkbox';
        selectAll.dataset.type = type;
        selectAll.style.display = state.isDeleteMode ? 'inline-block' : 'none';
        selectAll.style.width = '16px';
        selectAll.style.height = '16px';
        selectAll.style.marginRight = '8px';
        selectAll.style.accentColor = '#ef4444';

        // 关键：直接写onclick事件，不依赖任何外部函数
        selectAll.onclick = function() {
            // 找到当前容器内的所有子复选框
            const allCheckboxes = container.querySelectorAll('.action-checkbox');
            // 同步勾选状态
            allCheckboxes.forEach(cb => {
                cb.checked = this.checked;
            });
        };

        // 全选文字
        const selectText = document.createElement('span');
        selectText.textContent = '全选';
        selectText.style.marginRight = '10px';

        // 组装批量栏
        batchBar.appendChild(selectAll);
        batchBar.appendChild(selectText);


        // ========== 2. 清空容器，先加批量栏，再加统计和列表 ==========
        container.innerHTML = '';
        container.appendChild(batchBar); // 批量栏放在最顶部，不会被覆盖

        // ========== 2. 追加统计文字（用+=，不覆盖） ==========
        // 显示数据统计
        // container.innerHTML += '<div style="padding: 10px; color: #666;">共' + items.length + '条' + getTypeName(type) + '数据</div>';
        // 关键：把innerHTML += 改成 createElement + appendChild（行内显示）
        const countText = document.createElement('div');
        countText.style.display = 'inline-block'; // 统计文字也设为行内
        countText.style.padding = '10px 0';
        countText.style.color = '#666';
        countText.textContent = '共' + items.length + '条' + getTypeName(type) + '数据';
        container.appendChild(countText); // 替代原来的innerHTML +=

        if (!items || items.length === 0) {
            container.innerHTML = '<div style="text-align: center; padding: 20px;">暂无' + getTypeName(type) + '记录</div>';
            // 绑定全选框事件
            bindSelectAllEvent(type);
            // 绑定批量删除按钮事件
            // batchDeleteBtn.onclick = () => batchDeleteConfirm(type);
            return;
        }
        // 遍历数据渲染// ========== 3. 遍历渲染列表（移除重复创建的复选框） ==========
        items.forEach(item => {
            const itemDiv = document.createElement('div');
            itemDiv.className = 'action-item';
            itemDiv.style.padding = '12px';
            itemDiv.style.borderBottom = '1px solid #eee';
            itemDiv.style.background = '#f9f9f9';
            itemDiv.style.borderRadius = '4px';

            let content = '';
            let time = '';
            let targetId = '';
            let relatedMessageId = 0; // 关联的评论ID（用于查询内容）

            // 1. 确定关联的评论ID和基础信息
            switch (type) {
                case 'message':
                    content = '评论内容：' + (item.content || '无内容');
                    time = '发布时间：' + (item.createTime ? formatTime(item.createTime) : '未知');
                    targetId = item.id; // 正确绑定id
                    break;
                case 'reply':
                    relatedMessageId = item.targetMsgId;
                    targetId = item.id;

                    time = '回复时间：' + (item.createTime ? formatTime(item.createTime) : '未知');
                    fetch(state.basePath + '/GetMessageByIdServlet?messageId=' + relatedMessageId)
                        .then(res => res.json())
                        .then(data => {
                            // 拼接格式：回复了 [昵称(编号)] 的“[评论内容]”：[回复内容]
                            content = '回复了 ' + data.username + '(' + data.userCode + ') 的“' +
                                (data.content || '[已删除]') + '”：' + (item.content || '无内容');
                            itemDiv.querySelector('span').textContent = content;
                        });
                    content = '回复加载中...';
                    break;
                case 'like':
                    relatedMessageId = item.messageId;
                    targetId = item.likeId; // 正确绑定likeId
                    time = '点赞时间：' + (item.createTime ? formatTime(item.createTime) : '未知');
                    fetch(state.basePath + '/GetMessageByIdServlet?messageId=' + relatedMessageId)
                        .then(res => res.json())
                        .then(data => {
                            content = '点赞了 ' + data.username + '(' + data.userCode + ') 的“' +
                                (data.content || '[已删除]') + '”';
                            itemDiv.querySelector('span').textContent = content;
                        });
                    content = '点赞加载中...';
                    break;
                case 'collect':
                    relatedMessageId = item.messageId;
                    targetId = item.collectId; // 正确绑定collectId
                    time = '收藏时间：' + (item.collectTime ? formatTime(item.collectTime) : '未知');
                    fetch(state.basePath + '/GetMessageByIdServlet?messageId=' + relatedMessageId)
                        .then(res => res.json())
                        .then(data => {
                            content = '收藏了 ' + data.username + '(' + data.userCode + ') 的“' +
                                (data.content || '[已删除]') + '”';
                            itemDiv.querySelector('span').textContent = content;
                        });
                    content = '收藏加载中...';
                    break;
            }
            // 无需查询关联内容，直接渲染
            renderItem(itemDiv, content, time, targetId, type);
            container.appendChild(itemDiv);
        });

        // ========== 4. 绑定全选框事件（关键） ==========
        bindSelectAllEvent(type);


    }


    // 全选框和子复选框绑定（新增，只加这一段）    // 确保bindSelectAllEvent函数完整（如果没有就加在renderActionList外面）
    function bindSelectAllEvent(type) {
        const selectAllBox = document.getElementById(type + 'SelectAll');
        const contentContainer = document.getElementById(type + 'Content');
        if (!selectAllBox || !contentContainer) return;
        // 关键修改：只选当前容器内的.action-checkbox
        selectAllBox.addEventListener('change', function() {
            // 用contentContainer.querySelectorAll，只找当前标签页下的复选框
            const allItemCheckboxes = contentContainer.querySelectorAll('.action-checkbox');
            allItemCheckboxes.forEach(cb => {
                cb.checked = this.checked;
            });
        });
        // 子复选框同步全选框（同样限制在当前容器内）
        const allItemCheckboxes = contentContainer.querySelectorAll('.action-checkbox');
        allItemCheckboxes.forEach(cb => {
            cb.addEventListener('change', function() {
                const allChecked = Array.from(allItemCheckboxes).every(itemCb => itemCb.checked);
                selectAllBox.checked = allChecked;
            });
        });
    }

    // 辅助函数：渲染单条数据（统一格式）
    function renderItem(itemDiv, content, time, targetId, type) {


        itemDiv.innerHTML =
            '<div style="display: flex; flex-direction: column; gap: 8px;">' +
            '<div style="display: flex; align-items: center; gap: 8px;">' +
            '<input type="checkbox" class="action-checkbox" ' +
            'data-id="' + (targetId || '') + '" ' + // 空值传空字符串
            'data-type="' + type + '" ' +
            'style="display: ' + (state.isDeleteMode ? 'block !important': 'none') + '; width: 16px; height: 16px;">' +
            '<span style="flex: 1; font-size: 14px;">' + content + '</span>' +
            '<button class="delete-item-btn" ' +
            'data-id="' + (targetId || '') + '" ' + // 这里也加空值判断
            'data-type="' + type + '" ' +
            'style="display: ' + (state.isDeleteMode ? 'block' : 'none') + ';' +
            'background: #ff4444; color: white; border: none;' +
            'padding: 4px 10px; border-radius: 3px; cursor: pointer; font-size: 12px;">' +
            '删除' +
            '</button>' +
            '</div>' +
            '<span style="font-size: 12px; color: #999; margin-left: 24px;">' + time + '</span>' +
            '</div>';
        // 复选框 ↔ 删除按钮 双向联动（逻辑完全不变）
        const checkbox = itemDiv.querySelector('.action-checkbox');
        const deleteBtn = itemDiv.querySelector('.delete-item-btn');
        if (checkbox && deleteBtn) {
            // 点击删除按钮 → 切换复选框状态
            deleteBtn.onclick = function(e) {
                e.stopPropagation(); // 阻止冒泡到父元素
                checkbox.checked = !checkbox.checked;
                syncSelectAllStatus(type); // 同步全选框状态
            };
            // 点击复选框 → 同步全选框状态
            checkbox.onchange = function() {
                syncSelectAllStatus(type);
            };
        }
    }

    // 同步全选框状态（所有子复选框勾选 → 全选框勾选，否则取消）
    function syncSelectAllStatus(type) {
        // 获取当前类型的所有复选框和全选框
        const containerId = type === 'message' ? 'messagesContent' :
            type === 'reply' ? 'repliesContent' :
                type === 'like' ? 'likesContent' : 'collectsContent';
        const selectAllId = type === 'message' ? 'messagesSelectAll' :
            type === 'reply' ? 'repliesSelectAll' :
                type === 'like' ? 'likesSelectAll' : 'collectsSelectAll';

        const allCheckboxes = document.querySelectorAll('#' + containerId + ' .action-checkbox');
        const selectAllBox = document.getElementById(selectAllId);

        if (!selectAllBox || allCheckboxes.length === 0) return;

        // 判断是否所有复选框都勾选
        const allChecked = Array.from(allCheckboxes).every(cb => cb.checked);
        selectAllBox.checked = allChecked;
    }



    // 辅助函数：格式化时间（保持不变）
    function formatTime(timestamp) {
        return timestamp ? timestamp.split('.')[0] : '未知';
    }

    // 在JS代码的顶部（比如state定义后）添加该函数
    function getTypeName(type) {
        const typeMap = {
            'message': '评论',
            'reply': '回复',
            'like': '点赞',
            'collect': '收藏'
        };
        return typeMap[type] || '未知类型';
    }

    // 执行删除操作
    function executeDelete() {
        // 1. 验证删除目标是否存在
        if (!state.deleteTarget && !state.batchDelete) { // 新增：判断批量删除目标
            alert('未指定删除目标');
            return;
        }
        // 先判断密码是否已验证

        // 3. 验证密码
        const password = elements.modalPasswordInput.value.trim();
        if (password !== '741852') {
            alert('密码错误');
            return;
        }
        // 新增：批量删除逻辑（保留原有单个删除逻辑）
        if (state.batchDelete) {
            const batch = state.batchDelete;
            // 发送批量删除请求
            fetch(state.basePath + '/AdminBatchDeleteServlet', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'ids=' + batch.ids.join(',') + '&type=' + batch.type + '&userId=' + batch.userId
            })
                .then(res => res.text())
                .then(msg => {
                    alert(msg);
                    elements.passwordModal.style.display = 'none';
                    if (msg.includes('成功')) {
                        loadUserActions(state.currentUserId); // 刷新当前用户的行为记录
                    }
                    state.batchDelete = null; // 清空批量删除状态
                })
                .catch(err => {
                    console.error('执行批量删除失败:', err);
                    alert('删除失败：网络异常');
                });
            return; // 批量删除逻辑结束，避免执行单个删除
        }

        // 原有单个删除逻辑（完全保留，仅修正变量名）
        const target = state.deleteTarget;
        // 2. 再次验证要删除的用户ID
        if (target.id === undefined || target.id === null || isNaN(target.id)) {
            alert('删除目标ID无效');
            elements.passwordModal.style.display = 'none';
            return;
        }


        // 4. 发送删除请求（确保参数名与后端一致）
        fetch(state.basePath + '/AdminDeleteServlet', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            // 关键：参数名必须是后端期望的（这里假设后端用userId接收要删除的ID）
            // body: 'userId=' + target.id + '&operatorId=' + target.userId
            body: 'id=' + target.id + '&type=' + target.type + '&userId=' + target.userId
        })
            .then(res => res.text())
            .then(msg => {
                alert(msg); // 显示后端返回的结果（成功/失败原因）
                if (msg.includes('成功')) {
                    adminSearchUser(elements.searchUserInput.value); // 刷新列表
                }
            })
            .catch(err => {
                console.error('执行删除失败:', err);
                alert('删除失败：网络异常');
            });
    }

    // 新增：批量删除确认函数（收集选中ID并弹出密码框）
    function batchDeleteConfirm(type) {
        // 修复容器ID：直接写死与HTML一致的ID
        let containerId = '';
        if (type === 'message') containerId = 'messagesContent';
        else if (type === 'reply') containerId = 'repliesContent';
        else if (type === 'like') containerId = 'likesContent';
        else if (type === 'collect') containerId = 'collectsContent';

        const checkedBoxes = document.querySelectorAll('#' + containerId + ' .action-checkbox:checked');
        if (checkedBoxes.length === 0) {
            alert('请先勾选要删除的' + getTypeName(type) + '记录');
            return;
        }
        // 收集选中的ID和类型
        const ids = Array.from(checkedBoxes).map(cb => cb.dataset.id);
        state.batchDelete = {
            ids: ids,
            type: type,
            userId: state.currentUser.userId
        };
        elements.passwordModal.style.display = 'block';
        elements.modalPasswordInput.value = '';
        elements.modalPasswordInput.focus();
    }


    // 假设原有开启删除模式的函数
    function openDeleteMode() {
        state.isDeleteMode = true;
        // 显示所有删除按钮
        document.querySelectorAll('.delete-btn').forEach(btn => btn.style.display = 'block');
        // 显示全选框和批量操作栏
        document.querySelectorAll('.batch-actions').forEach(bar => bar.style.display = 'block');
        document.querySelectorAll('.select-all-checkbox').forEach(cb => cb.style.display = 'block');
        // 显示复选框
        document.querySelectorAll('.action-checkbox').forEach(cb => cb.style.display = 'block');
    }

    // 标签切换事件（直接操作DOM，避免变量错误）
    document.querySelectorAll('.detail-tab').forEach(tab => {
        tab.addEventListener('click', function () {
            // 1. 移除所有标签的active类
            document.querySelectorAll('.detail-tab').forEach(t => t.classList.remove('active'));
            // 2. 给当前标签添加active类
            this.classList.add('active');
            // 3. 隐藏所有内容容器
            document.querySelectorAll('.detail-content').forEach(content => {
                content.classList.remove('active');
                content.style.display = 'none'; // 先隐藏所有容器
            });
            // 4. 显示当前标签对应的容器（关键：通过ID直接获取）
            const tabName = this.dataset.tab; // 获取标签名：posts/replies/likes/collects
            const targetContainer = document.getElementById(tabName + 'Content');
            if (targetContainer) {
                targetContainer.classList.add('active');
                targetContainer.style.display = 'block'; // 强制显示激活的容器
                console.log('激活容器：', tabName + 'Content'); // 调试用
            } else {
                console.error('找不到的容器ID是：', tabName + 'Content'); // 报错时看这里
            }
            // ========== 新增：切换标签后刷新全选框显示状态 ==========
            const batchBar = document.getElementById(tabName + 'BatchActions');
            if (batchBar) {
                batchBar.style.display = state.isDeleteMode ? 'block' : 'none';
            }
            // 刷新当前标签数据（确保全选框和列表同步）
            if (state.currentUserId) {
                loadUserActions(state.currentUserId);
            }
        });
    });

    // 显示收藏/点赞弹窗
    function showActionModal(type) {
        const isCollect = type === 'collect';
        elements.actionModalTitle.textContent = isCollect ? '我的收藏' : '我的点赞';
        elements.actionModalContent.innerHTML = '';

        fetch(`${state.basePath}/GetMyActionsServlet?type=${type}&userId=${state.currentUser.userId}`)
            .then(res => res.json())
            .then(actions => {
                if (!actions || actions.length === 0) {
                    elements.actionModalContent.innerHTML = '<div>暂无数据</div>';
                } else {
                    actions.forEach(action => {
                        const msgItem = document.createElement('div');
                        msgItem.className = 'message-item';
                        msgItem.innerHTML = `
                            <div class="message-header">${action.username}（${action.userCode}）</div>
                            <div class="message-content">${action.content}</div>
                            <div class="message-actions">
                                <span class="time">${action.time}</span>
                            </div>
                        `;
                        elements.actionModalContent.appendChild(msgItem);
                    });
                }
                elements.actionModal.style.display = 'flex';
            })
            .catch(err => console.error('加载收藏/点赞失败:', err));
    }

    // 绑定所有事件 - 核心修复：修复语法错误、补充事件容错
    function bindEvents() {
        console.log('开始绑定事件，管理员按钮:', elements.adminActionBtn);

        // 核心：管理员操作按钮事件
        elements.adminActionBtn?.addEventListener('click', () => {
            state.isAdminMode = !state.isAdminMode;
            elements.adminActionBtn.classList.toggle('active');
            // 启用/禁用按钮
            elements.queryInput.disabled = !state.isAdminMode;
            elements.deleteActionBtn.disabled = !state.isAdminMode;
            // 隐藏/显示输入框
            elements.inputArea.style.display = state.isAdminMode ? 'none' : 'flex';
            // 退出管理员模式时重置删除模式
            if (!state.isAdminMode) {
                state.isDeleteMode = false;
                elements.deleteActionBtn.textContent = '删除（帖子/用户）';
                elements.passwordInput.disabled = true;
                elements.confirmBtn.disabled = true;
                // 隐藏所有删除按钮
                document.querySelectorAll('.delete-btn').forEach(btn => {
                    btn.style.display = 'none';
                });
            }
            alert(state.isAdminMode ? '已进入管理员模式，可点击查询框搜索用户' : '已退出管理员模式');
            console.log('管理员模式切换为:', state.isAdminMode);
        });

        // 管理员查询输入框点击事件
        elements.queryInput?.addEventListener('click', () => {
            if (!state.isAdminMode) return;
            // 切换页面
            if (elements.messageList) {
                elements.messageList.style.display = 'none';
            }
            if (elements.searchUserPage) {
                elements.searchUserPage.style.display = 'block';
            }
            if (elements.userDetailPage) {
                elements.userDetailPage.style.display = 'none';
            }
            // 更新标题
            document.getElementById('chatTitle').textContent = '用户查询';
            // 自动聚焦
            elements.searchUserInput.focus();
        });

        // 管理员搜索框回车事件
        elements.searchUserInput?.addEventListener('keyup', (e) => {
            if (e.key === 'Enter' && state.isAdminMode) {
                adminSearchUser(e.target.value);
            }
        });

        // 管理员搜索输入事件
        elements.searchUserInput?.addEventListener('input', (e) => {
            if (!state.isAdminMode) return;
            adminSearchUser(e.target.value);
        });

        // 管理员删除模式切换（替换原有逻辑）
        elements.deleteActionBtn?.addEventListener('click', () => {
            if (!state.isAdminMode) return;
            state.isDeleteMode = !state.isDeleteMode;

            // ========== 新增：给body加删除模式类 ==========
            document.body.classList.toggle('state-delete-mode', state.isDeleteMode);

            // 1. 按钮文字切换
            elements.deleteActionBtn.textContent = state.isDeleteMode ? '取消删除' : '删除（帖子/用户）';

            // 2. 启用/禁用右侧密码框+确认按钮
            elements.passwordInput.disabled = !state.isDeleteMode;
            elements.confirmBtn.disabled = !state.isDeleteMode;

            // 3. 显示/隐藏「删除该用户」按钮（核心：指定正确的ID）
            const deleteUserBtn = document.getElementById('deleteUserBtn');
            if (deleteUserBtn) {
                deleteUserBtn.style.display = state.isDeleteMode ? 'block' : 'none';
            }

            // 4. 显示/隐藏所有全选框（select-all-checkbox）
            document.querySelectorAll('.select-all-checkbox').forEach(cb => {
                cb.style.display = state.isDeleteMode ? 'inline-block' : 'none';
            });

            // 5. 显示/隐藏所有批量操作栏（包含全选框的容器）
            // 原代码中已有这行，确认保留
            document.querySelectorAll('.batch-actions').forEach(bar => {
                bar.style.display = state.isDeleteMode ? 'block' : 'none';
            });

            // 6. 显示/隐藏所有行内复选框（action-checkbox）
            document.querySelectorAll('.action-checkbox').forEach(cb => {
                cb.style.display = state.isDeleteMode ? 'block' : 'none';
            });

            // 7. 显示/隐藏所有行内红色删除按钮（delete-item-btn）
            document.querySelectorAll('.delete-item-btn').forEach(btn => {
                btn.style.display = state.isDeleteMode ? 'block' : 'none';
            });

            // ========== 新增：控制搜索结果中的“删除用户”按钮 ==========
            document.querySelectorAll('.user-delete-btn').forEach(btn => {
                btn.style.display = state.isDeleteMode ? 'block' : 'none';
            });

            // 8. 兼容原有.delete-btn的显示（用户列表的删除按钮）
            document.querySelectorAll('.delete-btn').forEach(btn => {
                btn.style.display = state.isDeleteMode ? 'block' : 'none';
            });

            // 强制控制所有批量操作栏的显示（新增）
            document.querySelectorAll('.batch-actions').forEach(bar => {
                bar.style.display = state.isDeleteMode ? 'block' : 'none';
            });
            // 强制控制所有全选框的显示（新增）
            document.querySelectorAll('.select-all-checkbox').forEach(cb => {
                cb.style.display = state.isDeleteMode ? 'inline-block' : 'none';
            });
            // ========== 新增：动态加载后重新显示全选框 ==========
            if (state.currentUserId) {
                loadUserActions(state.currentUserId); // 重新加载数据，触发全选框渲染
            }
        });

        // 管理员密码确认（删除核心逻辑：优先删用户，再批量删）
        elements.confirmBtn?.addEventListener('click', () => {
            const password = elements.passwordInput.value.trim();
            if (password !== '741852') {
                alert('密码错误');
                return;
            }

            // ===== 第一步：处理“删除用户”（无弹窗，直接删）=====
            if (state.deleteTarget?.type === 'user') {
                const target = state.deleteTarget;
                // 发送删除用户请求
                fetch(state.basePath + '/AdminDeleteServlet', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'id=' + target.id + '&type=user&userId=' + target.userId
                })
                    .then(res => res.text())
                    .then(msg => {
                        alert(msg);
                        elements.passwordInput.value = ''; // 清空密码框
                        state.deleteTarget = null; // 清空删除目标

                        // 删除成功后刷新页面
                        if (msg.includes('成功')) {
                            // 情况1：从用户详情页删除 → 返回搜索页
                            if (state.currentUserId) {
                                elements.userDetailPage.style.display = 'none';
                                elements.searchUserPage.style.display = 'block';
                                document.getElementById('chatTitle').textContent = '用户查询';
                                state.currentUserId = null;
                            }
                            // 情况2：从搜索结果删除 → 刷新搜索列表
                            adminSearchUser(elements.searchUserInput.value);
                        }
                    })
                    .catch(err => {
                        console.error('删除用户失败:', err);
                        alert('删除失败：网络异常');
                        elements.passwordInput.value = '';
                        state.deleteTarget = null;
                    });
                return; // 处理完用户删除，不执行下面的批量删除
            }

            // ===== 第二步：处理“批量删除（评论/点赞/收藏）”=====
            const allCheckedBoxes = document.querySelectorAll('.action-checkbox:checked');
            if (allCheckedBoxes.length === 0) {
                alert('请先勾选要删除的记录！');
                elements.passwordInput.value = '';
                return;
            }

            // 分组收集ID（按类型）
            const deleteGroups = {};
            allCheckedBoxes.forEach(cb => {
                const type = cb.dataset.type;
                const id = cb.dataset.id;
                if (!deleteGroups[type]) deleteGroups[type] = [];
                deleteGroups[type].push(id);
            });

            // 批量删除
            let deleteSuccess = true;
            const deletePromises = [];

            for (const type in deleteGroups) {
                const ids = deleteGroups[type];
                const formData = 'ids=' + ids.join(',') + '&type=' + type + '&userId=' + state.currentUser.userId;
                console.log("发送删除请求：type=" + type + "，ids=" + ids);
                deletePromises.push(
                    fetch(state.basePath + '/AdminBatchDeleteServlet', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        body: formData
                    })
                        .then(res => res.text())
                        .then(msg => {
                            if (msg.indexOf('失败') !== -1) {
                                deleteSuccess = false;
                                alert('删除' + getTypeName(type) + '失败：' + msg);
                            }
                            return msg;
                        })
                        .catch(err => {
                            deleteSuccess = false;
                            console.error('删除' + getTypeName(type) + '失败:', err);
                            alert('删除' + getTypeName(type) + '失败：网络异常');
                        })
                );
            }

            // 批量删除完成后刷新
            Promise.all(deletePromises).then(() => {
                if (deleteSuccess) {
                    alert('所有选中记录删除成功！');
                    elements.passwordInput.value = '';
                    // 刷新数据
                    setTimeout(() => {
                        if (state.currentUserId) {
                            loadUserActions(state.currentUserId);
                        } else {
                            adminSearchUser(elements.searchUserInput.value);
                        }
                    }, 1000);
                    // 取消所有勾选
                    document.querySelectorAll('.action-checkbox').forEach(cb => cb.checked = false);
                    document.querySelectorAll('.select-all-checkbox').forEach(cb => cb.checked = false);
                }
            });
        });

        // 页面返回按钮事件
        elements.backToPublicBtn?.addEventListener('click', () => {
            elements.messageList.style.display = 'block';
            elements.searchUserPage.style.display = 'none';
            elements.userDetailPage.style.display = 'none';
            document.getElementById('chatTitle').textContent = '公共界面';
        });
        elements.backToSearchBtn?.addEventListener('click', () => {
            elements.messageList.style.display = 'none';
            elements.searchUserPage.style.display = 'block';
            elements.userDetailPage.style.display = 'none';
            document.getElementById('chatTitle').textContent = '用户查询';
            state.currentUserId = null;
        });

        // ========== 新增：删除该用户按钮事件（放在这里） ==========
        document.getElementById('deleteUserBtn')?.addEventListener('click', () => {
            // 复用confirmDelete函数，和搜索结果中的删除按钮逻辑一致
            confirmDelete(state.currentUserId, 'user');
        });

        // 新增：退出登录按钮事件
        document.getElementById('logoutBtn')?.addEventListener('click', () => {
            // 1. 发送退出登录请求（后端销毁session）
            fetch(state.basePath + '/LogoutServlet', { method: 'POST' })
                .then(res => res.text())
                .then(msg => {
                    // 2. 跳转到登录页
                    window.location.href = state.basePath + '/pages/login.jsp';
                })
                .catch(err => {
                    console.error('退出登录失败:', err);
                    // 即使请求失败，也强制跳转到登录页
                    window.location.href = state.basePath + '/pages/login.jsp';
                });
        });

        // 绑定所有全选框的change事件


        // 标签切换事件
        elements.detailTabs?.forEach(tab => {
            tab.addEventListener('click', () => {
                // 移除所有标签active
                elements.detailTabs.forEach(t => t.classList.remove('active'));
                // 当前标签active
                tab.classList.add('active');
                // 隐藏所有容器
                document.querySelectorAll('.detail-content').forEach(content => {
                    content.classList.remove('active');
                });
                // 激活当前容器（用字符串拼接代替模板字符串）
                const tabName = tab.dataset.tab; // 获取标签的data-tab值（比如messages/replies）
                const targetContent = document.getElementById(tabName + 'Content'); // 拼接容器ID
                if (targetContent) {
                    targetContent.classList.add('active');
                    console.log('已激活标签页：' + tabName + '，容器是否存在：' + !!targetContent);
                } else {
                    console.error('找不到容器：' + tabName + 'Content');
                }
            });
        });

    }

    // 页面加载完成后初始化
    window.addEventListener('load', init);
    //]]>
</script>
</html>