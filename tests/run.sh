#!/bin/bash
#========================================
# 测试用例统一运行器
#========================================
#
# ## 功能
# - 自动发现并运行 tests/test-cases/ 下的所有测试
# - 支持 .sh 脚本
# - 统计测试结果
#
# ## 使用方式
# bash tests/run.sh              # 运行所有测试
# bash tests/run.sh api          # 只运行api目录测试
# bash tests/run.sh ui           # 只运行ui目录测试
# bash tests/run.sh login        # 只运行login测试
#
# ## 环境变量
# BASE_URL=http://test.com TOKEN=xxx bash tests/run.sh
# DEBUG=1 bash tests/run.sh      # 调试模式，显示输出
#
#========================================

# 配置
TEST_DIR="$(cd "$(dirname "$0")/test-cases" && pwd)"
FILTER="${1:-*}"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 统计
TOTAL=0
PASS=0
FAIL=0

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }

echo "========================================"
echo "测试用例运行器"
echo "========================================"
echo ""
log_info "测试目录: $TEST_DIR"
log_info "过滤器: $FILTER"
echo ""

# 查找测试文件
TEST_FILES=$(find "$TEST_DIR" -name "*.sh" -type f 2>/dev/null | grep -E "/${FILTER}" || true)

if [ -z "$TEST_FILES" ]; then
    log_info "没有找到匹配的测试文件: ${FILTER}"
    exit 0
fi

# 运行每个测试
while IFS= read -r test_file; do
    TOTAL=$((TOTAL + 1))
    test_name=$(basename "$test_file" .sh)
    
    echo "----------------------------------------"
    log_info "运行: $test_name"
    echo "文件: $test_file"
    
    if [ "$DEBUG" = "1" ]; then
        bash "$test_file" && PASS=$((PASS + 1)) && log_pass "$test_name" || { FAIL=$((FAIL + 1)); log_fail "$test_name"; }
    else
        if bash "$test_file" > /dev/null 2>&1; then
            PASS=$((PASS + 1))
            log_pass "$test_name"
        else
            FAIL=$((FAIL + 1))
            log_fail "$test_name"
        fi
    fi
    echo ""
done <<< "$TEST_FILES"

# 汇总
echo "========================================"
echo "测试结果汇总"
echo "========================================"
echo "总计: $TOTAL"
echo -e "${GREEN}通过: $PASS${NC}"
echo -e "${RED}失败: $FAIL${NC}"
echo ""

if [ $FAIL -gt 0 ]; then
    exit 1
else
    exit 0
fi
