#!/bin/bash

# backup-tools.sh
# A lightweight utility for creating and managing file backups with timestamps
# Author: Dimitrios Tsarouchas
# License: MIT
# GitHub: https://github.com/USERNAME/bash-backup-tool

# Set strict error handling
set -euo pipefail
IFS=$'\n\t'

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Version
readonly VERSION="1.0.0"

# Help message
show_help() {
    cat << EOF
Backup Tools ${VERSION}
A utility for creating and managing file backups with timestamps.

Usage:
    backup <filename>              Create a backup of the specified file
    list_backups <filename>        List all backups of the specified file
    restore_backup <backup_file>   Restore a specific backup file
    clean_backups <filename>       Remove old backups keeping the latest N versions

Options:
    -h, --help      Show this help message
    -v, --version   Show version information

Examples:
    backup config.json
    list_backups config.json
    restore_backup config.json.backup-20241122_143000
    clean_backups config.json 5

For more information, visit: https://github.com/USERNAME/bash-backup-tool
EOF
}

# Version information
show_version() {
    echo "Backup Tools v${VERSION}"
}

# Logger function
log() {
    local level=$1
    shift
    local message=$*
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO")  echo -e "${BLUE}[INFO ]${NC} ${timestamp} - $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} ${timestamp} - $message" >&2 ;;
        "WARN")  echo -e "${YELLOW}[WARN ]${NC} ${timestamp} - $message" ;;
        "SUCCESS") echo -e "${GREEN}[OK   ]${NC} ${timestamp} - $message" ;;
    esac
}

# Function to create backup
backup() {
    # Show help if no argument is provided
    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        return 1
    fi

    local source_file=$1
    
    # Check if file exists
    if [ ! -f "$source_file" ]; then
        log "ERROR" "File '$source_file' not found"
        return 1
    }

    # Create backup filename with timestamp
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${source_file}.backup-${timestamp}"

    # Perform the backup
    if cp "$source_file" "$backup_file"; then
        log "SUCCESS" "Created backup: $backup_file"
        log "INFO" "Original: $(ls -lh "$source_file" | awk '{print $5}')"
        log "INFO" "Backup: $(ls -lh "$backup_file" | awk '{print $5}')"
    else
        log "ERROR" "Failed to create backup"
        return 1
    fi
}

# Function to list backups
list_backups() {
    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        return 1
    }

    local base_file=$1
    local backup_count=0
    
    log "INFO" "Listing backups for $base_file:"
    echo "----------------------------------------"
    
    while IFS= read -r backup; do
        ((backup_count++))
        local timestamp
        timestamp=$(echo "$backup" | grep -o "backup-[0-9_]\+" | cut -d'-' -f2)
        local size
        size=$(ls -lh "$backup" | awk '{print $5}')
        echo -e "${BLUE}$backup_count.${NC} $(basename "$backup") ${YELLOW}($size)${NC}"
    done < <(ls -1 "$base_file".backup-* 2>/dev/null | sort -r)
    
    if [ "$backup_count" -eq 0 ]; then
        log "WARN" "No backups found for $base_file"
        return 1
    fi
    
    echo "----------------------------------------"
    log "INFO" "Total backups: $backup_count"
}

# Function to restore backup
restore_backup() {
    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        return 1
    }

    local backup_file=$1
    
    # Check if backup file exists
    if [ ! -f "$backup_file" ]; then
        log "ERROR" "Backup file '$backup_file' not found"
        return 1
    }
    
    # Extract original filename
    local original_file
    original_file=${backup_file%.backup-*}
    
    # Check if original file exists and prompt for overwrite
    if [ -f "$original_file" ]; then
        read -rp "$(echo -e "${YELLOW}Original file exists. Overwrite? (y/n):${NC} ")" answer
        if [ "$answer" != "y" ]; then
            log "WARN" "Restoration cancelled"
            return 1
        fi
    fi
    
    # Perform the restoration
    if cp "$backup_file" "$original_file"; then
        log "SUCCESS" "Restored $backup_file to $original_file"
    else
        log "ERROR" "Failed to restore backup"
        return 1
    fi
}

# Function to clean old backups
clean_backups() {
    if [ $# -lt 2 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        return 1
    }

    local base_file=$1
    local keep_count=$2
    
    # Validate keep_count is a number
    if ! [[ "$keep_count" =~ ^[0-9]+$ ]]; then
        log "ERROR" "Please provide a valid number for backups to keep"
        return 1
    }
    
    local backup_files=()
    while IFS= read -r backup; do
        backup_files+=("$backup")
    done < <(ls -1 "$base_file".backup-* 2>/dev/null | sort -r)
    
    local total_backups=${#backup_files[@]}
    
    if [ "$total_backups" -eq 0 ]; then
        log "WARN" "No backups found for $base_file"
        return 1
    fi
    
    if [ "$total_backups" -le "$keep_count" ]; then
        log "INFO" "No backups to clean (have $total_backups, keeping $keep_count)"
        return 0
    fi
    
    local delete_count=$((total_backups - keep_count))
    log "INFO" "Removing $delete_count old backup(s)..."
    
    for ((i=keep_count; i<total_backups; i++)); do
        if rm "${backup_files[i]}"; then
            log "SUCCESS" "Removed ${backup_files[i]}"
        else
            log "ERROR" "Failed to remove ${backup_files[i]}"
        fi
    done
    
    log "SUCCESS" "Cleanup complete. Kept $keep_count most recent backup(s)"
}

# Main execution
main() {
    # Process command line arguments
    case "${1:-}" in
        "-h"|"--help")
            show_help
            ;;
        "-v"|"--version")
            show_version
            ;;
        *)
            # Default behavior is to show help
            show_help
            ;;
    esac
}

# If script is being executed directly (not sourced), run main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
