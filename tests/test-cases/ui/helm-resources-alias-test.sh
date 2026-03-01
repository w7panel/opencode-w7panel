#!/bin/bash
# W7Panel Helm 资源概览别名测试
# 测试资源页面的 Deployment/DaemonSet/StatefulSet 别名显示

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
source "$BASE_DIR/tests/test-lib.sh"

echo "=========================================="
echo "  Helm 资源概览别名测试"
echo "=========================================="

check_service || exit 1

# 测试1: UI登录
ui_login || exit 1

# 测试2: 进入应用列表
test_app_list() {
    log_step "进入应用列表"
    
    agent-browser open "$BASE_URL/app/apps" 2>&1 | grep -v "^$" || true
    sleep 5
    
    local snapshot=$(agent-browser snapshot -i 2>&1)
    if echo "$snapshot" | grep -qE "应用列表|应用"; then
        log_pass "应用列表加载成功"
        return 0
    else
        log_fail "应用列表加载失败"
        return 1
    fi
}

test_app_list

# 测试3: 进入 Helm 应用详情
test_helm_detail() {
    log_step "进入 Helm 应用详情 (w7panel-offline)"
    
    # 直接导航到 Helm 应用详情页
    agent-browser open "$BASE_URL/app/appgroup/w7panel-offline/helm/detail" 2>&1 | grep -v "^$" || true
    sleep 5
    
    # 检查页面是否加载
    local snapshot=$(agent-browser snapshot -i 2>&1)
    
    # 检查是否有 Resources tab 或资源列表
    if echo "$snapshot" | grep -qE "Resources|资源"; then
        log_pass "Helm 详情页加载成功"
        return 0
    else
        log_warn "Helm 详情页可能未完全加载"
        agent-browser screenshot /tmp/helm-detail.png 2>&1 | grep -v "^$" || true
        return 1
    fi
}

test_helm_detail

# 测试4: 验证资源别名显示
test_resource_alias() {
    log_step "验证资源别名显示"
    
    # 等待资源加载
    sleep 3
    
    # 获取页面内容
    local page_text=$(agent-browser eval "document.body.innerText" 2>&1)
    
    # 验证别名显示
    local passed=0
    local failed=0
    
    # 检查 Deployment 别名
    if echo "$page_text" | grep -q "无状态应用"; then
        log_pass "Deployment 别名: [无状态应用]"
        ((passed++))
    else
        log_fail "Deployment 别名未显示"
        ((failed++))
    fi
    
    # 检查 DaemonSet 别名
    if echo "$page_text" | grep -q "守护进程应用"; then
        log_pass "DaemonSet 别名: [守护进程应用]"
        ((passed++))
    else
        log_fail "DaemonSet 别名未显示"
        ((failed++))
    fi
    
    # 检查 StatefulSet 别名
    if echo "$page_text" | grep -q "有状态应用"; then
        log_pass "StatefulSet 别名: [有状态应用]"
        ((passed++))
    else
        log_fail "StatefulSet 别名未显示"
        ((failed++))
    fi
    
    # 截图保存
    agent-browser screenshot /tmp/helm-resources-alias.png 2>&1 | grep -v "^$" || true
    
    echo ""
    echo "别名验证结果: 通过 $passed / 失败 $failed"
    
    if [ $failed -gt 0 ]; then
        return 1
    fi
    return 0
}

test_resource_alias

# 测试5: 验证名称可点击性
test_name_clickable() {
    log_step "验证 Deployment 名称可点击"
    
    # 检查是否有蓝色可点击的名称
    local result=$(agent-browser eval "
    (function() {
        // 查找包含 '无状态应用' 的元素
        const text = document.body.innerText;
        if (!text.includes('无状态应用')) {
            return JSON.stringify({found: false, reason: 'no alias text'});
        }
        
        // 查找资源行
        const rows = document.querySelectorAll('tbody tr, .arco-table-tr');
        for (const row of rows) {
            const rowText = row.innerText;
            if (rowText.includes('无状态应用') || rowText.includes('[无状态应用]')) {
                // 检查是否有蓝色的可点击元素
                const blueLinks = row.querySelectorAll('.c-blue, [class*=\"blue\"], a, [style*=\"color\"]');
                return JSON.stringify({
                    found: true,
                    hasClickable: blueLinks.length > 0,
                    rowText: rowText.substring(0, 100)
                });
            }
        }
        return JSON.stringify({found: false, reason: 'no matching row'});
    })()
    " 2>&1)
    
    echo "点击性检查: $result"
    
    if echo "$result" | grep -q '"found":true' && echo "$result" | grep -q '"hasClickable":true'; then
        log_pass "Deployment 名称可点击"
        return 0
    else
        log_warn "Deployment 名称点击性检查失败"
        return 1
    fi
}

test_name_clickable

# 关闭浏览器
agent-browser close 2>&1 | grep -v "^$" || true

echo ""
echo "=========================================="
echo "  测试完成"
echo "=========================================="
echo "截图保存: /tmp/helm-resources-alias.png"
echo ""
