---
name: codeblitz-development
description: Develop Web IDE using Codeblitz (OpenSumi). Create customized IDE with WebDAV filesystem support, default layout configurations, and integrated terminal. Use this skill when building browser-based code editors.
license: MIT
compatibility: opencode
metadata:
  audience: frontend-developers
  framework: react
  ui-library: codeblitz-opensumi
---

# Codeblitz 开发规范

本技能用于使用 Codeblitz (基于 OpenSumi 的纯前端 IDE 框架) 开发浏览器端 IDE。

## 项目结构

```
codeblitz/
├── src/
│   └── main.tsx          # 主入口文件
├── public/               # 静态资源
├── index.html            # HTML 模板
├── package.json          # 依赖配置
├── vite.config.ts        # Vite 配置
├── tsconfig.json         # TypeScript 配置
└── README.md             # 项目说明
```

## 核心概念

### 1. 布局系统

Codeblitz 使用 SlotLocation 定义布局区域：

```typescript
import { SlotLocation } from '@codeblitzjs/ide-core/bundle';

const layoutConfig = {
  [SlotLocation.left]: {
    modules: ['@opensumi/ide-explorer', '@opensumi/ide-search'],
  },
  [SlotLocation.main]: {
    modules: ['@opensumi/ide-editor'],
  },
  [SlotLocation.bottom]: {
    modules: ['@opensumi/ide-terminal-next', '@opensumi/ide-output'],
  },
  [SlotLocation.statusBar]: {
    modules: ['@opensumi/ide-status-bar'],
  },
};
```

### 2. 布局组件

使用 BoxPanel 和 SplitPanel 构建布局：

```typescript
import {
  SlotRenderer,
  SplitPanel,
  BoxPanel,
} from '@codeblitzjs/ide-core/bundle';

const LayoutComponent = () => (
  <BoxPanel direction="top-to-bottom">
    <SplitPanel overflow="hidden" id="main-horizontal" flex={1}>
      {/* 左侧区域 - 默认宽度 250px */}
      <SlotRenderer slot="left" minResize={220} minSize={220} initialSize={250} />
      <SplitPanel
        id="main-vertical"
        minResize={300}
        flexGrow={1}
        direction="top-to-bottom"
      >
        {/* 主编辑区 */}
        <SlotRenderer flex={2} flexGrow={1} minResize={200} slot="main" />
        {/* 底部区域 - 默认高度 300px */}
        <SlotRenderer flex={1} minResize={200} slot="bottom" initialSize={300} />
      </SplitPanel>
    </SplitPanel>
    <SlotRenderer slot="statusBar" />
  </BoxPanel>
);
```

### 3. 文件系统配置

支持多种文件系统类型：

```typescript
// WebDAV 文件系统
const filesystem = {
  fs: 'WebDAVFileSystem',
  options: {
    baseUrl: '/k8s/webdav-agent/1/agent',
    headers: {
      'Authorization': 'Bearer token',
    },
  },
};

// 内存文件系统
const filesystem = {
  fs: 'FileIndexSystem',
  options: {
    requestFileIndex() {
      return Promise.resolve({
        'main.js': 'console.log("hello")',
        'package.json': '{"name": "project"}',
      });
    },
  },
};
```

### 4. AppRenderer 配置

```typescript
<AppRenderer
  appConfig={{
    // 工作空间目录
    workspaceDir: 'workspace',
    
    // 布局配置
    layoutConfig,
    layoutComponent: LayoutComponent,
    
    // 默认偏好设置
    defaultPreferences: {
      'general.theme': 'opensumi-dark',  // 主题
      'editor.autoSave': 'afterDelay',    // 自动保存
      'editor.autoSaveDelay': 1000,       // 保存延迟
    },
    
    // 面板默认尺寸
    panelSizes: {
      [SlotLocation.left]: 250,
      [SlotLocation.bottom]: 300,
    },
    
    // 语言扩展
    extensionMetadata: [html, css, typescript],
  }}
  runtimeConfig={{
    workspace: { filesystem },
    startupEditor: 'welcomePage',  // 启动页
    defaultOpenFile: 'main.js',    // 默认打开文件
  }}
/>
```

## 默认布局设置

### 展开资源管理器

```typescript
panelSizes: {
  [SlotLocation.left]: 250,  // 设置默认宽度
}

// 在 SlotRenderer 中设置 initialSize
<SlotRenderer slot="left" minResize={220} minSize={220} initialSize={250} />
```

### 展开终端面板

```typescript
// 确保 bottom slot 包含终端模块
[SlotLocation.bottom]: {
  modules: ['@opensumi/ide-terminal-next', '@opensumi/ide-output'],
}

// 设置默认高度
panelSizes: {
  [SlotLocation.bottom]: 300,
}

// 在 SlotRenderer 中设置 initialSize
<SlotRenderer slot="bottom" minResize={200} initialSize={300} />
```

## 常用模块 ID

| 模块 | ID | 说明 |
|------|-----|------|
| 资源管理器 | @opensumi/ide-explorer | 文件树 |
| 搜索 | @opensumi/ide-search | 全文搜索 |
| 编辑器 | @opensumi/ide-editor | 代码编辑 |
| 终端 | @opensumi/ide-terminal-next | 集成终端 |
| 输出 | @opensumi/ide-output | 输出面板 |
| 问题 | @opensumi/ide-markers | 错误警告 |
| 状态栏 | @opensumi/ide-status-bar | 底部状态栏 |

## 语言扩展

```typescript
// 引入语言包
import '@codeblitzjs/ide-core/languages/html';
import '@codeblitzjs/ide-core/languages/css';
import '@codeblitzjs/ide-core/languages/javascript';
import '@codeblitzjs/ide-core/languages/typescript';
import '@codeblitzjs/ide-core/languages/json';
import '@codeblitzjs/ide-core/languages/php';
import '@codeblitzjs/ide-core/languages/python';
import '@codeblitzjs/ide-core/languages/vue';
import '@codeblitzjs/ide-core/languages/markdown';

// 或者全部引入
import '@codeblitzjs/ide-core/languages';

// 引入语言功能扩展
import html from '@codeblitzjs/ide-core/extensions/codeblitz.html-language-features-worker';
import css from '@codeblitzjs/ide-core/extensions/codeblitz.css-language-features-worker';
import typescript from '@codeblitzjs/ide-core/extensions/codeblitz.typescript-language-features-worker';

// 在 appConfig 中使用
extensionMetadata: [html, css, typescript],
```

## 开发流程

```bash
# 1. 安装依赖
npm install

# 2. 启动开发服务器
npm run dev

# 3. 构建生产版本
npm run build

# 4. 预览生产版本
npm run preview
```

## 部署方案

### 方案 1: 静态部署

```bash
# 构建项目
npm run build

# 复制 dist 到 w7panel
mkdir -p $BASE_DIR/w7panel/kodata/plugin/codeblitz
cp -r dist/* $BASE_DIR/w7panel/kodata/plugin/codeblitz/

# 访问
# http://localhost:8080/ui/plugin/codeblitz/index.html?api-url=/k8s/webdav-agent/1/agent
```

### 方案 2: 独立部署

```bash
# 构建并打包
npm run build
cd dist && zip -r ../codeblitz.zip .

# 部署到任意静态服务器
```

## 注意事项

1. **WebDAV 认证**: token 从 URL 参数 `api-token` 读取，并存入 localStorage
2. **初始布局**: 通过 `panelSizes` 和 `initialSize` 控制默认展开状态
3. **终端高度**: 必须设置 `initialSize` 否则可能显示异常
4. **文件系统**: WebDAV 需要正确处理跨域和认证头
