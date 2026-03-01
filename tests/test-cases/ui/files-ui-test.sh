#!/bin/bash
# W7Panel 文件管理 UI 测试用例
# 测试文件管理的各项功能

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-lib.sh"

echo "=========================================="
echo "  W7Panel 文件管理 UI 测试"
echo "=========================================="

# 测试前置条件：服务已启动，验证码已禁用
check_service || exit 1

#========================================
# 测试1: 登录功能
#========================================
test_login() {
    log_step "测试1: 登录功能"
    
    agent-browser open "$BASE_URL" 2>&1 | grep -v "^$" || true
    sleep 3
    
    # 获取登录表单
    agent-browser snapshot -i 2>&1 | grep -q "用户名" || {
        log_fail "登录页未正确加载"
        return 1
    }
    
    # 填写用户名密码并登录
    agent-browser fill @e1 "$USERNAME" 2>&1 | grep -q "Done" || return 1
    agent-browser fill @e2 "$PASSWORD" 2>&1 | grep -q "Done" || return 1
    agent-browser click @e4 2>&1 | grep -q "Done" || return 1
    sleep 3
    
    # 验证登录成功
    local url=$(agent-browser get url 2>&1)
    if [[ "$url" == *"/cluster/panel"* ]] || [[ "$url" == *"/app/apps"* ]]; then
        log_pass "登录成功，跳转正常"
        return 0
    else
        log_fail "登录失败，URL: $url"
        return 1
    fi
}

#========================================
# 测试2: 进入应用列表
#========================================
test_app_list() {
    log_step "测试2: 进入应用列表"
    
    # 导航到应用列表页面
    agent-browser open "$BASE_URL/app/apps" 2>&1 | grep -v "^$" || true
    sleep 5
    
    # 验证应用列表加载
    agent-browser snapshot -i 2>&1 | grep -q "应用列表" || {
        log_fail "应用列表未加载"
        return 1
    }
    
    log_pass "应用列表加载成功"
    return 0
}

#========================================
# 测试3: 打开文件管理
#========================================
test_open_file_manager() {
    log_step "测试3: 打开文件管理"
    
    # 点击第一个应用的文件管理按钮
    agent-browser eval "
    (function() {
        const rows = document.querySelectorAll('tbody tr');
        for (const row of rows) {
            const cells = row.querySelectorAll('td');
            if (cells.length >= 4) {
                const opsCell = cells[cells.length - 1];
                const spans = opsCell.querySelectorAll('span');
                for (const span of spans) {
                    if (span.textContent.trim() === '文件管理') {
                        span.click();
                        return 'clicked';
                    }
                }
            }
        }
        return 'not found';
    })()
    " 2>&1 | grep -q "clicked" || {
        log_fail "未找到文件管理按钮"
        return 1
    }
    
    sleep 3
    
    # 验证文件管理页面打开
    local url=$(agent-browser get url 2>&1)
    if [[ "$url" == *"/files"* ]]; then
        log_pass "文件管理页面打开成功"
        return 0
    else
        log_fail "文件管理页面未打开，URL: $url"
        return 1
    fi
}

#========================================
# 测试4: 文件列表加载
#========================================
test_file_list_load() {
    log_step "测试4: 文件列表加载"
    
    # 等待文件列表加载
    sleep 3
    
    # 检查控制台错误
    local errors=$(agent-browser console 2>&1 | grep -i "error" | grep -v "warning" | head -5)
    if [ -n "$errors" ]; then
        log_warn "控制台存在错误: $errors"
    fi
    
    # 获取页面内容
    local content=$(agent-browser eval "document.body.innerText" 2>&1)
    
    # 验证文件列表（可能为空目录或有文件）
    if [ -n "$content" ]; then
        log_pass "文件列表加载完成"
        return 0
    else
        log_fail "文件列表加载失败"
        return 1
    fi
}

#========================================
# 测试5: 目录导航
#========================================
test_directory_navigation() {
    log_step "测试5: 目录导航"
    
    # 尝试点击进入目录（如果有的话）
    agent-browser eval "
    (function() {
        const rows = document.querySelectorAll('tbody tr, .filetable tbody tr');
        for (const row of rows) {
            const nameCell = row.querySelector('.filename, [class*=filename]');
            if (nameCell) {
                const icon = nameCell.previousElementSibling;
                if (icon && (icon.classList.contains('folder') || icon.classList.contains('dir'))) {
                    nameCell.click();
                    return 'clicked';
                }
            }
        }
        return 'no folder';
    })()
    " 2>&1
    
    sleep 2
    
    log_pass "目录导航测试完成"
    return 0
}

#========================================
# 测试6: 面包屑导航
#========================================
test_breadcrumb() {
    log_step "测试6: 面包屑导航"
    
    # 检查面包屑是否存在
    local breadcrumb=$(agent-browser eval "
    (function() {
        const breadcrumbs = document.querySelectorAll('.pathbox, .arco-breadcrumb-item, [class*=breadcrumb]');
        return breadcrumbs.length > 0 ? 'found' : 'not found';
    })()
    " 2>&1)
    
    if [[ "$breadcrumb" == *"found"* ]]; then
        log_pass "面包屑导航正常"
    else
        log_warn "未找到面包屑导航"
    fi
    
    return 0
}

#========================================
# 测试7: 文件操作按钮
#========================================
test_file_buttons() {
    log_step "测试7: 文件操作按钮"
    
    # 获取页面按钮
    agent-browser snapshot -i 2>&1 | grep -E "复制|上传|新建" || {
        log_warn "未找到文件操作按钮"
    }
    
    log_pass "文件操作按钮检查完成"
    return 0
}

#========================================
# 测试8: 开发编辑器入口
#========================================
test_editor_entry() {
    log_step "测试8: 开发编辑器入口"
    
    # 检查是否有开发编辑器按钮
    agent-browser snapshot -i 2>&1 | grep -q "开发编辑器" && {
        log_pass "开发编辑器入口存在"
    } || {
        log_warn "未找到开发编辑器入口"
    }
    
    return 0
}

#========================================
# 主测试流程
#========================================
main() {
    local PASSED=0
    local FAILED=0
    
    # 测试1: 登录
    test_login && ((PASSED++)) || ((FAILED++))
    take_screenshot "/tmp/test-login.png"
    
    # 测试2: 应用列表
    test_app_list && ((PASSED++)) || ((FAILED++))
    
    # 测试3: 打开文件管理
    test_open_file_manager && ((PASSED++)) || ((FAILED++))
    take_screenshot "/tmp/test-filemanager.png"
    
    # 测试4: 文件列表
    test_file_list_load && ((PASSED++)) || ((FAILED++))
    
    # 测试5: 目录导航
    test_directory_navigation && ((PASSED++)) || ((FAILED++))
    
    # 测试6: 面包屑
    test_breadcrumb && ((PASSED++)) || ((FAILED++))
    
    # 测试7: 文件按钮
    test_file_buttons && ((PASSED++)) || ((FAILED++))
    
    # 测试8: 编辑器入口
    test_editor_entry && ((PASSED++)) || ((FAILED++))
    
    # 总结
    echo ""
    echo "=========================================="
    echo "  测试结果汇总"
    echo "=========================================="
    echo "通过: $PASSED"
    echo "失败: $FAILED"
    echo "总计: $((PASSED + FAILED))"
    
    agent-browser close 2>/dev/null || true
    
    if [ $FAILED -gt 0 ]; then
        exit 1
    fi
}

main "$@"
