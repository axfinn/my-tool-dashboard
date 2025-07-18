# Changelog

## 2025年7月7日

### Added
- 备案信息配置：支持通过本地配置文件 `src/config.js` 配置备案号，该文件不会被提交到远程仓库，方便个人部署。
- 移动端长按拖拽：所有可移动小组件（音乐播放器、宠物、小摆锤、时间摆件）在移动端支持长按拖拽移动。

### Changed
- 备案号配置从用户偏好设置中移除，改为从本地配置文件读取。

### Fixed
- 修复了 `MusicPlayer.vue`、`PetCard.vue`、`PendulumComponent.vue` 和 `TimeWidget.vue` 中 `ref` 变量使用不当导致的构建错误。

## 2025年7月2日

### Added
- 在页脚添加了个人博客链接。
- 添加了版本显示和更新检查功能。
- 在页面右上角添加了 GitHub 开源地址链接，包含 star 和 follow 按钮。
- 新增本地存储用户配置能力。
- 添加了 Dockerfile，用于自动化部署。
- 新增备案号配置能力，支持在页面底部显示备案号，并可控制其显示与隐藏。
- 新增音乐播放器“下一首”切歌功能。

### Changed
- **版本号更新至 v0.2.0。**
- 优化了 GitHub star/follow 按钮的定位和响应性，使其在不同设备上更友好。
- 优化了移动端的用户界面和交互体验，包括点击、编辑和控制台的可用性。
- 将右上角的控制控件开关改成一行一个，优化布局。
- 备案号默认显示，符合合规要求。
- 优化组件拖拽体验，使其更流畅。
- 重构背景音乐配置面板，使用专用模态框进行管理，提升用户体验。

### Fixed
- 修复右上角控制台失效问题。
- 修复 `App.vue` 中 `defaultData` 未定义的问题。
- 移除 `ToolModal.vue` 中硬编码的管理员密码。

## 2025年7月1日

### Added
- 背景图片轮播功能，支持多张图片自动切换。
- 背景模糊度控制滑块，允许用户调整背景图片的模糊度。
- 物理特效：小摆锤组件。
- 音乐播放器拖动功能。
- 管理员密码校验功能，用于新增和编辑工具。
- 小摆锤组件拖动功能。
- 小摆锤组件显示/隐藏开关。
- 右上角控制组件支持缩小和放大展开，默认缩小状态。

### Changed
- 宠物对话触发方式从点击改为鼠标悬停，并以气泡形式随机显示对话。
- 音乐播放器样式优化，使其更小巧美观，并调整其初始位置。
- 背景控制和音乐播放器位置调整。
- 音乐播放器进一步美化，使其更窄、更紧凑，音量控制在鼠标悬停时显示。
- 右上角控制组件支持鼠标悬停展开，并美化内部开关样式。
- 优化拖动功能（音乐播放器和小摆锤），通过节流提高流畅度。
- 优化控制面板展开/收缩动画，使用 `max-width` 和 `max-height` 属性，提高流畅度。
- 优化控制面板的响应性，通过防抖 `mouseleave` 事件和固定 `max-height` 提高流畅度。

### Fixed
- 修复宠物对话超出浏览器边界的问题。
- 修复 `PendulumComponent.vue` 中 `props` 变量未使用的 ESLint 错误。
- 修复 `App.vue` 中 `controlsContent` 变量重复声明的错误。