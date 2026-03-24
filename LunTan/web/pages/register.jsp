<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注册 - Melandi 论坛</title>
    <style>
        /* 使用主页的风格变量 */
        :root {
            --morandi-blue: #bf6c73;
            --morandi-blue-light: #b90e28;
            --morandi-blue-dark: #3757a5;
            --accent-gold: #C9B8A8;
            --background: #F8F5F2;
            --card-bg: #FFFFFF;
            --text-primary: #333333;
            --text-secondary: #666666;
            --shadow-soft: 0 8px 32px rgba(108, 142, 191, 0.08);
            --shadow-medium: 0 12px 40px rgba(108, 142, 191, 0.12);
            --radius-md: 12px;
            --radius-lg: 20px;
            --transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif;
        }

        body {
            display: flex;
            flex-direction: column;
            align-items: center;
            background: linear-gradient(135deg, #ffffff  0%, #ffffff  50%, #ffffff  100%);
            background-attachment: fixed;
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* 装饰性背景元素 */
        .bg-decoration {
            position: absolute;
            z-index: -1;
            border-radius: 50%;
            opacity: 0.1;
            filter: blur(40px);
        }

        .bg-1 {
            width: 400px;
            height: 400px;
            background: var(--morandi-blue);
            top: -150px;
            right: -150px;
        }

        .bg-2 {
            width: 350px;
            height: 350px;
            background: var(--accent-gold);
            bottom: -100px;
            left: -100px;
        }

        /* 顶部栏 - 蓝底白字，与登录页一致 */
        .shang1 {
            width: 100%;
            height: 120px;
            background: linear-gradient(135deg, var(--morandi-blue), var(--morandi-blue-dark));
            display: flex;
            justify-content: center;
            align-items: center;
            position: fixed;
            top: 0;
            left: 0;
            z-index: 999;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .shang1 h1 {
            color: white;
            font-size: 36px;
            font-weight: 900;
            letter-spacing: -0.5px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        /* 主内容区域 */
        .zhong1 {
            margin-top: 180px;
            width: 500px;
            padding: 40px;
            display: flex;
            flex-direction: column;
            align-items: center;
            background: var(--card-bg);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-medium);
            border: 1px solid rgba(108, 142, 191, 0.15);
            position: relative;
            overflow: hidden;
        }

        .zhong1::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 6px;
            background: linear-gradient(90deg, var(--morandi-blue), var(--accent-gold));
        }

        /* 输入框样式 - 与登录页对称对齐 */
        .kuang {
            border: 1px solid rgba(108, 142, 191, 0.3);
            width: 100%;
            height: 60px;
            margin: 15px 0;
            display: grid;
            grid-template-columns: 100px 1fr;
            align-items: center;
            color: var(--text-primary);
            font-size: 17px;
            background-color: white;
            border-radius: var(--radius-md);
            padding: 0 20px;
            transition: var(--transition);
        }

        .kuang:hover {
            border-color: var(--morandi-blue);
        }

        .kuang:focus-within {
            border-color: var(--morandi-blue);
            box-shadow: 0 0 0 3px rgba(108, 142, 191, 0.1);
            transform: translateY(-2px);
        }

        /* 标签文字 */
        .kuang span {
            text-align: center;
            padding-right: 15px;
            font-weight: 500;
            color: var(--text-primary);
        }

        /* 输入框 */
        .shuru {
            width: 100%;
            height: 30px;
            border: none;
            outline: none;
            padding: 0 10px;
            font-size: 16px;
            background-color: transparent;
            color: var(--text-primary);
        }

        .shuru::placeholder {
            color: var(--text-secondary);
            opacity: 0.7;
        }

        select.shuru {
            cursor: pointer;
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
            background: transparent;
            padding-right: 30px;
        }

        /* 随机编号样式 */
        #randomCode {
            font-weight: bold;
            color: var(--morandi-blue);
            font-family: 'Courier New', monospace;
            letter-spacing: 1px;
            padding: 5px 10px;
            background: rgba(108, 142, 191, 0.1);
            border-radius: 4px;
            transition: var(--transition);
        }

        #randomCode:hover {
            background: rgba(108, 142, 191, 0.2);
            cursor: pointer;
        }

        /* 注册按钮样式 */
        .btn-zhuce {
            border: none;
            width: 100%;
            height: 60px;
            background: linear-gradient(135deg, var(--morandi-blue), var(--morandi-blue-dark));
            color: white;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 30px;
            border-radius: var(--radius-md);
            transition: var(--transition);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            letter-spacing: 0.5px;
            box-shadow: 0 6px 20px rgba(108, 142, 191, 0.3);
        }

        .btn-zhuce:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 25px rgba(108, 142, 191, 0.4);
        }

        .btn-zhuce:active {
            transform: translateY(-2px);
        }

        /* 错误信息样式 */
        .error-message {
            margin-top: 20px;
            color: #e74c3c;
            font-size: 14px;
            text-align: center;
            width: 100%;
            padding: 10px;
            background: rgba(231, 76, 60, 0.1);
            border-radius: var(--radius-md);
            border-left: 4px solid #e74c3c;
        }

        /* 返回链接 */
        .back-link {
            display: inline-block;
            margin-top: 25px;
            color: var(--morandi-blue);
            text-decoration: none;
            font-size: 16px;
            transition: var(--transition);
            padding: 8px 16px;
            border-radius: var(--radius-md);
        }

        .back-link:hover {
            color: var(--morandi-blue-dark);
            background: rgba(108, 142, 191, 0.1);
            text-decoration: none;
        }

        /* 响应式设计 */
        @media (max-width: 768px) {
            .shang1 {
                height: 100px;
            }

            .shang1 h1 {
                font-size: 28px;
            }

            .zhong1 {
                width: 90%;
                margin-top: 150px;
                padding: 30px 25px;
            }

            .kuang {
                height: 55px;
                margin: 12px 0;
                padding: 0 15px;
                font-size: 15px;
                grid-template-columns: 90px 1fr;
            }

            .kuang span {
                font-size: 15px;
                padding-right: 10px;
            }

            .shuru {
                font-size: 15px;
            }

            .btn-zhuce {
                height: 55px;
                font-size: 17px;
            }

            #randomCode {
                font-size: 15px;
            }
        }

        @media (max-width: 480px) {
            .zhong1 {
                width: 95%;
                padding: 25px 20px;
            }

            .kuang {
                grid-template-columns: 80px 1fr;
            }

            .kuang span {
                font-size: 14px;
            }

            .shuru {
                font-size: 14px;
            }

            #randomCode {
                font-size: 14px;
            }
        }

        /* 页面加载动画 */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .zhong1 {
            animation: fadeInUp 0.8s ease-out forwards;
        }
    </style>
</head>
<body>
<!-- 装饰性背景元素 -->
<div class="bg-decoration bg-1"></div>
<div class="bg-decoration bg-2"></div>

<div class="shang1">
    <h1>欢迎进入论坛</h1>
</div>

<div class="zhong1">
    <form action="${pageContext.request.contextPath}/pages/register" method="post">
        <%-- 初始化一个基础编号（JSP生成，作为JS动态变化的起点） --%>
        <%
            String letters = "";
            for (int i = 0; i < 3; i++) {
                int letterCode = (int) (Math.random() * 26 + 97);
                letters += (char) letterCode;
            }
            String numbers = "";
            for (int i = 0; i < 3; i++) {
                numbers += (int) (Math.random() * 10);
            }
            String initCode = letters + numbers;
        %>

        <%-- 显示并动态变化的编号 --%>
        <div class="kuang">
            <span>随机编号：</span>
            <span id="randomCode"><%= initCode %></span>
        </div>

        <%-- 隐藏域：存储最终选择的编号 --%>
        <input type="hidden" id="finalUserCode" name="userCode" value="<%= initCode %>">

        <div class="kuang">
            <span>选择身份：</span>
            <select class="shuru" name="identity" id="identity" required>
                <option value="" disabled selected>请选择身份</option>
                <option value="geren">个人</option>
                <option value="youke">游客</option>
            </select>
        </div>

        <div class="kuang">
            <span>输入昵称：</span>
            <input type="text" class="shuru" name="username" placeholder="请输入昵称" required>
        </div>

        <div class="kuang">
            <span>输入密码：</span>
            <input type="password" class="shuru" name="password" placeholder="请输入密码" required>
        </div>

        <div class="kuang">
            <span>确认密码：</span>
            <input type="password" class="shuru" name="confirmPassword" placeholder="请确认密码" required>
        </div>

        <button type="submit" class="btn-zhuce">注册账号</button>
    </form>

    <% if (request.getAttribute("errorMessage") != null) { %>
    <div class="error-message">
        <%= request.getAttribute("errorMessage") %>
    </div>
    <% } %>

    <a href="<%= request.getContextPath() %>/pages/login.jsp" class="back-link">← 返回登录</a>
</div>

<script>
    // 完全保留原有的JavaScript功能
    const codeEl = document.getElementById('randomCode');
    const hiddenInput = document.getElementById('finalUserCode');
    let codeInterval;

    // 生成随机字母（a-z）
    function getRandomLetter() {
        const letters = 'abcdefghijklmnopqrstuvwxyz';
        return letters[Math.floor(Math.random() * letters.length)];
    }

    // 生成随机数字（0-9）
    function getRandomNum() {
        return Math.floor(Math.random() * 10);
    }

    // 生成并更新随机编号
    function updateCode() {
        const newLetters = getRandomLetter() + getRandomLetter() + getRandomLetter();
        const newNumbers = getRandomNum() + '' + getRandomNum() + '' + getRandomNum();
        const newCode = newLetters + newNumbers;
        codeEl.textContent = newCode;
        hiddenInput.value = newCode; // 同步到隐藏域
    }

    // 启动编号动态变化
    codeInterval = setInterval(updateCode, 80); // 每80毫秒变化一次

    // 点击编号停止变化
    codeEl.addEventListener('click', () => {
        clearInterval(codeInterval);
        codeEl.style.cursor = 'default';
        codeEl.style.color = 'var(--morandi-blue-dark)';
        codeEl.style.background = 'rgba(108, 142, 191, 0.15)';
    });
</script>
</body>
</html>