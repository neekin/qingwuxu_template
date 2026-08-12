#!/bin/bash
# kill_port.sh - 关闭占用指定端口的进程

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助
show_help() {
    echo -e "${BLUE}用法:${NC}"
    echo -e "  $0 <端口号> [端口号2] [端口号3] ..."
    echo -e "  $0 --all          关闭所有常见开发端口"
    echo -e "  $0 --list         列出常用端口占用情况"
    echo -e "  $0 --help         显示此帮助信息"
    echo ""
    echo -e "${BLUE}示例:${NC}"
    echo -e "  $0 3000           关闭占用 3000 端口的进程"
    echo -e "  $0 3000 3100      关闭占用 3000 和 3100 端口的进程"
    echo -e "  $0 --all          关闭所有常见开发端口"
}

# 常见开发端口列表
COMMON_PORTS=(3000 3100 4000 5000 5173 5174 8000 8080 8888 9292 3030 4200 6379 5432 27017)

# 关闭指定端口的进程
kill_port() {
    local port=$1
    
    # 查找占用端口的进程 PID
    local pid=$(lsof -ti :$port 2>/dev/null)
    
    if [ -z "$pid" ]; then
        echo -e "${YELLOW}⚠️  端口 $port 没有被占用${NC}"
        return 0
    fi
    
    # 获取进程信息
    local process_info=$(ps -p $pid -o comm= 2>/dev/null)
    
    echo -e "${BLUE}🔍 端口 $port 被占用:${NC}"
    echo -e "   PID: $pid"
    echo -e "   进程: $process_info"
    
    # 尝试优雅关闭
    echo -e "${YELLOW}   正在关闭...${NC}"
    kill $pid 2>/dev/null
    
    # 等待进程结束
    sleep 1
    
    # 检查进程是否还在
    if ps -p $pid > /dev/null 2>&1; then
        echo -e "${YELLOW}   进程未响应，强制关闭...${NC}"
        kill -9 $pid 2>/dev/null
        sleep 1
    fi
    
    # 再次检查
    if ps -p $pid > /dev/null 2>&1; then
        echo -e "${RED}❌ 无法关闭端口 $port 的进程 (PID: $pid)${NC}"
        return 1
    else
        echo -e "${GREEN}✅ 端口 $port 已释放${NC}"
        return 0
    fi
}

# 列出常用端口占用情况
list_ports() {
    echo -e "${BLUE}📊 常用端口占用情况:${NC}"
    echo "----------------------------------------"
    
    for port in "${COMMON_PORTS[@]}"; do
        local pid=$(lsof -ti :$port 2>/dev/null)
        if [ -n "$pid" ]; then
            local process_info=$(ps -p $pid -o comm= 2>/dev/null)
            printf "${RED}%-6s${NC} 被占用  PID: %-8s 进程: %s\n" "$port" "$pid" "$process_info"
        else
            printf "${GREEN}%-6s${NC} 空闲\n" "$port"
        fi
    done
    
    echo "----------------------------------------"
}

# 关闭所有常见开发端口
kill_all_common() {
    echo -e "${BLUE}🚀 关闭所有常见开发端口...${NC}"
    echo ""
    
    local killed=0
    
    for port in "${COMMON_PORTS[@]}"; do
        local pid=$(lsof -ti :$port 2>/dev/null)
        if [ -n "$pid" ]; then
            kill_port $port
            ((killed++))
        fi
    done
    
    if [ $killed -eq 0 ]; then
        echo -e "${GREEN}✅ 没有常见端口被占用${NC}"
    else
        echo ""
        echo -e "${GREEN}✅ 已处理 $killed 个端口${NC}"
    fi
}

# 主函数
main() {
    # 检查参数
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    # 处理特殊参数
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --list|-l)
            list_ports
            exit 0
            ;;
        --all|-a)
            kill_all_common
            exit 0
            ;;
    esac
    
    # 处理端口参数
    echo -e "${BLUE}🔧 端口清理工具${NC}"
    echo ""
    
    local success=0
    local failed=0
    
    for port in "$@"; do
        # 验证端口号是否为数字
        if ! [[ "$port" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}❌ 无效的端口号: $port${NC}"
            ((failed++))
            continue
        fi
        
        # 验证端口范围
        if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
            echo -e "${RED}❌ 端口号超出范围 (1-65535): $port${NC}"
            ((failed++))
            continue
        fi
        
        if kill_port "$port"; then
            ((success++))
        else
            ((failed++))
        fi
        echo ""
    done
    
    # 显示总结
    if [ $success -gt 0 ] || [ $failed -gt 0 ]; then
        echo "----------------------------------------"
        echo -e "${GREEN}成功: $success${NC}"
        if [ $failed -gt 0 ]; then
            echo -e "${RED}失败: $failed${NC}"
        fi
    fi
}

# 执行主函数
main "$@"