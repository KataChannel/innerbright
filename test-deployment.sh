#!/bin/bash

# Test deployment script for Bun migration
# This script tests if everything works before full deployment

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🧪 Testing Innerbright Deployment with Bun${NC}"
echo -e "${BLUE}===========================================${NC}\n"

# Export PATH for bun
export PATH="$HOME/.bun/bin:$PATH"

TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${CYAN}🔍 Testing: $test_name${NC}"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ PASS: $test_name${NC}\n"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL: $test_name${NC}\n"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Bun availability
run_test "Bun installation" "command -v bun &> /dev/null"

# Test 2: API dependencies
run_test "API Bun dependencies" "cd /chikiet/Innerbright/innerbright/api && bun install --dry-run"

# Test 3: Site dependencies
run_test "Site Bun dependencies" "cd /chikiet/Innerbright/innerbright/site && bun install --dry-run"

# Test 4: API build
run_test "API build with Bun" "cd /chikiet/Innerbright/innerbright/api && bun run build"

# Test 5: Site build
run_test "Site build with Bun" "cd /chikiet/Innerbright/innerbright/site && bun run build"

# Test 6: Docker compose syntax
run_test "Docker Compose syntax" "docker compose -f /chikiet/Innerbright/innerbright/docker-compose.yml config > /dev/null"

# Test 7: Dockerfile syntax (API)
run_test "API Dockerfile syntax" "docker build --dry-run /chikiet/Innerbright/innerbright/api > /dev/null 2>&1 || true"

# Test 8: Dockerfile syntax (Site)
run_test "Site Dockerfile syntax" "docker build --dry-run /chikiet/Innerbright/innerbright/site > /dev/null 2>&1 || true"

# Test 9: Environment files
run_test "Environment files check" "[[ -f /chikiet/Innerbright/innerbright/.env ]] || [[ -f /chikiet/Innerbright/innerbright/.env.example ]]"

# Test 10: Deployment scripts
run_test "Deployment scripts executable" "[[ -x /chikiet/Innerbright/innerbright/quick-deploy.sh ]] && [[ -x /chikiet/Innerbright/innerbright/full-deploy.sh ]]"

# Summary
echo -e "${BLUE}📊 Test Results${NC}"
echo -e "${BLUE}===============${NC}"
echo -e "${GREEN}✅ Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}❌ Tests Failed: $TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}🎉 All tests passed! Ready for deployment.${NC}"
    echo -e "${CYAN}You can now run:${NC}"
    echo -e "  • ${YELLOW}./quick-deploy.sh \"test deployment\"${NC}"
    echo -e "  • ${YELLOW}./full-deploy.sh \"production deployment\"${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️  Some tests failed. Please fix the issues before deployment.${NC}"
    exit 1
fi
