---
name: arco-vue-development
description: Develop Vue 3 frontend interfaces using Arco Design Vue component library. Strictly follow Arco Design specifications for component usage, layout, spacing, typography, and visual patterns. Use this skill when building enterprise-level Vue applications with Arco Design.
license: MIT
compatibility: opencode
metadata:
  audience: frontend-developers
  framework: vue3
  ui-library: arco-design
---

# Arco Design Vue 开发规范

本技能用于使用 Arco Design Vue 组件库开发企业级 Vue 3 应用。**必须严格遵循 Arco Design 规范**。

## 核心原则

1. **组件优先**: 优先使用 Arco Design 内置组件，而非自定义实现
2. **规范遵循**: 严格遵循 Arco Design 的设计规范，包括间距、颜色、字体等
3. **一致性**: 保持整个应用的设计一致性
4. **可访问性**: 遵循无障碍设计规范

## 项目初始化

```bash
# 安装 Arco Design Vue
npm install @arco-design/web-vue

# 可选：安装图标库
npm install @arco-design/web-vue/es/icon
```

### 基础使用

```vue
import { createApp } from 'vue'
import ArcoVue from '@arco-design/web-vue'
import '@arco-design/web-vue/dist/arco.css'

const app = createApp(App)
app.use(ArcoVue)
app.mount('#app')
```

## 组件使用规范

### 1. 布局组件

使用 `Grid` 栅格系统进行布局：

```vue
<a-row :gutter="[16, 16]">
  <a-col :span="8">内容区块</a-col>
  <a-col :span="8">内容区块</a-col>
  <a-col :span="8">内容区块</a-col>
</a-row>
```

- **间距规范**: 使用 4px 基础单位的倍数（4, 8, 12, 16, 20, 24, 32, 40, 48）
- **响应式断点**: xs(<768px), sm(≥768px), md(≥992px), lg(≥1200px), xl(≥1920px)

### 2. 按钮 Button

```vue
<!-- 主按钮 -->
<a-button type="primary">主要操作</a-button>

<!-- 次按钮 -->
<a-button>次要操作</a-button>

<!-- 文字按钮 -->
<a-button type="text">文字按钮</a-button>

<!-- 禁用状态 -->
<a-button disabled>禁用</a-button>

<!-- 加载状态 -->
<a-button loading>加载中</a-button>
```

**规范**:
- 主按钮用于主要操作，一个页面建议只有一个主按钮
- 按钮组使用 `<a-button-group>`
- 危险操作使用 `type="secondary"` 或 `status="danger"`

### 3. 表单 Form

使用 `a-form` 进行表单验证和布局：

```vue
<a-form :model="form" :rules="rules" layout="vertical" @submit="handleSubmit">
  <a-form-item label="用户名" field="username" required>
    <a-input v-model="form.username" placeholder="请输入用户名" />
  </a-form-item>
  
  <a-form-item label="邮箱" field="email" required>
    <a-input v-model="form.email" placeholder="请输入邮箱" />
  </a-form-item>
  
  <a-form-item label="状态" field="status">
    <a-select v-model="form.status" placeholder="请选择状态">
      <a-option value="active" label="激活" />
      <a-option value="inactive" label="未激活" />
    </a-select>
  </a-form-item>
  
  <a-form-item>
    <a-button html-type="submit" type="primary">提交</a-button>
  </a-form-item>
</a-form>
```

**规范**:
- 使用 `layout="vertical"` 获取更好的移动端体验
- 必填字段使用 `required` 属性
- 标签文字使用中文冒号（如"用户名："）
- 错误提示显示在输入框下方

### 4. 表格 Table

```vue
<a-table 
  :columns="columns" 
  :data="data" 
  :pagination="{ current: 1, pageSize: 10, total: 100 }"
  :loading="loading"
  @page-change="handlePageChange"
  @page-size-change="handlePageSizeChange"
>
  <template #status="{ record }">
    <a-tag :color="record.status === 'active' ? 'green' : 'gray'">
      {{ record.status === 'active' ? '激活' : '未激活' }}
    </a-tag>
  </template>
  
  <template #operations="{ record }">
    <a-button type="text" size="small" @click="handleEdit(record)">编辑</a-button>
    <a-button type="text" size="small" status="danger" @click="handleDelete(record)">删除</a-button>
  </template>
</a-table>

<!-- 分页配置 -->
<a-table 
  :data="data"
  :pagination="{
    current: 1,
    pageSize: 10,
    total: 100,
    showTotal: true,           // 显示总数
    showPageSize: true,        // 显示页码选择器
    pageSizeOptions: [10, 20, 50, 100],  // 页码选项
    simple: false,              // 简洁模式
    disabled: false,            // 禁用分页
  }"
/>

<!-- 客户端分页 -->
<a-table 
  :data="allData"
  :pagination="{
    current: 1,
    pageSize: 10,
    total: allData.length,
    isClientSidePagination: true,  // 客户端分页
  }"
/>
```

**规范**:
- 表格操作列固定在右侧
- 使用 `a-tag` 显示状态
- 启用分页和加载状态
- 列对齐：文字左对齐、数字右对齐、操作居中

**表格列配置**:

```typescript
const columns = [
  { title: '姓名', dataIndex: 'name', width: 120, align: 'left' },
  { title: '年龄', dataIndex: 'age', width: 80, align: 'right' },
  { title: '操作', dataIndex: 'operations', width: 120, align: 'center', fixed: 'right' },
  { title: '描述', dataIndex: 'desc', ellipsis: true },  // 文字省略
  { title: '状态', dataIndex: 'status', sortable: true },  // 排序
  { title: '创建时间', dataIndex: 'createTime', sorter: (a, b) => a.createTime - b.createTime },
]

### 5. 对话框 Modal/Drawer

```vue
<!-- Modal 对话框 -->
<a-modal 
  v-model:visible="modalVisible" 
  title="标题" 
  @ok="handleOk" 
  @cancel="handleCancel"
  :ok-button-props="{ disabled: !formValid }"
  :cancel-button-props="{ }"
>
  内容区域
</a-modal>

<!-- Drawer 抽屉 -->
<a-drawer
  v-model:visible="drawerVisible"
  title="标题"
  :width="500"
  placement="right"
  @ok="handleOk"
>
  内容区域
</a-drawer>
```

**规范**:
- 确认操作使用 Modal
- 复杂表单或详情使用 Drawer
- 必填项未填时禁用确认按钮

### 6. 消息提示

```vue
// 成功
this.$message.success('操作成功')

// 警告
this.$message.warning('请注意')

// 错误
this.$message.error('操作失败')

// 提示
this.$message.info('提示信息')

// 加载
const hide = this.$message.loading('加载中...')
hide() // 手动关闭
```

**规范**:
- 成功操作使用 `success`
- 表单验证失败使用 `warning`
- 接口错误使用 `error`
- 位置默认右上角

### 7. 导航 Menu

```vue
<a-menu 
  v-model:selected-keys="selectedKeys" 
  mode="horizontal" 
  :accordion="true"
>
  <a-menu-item key="home">首页</a-menu-item>
  <a-menu-item key="about">关于</a-menu-item>
  <a-sub-menu key="sub">
    <template #title>子菜单</template>
    <a-menu-item key="sub1">选项1</a-menu-item>
    <a-menu-item key="sub2">选项2</a-menu-item>
  </a-sub-menu>
</a-menu>
```

### 8. 卡片 Card

```vue
<a-card :bordered="false" class="card-demo">
  <template #title>
    <span>卡片标题</span>
  </template>
  <template #extra>
    <a-link>更多</a-link>
  </template>
  卡片内容
</a-card>
```

### 9. 标签 Tag

```vue
<!-- 普通标签 -->
<a-tag>标签</a-tag>

<!-- 颜色标签 -->
<a-tag color="blue">蓝色</a-tag>
<a-tag color="green">绿色</a-tag>
<a-tag color="orange">橙色</a-tag>
<a-tag color="red">红色</a-tag>

<!-- 可关闭标签 -->
<a-tag closable @close="handleClose">可关闭</a-tag>
```

### 10. 图标 Icon

Arco Design Vue 提供了一套完整的图标库。

#### 安装

```bash
npm install @arco-design/web-vue
```

#### 导入方式

```vue
// 方式1：按需导入单个图标（推荐）
import { IconHome, IconSearch, IconSettings, IconUser, IconPlus, IconDelete } from '@arco-design/web-vue/es/icon'

// 方式2：全量导入
import ArcoVueIcon from '@arco-design/web-vue/es/icon'
import '@arco-design/web-vue/dist/arco.css'
app.use(ArcoVueIcon)
```

#### 使用方式

```vue
<template>
  <!-- 按钮中使用图标 -->
  <a-button type="primary">
    <template #icon><IconSearch /></template>
    搜索
  </a-button>
  
  <!-- 单独使用图标 -->
  <IconHome />
  
  <!-- 图标旋转 -->
  <IconSettings :style="{ transform: 'rotate(90deg)' }" />
  
  <!-- 图标大小 -->
  <IconUser :size="20" />
  
  <!-- 图标颜色 -->
  <IconDelete :style="{ color: '#F53F3F' }" />
</template>

<script setup>
import { IconHome, IconSearch, IconSettings, IconUser, IconDelete } from '@arco-design/web-vue/es/icon'
</script>
```

#### 图标资源

- **在线图标库**: https://arco.design/iconbox
- **Vue 组件文档**: https://arco.design/vue/component/icon
- **图标列表**: 所有图标以 `Icon` 开头命名，如 `IconHome`, `IconArrowDown`, `IconPlus`, `IconSettings`

#### 常用图标速查

| 分类 | 图标 |
|------|------|
| 箭头 | IconArrowUp, IconArrowDown, IconArrowLeft, IconArrowRight, IconLeft, IconRight, IconUp, IconDown |
| 操作 | IconPlus, IconMinus, IconClose, IconCheck, IconEdit, IconDelete, IconCopy, IconCut, IconPaste |
| 导航 | IconHome, IconMenu, IconSettings, IconUser, IconUserGroup |
| 文件 | IconFolder, IconFile, IconImage, IconVideo, IconAudio, IconDocument |
| 加载 | IconLoading, IconRefresh |
| 提示 | IconInfo, IconWarning, IconCheckCircle, IconCloseCircle, IconExclamationCircle |
| 搜索 | IconSearch, IconZoomIn, IconZoomOut |
| 时间 | IconClock, IconDate |

### 11. 气泡卡片 Popover

```vue
<!-- 基础用法 -->
<a-popover>
  <template #content>
    <div>气泡内容</div>
  </template>
  <a-button>悬浮显示</a-button>
</a-popover>

<!-- 位置 -->
<a-popover position="bottom">
  <template #content>
    <div>底部气泡</div>
  </template>
  <a-button>位置示例</a-button>
</a-popover>

<!-- 触发方式 -->
<a-popover trigger="click">
  <template #content>
    <div>点击触发</div>
  </template>
  <a-button>点击触发</a-button>
</a-popover>

<!-- 嵌套复杂内容 -->
<a-popover>
  <template #content>
    <div class="popover-content">
      <p>标题</p>
      <a-button type="primary">操作</a-button>
    </div>
  </template>
  <span class="cursor">复杂内容</span>
</a-popover>
```

**position 选项**: `top`, `tl`, `tr`, `bottom`, `bl`, `br`, `left`, `lt`, `lb`, `right`, `rt`, `rb`

### 12. 文字提示 Tooltip

```vue
<!-- 基础用法 -->
<a-tooltip content="提示内容">
  <a-button>悬浮显示</aoltip>
</a-tooltip>

<!-- 位置 -->
<a-tooltip position="bottom" content="底部提示">
  <a-button>位置示例</a-button>
</a-tooltip>

<!-- 背景色 -->
<a-tooltip background-color="#165DFF" content="蓝色背景">
  <a-button>自定义颜色</a-button>
</a-tooltip>

<!-- 文字颜色 -->
<a-tooltip color="#FFF" content="白色文字">
  <a-button>自定义文字颜色</a-button>
</a-tooltip>
```

### 13. 标签页 Tabs

```vue
<!-- 基础用法 -->
<a-tabs v-model:activeKey="activeKey">
  <a-tab-pane key="1" title="标签1">内容1</a-tab-pane>
  <a-tab-pane key="2" title="标签2">内容2</a-tab-pane>
</a-tabs>

<!-- 卡片风格 -->
<a-tabs type="card" v-model:activeKey="activeKey">
  <a-tab-pane key="1" title="标签1">内容1</a-tab-pane>
  <a-tab-pane key="2" title="标签2">内容2</a-tab-pane>
</a-tabs>

<!-- 可编辑标签 -->
<a-tabs type="card" v-model:activeKey="activeKey" editable>
  <a-tab-pane key="1" title="标签1">内容1</a-tab-pane>
  <a-tab-pane key="2" title="标签2">内容2</a-tab-pane>
</a-tabs>

<!-- 禁用 -->
<a-tab-pane key="3" title="禁用标签" disabled>内容3</a-tab-pane>
```

### 14. 面包屑 Breadcrumb

```vue
<!-- 基础用法 -->
<a-breadcrumb>
  <a-breadcrumb-item>首页</a-breadcrumb-item>
  <a-breadcrumb-item>列表</a-breadcrumb-item>
  <a-breadcrumb-item>详情</a-breadcrumb-item>
</a-breadcrumb>

<!-- 可点击 -->
<a-breadcrumb>
  <a-breadcrumb-item><a href="/">首页</a></a-breadcrumb-item>
  <a-breadcrumb-item><a href="/list">列表</a></a-breadcrumb-item>
  <a-breadcrumb-item>详情</a-breadcrumb-item>
</a-breadcrumb>

<!-- 使用图标 -->
<a-breadcrumb>
  <a-breadcrumb-item>
    <icon-home />
  </a-breadcrumb-item>
  <a-breadcrumb-item>应用管理</a-breadcrumb-item>
  <a-breadcrumb-item>详情</a-breadcrumb-item>
</a-breadcrumb>
```

### 15. 开关 Switch

```vue
<!-- 基础用法 -->
<a-switch v-model="checked" />

<!-- 禁用 -->
<a-switch disabled />

<!-- 加载状态 -->
<a-switch loading />

<!-- 自定义颜色 -->
<a-switch checked-color="#00B42A" unchecked-color="#F53F3F" />

<!-- 文字描述 -->
<a-switch>
  <template #checked-icon><icon-check /></template>
  <template #unchecked-icon><icon-close /></template>
</a-switch>
```

### 16. 下拉菜单 Dropdown

```vue
<!-- 基础用法 -->
<a-dropdown>
  <a-button>下拉菜单 <icon-down /></a-button>
  <template #content>
    <a-doption>选项1</a-doption>
    <a-doption>选项2</a-doption>
    <a-doption>选项3</a-doption>
  </template>
</a-dropdown>

<!-- 带分组 -->
<a-dropdown>
  <a-button>下拉菜单</a-button>
  <template #content>
    <a-dgroup title="分组1">
      <a-doption>选项1</a-doption>
      <a-doption>选项2</a-doption>
    </a-dgroup>
    <a-dgroup title="分组2">
      <a-doption>选项3</a-doption>
    </a-dgroup>
  </template>
</a-dropdown>

<!-- 禁用选项 -->
<a-dropdown>
  <a-button>下拉菜单</a-button>
  <template #content>
    <a-doption>正常选项</a-doption>
    <a-doption disabled>禁用选项</a-doption>
  </template>
</a-dropdown>

<!-- 点击触发 -->
<a-dropdown trigger="click">
  <a-button>点击触发</a-button>
  <template #content>
    <a-doption @click="handleClick">点击执行</a-doption>
  </template>
</a-dropdown>
```

### 17. 加载 Loading

```vue
<!-- 全屏加载 -->
<a-spin :spinning="loading">
  <div>内容区域</div>
</a-spin>

<!-- 遮罩加载 -->
<a-spin :spinning="loading" tip="加载中...">
  <div class="content">内容区域</div>
</a-spin>

<!-- 自定义图标 -->
<a-spin :spinning="loading">
  <template #indicator>
    <icon-loading class="spin-icon" />
  </template>
  <div>内容区域</div>
</a-spin>

<!-- 按钮加载 -->
<a-button :loading="loading">提交</a-button>
<a-button :loading="true" disabled>加载中...</a-button>
```

### 18. 空状态 Empty

```vue
<!-- 基础用法 -->
<a-empty />

<!-- 自定义描述 -->
<a-empty description="暂无数据" />

<!-- 图片 -->
<a-empty :image-src="customImage" />

<!-- 操作按钮 -->
<a-empty description="暂无数据">
  <a-button type="primary">创建</a-button>
</a-empty>
```

### 19. 折叠面板 Collapse

```vue
<!-- 基础用法 -->
<a-collapse>
  <a-collapse-item key="1" title="标题1">
    <div>内容1</div>
  </a-collapse-item>
  <a-collapse-item key="2" title="标题2">
    <div>内容2</div>
  </a-collapse-item>
</a-collapse>

<!-- 手风琴模式 -->
<a-collapse accordion>
  <a-collapse-item key="1" title="标题1">
    <div>内容1</div>
  </a-collapse-item>
  <a-collapse-item key="2" title="标题2">
    <div>内容2</div>
  </a-collapse-item>
</a-collapse>

<!-- 默认展开 -->
<a-collapse :default-active-keys="['1']">
  <a-collapse-item key="1" title="默认展开">
    <div>内容1</div>
  </a-collapse-item>
</a-collapse>
```

### 20. 进度条 Progress

```vue
<!-- 线性进度条 -->
<a-progress :percent="50" />

<!-- 百分比显示 -->
<a-progress :percent="50" show-text />

<!-- 自定义格式 -->
<a-progress :percent="50" format="{value}% 完成" />

<!-- 状态 -->
<a-progress :percent="30" status="error" />
<a-progress :percent="60" status="warning" />
<a-progress :percent="100" status="success" />

<!-- 环形进度条 -->
<a-progress :percent="50" type="circle" />

<!-- 仪表盘类型 -->
<a-progress :percent="50" type="dashboard" />
```

## 配色规范

### 主题色

Arco Design 默认主题色为蓝色(#165DFF)，常用色值：

| 用途 | 颜色 | 变量 |
|------|------|------|
| 主色 | #165DFF | rgb(22, 93, 255) |
| 链接色 | #165DFF | - |
| 成功 | #00B42A | - |
| 警告 | #FF7D00 | - |
| 错误 | #F53F3F | - |
| 禁用 | #C9CDD4 | - |

### 中性色

| 用途 | 浅色模式 | 深色模式 |
|------|----------|----------|
| 背景 | #FFFFFF | #1D2129 |
| 次级背景 | #F2F3F5 | #2D323B |
| 边框 | #E5E6EB | #3D424E |
| 文字主要 | #1D2129 | #E5E6EB |
| 文字次要 | #4E5969 | #8B949E |

## 间距规范

使用 4px 基础单位：

- `size-1`: 4px
- `size-2`: 8px
- `size-3`: 12px
- `size-4`: 16px
- `size-5`: 20px
- `size-6`: 24px
- `size-8`: 32px
- `size-10`: 40px

## 组件尺寸

- 大型: `size="large"` - 用于重要操作或主页面
- 中型: `size="medium"` - 默认尺寸
- 小型: `size="small"` - 用于表格、操作列等紧凑场景

## 响应式设计

```vue
<!-- 响应式显示 -->
<a-responsive-grid breakpoint="desktop">
  <div>桌面端内容</div>
</a-responsive-grid>

<!-- 或使用 CSS 类 -->
<div class="hidden-xs">桌面端显示</div>
```

## 状态管理

使用 Pinia 进行状态管理：

```typescript
import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    userInfo: null as UserInfo | null,
    token: '',
  }),
  getters: {
    isLoggedIn: (state) => !!state.token,
  },
  actions: {
    async login(credentials: LoginCredentials) {
      const res = await api.login(credentials)
      this.token = res.token
      this.userInfo = res.userInfo
    },
  },
})
```

## 请求封装

使用 axios 并集成 Arco Design 消息提示：

```typescript
import axios from 'axios'
import { Message } from '@arco-design/web-vue'

const instance = axios.create({
  baseURL: '/api',
  timeout: 10000,
})

instance.interceptors.response.use(
  (response) => response.data,
  (error) => {
    const msg = error.response?.data?.message || '网络错误'
    Message.error(msg)
    return Promise.reject(error)
  }
)

export default instance
```

## TypeScript 类型

```typescript
// 定义接口
interface User {
  id: number
  name: string
  email: string
  status: 'active' | 'inactive'
}

// 表格列类型
interface TableColumn {
  title: string
  dataIndex: string
  width?: number
  align?: 'left' | 'center' | 'right'
}
```

## 常见模式

### 空状态

```vue
<a-empty description="暂无数据" />
```

### 加载状态

```vue
<a-spin :size="40" tip="加载中...">
  实际内容
</a-spin>
```

### 确认对话框

```vue
<a-popconfirm 
  title="确定要删除吗？"
  @ok="handleDelete"
  @cancel="handleCancel"
>
  <a-button type="primary" status="danger">删除</a-button>
</a-popconfirm>
```

### 步骤条

```vue
<a-steps :current="current">
  <a-step title="步骤1" description="描述信息" />
  <a-step title="步骤2" description="描述信息" />
  <a-step title="步骤3" description="描述信息" />
</a-steps>
```

### 时间线

```vue
<a-timeline>
  <a-timeline-item color="green">创建成功 - 2024-01-01</a-timeline-item>
  <a-timeline-item color="blue">处理中 - 2024-01-02</a-timeline-item>
  <a-timeline-item color="gray">等待中 - 2024-01-03</a-timeline-item>
</a-timeline>
```

## 注意事项

1. **不要重复造轮子**: 优先使用 Arco Design 组件
2. **保持简洁**: 避免过度设计，简洁清晰为主
3. **一致性**: 同类操作使用相同的组件和交互模式
4. **可访问性**: 确保键盘导航和屏幕阅读器支持
5. **性能**: 大列表使用虚拟滚动，合理使用 `v-if`/`v-show`

## 深色主题

### 全局深色模式

```typescript
import { setTheme, ThemeMode } from '@arco-design/web-vue'

// 切换到深色模式
setTheme(ThemeMode.Dark)

// 切换到浅色模式
setTheme(ThemeMode.Light)

// 跟随系统
setTheme(ThemeMode.Auto)
```

### CSS 变量覆盖

深色模式下会自动应用以下 CSS 变量：

```css
/* 浅色模式默认值 */
:root {
  --color-bg-1: #ffffff;
  --color-bg-2: #f7f8fa;
  --color-bg-3: #f2f3f5;
  --color-bg-4: #e5e6eb;
  --color-text-1: #1d2129;
  --color-text-2: #4e5969;
  --color-text-3: #86909c;
  --color-border-1: #e5e6eb;
  --color-border-2: #c9cdd4;
  --color-border-3: #86909c;
  --color-border-4: #4e5969;
}

/* 深色模式 */
[data-theme='dark'] {
  --color-bg-1: #1d2129;
  --color-bg-2: #23272e;
  --color-bg-3: #2d323b;
  --color-bg-4: #373c47;
  --color-text-1: #e5e6eb;
  --color-text-2: #8b949e;
  --color-text-3: #6d7681;
  --color-border-1: #3d424e;
  --color-border-2: #4e5969;
  --color-border-3: #6d7681;
  --color-border-4: #8b949e;
}
```

### 组件级深色样式

```vue
<template>
  <!-- 使用 class 切换 -->
  <div class="dark-mode-card">
    <a-card>
      <div>深色卡片内容</div>
    </a-card>
  </div>
</template>

<style scoped>
.dark-mode-card {
  --card-bg: #23272e;
  --card-border: #3d424e;
}

.dark-mode-card .arco-card {
  background: var(--card-bg);
  border-color: var(--card-border);
}
</style>
```

## 主题定制

### 自定义主题色

```typescript
import { setGlobalConfig } from '@arco-design/web-vue'

setGlobalConfig({
  theme: {
    primary: '#165DFF',  // 自定义主色
  },
})
```

### 全局配置

```typescript
import { setGlobalConfig } from '@arco-design/web-vue'

setGlobalConfig({
  // 组件尺寸
  size: 'medium',  // 'mini' | 'small' | 'medium' | 'large'
  
  // 国际化
  locale: 'zh-CN',  // 'zh-CN' | 'en-US'
  
  // 主题
  theme: {
    primary: '#165DFF',
  },
  
  // 消息配置
  message: {
    max: 3,
    duration: 3000,
  },
})
```

## 动画过渡

### 组件内置动画

Arco Design 组件内置了过渡动画：

```vue
<!-- 淡入淡出 -->
<a-fade-in>
  <div>内容</div>
</a-fade-in>

<!-- 缩放 -->
<a-scale-in>
  <div>内容</div>
</a-scale-in>

<!-- 滑动 -->
<a-slide-up-in>
  <div>内容</div>
</a-slide-up-in>

<a-slide-down-in>
  <div>内容</div>
</a-slide-down-in>

<a-slide-left-in>
  <div>内容</div>
</a-slide-left-in>

<a-slide-right-in>
  <div>内容</div>
</a-slide-right-in>
```

### Vue Transition

```vue
<template>
  <transition name="fade">
    <div v-if="show">内容</div>
  </transition>
</template>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
```

## 响应式断点

| 断点 | 最小宽度 | 适用场景 |
|------|----------|----------|
| `xs` | 320px | 超小屏幕 |
| `sm` | 576px | 手机 |
| `md` | 768px | 平板 |
| `lg` | 992px | 小屏笔记本 |
| `xl` | 1200px | 桌面 |
| `xxl` | 1400px | 大屏桌面 |

### 使用响应式类

```vue
<!-- 响应式隐藏/显示 -->
<div class="hidden-xs">桌面端显示</div>
<div class="visible-xs">手机端显示</div>

<!-- 响应式栅格 -->
<a-row>
  <a-col :xs="24" :md="12" :lg="8">响应式列</a-col>
</a-row>

<!-- 响应式间距 -->
<div class="mt-xs-4 mt-md-8">响应式间距</div>
```

## 表单验证

### 内置规则

```vue
<template>
  <a-form :model="form" :rules="rules" layout="vertical">
    <a-form-item label="用户名" field="username">
      <a-input v-model="form.username" placeholder="请输入用户名" />
    </a-form-item>
    <a-form-item label="邮箱" field="email">
      <a-input v-model="form.email" placeholder="请输入邮箱" />
    </a-form-item>
    <a-form-item label="密码" field="password">
      <a-input v-model="form.password" type="password" placeholder="请输入密码" />
    </a-form-item>
  </a-form>
</template>

<script setup>
const form = ref({})
const rules = {
  username: [
    { required: true, message: '请输入用户名' },
    { minLength: 3, message: '用户名至少3个字符' },
  ],
  email: [
    { required: true, message: '请输入邮箱' },
    { type: 'email', message: '请输入正确的邮箱格式' },
  ],
  password: [
    { required: true, message: '请输入密码' },
    { minLength: 6, message: '密码至少6个字符' },
  ],
}
</script>
```

### 自定义验证

```javascript
const rules = {
  password: [
    {
      validator: (value, callback) => {
        if (!value) {
          callback('请输入密码')
        } else if (value.length < 6) {
          callback('密码至少6个字符')
        } else if (!/\d/.test(value)) {
          callback('密码必须包含数字')
        } else {
          callback()
        }
      },
    },
  ],
}
```

## 国际化

### 基础用法

```typescript
import { useI18n } from 'vue-i18n'
import zhCN from '@arco-design/web-vue/es/locale/zh-CN'
import enUS from '@arco-design/web-vue/es/locale/en-US'

const { t } = useI18n()

// 中文
setGlobalConfig({ locale: zhCN })

// 英文
setGlobalConfig({ locale: enUS })

// 使用
const message = t('form.submit')
```

## 辅助功能

### 屏幕阅读器

```vue
<!-- 添加 aria-label -->
<a-button aria-label="提交表单">提交</a-button>

<!-- 禁用阅读 -->
<span aria-hidden="true">仅供展示</span>

<!-- 正确关联 -->
<label for="username">用户名</label>
<input id="username" v-model="form.username" />
```

### 键盘导航

```vue
<!-- 焦点顺序 -->
<a-button tabindex="1">第一个</a-button>
<a-button tabindex="3">第三个</a-button>
<a-button tabindex="2">第二个</a-button>

<!-- 快捷键 -->
<a-input 
  v-model="value" 
  @keydown.enter="handleEnter"
  @keydown.escape="handleEscape"
/>
```

## 性能优化

### 大列表优化

```vue
<!-- 虚拟列表 -->
<a-virtual-list 
  :data="largeList" 
  :item-size="60"
>
  <template #item="{ item }">
    <div>{{ item.name }}</div>
  </template>
</a-virtual-list>
```

### 图片懒加载

```vue
<a-image 
  :src="src" 
  loading="lazy"
/>
```

### 按需加载

```bash
# 使用 unplugin-vue-components 自动按需导入
npm install -D unplugin-vue-components unplugin-auto-import
```

```typescript
// vite.config.ts
import AutoImport from 'unplugin-auto-import/vite'
import Components from 'unplugin-vue-components/vite'
import { ArcoResolver } from 'unplugin-vue-components/resolvers'

export default defineConfig({
  plugins: [
    AutoImport({
      resolvers: [ArcoResolver()],
    }),
    Components({
      resolvers: [ArcoResolver()],
    }),
  ],
})
```

## 附录

### 常用颜色速查

| 颜色 | Hex | RGB | 用途 |
|------|-----|-----|------|
| 主色 | #165DFF | rgb(22, 93, 255) | 主要操作 |
| 成功 | #00B42A | rgb(0, 178, 42) | 成功状态 |
| 警告 | #FF7D00 | rgb(255, 125, 0) | 警告状态 |
| 错误 | #F53F3F | rgb(245, 63, 63) | 错误状态 |
| 信息 | #0FC6C2 | rgb(15, 198, 194) | 信息提示 |

### 常用间距速查

| 类名 | 间距 |
|------|------|
| `m-0` / `p-0` | 0 |
| `m-1` / `p-1` | 4px |
| `m-2` / `p-2` | 8px |
| `m-3` / `p-3` | 12px |
| `m-4` / `p-4` | 16px |
| `m-6` / `p-6` | 24px |
| `m-8` / `p-8` | 32px |

### 文档链接

- [Arco Design Vue 官网](https://arco.design/vue)
- [组件文档](https://arco.design/vue/component/button)
- [设计系统](https://arco.design/designlab/)
- [图标库](https://arco.design/iconbox)

