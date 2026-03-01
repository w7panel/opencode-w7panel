#!/bin/bash
# W7Panel 压缩功能 UI 测试
# 测试切换压缩类型时后缀是否正确替换

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 引入测试库
source "$SCRIPT_DIR/test-lib.sh"

#========================================
# 测试1: 后端API验证
#========================================
test_api() {
    log_step "测试1: 后端API验证"
    
    # 检查服务
    if ! check_service; then
        log_fail "服务未运行"
        return 1
    fi
    log_pass "服务运行正常"
    
    # 检查验证码配置
    if ! check_captcha_disabled; then
        log_fail "验证码未禁用，请设置 CAPTCHA_ENABLED=false"
        return 1
    fi
    log_pass "验证码已禁用"
    
    # API登录
    TOKEN=$(api_login)
    if [ -z "$TOKEN" ]; then
        log_fail "API登录失败"
        return 1
    fi
    log_pass "API登录成功"
    
    return 0
}

#========================================
# 测试2: UI登录
#========================================
test_ui_login() {
    log_step "测试2: UI登录"
    ui_login && return 0 || return 1
}

#========================================
# 测试3: 压缩功能完整UI测试
#========================================
test_compress_ui() {
    log_step "测试3: 压缩功能完整UI测试"
    
    # 登录后台
    if ! ui_login; then
        return 1
    fi
    
    # 进入文件管理
    if ! enter_file_manager; then
        return 1
    fi
    
    # 选中一个文件夹
    log_step "选中 etc 文件夹"
    select_file "etc"
    
    # 点击压缩按钮
    log_step "点击压缩按钮"
    click_button "压缩"
    sleep 2
    
    # 测试压缩类型切换
    log_step "测试压缩类型切换"
    
    local initial_path=$(get_input_value ".zip")
    log_info "初始路径: $initial_path"
    
    # 切换到 tar.gz
    select_option "tar.gz"
    local path1=$(get_input_value ".tar")
    log_info "zip → tar.gz: $path1"
    
    # 切换到 tar.xz
    select_option "tar.xz"
    local path2=$(get_input_value ".tar")
    log_info "tar.gz → tar.xz: $path2"
    
    # 切换到 tar
    select_option "tar（无压缩）"
    local path3=$(get_input_value ".tar")
    log_info "tar.xz → tar: $path3"
    
    # 切换回 zip
    select_option "zip"
    local path4=$(get_input_value ".zip")
    log_info "tar → zip: $path4"
    
    # 切换到 tar.gz
    select_option "tar.gz"
    local path5=$(get_input_value ".tar")
    log_info "zip → tar.gz: $path5"
    
    # 验证结果
    local failed=0
    if [[ "$path1" == *"tar.tar"* ]]; then
        log_fail "tar.gz 路径有后缀叠加: $path1"
        ((failed++))
    fi
    if [[ "$path2" == *"tar.tar"* ]]; then
        log_fail "tar.xz 路径有后缀叠加: $path2"
        ((failed++))
    fi
    if [[ "$path3" == *"tar.tar"* ]]; then
        log_fail "tar 路径有后缀叠加: $path3"
        ((failed++))
    fi
    if [[ "$path4" == *"tar.tar"* ]]; then
        log_fail "zip 路径有后缀叠加: $path4"
        ((failed++))
    fi
    if [[ "$path5" == *"tar.tar"* ]]; then
        log_fail "tar.gz 路径有后缀叠加: $path5"
        ((failed++))
    fi
    
    if [ $failed -eq 0 ]; then
        log_pass "压缩类型切换测试通过，无后缀叠加"
        take_screenshot "/tmp/compress-test-pass.png"
        return 0
    else
        log_fail "压缩类型切换测试失败"
        take_screenshot "/tmp/compress-test-fail.png"
        return 1
    fi
}

#========================================
# 测试4: 编译验证
#========================================
test_build() {
    log_step "测试4: 编译验证"
    
    local files_js=$(ls -t /home/wwwroot/w7panel-dev/w7panel/kodata/assets/files.*.js 2>/dev/null | head -1)
    
    if [ -z "$files_js" ]; then
        log_fail "找不到编译后的files.js"
        return 1
    fi
    
    if grep -o 'onCompressTypeChange[^}]*}' "$files_js" | grep -q 'zip|tar'; then
        log_pass "编译文件包含新正则: $(basename $files_js)"
        return 0
    else
        log_fail "编译文件未包含新正则"
        return 1
    fi
}

#========================================
# 运行所有测试
#========================================
run_all_tests() {
    echo ""
    echo "=========================================="
    echo "  W7Panel 压缩功能测试"
    echo "=========================================="
    echo ""
    
    local passed=0
    local failed=0
    
    if test_api; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_ui_login; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_compress_ui; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_build; then
        ((passed++))
    else
        ((failed++))
    fi
    
    echo ""
    echo "=========================================="
    echo "  测试结果: 通过 $passed / 失败 $failed"
    echo "=========================================="
    
    close_browser
    
    return $failed
}

#========================================
# 主入口
#========================================
case "${1:-all}" in
    "api")
        test_api
        ;;
    "login")
        test_ui_login
        close_browser
        ;;
    "compress")
        test_compress_ui
        close_browser
        ;;
    "build")
        test_build
        ;;
    "all")
        run_all_tests
        ;;
    *)
        echo "用法: $0 [api|login|compress|build|all]"
        echo ""
        echo "  api      - 后端API测试"
        echo "  login    - UI登录测试"
        echo "  compress - 压缩功能完整UI测试"
        echo "  build    - 编译验证"
        echo "  all      - 运行所有测试"
        exit 1
        ;;
esac
