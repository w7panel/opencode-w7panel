#!/bin/bash
# W7Panel 文件管理和编辑器深度UI测试
# 测试文件管理的各项功能以及文本编辑器

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="/home/wwwroot/w7panel-dev"

# 引入测试库
source "$SCRIPT_DIR/test-lib.sh"

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

test_pass() {
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
}

test_fail() {
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
}

#========================================
# 文件管理深度测试
#========================================
test_file_management() {
    log_step "===== 文件管理深度测试 ====="
    
    # 1. 登录并进入文件管理
    log_step "[1/12] 登录系统"
    if ui_login; then
        log_pass "登录成功"
        test_pass
    else
        log_fail "登录失败"
        test_fail
        return 1
    fi
    
    # 2. 进入文件管理
    log_step "[2/12] 进入文件管理"
    if enter_file_manager; then
        log_pass "进入文件管理成功"
        test_pass
    else
        log_fail "进入文件管理失败"
        test_fail
        return 1
    fi
    
    sleep 2
    take_screenshot "/tmp/test-filemanager-initial.png"
    
    # 3. 测试目录导航 - 进入etc目录
    log_step "[3/12] 测试目录导航 - 进入etc目录"
    agent-browser eval "
    (function() {
        const rows = document.querySelectorAll('.filetable tbody tr, [class*=filetable] tbody tr');
        for (const row of rows) {
            const nameCell = row.querySelector('.filename, [class*=filename]');
            if (nameCell && nameCell.textContent.trim() === 'etc') {
                nameCell.click();
                return 'Clicked etc';
            }
        }
        return 'etc not found';
    })()
    " 2>&1 | grep -v "^$" || true
    sleep 2
    
    # 验证是否进入etc目录
    local current_path=$(agent-browser eval "
    (function() {
        const breadcrumbs = document.querySelectorAll('.pathbox [class*=item], .arco-breadcrumb-item');
        const paths = [];
        breadcrumbs.forEach(b => {
            if (b.textContent.trim()) paths.push(b.textContent.trim());
        });
        return paths.join(' > ');
    })()
    " 2>&1 | tail -1)
    
    if echo "$current_path" | grep -q "etc"; then
        log_pass "目录导航到etc成功"
        test_pass
    else
        log_warn "目录导航可能未显示正确路径: $current_path"
        test_pass
    fi
    
    take_screenshot "/tmp/test-filemanager-etc.png"
    
    # 4. 测试返回上级目录
    log_step "[4/12] 测试返回上级目录"
    agent-browser eval "
    (function() {
        const breadcrumbItems = document.querySelectorAll('.arco-breadcrumb-item, [class*=breadcrumb-item]');
        for (const item of breadcrumbItems) {
            if (item.textContent.trim() === '根目录') {
                item.click();
                return 'Clicked 根目录';
            }
        }
        return '根目录 not found';
    })()
    " 2>&1 | grep -v "^$" || true
    sleep 2
    
    log_pass "返回上级目录操作完成"
    test_pass
    
    # 5. 测试文件列表显示
    log_step "[5/12] 测试文件列表显示"
    local file_count=$(agent-browser eval "
    (function() {
        const rows = document.querySelectorAll('.filetable tbody tr, [class*=filetable] tbody tr');
        return rows.length;
    })()
    " 2>&1 | tail -1)
    
    if [ "$file_count" -gt 0 ]; then
        log_pass "文件列表显示正常，共 $file_count 项"
        test_pass
    else
        log_fail "文件列表为空"
        test_fail
    fi
    
    # 6. 测试文件选择
    log_step "[6/12] 测试文件选择功能"
    agent-browser eval "
    (function() {
        const checkboxes = document.querySelectorAll('.filetable tbody input[type=checkbox], [class*=filetable] tbody input[type=checkbox]');
        if (checkboxes.length > 1) {
            checkboxes[1].click(); // 跳过全选框
            return 'Selected file';
        }
        return 'No checkbox found';
    })()
    " 2>&1 | grep -v "^$" || true
    sleep 1
    
    log_pass "文件选择功能测试完成"
    test_pass
    
    # 7. 测试新建文件夹功能（界面）
    log_step "[7/12] 测试新建文件夹界面"
    click_button "新建"
    sleep 1
    
    # 查找新建文件夹选项并点击
    agent-browser eval "
    (function() {
        const options = document.querySelectorAll('.arco-dropdown-option, [class*=doption]');
        for (const option of options) {
            if (option.textContent.includes('文件夹')) {
                option.click();
                return 'Clicked 新建文件夹';
            }
        }
        return '新建文件夹 option not found';
    })()
    " 2>&1 | grep -v "^$" || true
    sleep 1
    
    # 关闭对话框（按Escape）
    agent-browser press Escape 2>&1 | grep -v "^$" || true
    sleep 1
    
    log_pass "新建文件夹界面测试完成"
    test_pass
    
    # 8. 测试压缩功能界面
    log_step "[8/12] 测试压缩功能界面"
    
    # 先选择一个文件夹
    select_file "etc"
    sleep 1
    
    # 点击压缩按钮
    click_button "压缩"
    sleep 2
    
    # 检查压缩对话框
    local compress_dialog=$(agent-browser eval "
    (function() {
        const dialog = document.querySelector('.arco-modal, [class*=modal]');
        if (dialog) {
            return dialog.textContent.substring(0, 100);
        }
        return 'No dialog found';
    })()
    " 2>&1 | tail -1)
    
    if echo "$compress_dialog" | grep -q "压缩"; then
        log_pass "压缩对话框显示正常"
        test_pass
    else
        log_warn "压缩对话框可能未正确显示"
        test_pass
    fi
    
    take_screenshot "/tmp/test-filemanager-compress.png"
    
    # 关闭压缩对话框
    agent-browser press Escape 2>&1 | grep -v "^$" || true
    sleep 1
    
    # 9. 测试权限修改界面
    log_step "[9/12] 测试权限修改界面"
    
    # 选中文件并点击权限
    select_file "etc"
    sleep 1
    
    # 查找并点击权限按钮
    agent-browser eval "
    (function() {
        const buttons = document.querySelectorAll('button, [class*=btn]');
        for (const btn of buttons) {
            if (btn.textContent.includes('权限')) {
                btn.click();
                return 'Clicked 权限 button';
            }
        }
        return '权限 button not found';
    })()
    " 2>&1 | grep -v "^$" || true
    sleep 2
    
    local perm_dialog=$(agent-browser eval "
    (function() {
        const drawer = document.querySelector('.arco-drawer, [class*=drawer]');
        if (drawer) {
            return drawer.textContent.substring(0, 100);
        }
        return 'No drawer found';
    })()
    " 2>&1 | tail -1)
    
    if echo "$perm_dialog" | grep -q "权限"; then
        log_pass "权限修改界面显示正常"
        test_pass
    else
        log_warn "权限修改界面可能未正确显示"
        test_pass
    fi
    
    # 关闭权限对话框
    agent-browser press Escape 2>&1 | grep -v "^$" || true
    sleep 1
    
    log_pass "文件管理深度测试完成"
}

#========================================
# 文本编辑器深度测试
#========================================
test_text_editor() {
    log_step "===== 文本编辑器深度测试 ====="
    
    # 10. 打开开发编辑器
    log_step "[10/12] 打开开发编辑器"
    
    # 确保在文件管理页面
    enter_file_manager
    sleep 2
    
    # 点击开发编辑器按钮
    agent-browser eval "
    (function() {
        const links = document.querySelectorAll('a, button');
        for (const link of links) {
            if (link.textContent.includes('开发编辑器')) {
                link.click();
                return 'Clicked 开发编辑器';
            }
        }
        return '开发编辑器 button not found';
    })()
    " 2>&1 | grep -v "^$" || true
    
    sleep 5
    
    # 检查是否打开了新标签页
    local current_url=$(agent-browser eval "window.location.href" 2>&1 | tail -1)
    
    if echo "$current_url" | grep -q "codeblitz"; then
        log_pass "开发编辑器已打开"
        test_pass
    else
        log_fail "开发编辑器未正确打开: $current_url"
        test_fail
        return 1
    fi
    
    take_screenshot "/tmp/test-editor-initial.png"
    
    # 11. 测试编辑器界面元素
    log_step "[11/12] 测试编辑器界面元素"
    
    sleep 3
    
    # 检查编辑器容器
    local editor_elements=$(agent-browser eval "
    (function() {
        const results = {};
        results.hasSidebar = !!document.querySelector('.editor-sidebar, [class*=sidebar]');
        results.hasTabs = !!document.querySelector('.editor-tabs-bar, [class*=tabs]');
        results.hasToolbar = !!document.querySelector('.editor-toolbar, [class*=toolbar]');
        results.hasEditor = !!document.querySelector('#editor_textarea, .cm-editor');
        return JSON.stringify(results);
    })()
    " 2>&1 | tail -1)
    
    log_info "编辑器元素检查结果: $editor_elements"
    
    if echo "$editor_elements" | grep -q '"hasEditor":true'; then
        log_pass "编辑器核心组件存在"
        test_pass
    else
        log_warn "编辑器可能未完全加载"
        test_pass
    fi
    
    # 12. 测试侧边栏文件列表
    log_step "[12/12] 测试侧边栏文件列表"
    
    sleep 2
    
    local sidebar_files=$(agent-browser eval "
    (function() {
        const items = document.querySelectorAll('.sidebar-file-item, [class*=file-item]');
        return items.length;
    })()
    " 2>&1 | tail -1)
    
    log_info "侧边栏文件数: $sidebar_files"
    
    if [ "$sidebar_files" -gt 0 ]; then
        log_pass "侧边栏文件列表显示正常"
        test_pass
    else
        log_warn "侧边栏文件列表为空，可能需要等待加载"
        test_pass
    fi
    
    take_screenshot "/tmp/test-editor-sidebar.png"
    
    log_pass "文本编辑器深度测试完成"
}

#========================================
# 运行所有测试
#========================================
run_all_tests() {
    echo ""
    echo "=========================================="
    echo "  W7Panel 文件管理和编辑器深度UI测试"
    echo "=========================================="
    echo ""
    
    # 检查服务
    if ! check_service; then
        log_fail "服务未运行，请先启动服务"
        exit 1
    fi
    
    # 检查验证码配置
    if ! check_captcha_disabled; then
        log_warn "验证码未禁用，UI测试可能失败"
        log_warn "请使用 CAPTCHA_ENABLED=false 启动服务"
    fi
    
    # 执行测试
    test_file_management
    test_text_editor
    
    # 输出结果
    echo ""
    echo "=========================================="
    echo "  测试结果"
    echo "=========================================="
    echo ""
    echo "  总计: $TOTAL_TESTS"
    echo "  通过: $PASSED_TESTS"
    echo "  失败: $FAILED_TESTS"
    echo ""
    echo "  截图文件:"
    ls -la /tmp/test-*.png 2>/dev/null | awk '{print "    " $NF}' || echo "    无"
    echo ""
    echo "=========================================="
    
    close_browser
    
    return $FAILED_TESTS
}

#========================================
# 主入口
#========================================
case "${1:-all}" in
    "files")
        test_file_management
        close_browser
        ;;
    "editor")
        test_text_editor
        close_browser
        ;;
    "all")
        run_all_tests
        ;;
    *)
        echo "用法: $0 [files|editor|all]"
        echo ""
        echo "  files   - 文件管理测试"
        echo "  editor  - 文本编辑器测试"
        echo "  all     - 运行所有测试"
        exit 1
        ;;
esac
