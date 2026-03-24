<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.luntan.software.model.User" %>
<%@ page import="com.alibaba.fastjson.JSON" %>

<%
    // 主界面JSP顶部，确保从Session获取用户并生成JSON
    User currentUser = (User) request.getSession().getAttribute("currentUser");
    String userJson = "{}"; // 默认空对象

    if (currentUser == null) {
        // 若未登录，强制跳转到登录页
        response.sendRedirect(request.getContextPath() + "/pages/login.jsp");
        return; // 关键：这里必须return，停止JSP后续执行
    } else {
        userJson = JSON.toJSONString(currentUser);
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title >论坛聊天界面</title>
    <link rel="stylesheet" href="../static/main.css">
</head>
<body>

<!-- 顶部导航栏 -->
<div class="shang1">
    <h1 style="color: white;">欢迎进入论坛</h1>
</div>
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

        <!-- 申请中容器 -->
        <div id="pendingRequests"></div>
        <!-- 待审批容器 -->
        <div id="receivedRequests"></div>

    </div>

    <!-- 中间聊天界面 -->
    <div class="chat-panel" id="chatPanel">
        <!-- 聊天头部 -->
        <div class="chat-header">
            <div class="chat-title" id="chatTitle">公共界面</div>
            <button class="exit-chat-btn" id="exitChatBtn">退出</button>
        </div>

        <!-- 消息列表 -->
        <div class="message-list" id="messageList">
        </div>

        <!-- 输入栏 -->
        <div class="input-area">
            <input type="text" class="message-input" id="messageInput" placeholder="请输入消息..." />
            <button class="send-btn" id="sendBtn" onclick="sendMessage()">发送</button>
        </div>
    </div>


    <!-- 右侧功能栏 -->
    <div class="right-panel">
        <div class="user-info">
            <div class="user-avatar" id="userAvatar">我</div>
            <!-- 修复后的用户信息显示 -->
            <div>编号：<%= currentUser.getUserCode() %></div>
            <div>昵称：<%= currentUser.getUsername() %></div>
        </div>
        <button class="action-btn" id="changeAvatarBtn">换头像</button>
        <button class="action-btn" id="changeBgBtn">换背景</button>
        <button class="action-btn" id="collectBtn">我的收藏</button>
        <button class="action-btn" id="likeBtn">我的点赞</button>
        <!-- 退出登录按钮 -->
        <button class="action-btn" id="logoutBtn">退出登录</button>
        <button class="action-btn" id="exitActionBtn" style="display: none;">返回公共</button>
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

<div class="chat-area">
    <!-- 聊天内容区域 -->
</div>

<script>
    // 全局DOM元素引用（非管理员界面专用）
    const elements = {
        // 好友面板
        friendPanel: document.querySelector('.friend-panel'),
        friendList: document.getElementById('friendList'),
        searchFriend: document.getElementById('searchFriend'),
        searchResult: document.getElementById('searchResult'),
        deleteFriendBtn: document.getElementById('deleteFriendBtn'),
        // 申请/审批相关
        pendingRequests: document.getElementById('pendingRequests'), // 申请中容器
        receivedRequests: document.getElementById('receivedRequests'), // 待审批容器
        // 消息面板
        messageList: document.getElementById('messageList'),
        messageInput: document.getElementById('messageInput'),
        sendBtn: document.getElementById('sendBtn'),
        // 消息操作
        collectBtn: document.getElementById('collectBtn'),
        likeBtn: document.getElementById('likeBtn'),
        actionModal: document.getElementById('actionModal'),
        actionModalTitle: document.getElementById('actionModalTitle'),
        actionModalContent: document.getElementById('actionModalContent'),
        closeActionModal: document.getElementById('closeActionModal')
    };

    // 全局状态
    // 全局状态
    const state = {
        currentUser: null, // 先设为null
        isDeleteMode: false,
        basePath: '<%= request.getContextPath() %>'
    };

    // 安全地解析用户JSON
    try {
        // 确保 userJson 是有效的JSON字符串
        const userJsonStr = '<%= userJson %>';
        console.log('原始userJson:', userJsonStr);

        if (userJsonStr && userJsonStr !== '{}') {
            state.currentUser = JSON.parse(userJsonStr.replace(/&quot;/g, '"'));
        } else {
            console.warn('用户JSON为空或未登录');
            // 如果未登录，应该跳转，但这里由后面的代码处理
        }
    } catch (error) {
        console.error('解析用户JSON失败:', error);
        // 尝试直接从JSP获取（备用方案）
        state.currentUser = {
            userId: <%= currentUser != null ? currentUser.getUserId() : "null" %>,
            username: <%= currentUser != null ? "\"" + currentUser.getUsername().replace("\"", "\\\"") + "\"" : "null" %>,
            userCode: <%= currentUser != null ? "\"" + currentUser.getUserCode().replace("\"", "\\\"") + "\"" : "null" %>
        };
    }

    // 输出调试信息
    console.log('当前用户状态:', state.currentUser);
    console.log('用户ID:', state.currentUser?.userId);
    console.log('项目路径:', state.basePath);

    // 如果用户信息为空，直接跳转
    if (!state.currentUser || !state.currentUser.userId) {
        console.error('用户信息缺失，跳转到登录页');
        window.location.href = state.basePath + '/pages/login.jsp';
    }

    // 初始化
    // ============ 修改现有的 init() 函数 ============

    // 找到现有的 init() 函数（大约在 100 行左右），修改为：
    function init() {
        console.log('init函数执行了！');

        // 再次检查登录状态
        if (!state.currentUser || !state.currentUser.userId) {
            alert('请先登录');
            window.location.href = state.basePath + '/pages/login.jsp';
            return;
        }

        console.log('当前登录用户ID:', state.currentUser.userId);
        console.log('当前登录用户名:', state.currentUser.username);

        loadFriends(); // 加载已添加的好友（绿色框）
        loadPendingRequests(); // 加载申请中（黄色框）
        loadReceivedRequests(); // 加载待审批（浅蓝色框）
        loadMessages(); // 加载聊天消息

        // ============ 添加这一行 ============
        // 检查被拒绝的好友请求
        checkRejectedRequests();

        // ============ 添加定时检查 ============
        // 每30秒检查一次被拒绝的请求
        setInterval(checkRejectedRequests, 30000);
    }

    // 退出登录按钮点击事件
    document.getElementById('logoutBtn').addEventListener('click', function() {
        // 1. 清除Session（通过后端）
        fetch(state.basePath + '/LogoutServlet', {
            method: 'POST',
            credentials: 'include'
        })
            .then(() => {
                // 2. 清除前端存储
                sessionStorage.clear();
                localStorage.clear();

                // 3. 跳转到登录页
                window.location.href = state.basePath + '/pages/login.jsp';
            })
            .catch(err => {
                console.error('退出登录失败:', err);
                // 直接跳转
                window.location.href = state.basePath + '/pages/login.jsp';
            });
    });

    // 1. 好友管理相关功能
    function loadFriends() {
        fetch(state.basePath + "/LoadFriendsServlet", {
            method: 'GET',
            credentials: 'include' // 关键：包含Session cookie
        })
            .then(res => {
                if (res.status === 401 || res.status === 403) {
                    // 会话过期
                    alert('登录已过期，请重新登录');
                    window.location.href = state.basePath + '/pages/login.jsp';
                    return Promise.reject('会话过期');
                }
                return res.json();
            })
            .then(friends => {
                renderFriends(friends);
            })
            .catch(err => {
                if (err !== '会话过期') {
                    console.error('加载好友失败:', err);
                }
            });
    }

    function renderFriends(friends) {
        console.log('渲染好友列表，数据：', friends);
        elements.friendList.innerHTML = '';

        if (!friends || friends.length === 0) {
            elements.friendList.innerHTML = '<div class="empty-tip">暂无好友</div>';
            return;
        }

        friends.forEach(friend => {
            const item = document.createElement('div');
            item.className = 'friend-item green';
            item.dataset.id = friend.friendId;

            // 统一使用 user 对象的数据结构
            const user = {
                username: friend.username,
                userCode: friend.userCode,
                userId: friend.friendId
            };

            item.innerHTML = '<span>' + user.username + '（' + user.userCode + '）</span>';
            elements.friendList.appendChild(item);
        });
    }


    function loadPendingRequests() {
        console.log('🔄 开始加载申请中请求，用户ID:', state.currentUser.userId);
        fetch(state.basePath + '/LoadFriendRequestsServlet?userId=' + state.currentUser.userId + '&type=pending', {
            credentials: 'include' // 关键：包含Session cookie
        })
            .then(res => {
                if (res.status === 401 || res.status === 403) {
                    throw new Error('会话过期');
                }
                console.log('📡 申请中请求响应状态:', res.status);
                return res.json();
            })
            .then(requests => {
                console.log('✅ 收到的申请中请求数据:', requests);
                console.log('📊 请求数量:', requests.length);
                renderRequests(elements.pendingRequests, requests, 'pending');
            })
            .catch(err => {
                if (err.message === '会话过期') {
                    alert('登录已过期，请重新登录');
                    window.location.href = state.basePath + '/pages/login.jsp';
                } else {
                    console.error('❌ 加载申请中请求失败:', err);
                }
            });
    }

    function loadReceivedRequests() {
        console.log('🔄 开始加载待审批请求，用户ID:', state.currentUser.userId);

        fetch(state.basePath + '/LoadFriendRequestsServlet?userId=' + state.currentUser.userId + '&type=received', {
            credentials: 'include' // 关键：包含Session cookie
        })
            .then(res => {
                if (res.status === 401 || res.status === 403) {
                    throw new Error('会话过期');
                }
                console.log('📡 待审批请求响应状态:', res.status);
                return res.json();
            })
            .then(requests => {
                console.log('✅ 收到的待审批请求数据:', requests);
                console.log('📊 请求数量:', requests.length);
                renderRequests(elements.receivedRequests, requests, 'received');
            })
            .catch(err => {
                if (err.message === '会话过期') {
                    alert('登录已过期，请重新登录');
                    window.location.href = state.basePath + '/pages/login.jsp';
                } else {
                    console.error('❌ 加载待审批请求失败:', err);
                }
            });
    }

    function renderRequests(container, requests, type) {
        console.log('🎨 开始渲染请求列表，类型:', type, '数量:', requests.length, '容器:', container);

        // 清空容器
        container.innerHTML = '';

        if (!requests || requests.length === 0) {
            console.log('📭 没有请求数据，显示空状态');
            const emptyDiv = document.createElement('div');
            emptyDiv.className = 'empty-tip';
            emptyDiv.textContent = '暂无' + (type === 'pending' ? '申请中' : '待审批') + '请求';
            container.appendChild(emptyDiv);
            return;
        }

        // 创建标题
        const title = document.createElement('div');
        title.className = "request-title " + (type === 'pending' ? 'yellow' : 'lightblue');

        // 创建标题内容
        const titleContent = document.createElement('span');
        titleContent.className = 'title-text';
        titleContent.textContent = (type === 'pending' ? '申请中（' + requests.length + '）' : '待审批（' + requests.length + '）');

        // 创建箭头
        const arrow = document.createElement('span');
        arrow.className = 'arrow';
        arrow.textContent = '▼';
        arrow.style.marginLeft = '8px';
        arrow.style.fontSize = '12px';
        arrow.style.transition = 'transform 0.3s ease';

        // 组装标题
        title.appendChild(titleContent);
        title.appendChild(arrow);
        container.appendChild(title);

        // 创建列表容器
        const listContainer = document.createElement('div');
        listContainer.className = 'request-list show';
        container.appendChild(listContainer);

        console.log('🖼️ 开始渲染请求项，数量:', requests.length);

        // 渲染每个请求项
        requests.forEach((req, index) => {
            console.log('  渲染请求项', index, ':', '用户名=', req.username, '编号=', req.userCode);

            const item = document.createElement('div');
            item.className = 'request-item';

            // 用户信息
            const userInfo = document.createElement('span');
            userInfo.className = 'user-info';
            userInfo.textContent = req.username + ' (' + req.userCode + ')';

            // 时间
            const time = document.createElement('span');
            time.className = 'time';
            if (req.requestTime) {
                const formattedTime = req.requestTime.replace(/:\d+$/, ''); // 去掉最后的秒数
                time.textContent = formattedTime;
            }

            // 按钮容器
            const actionButtons = document.createElement('div');
            actionButtons.className = 'action-buttons';

            // 构建操作按钮
// 构建操作按钮
            if (type === 'received') {
                const agreeBtn = document.createElement('button');
                agreeBtn.className = 'agree-btn';
                agreeBtn.textContent = '同意';

                // 关键：这里req.userId是申请者ID，state.currentUser.userId是接收者ID
                agreeBtn.dataset.requestId = req.id;
                agreeBtn.dataset.requesterId = req.userId;  // 申请者
                agreeBtn.dataset.receiverId = state.currentUser.userId; // 接收者（当前用户）

                const rejectBtn = document.createElement('button');
                rejectBtn.className = 'reject-btn';
                rejectBtn.textContent = '拒绝';
                rejectBtn.dataset.requestId = req.id;
                rejectBtn.dataset.requesterId = req.userId;  // 申请者
                rejectBtn.dataset.receiverId = state.currentUser.userId; // 接收者（当前用户）

                actionButtons.appendChild(agreeBtn);
                actionButtons.appendChild(rejectBtn);
            }

            // 删除按钮（删除模式下显示）
            if (state.isDeleteMode) {
                const deleteBtn = document.createElement('button');
                deleteBtn.className = 'temp-delete';
                deleteBtn.textContent = '删除';
                deleteBtn.setAttribute('data-id', req.id);
                deleteBtn.setAttribute('data-type', type);
                actionButtons.appendChild(deleteBtn);
            }

            // 组装item
            item.appendChild(userInfo);
            item.appendChild(time);
            item.appendChild(actionButtons);

            listContainer.appendChild(item);
            console.log('  ✅ 已添加请求项到DOM');
        });

        // 点击标题展开/收起列表
        title.addEventListener('click', function() {
            const isShowing = listContainer.classList.contains('show');
            console.log('📌 点击了标题，当前显示状态:', isShowing);

            listContainer.classList.toggle('show');
            arrow.style.transform = listContainer.classList.contains('show')
                ? 'rotate(0deg)'
                : 'rotate(-90deg)';
        });

        // 绑定同意/拒绝按钮事件（待审批类型）
// 绑定同意/拒绝按钮事件
        if (type === 'received') {
            console.log('🔗 绑定同意/拒绝按钮事件');

            listContainer.querySelectorAll('.agree-btn').forEach(function(btn) {
                btn.addEventListener('click', function(e) {
                    e.stopPropagation();
                    console.log('👍 点击同意按钮');

                    const requestId = parseInt(this.dataset.requestId);
                    const requesterId = parseInt(this.dataset.requesterId);
                    const receiverId = parseInt(this.dataset.receiverId);

                    console.log('参数:', {requestId, requesterId, receiverId});

                    handleRequest(requestId, 1, requesterId, receiverId);
                });
            });

            listContainer.querySelectorAll('.reject-btn').forEach(function(btn) {
                btn.addEventListener('click', function(e) {
                    e.stopPropagation();
                    console.log('👎 点击拒绝按钮');

                    const requestId = parseInt(this.dataset.requestId);
                    const requesterId = parseInt(this.dataset.requesterId);
                    const receiverId = parseInt(this.dataset.receiverId);

                    console.log('参数:', {requestId, requesterId, receiverId});

                    handleRequest(requestId, 2, requesterId, receiverId);
                });
            });
        }

        // 绑定删除按钮事件（删除模式）
        listContainer.querySelectorAll('.temp-delete').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                console.log('🗑️ 点击删除按钮');
                const requestId = parseInt(btn.getAttribute('data-id'));
                const requestType = btn.getAttribute('data-type');
                if (confirm('确定删除此请求吗？')) {
                    deleteFriendRequest(requestId, requestType);
                }
            });
        });

        console.log('🎉 渲染完成，标题文本:', titleContent.textContent);
    }

    // 处理好友请求的辅助函数
    function handleRequest(requestId, status, requesterId, receiverId) {
        console.log('=== 处理好友请求 ===');
        console.log('请求参数:', {
            requestId: requestId,
            status: status,
            userId: requesterId,      // 申请者ID
            friendId: receiverId      // 接收者ID
        });
        if (!requestId || !status || !requesterId || !receiverId) {
            console.error('参数无效');
            alert('参数错误');
            return;
        }
        const url = state.basePath + '/HandleFriendRequestServlet';
        const params = new URLSearchParams();
        params.append('requestId', requestId);
        params.append('status', status);
        params.append('userId', requesterId);      // 申请者ID
        params.append('friendId', receiverId);     // 接收者ID
        console.log('请求字符串:', params.toString());
        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString(),
            credentials: 'include'
        })
            .then(res => res.text())
            .then(msg => {
                console.log('服务器返回:', msg);
                if (msg === 'success') {
                    if (status === 1) {
                        alert('你们已添加为好友');
                    } else if (status === 2) {
                        alert('你拒绝了他的好友请求');
                    }
                    // 刷新列表
                    loadReceivedRequests();
                    loadFriends();
                    setTimeout(() => loadPendingRequests(), 1000);
                } else {
                    alert('操作失败：' + msg);
                }
            })
            .catch(err => {
                console.error('请求失败:', err);
                alert('网络错误');
            });
    }

    // 删除好友请求的辅助函数
    function deleteFriendRequest(requestId, type) {
        console.log('🗑️ 删除好友请求:', requestId, type);

        fetch(state.basePath + '/DeleteFriendRequestServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `requestId=${requestId}&userId=${state.currentUser.userId}`,
            credentials: 'include' // 关键：包含Session cookie
        })
            .then(res => {
                if (res.status === 401 || res.status === 403) {
                    throw new Error('会话过期');
                }
                return res.text();
            })
            .then(msg => {
                console.log('删除请求响应:', msg);
                if (msg === 'success') {
                    alert('删除成功');
                    // 重新加载对应的请求列表
                    if (type === 'pending') {
                        loadPendingRequests();
                    } else {
                        loadReceivedRequests();
                    }
                } else {
                    alert('删除失败: ' + msg);
                }
            })
            .catch(err => {
                if (err.message === '会话过期') {
                    alert('登录已过期，请重新登录');
                    window.location.href = state.basePath + '/pages/login.jsp';
                } else {
                    console.error('删除请求失败:', err);
                    alert('网络错误，请重试');
                }
            });
    }

    // 搜索好友函数（修复版）
    function searchFriends(keyword) {
        if (!keyword) {
            elements.searchResult.classList.remove('show');
            return;
        }
        fetch(state.basePath + '/SearchUserServlet?keyword=' + encodeURIComponent(keyword) + '&excludeSelf=' + state.currentUser.userId, {
            credentials: 'include' // 关键：包含Session cookie
        })
            .then(res => {
                if (res.status === 401 || res.status === 403) {
                    throw new Error('会话过期');
                }
                return res.json();
            })
            .then(users => {
                console.log('搜索到用户数据:', users);

                elements.searchResult.innerHTML = '';

                if (users && users.length > 0) {
                    users.forEach((user, index) => {
                        console.log('渲染用户' + index + ':', user);

                        const item = document.createElement('div');
                        item.className = 'result-item';

                        const identityLabel = user.identity === 'geren' ?
                            '<span style="font-size:12px; color: green; margin-left: 8px;">个人</span>' :
                            '<span style="font-size:12px; color: blue; margin-left: 8px;">游客</span>';

                        // 关键修改：使用 userId 而不是 userCode
                        item.innerHTML =
                            '<span>' + user.username + '（' + user.userCode + '）' + identityLabel + '</span>' +
                            '<button class="add-friend" data-id="' + user.userId + '">添加</button>';

                        elements.searchResult.appendChild(item);
                    });
                } else {
                    elements.searchResult.innerHTML = '<div>未找到用户</div>';
                }
                elements.searchResult.classList.add('show');
            })
            .catch(err => {
                if (err.message === '会话过期') {
                    alert('登录已过期，请重新登录');
                    window.location.href = state.basePath + '/pages/login.jsp';
                } else {
                    console.error('搜索失败:', err);
                    elements.searchResult.innerHTML = '<div>搜索失败</div>';
                    elements.searchResult.classList.add('show');
                }
            });
    }

    // 发送好友请求（修复版 - 解决"请先登录"问题）
    function sendFriendRequest(friendId) {
        console.log('发送好友请求，目标用户ID:', friendId, '类型:', typeof friendId);
        // 再次检查登录状态
        if (!state.currentUser || !state.currentUser.userId) {
            alert('请先登录');
            window.location.href = state.basePath + '/pages/login.jsp';
            return;
        }

        // 调试：检查参数是否正确
        console.log('请求参数:', {
            friendId: friendId,
            userId: state.currentUser.userId
        });

        // 关键修复：使用正确的参数名和值
        const params = new URLSearchParams();
        params.append('friendId', friendId);  // 参数名必须与Servlet中的getParameter("friendId")一致
        params.append('userId', state.currentUser.userId);

        console.log('请求参数字符串:', params.toString());

        fetch(state.basePath + '/AddFriendServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded' // 关键：必须设置正确的Content-Type
            },
            body: params.toString(), // 使用URLSearchParams的字符串形式
            credentials: 'include' // 关键：包含Session cookie
        })
            .then(res => {
                console.log('响应状态:', res.status, res.statusText);
                if (res.status === 401 || res.status === 403) {
                    throw new Error('会话过期');
                }
                return res.text();
            })
            .then(msg => {
                console.log('服务器响应:', msg);
                if (msg === 'success') {
                    alert('好友请求已发送！');
                    elements.searchFriend.value = ''; // 清空搜索框
                    elements.searchResult.classList.remove('show'); // 隐藏搜索结果
                    loadPendingRequests(); // 刷新"申请中"列表
                } else {
                    alert('发送失败：' + msg);
                }
            })
            .catch(err => {
                if (err.message === '会话过期') {
                    alert('登录已过期，请重新登录');
                    window.location.href = state.basePath + '/pages/login.jsp';
                } else {
                    console.error('发送好友请求失败:', err);
                    alert('网络错误，请重试');
                }
            });
    }

    // 2. 消息互动功能
    function enterChat(friendId, friendName) {
        document.getElementById('chatTitle').textContent = `与 ${friendName} 聊天`;
        fetch(state.basePath + '/LoadChatMessagesServlet?userId=' + state.currentUser.userId + '&friendId=' + friendId, {
            credentials: 'include' // 关键：包含Session cookie
        })
            .then(res => {
                if (res.status === 401 || res.status === 403) {
                    throw new Error('会话过期');
                }
                return res.json();
            })
            .then(messages => {
                renderMessages(messages);
            })
            .catch(err => {
                if (err.message === '会话过期') {
                    alert('登录已过期，请重新登录');
                    window.location.href = state.basePath + '/pages/login.jsp';
                }
            });
    }

    // 加载消息列表（包含回复）
    function loadMessages() {
        // 请求你的LoadPublicMessagesServlet
        fetch(state.basePath + '/LoadPublicMessagesServlet', {
            credentials: 'include' // 关键：包含Session cookie
        })
            .then(res => {
                if (res.status === 401 || res.status === 403) {
                    throw new Error('会话过期');
                }
                if (!res.ok) throw new Error('加载消息失败');
                return res.json();
            })
            .then(result => {
                console.log('加载到的消息（含回复）：', result);

                // 关键修复：正确处理返回的对象结构
                if (result && result.success === true) {
                    // 使用 result.messages 而不是直接使用 result
                    const messages = result.messages || [];
                    console.log('实际消息数据：', messages);
                    renderMessages(messages); // 渲染时包含回复
                } else {
                    console.error('加载消息失败：', result?.msg);
                    renderMessages([]);
                }
            })
            .catch(err => {
                if (err.message === '会话过期') {
                    alert('登录已过期，请重新登录');
                    window.location.href = state.basePath + '/pages/login.jsp';
                } else {
                    console.error('加载消息出错：', err);
                    renderMessages([]);
                }
            });
    }

    // 1. 在loadPublicMessages函数外面，全局定义一个变量
    let isLoadingMessages = false;
    // 1. 加载公共评论列表的核心函数（解决自动刷新问题）
    function loadPublicMessages() {
        // 新增：如果正在加载，直接返回，避免重复执行
        if (isLoadingMessages) {
            console.log('【加载评论】正在加载中，跳过重复请求');
            return;
        }
        isLoadingMessages = true; // 标记为"正在加载"

        // ------------ 下面是你原有的loadPublicMessages代码 ------------
        console.log('【触发加载评论】当前时间：', new Date().toLocaleTimeString());
        const contextPath = state.basePath;
        const url = contextPath + '/LoadPublicMessagesServlet';

        console.log('【加载评论】请求URL：', url);
        fetch(url, {
            credentials: 'include' // 关键：包含Session cookie
        })
            .then(response => {
                if (response.status === 401 || response.status === 403) {
                    throw new Error('会话过期');
                }
                return response.json();
            })
            .then(result => {
                console.log('【后端返回的原始消息】', result.messages);

                // 关键修复：正确处理返回的对象结构
                if (result && result.success === true) {
                    // 使用 result.messages 而不是直接使用 result
                    const messages = result.messages || [];
                    console.log('实际消息数据：', messages);

                    // 只调用一次 renderMessages
                    renderMessages(messages);
                } else {
                    console.warn('加载评论失败：', result?.msg);
                    renderMessages([]);
                }
            })
            .catch(error => {
                if (error.message === '会话过期') {
                    alert('登录已过期，请重新登录');
                    window.location.href = state.basePath + '/pages/login.jsp';
                } else {
                    console.error('加载评论异常：', error);
                    renderMessages([]);
                }
            })
            .finally(() => {
                // 新增：加载完成后，重置为"未加载"
                isLoadingMessages = false;
            });
    }

    // 全局定义：标记是否正在发送评论
    let isSendingMessage = false;
    // 2. 发送评论的函数（你的原有函数，已保留所有逻辑）
    function sendMessage() {
        // 新增：如果正在发送，直接返回
        if (isSendingMessage) {
            console.log('【发送评论】正在发送中，跳过重复点击');
            return;
        }
        isSendingMessage = true; // 标记为"正在发送"


        // ------------ 下面是你原有的sendMessage代码 ------------
        // 1. 获取评论输入框DOM元素
        const input = document.querySelector('#messageInput');
        // 容错：如果输入框不存在，直接返回并打印错误
        if (!input) {
            console.error('未找到评论输入框，ID为messageInput的元素不存在');
            alert('页面异常，未找到输入框');
            isSendingMessage = false;
            return;
        }

        // 2. 获取并处理输入内容（保留首尾空格，避免后端误判为空）
        let content = input.value; // 原始内容，不先trim
        const pureContent = content.trim(); // 去除首尾空格的纯内容
        // 严格判断：如果纯内容为空，提示用户输入
        if (!pureContent) {
            alert('请输入有效的评论内容，不能仅包含空格');
            isSendingMessage = false;
            return;
        }

        // 3. 检查登录状态（更严谨的容错）
        if (!state) {
            console.error('全局state对象未定义');
            alert('页面状态异常，请刷新重试');
            isSendingMessage = false;
            return;
        }
        if (!state.currentUser) {
            alert('请先登录后再发送评论');
            window.location.href = state.basePath + '/pages/login.jsp';
            isSendingMessage = false;
            return;
        }
        if (!state.currentUser.userId || isNaN(state.currentUser.userId)) {
            console.error('当前用户ID无效，userId：', state.currentUser.userId);
            alert('用户信息异常，ID无效');
            isSendingMessage = false;
            return;
        }
        const userId = state.currentUser.userId;

        // 4. 拼接请求URL（容错：如果basePath未定义，使用空字符串）
        const basePath = state.basePath || '';
        const url = basePath + '/SendMessageServlet';
        console.log('【发送评论】请求URL：', url);
        console.log('【发送评论】用户ID：', userId);
        console.log('【发送评论】原始内容：', content);
        console.log('【发送评论】纯内容：', pureContent);

        // 5. 发送POST请求到后端Servlet
        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            },
            // 传递参数：直接用原始内容，避免编码导致后端解析失败
            body: 'content=' + encodeURIComponent(content) + '&userId=' + userId,
            credentials: 'include' // 关键：包含Session cookie
        })
            .then(response => {
                console.log('【发送评论】后端响应状态：', response.status, response.statusText);
                if (response.status === 401 || response.status === 403) {
                    throw new Error('会话过期');
                }
                // 处理非200的响应状态
                if (!response.ok) {
                    throw new Error(`后端接口返回错误，状态码：${response.status}，状态信息：${response.statusText}`);
                }
                // 解析后端返回的JSON数据
                return response.json();
            })
            .then(result => {
                console.log('【发送评论】后端返回结果：', result);
                // 处理后端的业务逻辑结果
                if (result && result.success === true) {
                    console.log('【发送评论】成功，清空输入框并重新加载列表');
                    input.value = ''; // 清空输入框
                    // 重新加载公共消息列表，确保新评论显示
                    if (typeof loadPublicMessages === 'function') {
                        loadPublicMessages(); // 现在这个函数已定义，会自动刷新
                    } else {
                        console.warn('loadPublicMessages函数未定义，无法自动刷新列表');
                    }
                } else {
                    // 后端返回失败，提示具体原因
                    const errorMsg = result && result.msg ? result.msg : '发送失败，后端未返回具体原因';
                    alert('发送失败：' + errorMsg);
                    console.error('【发送评论】失败，原因：', errorMsg);
                }
            })
            .catch(error => {
                // 捕获网络错误、解析错误等异常
                if (error.message === '会话过期') {
                    alert('登录已过期，请重新登录');
                    window.location.href = state.basePath + '/pages/login.jsp';
                } else {
                    console.error('【发送评论】异常：', error);
                    alert('网络错误或接口异常，无法发送评论，请检查后端服务是否启动');
                }
            })
            .finally(() => {
                // 新增：无论成功/失败，都重置为"未发送"
                isSendingMessage = false;
            });
    }

    function renderMessages(messages) {
        console.log('=== 渲染消息调试 ===');
        console.log('原始消息数据：', messages);

        // 确保 messages 是数组
        if (!Array.isArray(messages)) {
            console.log("后端返回的不是数组，已转为空数组");
            messages = [];
        }

        console.log('消息数量：', messages.length);
        const messageList = document.getElementById('messageList');

        if (!messageList) {
            console.error('未找到messageList容器');
            return;
        }
        messageList.innerHTML = '';

        // 放宽过滤条件：只要有content就显示
        const validMessages = messages.filter(msg => msg && msg.content);

        console.log('有效消息数量：', validMessages.length);
        console.log('有效消息详情：', validMessages);

        if (validMessages.length === 0) {
            messageList.innerHTML = '<div class="empty-tip">暂无有效消息</div>';
            return;
        }

        // 排序逻辑
        validMessages.sort((a, b) => {
            const timeA = new Date(a.time || a.createTime || '').getTime();
            const timeB = new Date(b.time || b.createTime || '').getTime();
            return timeA !== timeB ? timeA - timeB : (a.id || 0) - (b.id || 0);
        });

        // 渲染逻辑
        validMessages.forEach(function(msg) {
            console.log('渲染单条消息：', msg);

            // 使用更宽松的数据处理
            const isSelf = window.state?.currentUser?.userId === (msg.userId || msg.user_id);
            const likeCount = msg.likeCount || 0;
            const collectCount = msg.collectCount || 0;
            const isLiked = msg.isLiked === true;
            const isCollected = msg.isCollected === true;
            const replyCount = msg.replyCount || 0;
            const username = msg.username || '';
            const userCode = msg.userCode || '';
            const content = msg.content || '';
            const time = msg.time || msg.createTime || '';

            // 生成消息项
            const msgItem = document.createElement('div');
            msgItem.dataset.id = msg.id || msg.messageId || '';
            msgItem.className = `message-item ${isSelf ? 'self-message' : 'message-others'}`;

            // 根据消息类型应用不同的样式
            if (isSelf) {
                // 自己的消息：右对齐 + 莫兰迪蓝渐变
                msgItem.style.cssText = `
                max-width: 75%;
                margin: 10px 0 !important;
                padding: 14px 16px !important;
                border-radius: 12px !important;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1) !important;
                background: linear-gradient(135deg, #A7C4D4, #8FB3C9) !important;
                color: white !important;
                margin-left: auto !important;
                float: right !important;
                clear: both !important;
            `;
            } else {
                // 他人的消息：左对齐 + 浅白背景
                msgItem.style.cssText = `
                max-width: 75%;
                margin: 10px 0 !important;
                padding: 14px 16px !important;
                border-radius: 12px !important;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1) !important;
                background: linear-gradient(135deg, #FFFFFF, #F8F9FA) !important;
                color: #2C3E50 !important;
                margin-right: auto !important;
                float: left !important;
                clear: both !important;
            `;
            }

            let html =
                '<div class="message-header">' + username + (userCode ? ' (' + userCode + ')' : '') + '</div>' +
                '<div class="message-content">' + content + '</div>' +
                '<div class="message-actions">' +
                '<span class="reply-btn">回复(' + replyCount + ')</span>' +
                '<span class="like-btn' + (isLiked ? ' liked' : '') + '">点赞(' + likeCount + ')</span>' +
                '<span class="collect-btn' + (isCollected ? ' collected' : '') + '">收藏(' + collectCount + ')</span>' +
                '<span class="time">' + time + '</span>' +
                '</div>' +
                '<div class="reply-input-area" style="display: none !important;">' +
                '<input type="text" class="reply-input" placeholder="输入回复...">' +
                '<button class="reply-send">发送</button>' +
                '</div>' +
                '<div class="replies-list" style="display: none !important;"></div>';

            msgItem.innerHTML = html;
            messageList.appendChild(msgItem);

            // 填充回复列表
            const repliesList = msgItem.querySelector('.replies-list');
// 在 renderMessages 函数中找到填充回复列表的部分，修改为：
            if (repliesList && msg.replies && msg.replies.length > 0) {
                let replyHtml = '';
                msg.replies.forEach(reply => {
                    replyHtml += '<div class="reply-item">' +
                        '<strong>' + (reply.username || '用户') + '</strong>: ' + (reply.content || '') +
                        '<span class="time">' + (reply.time || '') + '</span>' +
                        '</div>';
                });
                repliesList.innerHTML = replyHtml;
            }

            // ============ 关键：绑定回复事件 ============
            // 1. 绑定回复按钮点击事件
            const replyBtn = msgItem.querySelector('.reply-btn');
            const replyInputArea = msgItem.querySelector('.reply-input-area');
            const replyInput = msgItem.querySelector('.reply-input');
            const replySendBtn = msgItem.querySelector('.reply-send');

            if (replyBtn && replyInputArea) {
                replyBtn.addEventListener('click', function(e) {
                    e.stopPropagation();
                    const isShowing = replyInputArea.style.display === 'block';
                    replyInputArea.style.display = isShowing ? 'none' : 'block';

                    if (repliesList) {
                        repliesList.style.display = isShowing ? 'none' : 'block';
                    }

                    // 自动聚焦到输入框
                    if (!isShowing && replyInput) {
                        setTimeout(() => {
                            replyInput.focus();
                        }, 100);
                    }
                });
            }

            // 2. 绑定发送回复按钮事件
            if (replySendBtn && replyInput) {
                replySendBtn.addEventListener('click', function(e) {
                    e.stopPropagation();
                    const content = replyInput.value.trim();
                    if (content) {
                        sendReply(msg.id || msg.messageId, content, replyInput);
                    } else {
                        alert('请输入回复内容');
                    }
                });
            }

            // 3. 绑定回复输入框的Enter键事件
            if (replyInput) {
                replyInput.addEventListener('keypress', function(e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        e.stopPropagation();
                        const content = replyInput.value.trim();
                        if (content) {
                            sendReply(msg.id || msg.messageId, content, replyInput);
                        } else {
                            alert('请输入回复内容');
                        }
                    }
                });
            }
            // ============ 回复事件绑定结束 ============
        });

        messageList.scrollTop = messageList.scrollHeight;
    }

    // 4. 页面加载完成后，自动加载评论列表（打开页面就显示评论）
    document.addEventListener('DOMContentLoaded', function() {
        loadPublicMessages();
    });


    // 渲染完消息后，绑定回复发送事件
    function bindReplyEvents() {
        document.querySelectorAll('.reply-send').forEach(btn => {
            btn.addEventListener('click', function() {
                const input = this.previousElementSibling; // 获取输入框
                const content = input.value.trim();
                const msgItem = this.closest('.message-item'); // 获取当前消息项
                const msgId = msgItem.dataset.id; // 获取主消息ID

                if (!content) {
                    alert('请输入回复内容');
                    return;
                }

                // 发送回复到后端（需实现 sendReply 函数）
                sendReply(msgId, content, input);
            });
        });
    }


    function sendReply(targetMsgId, content, inputElement) {
        const userId = state.currentUser?.userId;
        if (!userId) {
            alert('请先登录');
            window.location.href = state.basePath + '/pages/login.jsp';
            return;
        }

        console.log('📤 发送回复，目标消息ID:', targetMsgId, '内容:', content);

        fetch(state.basePath + '/SendReplyServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: 'targetMsgId=' + targetMsgId + '&content=' + encodeURIComponent(content) + '&userId=' + userId,
            credentials: 'include'
        })
            .then(res => {
                if (res.status === 401 || res.status === 403) {
                    throw new Error('会话过期');
                }
                return res.json();
            })
            .then(data => {
                console.log('📥 回复发送结果:', data);
                if (data.success) {
                    // 清空输入框
                    inputElement.value = '';
                    // 找到消息项
                    const msgItem = inputElement.closest('.message-item');
                    if (!msgItem) {
                        console.error('未找到消息项');
                        return;
                    }

                    // 【核心修复】更新回复计数
                    const replyBtn = msgItem.querySelector('.reply-btn');
                    console.log('🔢 回复按钮原始文本:', replyBtn.textContent);

                    // 方法A：先尝试提取现有数字
                    const currentText = replyBtn.textContent;
                    let currentCount = 0;

                    // 查找括号内的数字
                    const startIndex = currentText.indexOf('(');
                    const endIndex = currentText.indexOf(')');

                    if (startIndex !== -1 && endIndex !== -1) {
                        const numStr = currentText.substring(startIndex + 1, endIndex);
                        console.log('提取的字符串:', numStr);

                        const num = parseInt(numStr);
                        if (!isNaN(num)) {
                            currentCount = num;
                        }
                    }

                    // +1 更新
                    const newCount = currentCount + 1;
                    console.log(`🎯 更新回复计数: ${currentCount} + 1 = ${newCount}`);
                    replyBtn.textContent = '回复(' + newCount + ')';

                    // 更新回复列表
                    const repliesList = msgItem.querySelector('.replies-list');
                    if (repliesList) {
                        repliesList.style.display = 'block';

                        const newReply = document.createElement('div');
                        newReply.className = 'reply-item';

                        // 关键：使用字符串拼接，不要用模板字符串
                        newReply.innerHTML =
                            '<strong>' + (state.currentUser.username || '用户') + '</strong>: ' + content +
                            '<span class="time">' + new Date().toLocaleTimeString() + '</span>';

                        repliesList.appendChild(newReply);
                        repliesList.scrollTop = repliesList.scrollHeight;
                    }

                    console.log('✅ 回复成功，新计数:', newCount);

                } else {
                    alert('发送失败：' + (data.msg || '未知错误'));
                }
            })
            .catch(err => {
                console.error('❌ 回复发送失败:', err);
                alert(err.message === '会话过期' ? '登录已过期，请重新登录' : '网络错误，请重试');
            });
    }


    // 页面加载完成后绑定发送按钮事件（避免重复绑定）
    document.addEventListener('DOMContentLoaded', function() {
        const sendBtn = document.querySelector('.message-send-btn'); // 确保按钮类名正确
        if (sendBtn) {
            sendBtn.addEventListener('click', sendMessage);
        }
    });


    function handleMessageAction(e) {
        const target = e.target;
        const msgItem = target.closest('.message-item');

        if (!msgItem) return;

        const msgId = msgItem.dataset.id;
        if (!msgId || !state.currentUser?.userId) {
            alert('请先登录');
            window.location.href = state.basePath + '/pages/login.jsp';
            return;
        }

        // ============ 1. 处理点赞 ============
        if (target.classList.contains('like-btn')) {
            e.preventDefault();
            e.stopPropagation();

            // 禁用按钮防止重复点击
            target.disabled = true;

            // 获取当前状态和数字
            const isLiked = target.classList.contains('liked');
            const numMatch = target.textContent.match(/\((\d+)\)/);
            let currentNum = numMatch ? parseInt(numMatch[1]) : 0;

            // ===== 立即更新UI（关键：先更新再请求）=====
            console.log('🔄 【前端】点赞前状态：isLiked=', isLiked, 'currentNum=', currentNum);

            if (!isLiked) {
                // 点赞：数字+1，添加样式
                currentNum++;
                target.classList.add('liked');
                target.style.color = '#ff4444';
                target.style.fontWeight = 'bold';
                console.log('🔼 【前端】UI更新：点赞，数字变为', currentNum);
            } else {
                // 取消点赞：数字-1，移除样式
                if (currentNum > 0) {
                    currentNum--;
                }
                target.classList.remove('liked');
                target.style.color = '';
                target.style.fontWeight = '';
                console.log('🔽 【前端】UI更新：取消点赞，数字变为', currentNum);
            }
            // 立即更新显示的数字
            target.textContent = '点赞(' + currentNum + ')';

            // ===== 发送请求到后端 =====
            const likeUrl = state.basePath + '/LikeMessageServlet?msgId=' + msgId + '&userId=' + state.currentUser.userId;
            console.log('📤 【请求】点赞URL:', likeUrl);

            fetch(likeUrl, {
                method: 'GET',
                credentials: 'include'
            })
                .then(res => {
                    console.log('📥 【响应】状态码:', res.status);

                    const contentType = res.headers.get('content-type') || '';
                    if (!contentType.includes('application/json')) {
                        return res.text().then(text => {
                            console.error('❌ 【错误】服务器返回的不是JSON');
                            throw new Error('服务器返回格式错误');
                        });
                    }

                    if (res.status === 401 || res.status === 403) {
                        throw new Error('会话过期');
                    }

                    if (!res.ok) {
                        throw new Error('HTTP ' + res.status);
                    }

                    return res.json();
                })
                .then(data => {
                    console.log('✅ 【成功】收到后端JSON数据:', data);
                    target.disabled = false;

                    if (data && data.success === true) {
                        console.log('🎉 【成功】后端确认操作成功');

                        // 方案A：完全使用前端当前显示的数字
                        const currentText = target.textContent;
                        const numMatch2 = currentText.match(/\((\d+)\)/);
                        const finalNum = numMatch2 ? parseInt(numMatch2[1]) : (isLiked ? currentNum - 1 : currentNum);

                        console.log('🔢 【数据】最终点赞数:', finalNum);

                        // 根据后端action更新样式
                        if (data.action === 'like') {
                            target.classList.add('liked');
                            target.style.color = '#ff4444';
                            target.style.fontWeight = 'bold';
                            console.log('❤️ 【状态】后端确认：已点赞');
                        } else if (data.action === 'cancel') {
                            target.classList.remove('liked');
                            target.style.color = '';
                            target.style.fontWeight = '';
                            console.log('♡ 【状态】后端确认：已取消点赞');
                        }

                        // 确保数字正确
                        target.textContent = '点赞(' + finalNum + ')';
                    } else {
                        console.error('❌ 【失败】后端返回success=false');

                        // 回滚UI
                        const currentIsLiked = target.classList.contains('liked');
                        if (currentIsLiked) {
                            const currentText = target.textContent;
                            const numMatch2 = currentText.match(/\((\d+)\)/);
                            let rollbackNum = numMatch2 ? parseInt(numMatch2[1]) : 0;
                            if (rollbackNum > 0) rollbackNum--;
                            target.classList.remove('liked');
                            target.style.color = '';
                            target.style.fontWeight = '';
                            target.textContent = '点赞(' + rollbackNum + ')';
                            console.log('↩️ 【回滚】取消点赞，数字设为', rollbackNum);
                        }

                        alert('点赞失败: ' + (data && data.msg ? data.msg : '未知错误'));
                    }
                })
                .catch(err => {
                    console.error('❌ 【异常】请求失败:', err);
                    target.disabled = false;

                    // 网络错误时保持前端状态（不回滚）
                    console.log('🌐 【网络错误】保持前端UI状态');

                    if (err.message.includes('会话过期')) {
                        alert('登录已过期，请重新登录');
                        window.location.href = state.basePath + '/pages/login.jsp';
                    } else if (err.message.includes('404')) {
                        console.log('⚠️ 点赞接口404，但前端UI已更新');
                    } else if (err.message.includes('405')) {
                        console.log('⚠️ 点赞接口405，但前端UI已更新');
                    } else {
                        console.log('⚠️ 网络错误，但前端UI已更新');
                    }
                });

            return;
        }

        // ============ 2. 处理收藏 ============
        if (target.classList.contains('collect-btn')) {
            e.preventDefault();
            e.stopPropagation();

            // 禁用按钮防止重复点击
            target.disabled = true;

            // 获取当前状态和数字
            const isCollected = target.classList.contains('collected');
            const numMatch = target.textContent.match(/\((\d+)\)/);
            let currentNum = numMatch ? parseInt(numMatch[1]) : 0;

            // ===== 立即更新UI（关键：先更新再请求）=====
            console.log('🔄 【前端】收藏前状态：isCollected=', isCollected, 'currentNum=', currentNum);

            if (!isCollected) {
                // 收藏：数字+1，添加样式
                currentNum++;
                target.classList.add('collected');
                target.style.color = '#ffaa00';
                target.style.fontWeight = 'bold';
                console.log('🔼 【前端】UI更新：收藏，数字变为', currentNum);
            } else {
                // 取消收藏：数字-1，移除样式
                if (currentNum > 0) {
                    currentNum--;
                }
                target.classList.remove('collected');
                target.style.color = '';
                target.style.fontWeight = '';
                console.log('🔽 【前端】UI更新：取消收藏，数字变为', currentNum);
            }
            // 立即更新显示的数字
            target.textContent = '收藏(' + currentNum + ')';

            // ===== 发送请求到后端 =====
            const collectUrl = state.basePath + '/CollectMessageServlet?msgId=' + msgId + '&userId=' + state.currentUser.userId;
            console.log('📤 【请求】收藏URL:', collectUrl);

            fetch(collectUrl, {
                method: 'GET',
                credentials: 'include'
            })
                .then(res => {
                    console.log('📥 【响应】状态码:', res.status);

                    const contentType = res.headers.get('content-type') || '';
                    if (!contentType.includes('application/json')) {
                        return res.text().then(text => {
                            console.error('❌ 【错误】服务器返回的不是JSON');
                            throw new Error('服务器返回格式错误');
                        });
                    }

                    if (res.status === 401 || res.status === 403) {
                        throw new Error('会话过期');
                    }

                    if (!res.ok) {
                        throw new Error('HTTP ' + res.status);
                    }

                    return res.json();
                })
                .then(data => {
                    console.log('✅ 【成功】收到后端JSON数据:', data);
                    target.disabled = false;

                    if (data && data.success === true) {
                        console.log('🎉 【成功】后端确认操作成功');

                        // 方案A：完全使用前端当前显示的数字
                        const currentText = target.textContent;
                        const numMatch2 = currentText.match(/\((\d+)\)/);
                        const finalNum = numMatch2 ? parseInt(numMatch2[1]) : (isCollected ? currentNum - 1 : currentNum);

                        console.log('🔢 【数据】最终收藏数:', finalNum);

                        // 根据后端action更新样式
                        if (data.action === 'collect') {
                            target.classList.add('collected');
                            target.style.color = '#ffaa00';
                            target.style.fontWeight = 'bold';
                            console.log('⭐ 【状态】后端确认：已收藏');
                        } else if (data.action === 'cancel') {
                            target.classList.remove('collected');
                            target.style.color = '';
                            target.style.fontWeight = '';
                            console.log('☆ 【状态】后端确认：已取消收藏');
                        }

                        // 确保数字正确
                        target.textContent = '收藏(' + finalNum + ')';
                    } else {
                        console.error('❌ 【失败】后端返回success=false');

                        // 回滚UI
                        const currentIsCollected = target.classList.contains('collected');
                        if (currentIsCollected) {
                            const currentText = target.textContent;
                            const numMatch2 = currentText.match(/\((\d+)\)/);
                            let rollbackNum = numMatch2 ? parseInt(numMatch2[1]) : 0;
                            if (rollbackNum > 0) rollbackNum--;
                            target.classList.remove('collected');
                            target.style.color = '';
                            target.style.fontWeight = '';
                            target.textContent = '收藏(' + rollbackNum + ')';
                            console.log('↩️ 【回滚】取消收藏，数字设为', rollbackNum);
                        }

                        alert('收藏失败: ' + (data && data.msg ? data.msg : '未知错误'));
                    }
                })
                .catch(err => {
                    console.error('❌ 【异常】请求失败:', err);
                    target.disabled = false;

                    // 网络错误时保持前端状态（不回滚）
                    console.log('🌐 【网络错误】保持前端UI状态');

                    if (err.message.includes('会话过期')) {
                        alert('登录已过期，请重新登录');
                        window.location.href = state.basePath + '/pages/login.jsp';
                    } else {
                        console.log('⚠️ 网络错误，但前端UI已更新');
                    }
                });

            return;
        }

        // ============ 3. 处理回复按钮（展开/收起回复框）============
        if (target.classList.contains('reply-btn')) {
            e.stopPropagation();

            const replyInputArea = msgItem.querySelector('.reply-input-area');
            const repliesList = msgItem.querySelector('.replies-list');

            if (replyInputArea) {
                const isShowing = replyInputArea.style.display === 'block' || replyInputArea.style.display === '';
                if (isShowing) {
                    replyInputArea.style.display = 'none';
                    if (repliesList) repliesList.style.display = 'none';
                    console.log('📤 收起回复框');
                } else {
                    replyInputArea.style.display = 'block';
                    if (repliesList) repliesList.style.display = 'block';
                    console.log('📥 展开回复框');

                    // 自动聚焦到输入框
                    setTimeout(() => {
                        const replyInput = replyInputArea.querySelector('.reply-input');
                        if (replyInput) replyInput.focus();
                    }, 100);
                }
            }
            return;
        }

        // ============ 4. 处理发送回复按钮 ============
        if (target.classList.contains('reply-send')) {
            e.stopPropagation();

            const replyInput = msgItem.querySelector('.reply-input');
            const content = replyInput.value.trim();

            if (!content) {
                alert('请输入回复内容');
                return;
            }

            console.log('📤 发送回复，内容:', content, '目标消息ID:', msgId);
            sendReply(msgId, content, replyInput);
            return;
        }

        // ============ 5. 处理回复输入框的Enter键 ============
        if (target.classList.contains('reply-input')) {
            if (e.key === 'Enter') {
                e.preventDefault();
                e.stopPropagation();

                const content = target.value.trim();
                if (!content) {
                    alert('请输入回复内容');
                    return;
                }

                console.log('📤 Enter键发送回复，内容:', content);
                sendReply(msgId, content, target);
            }
            return;
        }
    }

    // 统一处理点赞/收藏逻辑
    function handleLikeOrCollect(e, type) {
        const btn = e.target;
        const msgItem = btn.closest('.message-item');
        if (!msgItem) {
            console.error('未找到消息项');
            return;
        }

        // 获取消息ID
        const msgId = msgItem.dataset.id;
        if (!msgId || isNaN(msgId) || parseInt(msgId) <= 0) {
            console.error('无效的消息ID：', msgId);
            return;
        }

        // 禁用按钮，防止重复点击
        btn.disabled = true;

        // 拼接请求地址
        const url = state.basePath + '/' + (type === 'like' ? 'LikeMessageServlet' : 'CollectMessageServlet') + '?msgId=' + msgId + '&userId=' + state.currentUser.userId;

        fetch(url, {
            credentials: 'include' // 关键：包含Session cookie
        })
            .then(res => {
                if (res.status === 401 || res.status === 403) {
                    throw new Error('会话过期');
                }
                return res.json();
            })
            .then(data => {
                if (data.success) {
                    // 提取当前数字（核心：兼容初始值0）
                    const numMatch = btn.textContent.match(/\((\d+)\)/);
                    let currentNum = numMatch ? parseInt(numMatch[1]) : 0;

                    // 根据action更新数字和样式
                    if (data.action === type) {
                        // 点赞/收藏：+1，添加变色样式
                        currentNum += 1;
                        btn.classList.add('active');
                    } else if (data.action === 'cancel') {
                        // 取消：-1，移除变色样式（最小为0）
                        currentNum = Math.max(0, currentNum - 1);
                        btn.classList.remove('active');
                    }

                    // 更新按钮文字
                    btn.textContent = (type === 'like' ? '点赞' : '收藏') + '(' + currentNum + ')';
                } else {
                    console.error(type === 'like' ? '点赞' : '收藏' + '操作失败');
                }
            })
            .catch(err => {
                if (err.message === '会话过期') {
                    alert('登录已过期，请重新登录');
                    window.location.href = state.basePath + '/pages/login.jsp';
                } else {
                    console.error(type === 'like' ? '点赞' : '收藏' + '请求失败：', err);
                }
            })
            .finally(() => {
                // 恢复按钮
                btn.disabled = false;
            });
    }

    // 定时刷新所有消息的点赞/收藏数（每30秒一次，平衡实时性和性能）
    setInterval(() => {
        // 获取所有消息ID
        const msgItems = document.querySelectorAll('.message-item');
        if (msgItems.length === 0) return;

        // 批量查询计数（需后端提供批量接口）
        const msgIds = Array.from(msgItems).map(item => item.dataset.id).join(',');
        fetch(state.basePath + `/GetCountsServlet?msgIds=${msgIds}`, {
            credentials: 'include' // 关键：包含Session cookie
        })
            .then(res => {
                if (res.status === 401 || res.status === 403) {
                    return; // 静默处理，不重定向
                }
                return res.json();
            })
            .then(data => {
                // data格式：{ "1": {like: 2, collect: 1}, "2": {like: 0, collect: 1} }
                msgItems.forEach(item => {
                    const msgId = item.dataset.id;
                    const counts = data[msgId];
                    if (counts) {
                        // 更新点赞数
                        const likeBtn = item.querySelector('.like-btn');
                        if (likeBtn) {
                            likeBtn.textContent = `点赞(${counts.like})`;
                        }
                        // 更新收藏数
                        const collectBtn = item.querySelector('.collect-btn');
                        if (collectBtn) {
                            collectBtn.textContent = `收藏(${counts.collect})`;
                        }
                    }
                });
            })
            .catch(err => console.error('刷新计数失败：', err));
    }, 30000); // 30秒刷新一次

    // 3. 其他功能
    function showActionModal(type) {
        const isCollect = type === 'collect';
        elements.actionModalTitle.textContent = isCollect ? '我的收藏' : '我的点赞';
        elements.actionModalContent.innerHTML = '';

        // 关键：请求路径改为新建的Servlet，且携带当前用户ID
        fetch(state.basePath + `/GetMy${isCollect ? 'Collected' : 'Liked'}MessagesServlet?userId=${state.currentUser.userId}`, {
            credentials: 'include' // 关键：包含Session cookie
        })
            .then(res => {
                if (res.status === 401 || res.status === 403) {
                    throw new Error('会话过期');
                }
                return res.json();
            })
            .then(actions => {
                console.log('我的' + (isCollect ? '收藏' : '点赞') + '数据：', actions);
                if (actions.length === 0) {
                    elements.actionModalContent.innerHTML = '<div>暂无数据</div>';
                } else {
                    actions.forEach(action => {
                        const item = document.createElement('div');
                        item.className = 'message-item';
                        item.innerHTML = `
                        <div class="message-header">${action.username}</div>
                        <div class="message-content">${action.content}</div>
                        <div class="time">${action.time}</div>
                    `;
                        elements.actionModalContent.appendChild(item);
                    });
                }
                elements.actionModal.style.display = 'flex';
            })
            .catch(err => {
                if (err.message === '会话过期') {
                    alert('登录已过期，请重新登录');
                    window.location.href = state.basePath + '/pages/login.jsp';
                } else {
                    console.error('查询失败：', err);
                    elements.actionModalContent.innerHTML = '<div>加载失败，请重试</div>';
                    elements.actionModal.style.display = 'flex';
                }
            });
    }

    // 完整的 bindEvents() 函数
    function bindEvents() {
        // 1. 好友搜索功能
        const searchInput = document.getElementById('searchFriend');
        if (searchInput) {
            searchInput.addEventListener('input', function(e) {
                const keyword = e.target.value.trim();
                searchFriends(keyword);
            });

            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    const keyword = e.target.value.trim();
                    searchFriends(keyword);
                }
            });
        } else {
            console.error('未找到搜索框元素，请检查HTML中id是否为"searchFriend"');
        }

        // 关键修复：为搜索结果容器添加事件委托
        if (elements.searchResult) {
            elements.searchResult.addEventListener('click', function(e) {
                console.log('点击了搜索结果容器', e.target);
                if (e.target.classList.contains('add-friend')) {
                    console.log('点击了添加按钮');
                    const friendId = e.target.getAttribute('data-id') || e.target.dataset.id;
                    console.log('好友ID:', friendId);
                    if (friendId) {
                        sendFriendRequest(parseInt(friendId));
                    }
                }
            });
        }

        // 2. 删除模式切换按钮（核心修改）
// 在 bindEvents() 函数中修改：
        if (elements.deleteFriendBtn) {
            elements.deleteFriendBtn.addEventListener('click', function() {
                state.isDeleteMode = !state.isDeleteMode;
                const btnText = state.isDeleteMode ? '取消' : '删除';  // 只保留"删除好友"
                elements.deleteFriendBtn.textContent = btnText;
                elements.deleteFriendBtn.style.backgroundColor = state.isDeleteMode ? '#ff4444' : '';
                elements.deleteFriendBtn.style.color = state.isDeleteMode ? 'white' : '';

                console.log('删除模式:', state.isDeleteMode ? '开启' : '关闭');

                // 只刷新好友列表，不刷新请求列表
                loadFriends();
            });
        }

        // 3. 好友面板点击事件（处理删除按钮）
        if (elements.friendPanel) {
            elements.friendPanel.addEventListener('click', function(e) {
                const target = e.target;

                // ============ 处理好友删除按钮 ============
                if (target.classList.contains('delete-friend-action-btn')) {
                    e.stopPropagation();
                    console.log('点击好友删除按钮');

                    const friendItem = target.closest('.friend-item');
                    if (!friendItem) {
                        console.error('未找到对应的好友项');
                        return;
                    }

                    const friendId = friendItem.dataset.id;
                    const friendName = friendItem.querySelector('span').textContent;

                    if (confirm(`确定要删除好友 "${friendName}" 吗？\n\n这将同时删除双方的好友关系。`)) {
                        deleteFriend(friendId, friendItem);
                    }
                    return;
                }



                // ============ 原有的删除逻辑（保留兼容） ============
                if (target.classList.contains('temp-delete') && state.isDeleteMode) {
                    const id = target.dataset.id;
                    const type = target.dataset.type;
                    if (confirm('确定删除？')) {
                        // 这里调用通用的删除接口
                        deleteFriendOrRequest(id, type, target);
                    }
                }
            });
        }

        // 4. 消息发送功能
        if (elements.sendBtn) {
            elements.sendBtn.addEventListener('click', sendMessage);
        }

        if (elements.messageInput) {
            elements.messageInput.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    sendMessage();
                }
            });
        }

        // 5. 消息点赞/收藏/回复功能
        if (elements.messageList) {
            elements.messageList.addEventListener('click', handleMessageAction);
        }

        // 6. 我的收藏/点赞弹窗
        if (elements.collectBtn) {
            elements.collectBtn.addEventListener('click', () => showActionModal('collect'));
        }

        if (elements.likeBtn) {
            elements.likeBtn.addEventListener('click', () => showActionModal('like'));
        }

        if (elements.closeActionModal) {
            elements.closeActionModal.addEventListener('click', () => {
                elements.actionModal.style.display = 'none';
            });
        }

        // 7. 退出聊天按钮（如果存在）
        const exitChatBtn = document.getElementById('exitChatBtn');
        if (exitChatBtn) {
            exitChatBtn.addEventListener('click', function() {
                document.getElementById('chatTitle').textContent = '公共界面';
                loadPublicMessages();
            });
        }

        // 8. 返回公共按钮（如果存在）
        const exitActionBtn = document.getElementById('exitActionBtn');
        if (exitActionBtn) {
            exitActionBtn.addEventListener('click', function() {
                loadPublicMessages();
                this.style.display = 'none';
            });
        }

        // 9. 评论弹窗关闭按钮
        const closeReplyModal = document.getElementById('closeReplyModal');
        if (closeReplyModal) {
            closeReplyModal.addEventListener('click', function() {
                document.getElementById('replyModal').style.display = 'none';
            });
        }

        // 10. 换头像按钮（如果存在）
        const changeAvatarBtn = document.getElementById('changeAvatarBtn');
        if (changeAvatarBtn) {
            changeAvatarBtn.addEventListener('click', function() {
                alert('换头像功能正在开发中...');
            });
        }

        // 11. 换背景按钮（如果存在）
        const changeBgBtn = document.getElementById('changeBgBtn');
        if (changeBgBtn) {
            changeBgBtn.addEventListener('click', function() {
                alert('换背景功能正在开发中...');
            });
        }

        // 12. 好友项目点击事件（进入私聊）
        // 使用事件委托处理动态添加的好友项
        if (elements.friendList) {
            elements.friendList.addEventListener('click', function(e) {
                // 只有当点击的不是删除按钮时才进入聊天
                if (!e.target.classList.contains('delete-friend-action-btn') &&
                    !e.target.classList.contains('delete-request-btn')) {
                    const friendItem = e.target.closest('.friend-item');
                    if (friendItem) {
                        const friendId = friendItem.dataset.id;
                        const friendName = friendItem.querySelector('span').textContent;

                        // 只有在非删除模式下才进入聊天
                        if (!state.isDeleteMode) {
                            console.log('进入与', friendName, '的聊天');
                            enterChat(friendId, friendName);
                        }
                    }
                }
            });
        }
    }

    // ============ 辅助函数：刷新所有列表 ============
    function refreshAllLists() {
        // 重新加载好友列表以显示/隐藏删除按钮
        loadFriends();

        // 重新加载申请中和待审批列表
        loadPendingRequests();
        loadReceivedRequests();
    }

    // ============ 修改现有的渲染函数以支持删除模式 ============

    // 在 renderFriends() 函数的最后添加
    function renderFriends(friends) {
        console.log('渲染好友列表，数据：', friends);
        elements.friendList.innerHTML = '';

        if (!friends || friends.length === 0) {
            elements.friendList.innerHTML = '<div class="empty-tip">暂无好友</div>';
            return;
        }

        friends.forEach(friend => {
            const item = document.createElement('div');
            item.className = 'friend-item green';
            item.dataset.id = friend.friendId;

            const user = {
                username: friend.username,
                userCode: friend.userCode,
                userId: friend.friendId
            };

            item.innerHTML = '<span>' + user.username + '（' + user.userCode + '）</span>';

            // 新增：如果处于删除模式，添加删除按钮
            if (state.isDeleteMode) {
                const deleteBtn = document.createElement('button');
                deleteBtn.className = 'delete-friend-action-btn';
                deleteBtn.textContent = '删除';
                deleteBtn.style.cssText = `
                margin-left: 10px;
                padding: 2px 8px;
                background-color: #ff4444;
                color: white;
                border: none;
                border-radius: 3px;
                font-size: 12px;
                cursor: pointer;
            `;
                item.appendChild(deleteBtn);

                // 添加删除模式样式
                item.style.backgroundColor = '#ffe6e6';
                item.style.borderColor = '#ff4444';
            }

            elements.friendList.appendChild(item);
        });
    }

    // 在 renderRequests() 函数中添加删除按钮
    function renderRequests(container, requests, type) {
        console.log('🎨 开始渲染请求列表，类型:', type, '数量:', requests.length, '容器:', container);

        // 清空容器
        container.innerHTML = '';

        if (!requests || requests.length === 0) {
            console.log('📭 没有请求数据，显示空状态');
            const emptyDiv = document.createElement('div');
            emptyDiv.className = 'empty-tip';
            emptyDiv.textContent = '暂无' + (type === 'pending' ? '申请中' : '待审批') + '请求';
            container.appendChild(emptyDiv);
            return;
        }

        // 创建标题
        const title = document.createElement('div');
        title.className = "request-title " + (type === 'pending' ? 'yellow' : 'lightblue');

        // 创建标题内容
        const titleContent = document.createElement('span');
        titleContent.className = 'title-text';
        titleContent.textContent = (type === 'pending' ? '申请中（' + requests.length + '）' : '待审批（' + requests.length + '）');

        // 创建箭头
        const arrow = document.createElement('span');
        arrow.className = 'arrow';
        arrow.textContent = '▼';
        arrow.style.marginLeft = '8px';
        arrow.style.fontSize = '12px';
        arrow.style.transition = 'transform 0.3s ease';

        // 组装标题
        title.appendChild(titleContent);
        title.appendChild(arrow);
        container.appendChild(title);

        // 创建列表容器
        const listContainer = document.createElement('div');
        listContainer.className = 'request-list show';
        container.appendChild(listContainer);

        console.log('🖼️ 开始渲染请求项，数量:', requests.length);

        // 渲染每个请求项
        requests.forEach((req, index) => {
            console.log('  渲染请求项', index, ':', '用户名=', req.username, '编号=', req.userCode, '请求ID=', req.id);

            const item = document.createElement('div');
            item.className = 'request-item';

            // 在请求项元素上存储ID（作为备用获取方式）
            item.dataset.requestId = req.id;
            item.dataset.requestType = type;

            // 用户信息
            const userInfo = document.createElement('span');
            userInfo.className = 'user-info';
            userInfo.textContent = req.username + ' (' + req.userCode + ')';

            // 时间
            const time = document.createElement('span');
            time.className = 'time';
            if (req.requestTime) {
                const formattedTime = req.requestTime.replace(/:\d+$/, ''); // 去掉最后的秒数
                time.textContent = formattedTime;
            }

            // 按钮容器
            const actionButtons = document.createElement('div');
            actionButtons.className = 'action-buttons';

            // ============ 构建操作按钮 ============

            // 待审批的请求显示同意/拒绝按钮
            if (type === 'received') {
                const agreeBtn = document.createElement('button');
                agreeBtn.className = 'agree-btn';
                agreeBtn.textContent = '同意';
                agreeBtn.style.cssText = `
                margin-right: 5px;
                padding: 3px 10px;
                background-color: #4CAF50;
                color: white;
                border: none;
                border-radius: 3px;
                font-size: 12px;
                cursor: pointer;
            `;

                // 关键：这里req.userId是申请者ID，state.currentUser.userId是接收者ID
                agreeBtn.dataset.requestId = req.id;
                agreeBtn.dataset.requesterId = req.userId;  // 申请者
                agreeBtn.dataset.receiverId = state.currentUser.userId; // 接收者（当前用户）

                const rejectBtn = document.createElement('button');
                rejectBtn.className = 'reject-btn';
                rejectBtn.textContent = '拒绝';
                rejectBtn.style.cssText = `
                margin-right: 5px;
                padding: 3px 10px;
                background-color: #ff4444;
                color: white;
                border: none;
                border-radius: 3px;
                font-size: 12px;
                cursor: pointer;
            `;
                rejectBtn.dataset.requestId = req.id;
                rejectBtn.dataset.requesterId = req.userId;  // 申请者
                rejectBtn.dataset.receiverId = state.currentUser.userId; // 接收者（当前用户）

                actionButtons.appendChild(agreeBtn);
                actionButtons.appendChild(rejectBtn);
            }

            // ============ 删除按钮（删除模式下显示） ============
            if (state.isDeleteMode) {
                const deleteBtn = document.createElement('button');
                deleteBtn.className = 'delete-request-btn';
                deleteBtn.textContent = '删除';
                deleteBtn.style.cssText = `
                margin-left: 5px;
                padding: 3px 10px;
                background-color: #ff8800;
                color: white;
                border: none;
                border-radius: 3px;
                font-size: 12px;
                cursor: pointer;
            `;

                // 关键：设置多个数据属性确保能获取到
                deleteBtn.setAttribute('data-request-id', req.id);  // 使用setAttribute
                deleteBtn.dataset.requestId = req.id;                // 同时设置dataset
                deleteBtn.dataset.requestType = type;
                deleteBtn.title = '删除此请求';

                actionButtons.appendChild(deleteBtn);

                // 添加删除模式样式
                item.style.backgroundColor = '#fff3e0';
                item.style.borderLeft = '3px solid #ff8800';
            }

            // ============ 组装item ============
            item.appendChild(userInfo);
            item.appendChild(time);
            item.appendChild(actionButtons);

            listContainer.appendChild(item);
            console.log('  ✅ 已添加请求项到DOM，请求ID:', req.id);
        });

        // ============ 点击标题展开/收起列表 ============
        title.addEventListener('click', function() {
            const isShowing = listContainer.classList.contains('show');
            console.log('📌 点击了标题，当前显示状态:', isShowing);

            listContainer.classList.toggle('show');
            arrow.style.transform = listContainer.classList.contains('show')
                ? 'rotate(0deg)'
                : 'rotate(-90deg)';
        });

        // ============ 绑定同意/拒绝按钮事件（待审批类型） ============
        if (type === 'received') {
            console.log('🔗 绑定同意/拒绝按钮事件，数量:', listContainer.querySelectorAll('.agree-btn').length);

            listContainer.querySelectorAll('.agree-btn').forEach(function(btn) {
                btn.addEventListener('click', function(e) {
                    e.stopPropagation();
                    console.log('👍 点击同意按钮');

                    const requestId = parseInt(this.dataset.requestId);
                    const requesterId = parseInt(this.dataset.requesterId);
                    const receiverId = parseInt(this.dataset.receiverId);

                    console.log('同意请求参数:', {requestId, requesterId, receiverId});

                    handleRequest(requestId, 1, requesterId, receiverId);
                });
            });

            listContainer.querySelectorAll('.reject-btn').forEach(function(btn) {
                btn.addEventListener('click', function(e) {
                    e.stopPropagation();
                    console.log('👎 点击拒绝按钮');

                    const requestId = parseInt(this.dataset.requestId);
                    const requesterId = parseInt(this.dataset.requesterId);
                    const receiverId = parseInt(this.dataset.receiverId);

                    console.log('拒绝请求参数:', {requestId, requesterId, receiverId});

                    handleRequest(requestId, 2, requesterId, receiverId);
                });
            });
        }

        // ============ 绑定删除按钮事件（使用事件委托） ============
        // 注意：这里我们不在render函数中直接绑定，而是通过bindEvents()中的事件委托处理
        // 这样可以避免重复绑定和内存泄漏

        console.log('🎉 渲染完成，标题文本:', titleContent.textContent);

        // ============ 调试函数：检查所有请求项的数据 ============
        // 可选：添加调试功能
        setTimeout(() => {
            console.log('🔍 渲染完成后的DOM检查:');
            listContainer.querySelectorAll('.request-item').forEach((item, idx) => {
                const requestId = item.dataset.requestId;
                const deleteBtn = item.querySelector('.delete-request-btn');
                console.log(`  请求项 ${idx}: requestId=${requestId}, 删除按钮存在: ${!!deleteBtn}, 删除按钮dataset:`, deleteBtn?.dataset);
            });
        }, 100);
    }

    // ============ 删除好友函数 ============
    function deleteFriend(friendId, itemElement) {
        console.log('删除好友，ID:', friendId);

        // 添加删除中状态
        itemElement.style.opacity = '0.6';
        itemElement.style.pointerEvents = 'none';

        // 使用 URLSearchParams 确保参数正确传递
        const params = new URLSearchParams();
        params.append('friendId', friendId);
        params.append('userId', state.currentUser.userId);

        fetch(state.basePath + '/DeleteFriendServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params.toString(),
            credentials: 'include'
        })
            .then(res => {
                console.log('删除好友响应状态:', res.status);
                if (res.status === 404) {
                    throw new Error('DeleteFriendServlet未找到，请检查后端代码');
                }
                return res.text();
            })
            .then(msg => {
                console.log('删除好友响应内容:', msg);
                if (msg === 'success') {
                    // 删除成功动画
                    itemElement.style.transition = 'all 0.3s';
                    itemElement.style.transform = 'translateX(-100%)';
                    itemElement.style.opacity = '0';

                    setTimeout(() => {
                        if (itemElement.parentNode) {
                            itemElement.parentNode.removeChild(itemElement);
                        }
                        // 显示成功提示
                        showNotification('好友删除成功', 'success');
                    }, 300);
                } else {
                    // 恢复状态
                    itemElement.style.opacity = '1';
                    itemElement.style.pointerEvents = 'auto';
                    alert('删除失败: ' + msg);
                }
            })
            .catch(err => {
                console.error('删除好友失败:', err);
                // 恢复状态
                itemElement.style.opacity = '1';
                itemElement.style.pointerEvents = 'auto';
                alert('删除失败: ' + err.message);
            });
    }

    // ============ 删除好友请求函数 ============
    // ============ 删除好友请求函数（优化版） ============
    function deleteFriendRequest(requestId, requestType, itemElement) {
        console.log('=== deleteFriendRequest() 开始 ===');
        console.log('参数:', {requestId, requestType, itemElement});

        // ============ 参数验证 ============
        if (!requestId) {
            console.error('❌ 错误: requestId 为空');
            alert('错误: 请求ID不能为空');
            return;
        }

        // 转换为数字（处理可能的字符串）
        requestId = parseInt(requestId);
        if (isNaN(requestId) || requestId <= 0) {
            console.error('❌ 错误: requestId 不是有效数字', requestId);
            alert('错误: 请求ID格式不正确');
            return;
        }

        // 获取用户名用于确认提示
        let userName = '未知用户';
        if (itemElement) {
            const userInfoEl = itemElement.querySelector('.user-info');
            if (userInfoEl) {
                userName = userInfoEl.textContent.trim();
            }
        }

        // 确认提示
        const actionText = requestType === 'pending' ? '我发送的' : '我收到的';
        if (!confirm(`确定要删除${actionText}对 "${userName}" 的好友请求吗？\n\n此操作不可撤销。`)) {
            console.log('用户取消了删除操作');
            return;
        }

        // ============ UI状态更新 ============
        if (itemElement) {
            // 添加删除中状态
            itemElement.style.opacity = '0.6';
            itemElement.style.pointerEvents = 'none';
            itemElement.style.transition = 'all 0.3s';

            // 添加加载动画
            const originalText = itemElement.querySelector('.delete-request-btn')?.textContent;
            if (originalText) {
                itemElement.querySelector('.delete-request-btn').textContent = '删除中...';
                itemElement.querySelector('.delete-request-btn').style.opacity = '0.7';
            }
        }

        // ============ 准备请求参数 ============
        const params = new URLSearchParams();
        params.append('requestId', requestId);
        params.append('userId', state.currentUser.userId);
        params.append('requestType', requestType); // 新增参数，供后端调试

        console.log('发送删除请求参数:', {
            url: state.basePath + '/DeleteFriendRequestServlet',
            method: 'POST',
            params: params.toString(),
            credentials: 'include'
        });

        // ============ 发送请求 ============
        fetch(state.basePath + '/DeleteFriendRequestServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: params.toString(),
            credentials: 'include'
        })
            .then(response => {
                console.log('响应状态:', response.status, response.statusText);
                console.log('响应头:', Object.fromEntries(response.headers.entries()));

                if (response.status === 404) {
                    throw new Error('DeleteFriendRequestServlet 未找到，请检查后端代码部署');
                }
                if (response.status === 500) {
                    throw new Error('服务器内部错误');
                }
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }

                return response.text();
            })
            .then(result => {
                console.log('服务器返回结果:', result);

                if (result === 'success') {
                    // ============ 删除成功处理 ============
                    console.log('✅ 好友请求删除成功');

                    if (itemElement) {
                        // 成功动画
                        itemElement.style.transform = 'translateX(-100%)';
                        itemElement.style.opacity = '0';

                        // 3秒后从DOM移除
                        setTimeout(() => {
                            if (itemElement.parentNode) {
                                itemElement.parentNode.removeChild(itemElement);
                                console.log('已从DOM移除请求项');
                            }
                        }, 300);
                    }

                    // 显示成功通知
                    showNotification('好友请求删除成功', 'success');

                    // 重新加载对应的请求列表（延迟执行，避免冲突）
                    setTimeout(() => {
                        console.log('重新加载请求列表，类型:', requestType);
                        if (requestType === 'pending') {
                            loadPendingRequests();
                        } else if (requestType === 'received') {
                            loadReceivedRequests();
                        }
                    }, 500);

                } else {
                    // ============ 删除失败处理 ============
                    console.error('❌ 删除失败:', result);

                    if (itemElement) {
                        // 恢复UI状态
                        itemElement.style.opacity = '1';
                        itemElement.style.pointerEvents = 'auto';
                        itemElement.style.transform = 'translateX(0)';

                        // 恢复按钮文字
                        const deleteBtn = itemElement.querySelector('.delete-request-btn');
                        if (deleteBtn) {
                            deleteBtn.textContent = '删除';
                            deleteBtn.style.opacity = '1';
                        }
                    }

                    // 显示错误提示
                    let errorMsg = '删除失败';
                    if (result.includes('不存在')) errorMsg = '该请求不存在或已被删除';
                    else if (result.includes('登录')) errorMsg = '请重新登录';
                    else if (result.includes('参数')) errorMsg = '参数错误';

                    showNotification(errorMsg, 'error');
                }
            })
            .catch(error => {
                // ============ 网络/服务器错误处理 ============
                console.error('❌ 删除请求失败:', error);

                if (itemElement) {
                    // 恢复UI状态
                    itemElement.style.opacity = '1';
                    itemElement.style.pointerEvents = 'auto';
                    itemElement.style.transform = 'translateX(0)';

                    // 恢复按钮文字
                    const deleteBtn = itemElement.querySelector('.delete-request-btn');
                    if (deleteBtn) {
                        deleteBtn.textContent = '删除';
                        deleteBtn.style.opacity = '1';
                    }
                }

                // 显示错误通知
                let errorMsg = '网络错误，请检查连接';
                if (error.message.includes('404')) errorMsg = '服务器接口未找到';
                else if (error.message.includes('500')) errorMsg = '服务器内部错误';

                showNotification(errorMsg, 'error');
                console.log('=== deleteFriendRequest() 结束（错误）===');
            })
            .finally(() => {
                console.log('=== deleteFriendRequest() 结束 ===');
            });
    }

    // ============ 显示通知函数（优化版） ============
    function showNotification(message, type = 'info') {
        // 移除之前的同类型通知
        document.querySelectorAll('.notification').forEach(n => {
            if (n.parentNode) n.parentNode.removeChild(n);
        });

        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.textContent = message;

        // 样式配置
        const styles = {
            success: { bg: '#4CAF50', icon: '✅' },
            error: { bg: '#f44336', icon: '❌' },
            info: { bg: '#2196F3', icon: 'ℹ️' },
            warning: { bg: '#ff9800', icon: '⚠️' }
        };

        const style = styles[type] || styles.info;

        notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 24px;
        background-color: ${style.bg};
        color: white;
        border-radius: 6px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 9999;
        animation: slideInRight 0.3s ease;
        font-size: 14px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 8px;
        max-width: 300px;
        word-break: break-word;
    `;

        // 添加图标
        notification.innerHTML = `${style.icon} ${message}`;

        document.body.appendChild(notification);

        // 4秒后自动消失
        setTimeout(() => {
            notification.style.animation = 'slideOutRight 0.3s ease';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }, 4000);

        // 点击关闭
        notification.addEventListener('click', () => {
            notification.style.animation = 'slideOutRight 0.3s ease';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        });

        // 添加CSS动画
        if (!document.getElementById('notification-animations')) {
            const styleSheet = document.createElement('style');
            styleSheet.id = 'notification-animations';
            styleSheet.textContent = `
            @keyframes slideInRight {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
            @keyframes slideOutRight {
                from { transform: translateX(0); opacity: 1; }
                to { transform: translateX(100%); opacity: 0; }
            }
        `;
            document.head.appendChild(styleSheet);
        }
    }

    // ============ 显示通知函数 ============
    function showNotification(message, type) {
        // 创建通知元素
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.textContent = message;
        notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 10px 20px;
        background-color: ${type == 'success' ? '#4CAF50' : '#f44336'};
        color: white;
        border-radius: 4px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.2);
        z-index: 1000;
        animation: slideIn 0.3s ease;
    `;

        document.body.appendChild(notification);

        // 3秒后自动消失
        setTimeout(() => {
            notification.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }, 3000);

        // 添加CSS动画
        if (!document.getElementById('notification-styles')) {
            const style = document.createElement('style');
            style.id = 'notification-styles';
            style.textContent = `
            @keyframes slideIn {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
            @keyframes slideOut {
                from { transform: translateX(0); opacity: 1; }
                to { transform: translateX(100%); opacity: 0; }
            }
        `;
            document.head.appendChild(style);
        }
    }

    // 页面加载后初始化
    window.onload = function() {
        init();
        bindEvents();
        // 保存用户信息到sessionStorage，供其他页面使用
        if (state.currentUser && state.currentUser.userId) {
            sessionStorage.setItem('currentUser', JSON.stringify(state.currentUser));
        }
    };

    // ============ 辅助函数：刷新所有列表 ============
    function refreshAllLists() {
        // 重新加载好友列表以显示/隐藏删除按钮
        loadFriends();

        // 重新加载申请中和待审批列表
        loadPendingRequests();
        loadReceivedRequests();
    }

    // ============ 辅助函数：为好友项添加删除按钮 ============
    function addDeleteButtonsToFriends() {
        if (!state.isDeleteMode) return;

        document.querySelectorAll('.friend-item').forEach(item => {
            // 如果还没有删除按钮，则添加
            if (!item.querySelector('.delete-friend-action-btn')) {
                const deleteBtn = document.createElement('button');
                deleteBtn.className = 'delete-friend-action-btn';
                deleteBtn.textContent = '删除';
                deleteBtn.style.cssText = `
                margin-left: 10px;
                padding: 2px 8px;
                background-color: #ff4444;
                color: white;
                border: none;
                border-radius: 3px;
                font-size: 12px;
                cursor: pointer;
            `;
                item.appendChild(deleteBtn);
            }

            // 添加删除模式样式
            item.style.backgroundColor = '#ffe6e6';
            item.style.borderColor = '#ff4444';
        });
    }

    // ============ 辅助函数：为请求项添加删除按钮 ============
    function addDeleteButtonsToRequests() {
        if (!state.isDeleteMode) return;

        document.querySelectorAll('.request-item').forEach(item => {
            const actionButtons = item.querySelector('.action-buttons');
            if (actionButtons && !actionButtons.querySelector('.delete-request-btn')) {
                const deleteBtn = document.createElement('button');
                deleteBtn.className = 'delete-request-btn';
                deleteBtn.textContent = '删除';
                deleteBtn.style.cssText = `
                margin-left: 5px;
                padding: 2px 8px;
                background-color: #ff8800;
                color: white;
                border: none;
                border-radius: 3px;
                font-size: 12px;
                cursor: pointer;
            `;

                // 从父元素获取请求信息
                const requestContainer = item.closest('.pendingRequests, .receivedRequests');
                const requestType = requestContainer.id === 'pendingRequests' ? 'pending' : 'received';
                const requestId = item.querySelector('.agree-btn')?.dataset.requestId ||
                    item.querySelector('.reject-btn')?.dataset.requestId;

                if (requestId) {
                    deleteBtn.dataset.requestId = requestId;
                    deleteBtn.dataset.requestType = requestType;
                }

                actionButtons.appendChild(deleteBtn);
            }

            // 添加删除模式样式
            item.style.backgroundColor = '#fff3e0';
        });
    }

    // ============ 删除好友函数 ============
    function deleteFriend(friendId, itemElement) {
        console.log('删除好友，ID:', friendId);

        // 添加删除中状态
        itemElement.style.opacity = '0.6';
        itemElement.style.pointerEvents = 'none';

        // 修复：使用正确的参数名
        const params = new URLSearchParams();
        params.append('friendId', friendId);  // 参数名必须是friendId
        params.append('userId', state.currentUser.userId);

        fetch(state.basePath + '/DeleteFriendServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params.toString(),  // 使用URLSearchParams
            credentials: 'include'
        })
            .then(res => {
                console.log('删除好友响应状态:', res.status);
                if (res.status === 404) {
                    throw new Error('DeleteFriendServlet未找到，请检查后端代码');
                }
                return res.text();
            })
            .then(msg => {
                console.log('删除好友响应内容:', msg);
                if (msg === 'success') {
                    // 删除成功动画
                    itemElement.style.transition = 'all 0.3s';
                    itemElement.style.transform = 'translateX(-100%)';
                    itemElement.style.opacity = '0';

                    setTimeout(() => {
                        if (itemElement.parentNode) {
                            itemElement.parentNode.removeChild(itemElement);
                        }
                        // 显示成功提示
                        showNotification('好友删除成功', 'success');
                    }, 300);
                } else {
                    // 恢复状态
                    itemElement.style.opacity = '1';
                    itemElement.style.pointerEvents = 'auto';
                    alert('删除失败: ' + msg);
                }
            })
            .catch(err => {
                console.error('删除好友失败:', err);
                // 恢复状态
                itemElement.style.opacity = '1';
                itemElement.style.pointerEvents = 'auto';
                alert('删除失败: ' + err.message);
            });
    }

    // ============ 删除好友请求函数 ============
    function deleteFriendRequest(requestId, requestType, itemElement) {
        console.log('删除好友请求:', requestId, requestType);

        // 添加删除中状态
        if (itemElement) {
            itemElement.style.opacity = '0.6';
            itemElement.style.pointerEvents = 'none';
        }

        fetch(state.basePath + '/DeleteFriendRequestServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `requestId=${requestId}&userId=${state.currentUser.userId}`,
            credentials: 'include'
        })
            .then(res => res.text())
            .then(msg => {
                if (msg === 'success') {
                    // 删除成功动画
                    if (itemElement) {
                        itemElement.style.transition = 'all 0.3s';
                        itemElement.style.transform = 'translateX(-100%)';
                        itemElement.style.opacity = '0';

                        setTimeout(() => {
                            if (itemElement.parentNode) {
                                itemElement.parentNode.removeChild(itemElement);
                            }
                        }, 300);
                    }

                    // 显示成功提示
                    showNotification('请求删除成功', 'success');

                    // 重新加载对应的请求列表
                    setTimeout(() => {
                        if (requestType === 'pending') {
                            loadPendingRequests();
                        } else if (requestType === 'received') {
                            loadReceivedRequests();
                        }
                    }, 500);
                } else {
                    // 恢复状态
                    if (itemElement) {
                        itemElement.style.opacity = '1';
                        itemElement.style.pointerEvents = 'auto';
                    }
                    alert('删除失败: ' + msg);
                }
            })
            .catch(err => {
                console.error('删除请求失败:', err);
                if (itemElement) {
                    itemElement.style.opacity = '1';
                    itemElement.style.pointerEvents = 'auto';
                }
                alert('网络错误，请重试');
            });
    }

    // ============ 通用的删除函数（兼容原有逻辑） ============
    function deleteFriendOrRequest(id, type, targetElement) {
        console.log('通用删除函数:', id, type);

        // 根据类型调用不同的删除函数
        if (type === 'friend') {
            const friendItem = targetElement.closest('.friend-item');
            deleteFriend(id, friendItem);
        } else if (type === 'pending' || type === 'received') {
            const requestItem = targetElement.closest('.request-item');
            deleteFriendRequest(id, type, requestItem);
        }
    }

    // ============ 显示通知函数 ============
    function showNotification(message, type) {
        // 创建通知元素
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.textContent = message;
        notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 10px 20px;
        background-color: ${type == 'success' ? '#4CAF50' : '#f44336'};
        color: white;
        border-radius: 4px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.2);
        z-index: 1000;
        animation: slideIn 0.3s ease;
    `;

        document.body.appendChild(notification);

        // 3秒后自动消失
        setTimeout(() => {
            notification.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }, 3000);

        // 添加CSS动画
        if (!document.getElementById('notification-styles')) {
            const style = document.createElement('style');
            style.id = 'notification-styles';
            style.textContent = `
            @keyframes slideIn {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
            @keyframes slideOut {
                from { transform: translateX(0); opacity: 1; }
                to { transform: translateX(100%); opacity: 0; }
            }
        `;
            document.head.appendChild(style);
        }
    }

    // ============ 修改现有的渲染函数 ============
    // 在 renderFriends() 函数的最后添加
    function renderFriends(friends) {
        console.log('渲染好友列表，数据：', friends);
        elements.friendList.innerHTML = '';

        if (!friends || friends.length === 0) {
            elements.friendList.innerHTML = '<div class="empty-tip">暂无好友</div>';
            return;
        }

        friends.forEach(friend => {
            const item = document.createElement('div');
            item.className = 'friend-item green';
            item.dataset.id = friend.friendId;

            const user = {
                username: friend.username,
                userCode: friend.userCode,
                userId: friend.friendId
            };

            item.innerHTML = '<span>' + user.username + '（' + user.userCode + '）</span>';
            elements.friendList.appendChild(item);

            // 新增：如果处于删除模式，添加删除按钮
            if (state.isDeleteMode) {
                const deleteBtn = document.createElement('button');
                deleteBtn.className = 'delete-friend-action-btn';
                deleteBtn.textContent = '删除';
                deleteBtn.style.cssText = `
                margin-left: 10px;
                padding: 2px 8px;
                background-color: #ff4444;
                color: white;
                border: none;
                border-radius: 3px;
                font-size: 12px;
                cursor: pointer;
            `;
                item.appendChild(deleteBtn);

                // 添加删除模式样式
                item.style.backgroundColor = '#ffe6e6';
                item.style.borderColor = '#ff4444';
            }
        });
    }

    // 在 renderRequests() 函数的渲染每个请求项的部分修改
    // 找到 actionButtons.appendChild(agreeBtn); 和 actionButtons.appendChild(rejectBtn); 之后添加：
    if (state.isDeleteMode) {
        const deleteBtn = document.createElement('button');
        deleteBtn.className = 'delete-request-btn';
        deleteBtn.textContent = '删除';
        deleteBtn.style.cssText = `
        margin-left: 5px;
        padding: 2px 8px;
        background-color: #ff8800;
        color: white;
        border: none;
        border-radius: 3px;
        font-size: 12px;
        cursor: pointer;
    `;
        deleteBtn.dataset.requestId = req.id;
        deleteBtn.dataset.requestType = type;
        actionButtons.appendChild(deleteBtn);

        // 添加删除模式样式
        item.style.backgroundColor = '#fff3e0';
    }
    // ============ 添加这些新函数到现有代码中 ============

    // 检查我的好友请求状态（被拒绝的）
    function checkRejectedRequests() {
        console.log('🔍 检查被拒绝的好友请求...');

        fetch(state.basePath + '/CheckMyRequestStatusServlet', {
            credentials: 'include'
        })
            .then(res => {
                if (res.status === 401 || res.status === 403) {
                    throw new Error('会话过期');
                }
                return res.json();
            })
            .then(result => {
                console.log('检查结果:', result);

                if (result.status === 'success' && result.data && result.data.length > 0) {
                    result.data.forEach(req => {
                        if (req.status === 2) { // 被拒绝
                            const storageKey = 'shown_reject_' + req.id;
                            if (!sessionStorage.getItem(storageKey)) {
                                // 显示拒绝提示
                                showRejectionNotification(req.username, req.userCode);
                                sessionStorage.setItem(storageKey, 'true');

                                // 从"申请中"列表移除已处理的请求
                                setTimeout(() => {
                                    loadPendingRequests();
                                }, 1000);
                            }
                        } else if (req.status === 1) { // 已同意
                            const storageKey = 'shown_accept_' + req.id;
                            if (!sessionStorage.getItem(storageKey)) {
                                // 也可以显示同意提示（可选）
                                console.log('用户 ' + req.username + ' 同意了你的好友请求');
                                sessionStorage.setItem(storageKey, 'true');

                                setTimeout(() => {
                                    loadPendingRequests();
                                    loadFriends(); // 刷新好友列表
                                }, 1000);
                            }
                        }
                    });
                }
            })
            .catch(err => {
                if (err.message === '会话过期') {
                    console.log('会话过期，跳过检查');
                } else {
                    console.error('检查被拒绝请求失败:', err);
                }
            });
    }

    // 显示拒绝通知
    function showRejectionNotification(username, userCode) {
        console.log('显示拒绝通知:', username, userCode);

        // 如果用户名无效，使用默认值
        const displayName = (username && username !== 'null' && username !== 'undefined')
            ? username
            : '未知用户';
        const displayCode = (userCode && userCode !== 'null' && userCode !== 'undefined')
            ? userCode
            : '';

        // 创建通知容器
        const notification = document.createElement('div');
        notification.className = 'rejection-notification';

        // 构建消息文本 - 使用字符串拼接
        let messageText = '用户 ' + displayName;
        if (displayCode) {
            messageText = messageText + ' (' + displayCode + ')';
        }
        messageText = messageText + ' 拒绝了你的好友申请';

        // 构建HTML - 使用字符串拼接
        notification.innerHTML =
            '<div class="notification-content">' +
            '   <div class="notification-icon">❌</div>' +
            '   <div class="notification-text">' +
            '       <div class="notification-title">好友请求被拒绝</div>' +
            '       <div class="notification-message">' + messageText + '</div>' +
            '   </div>' +
            '   <button class="notification-close">×</button>' +
            '</div>';

        // 设置CSS样式
        notification.style.cssText =
            'position: fixed;' +
            'top: 20px;' +
            'right: 20px;' +
            'min-width: 320px;' +
            'max-width: 400px;' +
            'background: white;' +
            'border-radius: 8px;' +
            'box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);' +
            'border-left: 4px solid #ff4444;' +
            'z-index: 9999;' +
            'animation: notificationSlideIn 0.3s ease forwards;' +
            'font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;' +
            'overflow: hidden;';

        document.body.appendChild(notification);

        // 添加CSS动画（如果不存在）
        if (!document.getElementById('notification-animations')) {
            const style = document.createElement('style');
            style.id = 'notification-animations';
            style.textContent =
                '@keyframes notificationSlideIn {' +
                '    from { transform: translateX(100%); opacity: 0; }' +
                '    to { transform: translateX(0); opacity: 1; }' +
                '}' +
                '@keyframes notificationSlideOut {' +
                '    from { transform: translateX(0); opacity: 1; }' +
                '    to { transform: translateX(100%); opacity: 0; }' +
                '}';
            document.head.appendChild(style);
        }

        // 3秒后自动消失
        const autoRemoveTimer = setTimeout(() => {
            if (notification.parentNode) {
                notification.style.animation = 'notificationSlideOut 0.3s ease forwards';
                setTimeout(() => {
                    if (notification.parentNode) {
                        notification.parentNode.removeChild(notification);
                    }
                }, 300);
            }
        }, 5000);

        // 点击关闭按钮
        const closeBtn = notification.querySelector('.notification-close');
        if (closeBtn) {
            closeBtn.addEventListener('click', function() {
                clearTimeout(autoRemoveTimer); // 清除自动关闭计时器
                if (notification.parentNode) {
                    notification.style.animation = 'notificationSlideOut 0.3s ease forwards';
                    setTimeout(() => {
                        if (notification.parentNode) {
                            notification.parentNode.removeChild(notification);
                        }
                    }, 300);
                }
            });

            // 设置关闭按钮样式
            closeBtn.style.cssText =
                'background: none;' +
                'border: none;' +
                'font-size: 20px;' +
                'color: #999;' +
                'cursor: pointer;' +
                'padding: 0;' +
                'width: 24px;' +
                'height: 24px;' +
                'display: flex;' +
                'align-items: center;' +
                'justify-content: center;' +
                'flex-shrink: 0;' +
                'border-radius: 50%;' +
                'transition: all 0.2s;';

            closeBtn.addEventListener('mouseover', function() {
                this.style.backgroundColor = '#f5f5f5';
                this.style.color = '#666';
            });

            closeBtn.addEventListener('mouseout', function() {
                this.style.backgroundColor = 'transparent';
                this.style.color = '#999';
            });
        }

        // 设置内容区域样式
        const content = notification.querySelector('.notification-content');
        if (content) {
            content.style.cssText =
                'display: flex;' +
                'align-items: flex-start;' +
                'padding: 16px;' +
                'gap: 12px;';
        }

        // 设置图标样式
        const icon = notification.querySelector('.notification-icon');
        if (icon) {
            icon.style.cssText =
                'font-size: 20px;' +
                'color: #ff4444;' +
                'flex-shrink: 0;' +
                'margin-top: 2px;';
        }

        // 设置文本容器样式
        const textContainer = notification.querySelector('.notification-text');
        if (textContainer) {
            textContainer.style.cssText =
                'flex: 1;' +
                'min-width: 0;';
        }

        // 设置标题样式
        const title = notification.querySelector('.notification-title');
        if (title) {
            title.style.cssText =
                'font-weight: 600;' +
                'font-size: 14px;' +
                'color: #333;' +
                'margin-bottom: 4px;';
        }

        // 设置消息样式
        const message = notification.querySelector('.notification-message');
        if (message) {
            message.style.cssText =
                'font-size: 13px;' +
                'color: #666;' +
                'line-height: 1.4;';
        }
    }

    // 封装查点赞数的函数
    function getLikeCount(messageId, domItem) {
        // 替换模板字符串为字符串拼接
        fetch("/GetLikeCountServlet?messageId=" + messageId)
            .then(function(res) {
                return res.json();
            })
            .then(function(data) {
                if (data.code === 0) {
                    // 找到点赞按钮，把数字填到括号里
                    const likeBtn = domItem.querySelector(".like-btn");
                    // 字符串拼接代替
                    likeBtn.textContent = "点赞(" + data.count + ")";
                }
            })
            .catch(function(err) {
                console.log("查点赞数失败：", err);
            });
    }

    // 点击点赞按钮的逻辑
    function clickLike(messageId) {
        // 1. 先调用点赞/取消点赞接口（替换模板字符串）
        fetch("/LikeMessageServlet?messageId=" + messageId, { method: "POST" })
            .then(function(res) {
                return res.json();
            })
            .then(function(result) {
                if (result.success) {
                    // 2. 点赞成功后，重新查最新点赞数并更新
                    const messageItem = document.querySelector("[data-msg-id=\"" + messageId + "\"]");
                    getLikeCount(messageId, messageItem);
                    // 同时更新按钮颜色（你原来的逻辑保留）
                    const likeBtn = messageItem.querySelector(".like-btn");
                    likeBtn.classList.toggle("liked"); // 切换已点赞样式
                }
            });
    }


    // 页面加载后初始化
    window.onload = function() {
        init();
        bindEvents();
        // 找到所有消息项
        const messageItems = document.querySelectorAll(".message-item");
        messageItems.forEach(item => {
            const messageId = item.getAttribute("data-msg-id");
            // 调用接口查点赞数
            getLikeCount(messageId, item);
        });
        // 保存用户信息到sessionStorage，供其他页面使用
        if (state.currentUser && state.currentUser.userId) {
            sessionStorage.setItem('currentUser', JSON.stringify(state.currentUser));
        }
    };
</script>
</body>
</html>