# 我的工具导航 (My Tool Dashboard)

## 项目简介

“我的工具导航”是一个高度可定制的个人工具导航页，旨在帮助用户集中管理和快速访问常用的在线工具。它不仅提供了一个简洁的界面来组织你的工具，还融入了多种动态和个性化元素，如背景轮播、宠物互动、音乐播放器和可拖动的组件，为你的日常使用增添乐趣。

## 功能特性

- **工具管理**：
  - 实时搜索工具。
  - 添加、编辑和删除自定义工具，支持分类管理。
  - 工具数据本地持久化，确保刷新页面后数据不丢失。

- **个性化设置**：
  - **背景控制**：支持背景图片轮播，并可调整背景模糊度。
  - **组件可见性与可移动性**：
    - 可控制音乐播放器、宠物、小摆锤和时间摆件的显示/隐藏。
    - 可控制音乐播放器、宠物、小摆锤和时间摆件是否可拖动，并持久化其位置。
  - **音乐播放器**：集成背景音乐播放功能，支持拖动和音量控制。
  - **宠物互动**：可爱的小宠物会随机显示对话，并支持拖动。
  - **物理小摆锤**：一个动态的小摆锤组件，可控制显示和拖动。
  - **时间摆件**：新增的时间显示组件，可控制显示和拖动。

- **备案信息配置**：
  - 支持通过本地配置文件 `src/config.js` 配置备案号，该文件不会被提交到远程仓库，方便个人部署。

## 技术栈

- **前端框架**：Vue 3 (使用 Composition API 和 `<script setup>`) 
- **UI 组件库**：Bootstrap 5
- **状态管理**：Vue `ref` 和 `computed`
- **本地存储**：`localStorage`
- **构建工具**：Vue CLI / Webpack

## 安装与运行

### 开发环境

1.  **克隆仓库**：
    ```bash
    git clone https://github.com/axfinn/my-tool-dashboard.git
    cd my-tool-dashboard
    ```
2.  **安装依赖**：
    ```bash
    npm install
    ```
3.  **配置备案信息 (可选)**：
    如果你需要显示备案号，请复制 `src/config.example.js` 为 `src/config.js`，并修改 `src/config.js` 中的 `icpNumber` 和 `icpVisible`。
    ```bash
    cp src/config.example.js src/config.js
    # 然后编辑 src/config.js 文件
    ```
4.  **运行开发服务器**：
    ```bash
    npm run serve
    ```
    应用将在 `http://localhost:8080` (或类似地址) 运行。

### 生产环境 (使用 Docker)

1.  **构建 Docker 镜像**：
    ```bash
    docker build -t my-tool-dashboard .
    ```
2.  **运行 Docker 容器**：
    ```bash
    docker run -p 80:80 my-tool-dashboard
    ```
    应用将在 `http://localhost` 运行。

## 使用说明

- **添加/编辑工具**：点击搜索框旁边的“添加新工具”按钮，或点击现有工具卡片上的编辑图标。输入管理员密码（默认为 `admin123`）进行操作。
- **搜索工具**：在搜索框中输入关键词，工具卡片将实时过滤显示。
- **个性化控制面板**：点击右上角的展开/收缩按钮，可以打开控制面板。在这里，你可以：
  - 开启/关闭背景轮播。
  - 调整背景模糊度。
  - 控制音乐播放器、宠物、小摆锤和时间摆件的显示/隐藏。
  - 控制这些组件是否可以拖动。
- **拖动组件**：当组件设置为可移动时，你可以点击并拖动它们到页面上的任意位置。在移动端，支持**长按**组件进行拖拽。

## 项目结构

```
my-tool-dashboard/
├── public/             # 静态资源
├── src/                # 源代码
│   ├── assets/         # 静态文件 (图片, CSS, 音频)
│   ├── components/     # Vue 组件
│   │   ├── MusicPlayer.vue
│   │   ├── PetCard.vue
│   │   ├── PendulumComponent.vue
│   │   ├── TimeWidget.vue
│   │   └── ...
│   ├── config.js       # 本地备案信息配置文件 (不会提交到 Git)
│   ├── config.example.js # 备案信息配置文件示例
│   ├── App.vue         # 主应用组件
│   └── main.js         # 应用入口文件
├── Dockerfile          # Docker 部署文件
├── package.json        # 项目依赖和脚本
├── README.md           # 项目说明
└── ...
```

## 贡献

欢迎任何形式的贡献！如果你有任何建议、bug 报告或功能请求，请随时提交 Issue 或 Pull Request。

## 许可证

本项目采用 MIT 许可证。详情请参阅 `LICENSE` 文件。