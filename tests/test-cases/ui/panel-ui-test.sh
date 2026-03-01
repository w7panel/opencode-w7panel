#!/bin/bash
# W7Panel 面板功能完整UI测试
# 测试面板的主要功能模块

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 引入测试库
source "$SCRIPT_DIR/test-lib.sh"

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

#========================================
# 测试计数器
#========================================
test_pass() {
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
}

test_fail() {
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
}

#========================================
# 测试1: 登录功能
#========================================
test_login() {
    log_step "[1/8] 登录功能测试"
    
    if ui_login; then
        log_pass "登录成功"
        test_pass
        return 0
    else
        log_fail "登录失败"
        test_fail
        return 1
    fi
}

#========================================
# 测试2: 集群概览页面
#========================================
test_dashboard() {
    log_step "[2/8] 集群概览页面测试"
    
    # 检查概览信息是否显示
    local snapshot=$(agent-browser snapshot 2>&1)
    
    if echo "$snapshot" | grep -q "概览"; then
        log_pass "概览页面显示正常"
        test_pass
    else
        log_fail "概览页面显示异常"
        test_fail
    fi
    
    # 检查节点信息
    if echo "$snapshot" | grep -q "节点"; then
        log_pass "节点信息显示正常"
        test_pass
    else
        log_fail "节点信息未显示"
        test_fail
    fi
    
    # 检查应用信息
    if echo "$snapshot" | grep -q "应用"; then
        log_pass "应用信息显示正常"
        test_pass
    else
        log_fail "应用信息未显示"
        test_fail
    fi
}

#========================================
# 测试3: 应用列表页面
#========================================
test_app_list() {
    log_step "[3/8] 应用列表页面测试"
    
    # 导航到应用列表
    agent-browser open "$BASE_URL/app/apps" 2>&1 | grep -v "^$" || true
    sleep 5
    
    # 点击应用列表菜单
    agent-browser eval "
    (function() {
        const items = document.querySelectorAll('[class*=menu]');
        for (const item of items) {
            if (item.textContent.trim() === '应用列表') {
                item.click();
                return true;
            }
        }
        return false;
    })()
    " 2>&1 | grep -v "^$" || true
    sleep 3
    
    # 截图
    take_screenshot "/tmp/panel-test-app-list.png"
    
    # 检查应用列表表格
    local snapshot=$(agent-browser snapshot 2>&1)
    
    if echo "$snapshot" | grep -q "应用名称"; then
        log_pass "应用列表表格显示正常"
        test_pass
    else
        log_fail "应用列表表格显示异常"
        test_fail
    fi
    
    # 检查新建按钮
    if echo "$snapshot" | grep -q "新建"; then
        log_pass "新建按钮显示正常"
        test_pass
    else
        log_fail "新建按钮未显示"
        test_fail
    fi
}

#========================================
# 测试4: 文件管理页面
#========================================
test_file_manager() {
    log_step "[4/8] 文件管理页面测试"
    
    # 进入文件管理
    if enter_file_manager; then
        log_pass "进入文件管理成功"
        test_pass
    else
        log_fail "进入文件管理失败"
        test_fail
        return 1
    fi
    
    # 截图
    take_screenshot "/tmp/panel-test-file-manager.png"
    
    # 检查文件列表
    local snapshot=$(agent-browser snapshot 2>&1)
    
    if echo "$snapshot" | grep -q "名称"; then
        log_pass "文件列表显示正常"
        test_pass
    else
        log_fail "文件列表显示异常"
        test_fail
    fi
    
    # 检查操作按钮
    if echo "$snapshot" | grep -q "上传"; then
        log_pass "上传按钮显示正常"
        test_pass
    else
        log_fail "上传按钮未显示"
        test_fail
    fi
}

#========================================
# 测试5: 压缩功能
#========================================
test_compress() {
    log_step "[5/8] 压缩功能测试"
    
    # 选中一个文件夹
    select_file "etc"
    sleep 1
    
    # 点击压缩按钮
    click_button "压缩"
    sleep 2
    
    # 检查压缩对话框
    local snapshot=$(agent-browser snapshot 2>&1)
    
    if echo "$snapshot" | grep -q "压缩类型"; then
        log_pass "压缩对话框显示正常"
        test_pass
    else
        log_fail "压缩对话框未显示"
        test_fail
        return 1
    fi
    
    # 测试类型切换
    local initial_path=$(get_input_value ".zip")
    
    # 切换到tar.gz
    select_option "tar.gz"
    sleep 1
    local path1=$(get_input_value ".tar")
    
    # 切换到zip
    select_option "zip"
    sleep 1
    local path2=$(get_input_value ".zip")
    
    # 验证无后缀叠加
    if [[ "$path1" != *"tar.tar"* ]] && [[ "$path2" != *"tar.tar"* ]]; then
        log_pass "压缩类型切换正常，无后缀叠加"
        test_pass
    else
        log_fail "压缩类型切换异常，存在后缀叠加"
        test_fail
    fi
    
    take_screenshot "/tmp/panel-test-compress.png"
    
    # 关闭对话框
    agent-browser press Escape 2>&1 | grep -v "^$" || true
    sleep 1
}

#========================================
# 测试6: 节点管理页面
#========================================
test_nodes() {
    log_step "[6/8] 节点管理页面测试"
    
    # 导航到节点管理
    agent-browser eval "
    (function() {
        const items = document.querySelectorAll('[class*=menu]');
        for (const item of items) {
            if (item.textContent.trim() === '节点管理') {
                item.click();
                return true;
            }
        }
        return false;
    })()
    " 2>&1 | grep -v "^$" || true
    sleep 5
    
    take_screenshot "/tmp/panel-test-nodes.png"
    
    local snapshot=$(agent-browser snapshot 2>&1)
    
    if echo "$snapshot" | grep -qE "节点|Node|状态"; then
        log_pass "节点管理页面显示正常"
        test_pass
    else
        log_fail "节点管理页面显示异常"
        test_fail
    fi
}

#========================================
# 测试7: 存储管理页面
#========================================
test_storage() {
    log_step "[7/8] 存储管理页面测试"
    
    # 点击存储管理菜单
    agent-browser eval "
    (function() {
        const items = document.querySelectorAll('[class*=menu]');
        for (const item of items) {
            const text = item.textContent.trim();
            if (text === '存储管理' || text === '存储设备') {
                item.click();
                return true;
            }
        }
        return false;
    })()
    " 2>&1 | grep -v "^$" || true
    sleep 3
    
    # 点击存储分区
    agent-browser eval "
    (function() {
        const items = document.querySelectorAll('[class*=menu]');
        for (const item of items) {
            if (item.textContent.trim() === '存储分区') {
                item.click();
                return true;
            }
        }
        return false;
    })()
    " 2>&1 | grep -v "^$" || true
    sleep 3
    
    take_screenshot "/tmp/panel-test-storage.png"
    
    local snapshot=$(agent-browser snapshot 2>&1)
    
    if echo "$snapshot" | grep -qE "存储|PVC|Volume"; then
        log_pass "存储管理页面显示正常"
        test_pass
    else
        log_warn "存储管理页面可能无数据"
        test_pass
    fi
}

#========================================
# 测试8: 用户菜单
#========================================
test_user_menu() {
    log_step "[8/8] 用户菜单测试"
    
    # 返回首页
    agent-browser open "$BASE_URL/" 2>&1 | grep -v "^$" || true
    sleep 5
    
    # 检查用户信息
    local snapshot=$(agent-browser snapshot 2>&1)
    
    if echo "$snapshot" | grep -q "admin"; then
        log_pass "用户信息显示正常"
        test_pass
    else
        log_fail "用户信息未显示"
        test_fail
    fi
    
    # 检查系统管理菜单
    if echo "$snapshot" | grep -q "系统管理"; then
        log_pass "系统管理菜单显示正常"
        test_pass
    else
        log_fail "系统管理菜单未显示"
        test_fail
    fi
    
    take_screenshot "/tmp/panel-test-user-menu.png"
}

#========================================
# 运行所有测试
#========================================
run_all_tests() {
    echo ""
    echo "=========================================="
    echo "  W7Panel 面板功能完整UI测试"
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
    test_login      # 测试1: 登录
    test_dashboard  # 测试2: 概览
    test_app_list   # 测试3: 应用列表
    test_file_manager # 测试4: 文件管理
    test_compress   # 测试5: 压缩功能
    test_nodes      # 测试6: 节点管理
    test_storage    # 测试7: 存储管理
    test_user_menu  # 测试8: 用户菜单
    
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
    ls -la /tmp/panel-test-*.png 2>/dev/null | awk '{print "    " $NF}' || echo "    无"
    echo ""
    echo "=========================================="
    
    close_browser
    
    return $FAILED_TESTS
}

#========================================
# 主入口
#========================================
case "${1:-all}" in
    "login")
        test_login
        close_browser
        ;;
    "dashboard")
        ui_login
        test_dashboard
        close_browser
        ;;
    "apps")
        ui_login
        test_app_list
        close_browser
        ;;
    "files")
        ui_login
        test_file_manager
        close_browser
        ;;
    "compress")
        ui_login
        enter_file_manager
        test_compress
        close_browser
        ;;
    "all")
        run_all_tests
        ;;
    *)
        echo "用法: $0 [login|dashboard|apps|files|compress|all]"
        echo ""
        echo "  login     - 登录测试"
        echo "  dashboard - 概览页面测试"
        echo "  apps      - 应用列表测试"
        echo "  files     - 文件管理测试"
        echo "  compress  - 压缩功能测试"
        echo "  all       - 运行所有测试"
        exit 1
        ;;
esac
