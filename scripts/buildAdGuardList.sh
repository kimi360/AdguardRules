#!/usr/bin/env bash
set -euo pipefail

# === 全局变量 ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FILTER_DIR="$PROJECT_ROOT/filters"
HEAD_FILE="$FILTER_DIR/00_head.info"
MERGED_FILE=$(mktemp -t ADGUARD_MERGED.XXXXXX)
trap 'rm -f "$MERGED_FILE"' EXIT

# === 函数定义 ===

# 打印错误并退出
error_exit() {
  echo "错误: $1" >&2
  exit "${2:-1}"
}

# 打印使用方法
usage() {
    echo "用法: $0 [输出文件]"
    echo "  输出文件 默认为 adguard.txt"
    exit 0
}

# 构建 AdGuard 列表
build_adguard_list() {
    local output_file="$1"

    [[ -f "$HEAD_FILE" ]] || error_exit "头文件不存在: $HEAD_FILE"

    shopt -o nullglob >/dev/null 2>&1 && OLD_NULLGLOB="on" || OLD_NULLGLOB="off"
    shopt -s nullglob

    TXT_FILES=("$FILTER_DIR"/*.txt)
    {
      sed "1a ! Version: $(date +'%Y%m%d%H%M')" "$HEAD_FILE"
      if (( ${#TXT_FILES[@]} )); then
          cat "${TXT_FILES[@]}" | grep -vE '^!($| )'
      fi
    } > "$MERGED_FILE"

    [[ "$OLD_NULLGLOB" == "off" ]] && shopt -u nullglob

    mv -f "$MERGED_FILE" "$output_file"

    echo "AdGuard 列表生成完成: $output_file"
}

# === 主函数 ===
main() {
    local output_file="${1:-adguard.txt}"  # 在这里处理默认值

    if [[ "$output_file" == "-h" || "$output_file" == "--help" ]]; then
        usage
    fi

    build_adguard_list "$output_file"
}

# === 执行入口 ===
main "$@"