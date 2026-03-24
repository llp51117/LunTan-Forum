<%--登录--进入主界面--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>论坛登录页面</title>
    <style>
        /* 莫兰迪蓝色主题 */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            display: flex;
            flex-direction: column;
            align-items: center;
            background: linear-gradient(135deg, #f5f7fa 0%, #e4e8f0 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif;
        }

        .shang1 {
            width: 100%;
            height: 150px;
            background: linear-gradient(135deg, #6C8EBF 0%, #4A6BA5 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            position: fixed;
            top: 0;
            z-index: 999;
            box-shadow: 0 4px 20px rgba(108, 142, 191, 0.2);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .shang1 h1 {
            color: white;
            font-size: 36px;
            font-weight: 700;
            letter-spacing: 1px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .zhong1 {
            margin-top: 200px;
            width: 600px;
            padding: 40px;
            display: flex;
            flex-direction: column;
            align-items: center;
            background: white;
            border-radius: 16px;
            box-shadow: 0 12px 30px rgba(108, 142, 191, 0.15);
            border: 1px solid rgba(108, 142, 191, 0.1);
        }

        .kuang {
            border: 1px solid #E1E8F0;
            width: 100%;
            height: 70px;
            margin: 15px 0;
            display: flex;
            justify-content: center;
            align-items: center;
            color: #2C3E50;
            font-size: 18px;
            background-color: white;
            border-radius: 10px;
            transition: all 0.3s ease;
            padding: 0 20px;
        }

        .kuang:focus-within {
            border-color: #6C8EBF;
            box-shadow: 0 0 0 3px rgba(108, 142, 191, 0.1);
            transform: translateY(-2px);
        }

        .shuru {
            width: 250px;
            height: 35px;
            margin-left: 15px;
            border: none;
            outline: none;
            padding: 0 12px;
            font-size: 16px;
            background-color: transparent;
            color: #34495E;
            font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif;
        }

        .shuru::placeholder {
            color: #95A5A6;
        }

        select.shuru {
            cursor: pointer;
            appearance: none;
            background: transparent;
            padding-right: 25px;
        }

        .btn-zhuce {
            border: none;
            width: 100%;
            height: 65px;
            background: linear-gradient(135deg, #6C8EBF 0%, #4A6BA5 100%);
            color: white;
            font-size: 20px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 25px;
            border-radius: 10px;
            transition: all 0.3s ease;
            letter-spacing: 1px;
            box-shadow: 0 6px 15px rgba(108, 142, 191, 0.3);
        }

        .btn-zhuce:hover {
            background: linear-gradient(135deg, #5A7CAD 0%, #3A5A95 100%);
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(108, 142, 191, 0.4);
        }

        .btn-zhuce:active {
            transform: translateY(-1px);
        }

        /* 添加注册按钮样式 - 莫兰迪风格 */
        .btn-register {
            position: fixed;
            top: 160px;
            right: 30px;
            width: 90px;
            height: 40px;
            background: white;
            color: #6C8EBF;
            border: 2px solid #6C8EBF;
            border-radius: 8px;
            cursor: pointer;
            font-size: 15px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .btn-register:hover {
            background: #6C8EBF;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(108, 142, 191, 0.3);
        }

        /* 错误信息样式 */
        .error {
            margin-top: 15px;
            color: #E74C3C;
            font-size: 16px;
            font-weight: 500;
            min-height: 20px;
            text-align: center;
            width: 100%;
            padding: 10px;
            background: rgba(231, 76, 60, 0.05);
            border-radius: 8px;
            border-left: 4px solid #E74C3C;
        }

        /* 响应式设计 */
        @media (max-width: 768px) {
            .zhong1 {
                width: 90%;
                margin-top: 180px;
                padding: 30px;
            }

            .shang1 h1 {
                font-size: 30px;
            }

            .kuang {
                height: 60px;
                font-size: 16px;
            }

            .shuru {
                width: 200px;
                font-size: 15px;
            }
        }

        @media (max-width: 480px) {
            .zhong1 {
                width: 95%;
                padding: 25px;
            }

            .shang1 h1 {
                font-size: 26px;
            }

            .btn-register {
                right: 20px;
                width: 80px;
                height: 35px;
                font-size: 14px;
            }
        }
    </style>
</head>
<body>
<div class="shang1">
    <h1>欢迎进入论坛</h1>
</div>
<!-- 注册按钮 -->
<button class="btn-register" onclick="location.href='<%= request.getContextPath() %>/pages/register.jsp'">注册</button>

<div class="zhong1">
    <form action="${pageContext.request.contextPath}/pages/login" method="post">
        <div class="kuang">
            请输入编号：<input type="text" class="shuru" name="userCode" placeholder="请输入编号" required>
        </div>

        <div class="kuang">
            请选择身份：
            <select class="shuru" name="identity" id="identity" required>
                <option value="" disabled selected>请选择身份</option>
                <option value="geren">个人</option>
                <option value="youke">游客</option>
                <option value="admin">管理员</option>
            </select>
        </div>

        <div class="kuang">
            请输入密码：<input type="password" class="shuru" name="password" placeholder="请输入密码" required>
        </div>
        <!-- 提交按钮，无需onclick，由表单action控制跳转 -->
        <button type="submit" class="btn-zhuce" onclick="handleLogin()">确认登录</button>
    </form>
    <!--  错误信息显示（id与JS保持一致） -->
    <div class="error" id="errorMsg"></div>
</div>

</body>
</html>