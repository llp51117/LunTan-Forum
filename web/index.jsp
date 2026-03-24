<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>论坛</title>
  <style>
    /* 基础重置与变量定义 */
    :root {
      --morandi-blue: #6ca2bf;
      --morandi-blue-light: #d55454;
      --morandi-blue-dark: #379a3f;
      --morandi-gray-blue: #B0C4DE;
      --background: #F8F5F2;
      --card-bg: #FFFFFF;
      --text-primary: #333333;
      --text-secondary: #666666;
      --text-light: #888888;
      --accent-gold: #C9B8A8;
      --shadow-soft: 0 8px 32px rgba(108, 142, 191, 0.08);
      --shadow-medium: 0 12px 40px rgba(108, 142, 191, 0.12);
      --radius-lg: 20px;
      --radius-md: 12px;
      --radius-sm: 8px;
      --transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.1);
    }

    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif;
    }

    body {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      background: linear-gradient(135deg, #F8F5F2 0%, #EDE9E4 50%, #E5E1DA 100%);
      background-attachment: fixed;
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

    /* 顶部导航栏 */
    .navbar {
      width: 100%;
      padding: 24px 40px;
      display: flex;
      justify-content: center;
      align-items: center;
      background: rgba(255, 255, 255, 0.85);
      backdrop-filter: blur(12px);
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
      position: sticky;
      top: 0;
      z-index: 1000;
      border-bottom: 1px solid rgba(108, 142, 191, 0.1);
    }

    .logo-container {
      display: flex;
      align-items: center;
      gap: 20px;
    }

    .logo-icon {
      width: 60px;
      height: 60px;
      background: linear-gradient(135deg, var(--morandi-blue), var(--morandi-blue-light));
      border-radius: var(--radius-md);
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: var(--shadow-soft);
      position: relative;
      overflow: hidden;
    }

    .logo-icon::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: linear-gradient(45deg, transparent 30%, rgba(255,255,255,0.3) 50%, transparent 70%);
      animation: shine 3s infinite linear;
    }

    .logo-text {
      display: flex;
      flex-direction: column;
      align-items: flex-start;
    }

    .forum-title {
      font-size: 24px;
      font-weight: 700;
      color: var(--text-primary);
      letter-spacing: -0.5px;
      line-height: 1.2;
    }

    .community-text {
      font-size: 42px;
      font-weight: 900;
      background: linear-gradient(135deg, var(--morandi-blue-dark), var(--morandi-blue));
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      letter-spacing: 2px;
      text-transform: uppercase;
      line-height: 1;
      margin-top: 4px;
      text-shadow: 0 2px 4px rgba(108, 142, 191, 0.1);
    }

    @keyframes shine {
      0% { transform: translateX(-100%); }
      100% { transform: translateX(100%); }
    }

    /* 主内容区域 */
    .main-container {
      flex: 1;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      width: 100%;
      max-width: 1200px;
      padding: 40px 20px;
    }

    .welcome-card {
      background: var(--card-bg);
      border-radius: var(--radius-lg);
      padding: 60px 50px;
      width: 100%;
      max-width: 900px;
      box-shadow: var(--shadow-medium);
      border: 1px solid rgba(108, 142, 191, 0.15);
      text-align: center;
      position: relative;
      overflow: hidden;
      margin-bottom: 60px;
    }

    .welcome-card::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 6px;
      background: linear-gradient(90deg, var(--morandi-blue), var(--accent-gold));
    }

    /* 调整后的"论坛"文字样式 */
    .forum-special-title {
      font-size: 56px;
      font-weight: 900;
      line-height: 1;
      margin-bottom: 30px;
      position: relative;
    }

    .forum-special {
      background: linear-gradient(135deg, var(--morandi-blue-dark), var(--morandi-blue), var(--accent-gold));
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      text-shadow: 0 4px 8px rgba(108, 142, 191, 0.2);
      position: relative;
      display: inline-block;
      padding: 0 15px;
      letter-spacing: 1px;
    }

    .forum-special::after {
      content: '';
      position: absolute;
      bottom: -8px;
      left: 15px;
      right: 15px;
      height: 3px;
      background: linear-gradient(90deg, var(--morandi-blue), var(--accent-gold));
      border-radius: 2px;
      opacity: 0.8;
    }

    .forum-special::before {
      content: '';
      position: absolute;
      top: -6px;
      left: 15px;
      right: 15px;
      height: 2px;
      background: linear-gradient(90deg, var(--morandi-blue), var(--accent-gold));
      border-radius: 1px;
      opacity: 0.6;
    }

    /* 修复的关键部分 - 标语容器 */
    .welcome-subtitle {
      font-size: 18px;
      color: var(--text-secondary);
      max-width: 800px;
      margin: 30px auto 40px;
      line-height: 1.8;
      font-weight: 400;
      padding: 0 15px;
      min-height: 160px; /* 增加高度确保内容完全显示 */
      display: block; /* 改为block而不是flex */
      text-align: center;
      word-wrap: break-word;
      overflow-wrap: break-word;
    }

    .welcome-highlight {
      color: var(--morandi-blue-dark);
      font-weight: 600;
      font-style: italic;
    }

    .community-line {
      margin: 12px 0;
      font-size: 20px;
      font-weight: 700;
      color: var(--morandi-blue);
      display: block;
      line-height: 1.5;
    }

    /* 按钮样式 */
    .btn-container {
      display: flex;
      gap: 30px;
      justify-content: center;
      flex-wrap: wrap;
      margin-top: 30px;
    }

    .btn-primary, .btn-secondary {
      padding: 20px 44px;
      font-size: 18px;
      font-weight: 600;
      border: none;
      border-radius: var(--radius-md);
      cursor: pointer;
      transition: var(--transition);
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 14px;
      min-width: 220px;
      position: relative;
      overflow: hidden;
      letter-spacing: 0.5px;
    }

    .btn-primary {
      background: linear-gradient(135deg, var(--morandi-blue), var(--morandi-blue-dark));
      color: white;
      box-shadow: 0 6px 20px rgba(108, 142, 191, 0.3);
    }

    .btn-primary:hover {
      transform: translateY(-5px);
      box-shadow: 0 12px 25px rgba(108, 142, 191, 0.4);
    }

    .btn-primary:active {
      transform: translateY(-2px);
    }

    .btn-secondary {
      background: transparent;
      color: var(--morandi-blue);
      border: 2px solid var(--morandi-blue);
    }

    .btn-secondary:hover {
      background: rgba(108, 142, 191, 0.08);
      transform: translateY(-5px);
      border-color: var(--morandi-blue-dark);
    }

    /* 自定义按钮图标 */
    .btn-icon {
      font-size: 22px;
      font-weight: bold;
    }

    .login-icon {
      display: inline-block;
      width: 22px;
      height: 22px;
      background: white;
      border-radius: 4px;
      position: relative;
      margin-right: 10px;
    }

    .login-icon::before {
      content: "";
      position: absolute;
      top: 5px;
      left: 9px;
      width: 4px;
      height: 12px;
      background: var(--morandi-blue);
      border-radius: 2px;
    }

    .login-icon::after {
      content: "";
      position: absolute;
      top: 5px;
      left: 4px;
      width: 5px;
      height: 5px;
      border: 2px solid var(--morandi-blue);
      border-radius: 50%;
    }

    /* 论坛特色展示 */
    .feature-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
      gap: 40px;
      width: 100%;
    }

    .feature-card {
      background: var(--card-bg);
      border-radius: var(--radius-lg);
      padding: 50px 40px;
      box-shadow: var(--shadow-soft);
      border: 1px solid rgba(108, 142, 191, 0.1);
      transition: var(--transition);
      text-align: center;
      display: flex;
      flex-direction: column;
      align-items: center;
      position: relative;
      overflow: hidden;
    }

    .feature-card::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 4px;
      background: linear-gradient(90deg, var(--morandi-blue), var(--accent-gold));
      opacity: 0;
      transition: var(--transition);
    }

    .feature-card:hover::before {
      opacity: 1;
    }

    .feature-card:hover {
      transform: translateY(-10px);
      box-shadow: var(--shadow-medium);
      border-color: rgba(108, 142, 191, 0.25);
    }

    .feature-icon {
      width: 90px;
      height: 90px;
      background: linear-gradient(135deg, rgba(108, 142, 191, 0.1), rgba(201, 184, 168, 0.1));
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-bottom: 28px;
      border: 2px solid rgba(108, 142, 191, 0.15);
      transition: var(--transition);
    }

    .feature-card:hover .feature-icon {
      transform: scale(1.1) rotate(5deg);
      border-color: var(--morandi-blue);
    }

    .feature-icon i {
      font-size: 36px;
      color: var(--morandi-blue);
      transition: var(--transition);
    }

    .feature-card:hover .feature-icon i {
      color: var(--morandi-blue-dark);
    }

    .feature-card h3 {
      font-size: 24px;
      font-weight: 700;
      color: var(--text-primary);
      margin-bottom: 18px;
    }

    .feature-card p {
      color: var(--text-secondary);
      line-height: 1.7;
      font-size: 16px;
      margin-bottom: 24px;
    }

    /* 悬浮动画按钮效果 */
    .floating-btn {
      position: fixed;
      bottom: 40px;
      right: 40px;
      width: 65px;
      height: 65px;
      background: linear-gradient(135deg, var(--morandi-blue), var(--morandi-blue-dark));
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 26px;
      box-shadow: 0 8px 25px rgba(108, 142, 191, 0.4);
      cursor: pointer;
      transition: var(--transition);
      z-index: 1000;
      animation: float 3s ease-in-out infinite;
    }

    .floating-btn:hover {
      transform: scale(1.15) rotate(15deg);
      box-shadow: 0 15px 30px rgba(108, 142, 191, 0.5);
    }

    @keyframes float {
      0%, 100% { transform: translateY(0px); }
      50% { transform: translateY(-12px); }
    }

    /* 响应式设计 */
    @media (max-width: 768px) {
      .navbar {
        padding: 20px;
      }

      .logo-icon {
        width: 50px;
        height: 50px;
      }

      .logo-icon i {
        font-size: 24px;
      }

      .forum-title {
        font-size: 20px;
      }

      .community-text {
        font-size: 32px;
      }

      .welcome-card {
        padding: 40px 25px;
        margin-bottom: 40px;
      }

      .forum-special-title {
        font-size: 40px;
        margin-bottom: 25px;
      }

      .forum-special {
        padding: 0 12px;
      }

      .welcome-subtitle {
        font-size: 16px;
        margin: 25px auto 35px;
        min-height: 140px;
        line-height: 1.7;
        padding: 0 10px;
      }

      .community-line {
        font-size: 18px;
        margin: 10px 0;
      }

      .feature-grid {
        grid-template-columns: 1fr;
        gap: 30px;
      }

      .feature-card {
        padding: 40px 25px;
      }

      .feature-icon {
        width: 80px;
        height: 80px;
        margin-bottom: 24px;
      }

      .feature-icon i {
        font-size: 32px;
      }

      .feature-card h3 {
        font-size: 22px;
      }

      .btn-primary, .btn-secondary {
        min-width: 100%;
        padding: 18px 30px;
        font-size: 17px;
      }

      .btn-container {
        flex-direction: column;
        gap: 18px;
      }

      .floating-btn {
        width: 55px;
        height: 55px;
        font-size: 22px;
        bottom: 20px;
        right: 20px;
      }
    }

    /* 在更小的屏幕上进一步优化 */
    @media (max-width: 480px) {
      .welcome-subtitle {
        font-size: 15px;
        min-height: 150px;
        line-height: 1.6;
      }

      .welcome-card {
        padding: 30px 15px;
      }

      .community-line {
        font-size: 16px;
      }

      .forum-special-title {
        font-size: 36px;
        margin-bottom: 20px;
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

    .fade-in {
      animation: fadeInUp 0.8s ease-out forwards;
    }

    .delay-1 { animation-delay: 0.2s; opacity: 0; }
    .delay-2 { animation-delay: 0.4s; opacity: 0; }
    .delay-3 { animation-delay: 0.6s; opacity: 0; }

    /* 底部信息 */
    .footer {
      text-align: center;
      padding: 40px;
      color: var(--text-light);
      font-size: 14px;
      width: 100%;
      border-top: 1px solid rgba(108, 142, 191, 0.1);
      margin-top: 70px;
    }
  </style>
</head>

<body>
<!-- 装饰性背景元素 -->
<div class="bg-decoration bg-1"></div>
<div class="bg-decoration bg-2"></div>

<!-- 导航栏 -->
<nav class="navbar">
  <div class="logo-container">
    <div class="logo-icon">
      <div style="font-size: 28px; color: white;">💬</div>
    </div>
    <div class="logo-text">
      <div class="forum-title">Melandi Forum</div>
      <div class="community-text">Community</div>
    </div>
  </div>
</nav>

<!-- 主内容区域 -->
<main class="main-container">
  <!-- 欢迎卡片 -->
  <div class="welcome-card fade-in">
    <!-- 调整后的"论坛"标题 -->
    <h1 class="forum-special-title">
      <span class="forum-special">论坛</span>
    </h1>

    <!-- 简化的标语系统 - 只显示一条完整的标语 -->
    <div class="welcome-subtitle" id="dynamicSlogan">
      在这里，<span class="welcome-highlight">没有边界，只有共鸣</span>。无论是深邃的哲学思辨、生活的点滴感悟，还是天马行空的创意遐想，每一段对话都值得被温柔倾听。
      <div class="community-line">加入我们的 Community</div>
      开启一段真诚的交流之旅。
    </div>

    <div class="btn-container">
      <form action="<%= request.getContextPath() %>/pages/login.jsp" method="post" class="fade-in delay-1">
        <button type="submit" class="btn-primary">
          <!-- 使用钥匙图标替代箭头 -->
          <span class="btn-icon">🔑</span>
          立即登录
        </button>
      </form>

      <button class="btn-secondary fade-in delay-2" onclick="location.href='<%= request.getContextPath() %>/pages/register.jsp'">
        <!-- 使用人物图标替代加号 -->
        <span class="btn-icon">👤</span>
        注册账号
      </button>
    </div>
  </div>

  <!-- 论坛特色展示 -->
  <div class="feature-grid">
    <div class="feature-card fade-in delay-1">
      <div class="feature-icon">
        <span style="font-size: 36px;">❤</span>
      </div>
      <h3>包容的交流氛围</h3>
      <p>我们相信，真正的智慧诞生于多样性的碰撞。无论您来自何方，持何种观点，这里都有一席之地。尊重、理解、包容，是我们的社区基石。</p>
    </div>

    <div class="feature-card fade-in delay-2">
      <div class="feature-icon">
        <span style="font-size: 36px;">🧠</span>
      </div>
      <h3>深度思考空间</h3>
      <p>从科技前沿到人文艺术，从生活哲学到创意灵感，我们鼓励深度、有质量的讨论与分享。在这里，每一次思考都值得被认真对待。</p>
    </div>

    <div class="feature-card fade-in delay-3">
      <div class="feature-icon">
        <span style="font-size: 36px;">🛡</span>
      </div>
      <h3>安全的分享环境</h3>
      <p>严格的社区准则和隐私保护，让每一位成员都能安心表达，无需担忧个人信息泄露。我们致力于打造一个让人安心的交流空间。</p>
    </div>
  </div>
</main>

<!-- 悬浮帮助按钮 -->
<div class="floating-btn" onclick="location.href='<%= request.getContextPath() %>/pages/help.jsp'">
  <span style="font-size: 26px;">?</span>
</div>

<!-- 底部信息 -->
<footer class="footer">
  <p>© 2025年12月12日启动 Melandi Forum Community. 一个啥都能唠的地方，期待您的加入。</p>
</footer>

<script>
  // 简化版标语切换系统 - 绝对保证正常工作
  document.addEventListener('DOMContentLoaded', function() {
    const sloganElement = document.getElementById('dynamicSlogan');

    // 简化的标语数组 - 每条标语都是完整的HTML
    const slogans = [
      `在这里，<span class="welcome-highlight">没有边界，只有共鸣</span>。无论是深邃的哲学思辨、生活的点滴感悟，还是天马行空的创意遐想，每一段对话都值得被温柔倾听。
      <div class="community-line">加入我们的 Community</div>
      开启一段真诚的交流之旅。`,

      `在这里，<span class="welcome-highlight">分享您的想法，聆听世界的声音</span>。每一次交流都是一次心灵的碰撞与成长，每一段对话都可能带来新的启发。
      <div class="community-line">加入我们的 Community</div>
      开启一段真诚的交流之旅。`,

      `在这里，<span class="welcome-highlight">每一次对话，都是一次心灵的相遇</span>。从日常闲聊到深度探讨，这里都有您的位置，每个声音都值得被认真倾听。
      <div class="community-line">加入我们的 Community</div>
      开启一段真诚的交流之旅。`,

      `在这里，<span class="welcome-highlight">连接思想，创造共鸣</span>。我们相信，真正的智慧诞生于多样性的碰撞，深刻的见解来源于真诚的交流。
      <div class="community-line">加入我们的 Community</div>
      开启一段真诚的交流之旅。`
    ];

    let currentIndex = 0;
    let sloganInterval;

    // 切换标语函数 - 最简化的版本
    function changeSlogan() {
      currentIndex = (currentIndex + 1) % slogans.length;
      sloganElement.innerHTML = slogans[currentIndex];
    }

    // 启动轮播（5秒后开始，每10秒切换一次）
    setTimeout(() => {
      sloganInterval = setInterval(changeSlogan, 10000);
    }, 5000);

    // 点击切换
    sloganElement.addEventListener('click', function() {
      changeSlogan();
      // 重置定时器
      clearInterval(sloganInterval);
      sloganInterval = setInterval(changeSlogan, 10000);
    });

    // 添加S键快捷键
    document.addEventListener('keydown', function(e) {
      if (e.key === 's' && !e.target.matches('input, textarea')) {
        e.preventDefault();
        changeSlogan();
      }
      // Alt + L 快速登录
      if (e.altKey && e.key === 'l') {
        e.preventDefault();
        document.querySelector('.btn-primary').click();
      }
      // Alt + R 快速注册
      if (e.altKey && e.key === 'r') {
        e.preventDefault();
        document.querySelector('.btn-secondary').click();
      }
    });

    // 添加提示
    sloganElement.title = "点击切换标语，或按S键切换";
    sloganElement.style.cursor = "pointer";
  });
</script>
</body>
</html>