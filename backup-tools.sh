#!/bin/bash

# backup-tools.sh
# A lightweight utility for creating and managing file backups with timestamps

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Version
VERSION="1.0.0"

# Help message
show_help() {
    echo "Backup Tools ${VERSION}"
    echo "A utility for creating and managing file backups with timestamps."
    echo
    echo "Usage:"
    echo "    backup <filename>              Create a backup of the specified file"
    echo "    list_backups <filename>        List all backups of the specified file"
    echo "    restore_backup <backup_file>   Restore a specific backup file"
    echo "    clean_backups <filename>       Remove old backups keeping the latest N versions"
    echo
    echo "Options:"
    echo "    -h, --help      Show this help message"
    echo "    -v, --version   Show version information"
    echo
    echo "Examples:"
    echo "    backup config.json"
    echo "    list_backups config.json"
    echo "    restore_backup config.json.backup-20241122_143000"
    echo "    clean_backups config.json 5"
}

# Version information
show_version() {
    echo "Backup Tools v${VERSION}"
}

# Logger function
log() {
    _level=$1
    shift
    _message=$*
    _timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$_level" in
        "INFO")  printf "%b[INFO ]%b %s - %s\n" "${BLUE}" "${NC}" "${_timestamp}" "${_message}" ;;
        "ERROR") printf "%b[ERROR]%b %s - %s\n" "${RED}" "${NC}" "${_timestamp}" "${_message}" >&2 ;;
        "WARN")  printf "%b[WARN ]%b %s - %s\n" "${YELLOW}" "${NC}" "${_timestamp}" "${_message}" ;;
        "SUCCESS") printf "%b[OK   ]%b %s - %s\n" "${GREEN}" "${NC}" "${_timestamp}" "${_message}" ;;
    esac
}

# Function to create backup
backup() {
    # Show help if no argument is provided
    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        return 1
    fi

    source_file=$1
    
    # Check if file exists
    if [ ! -f "$source_file" ]; then
        log "ERROR" "File '$source_file' not found"
        return 1
    fi

    # Create backup filename with timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_file="${source_file}.backup-${timestamp}"

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
    fi

    base_file=$1
    backup_count=0
    
    log "INFO" "Listing backups for $base_file:"
    echo "----------------------------------------"
    
    for backup in "$base_file".backup-*; do
        if [ -f "$backup" ]; then
            backup_count=$((backup_count + 1))
            size=$(ls -lh "$backup" | awk '{print $5}')
            echo -e "${BLUE}$backup_count.${NC} $(basename "$backup") ${YELLOW}($size)${NC}"
        fi
    done
    
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
    fi

    backup_file=$1
    
    # Check if backup file exists
    if [ ! -f "$backup_file" ]; then
        log "ERROR" "Backup file '$backup_file' not found"
        return 1
    fi
    
    # Extract original filename
    original_file=${backup_file%.backup-*}
    
    # Check if original file exists and prompt for overwrite
    if [ -f "$original_file" ]; then
        printf "%bOriginal file exists. Overwrite? (y/n):%b " "${YELLOW}" "${NC}"
        read -r answer
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
    fi

    base_file=$1
    keep_count=$2
    
    # Validate keep_count is a number
    if ! [[ "$keep_count" =~ ^[0-9]+$ ]]; then
        log "ERROR" "Please provide a valid number for backups to keep"
        return 1
    fi
    
    # Get all backups sorted by date (newest first)
    mapfile -t backup_files < <(ls -1 "$base_file".backup-* 2>/dev/null | sort -r)
    total_backups=${#backup_files[@]}
    
    if [ "$total_backups" -eq 0 ]; then
        log "WARN" "No backups found for $base_file"
        return 1
    fi
    
    if [ "$total_backups" -le "$keep_count" ]; then
        log "INFO" "No backups to clean (have $total_backups, keeping $keep_count)"
        return 0
    fi
    
    delete_count=$((total_backups - keep_count))
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
case "${1:-}" in
    "-h"|"--help")
        show_help
        ;;
    "-v"|"--version")
        show_version
        ;;
    "backup")
        shift
        backup "$@"
        ;;
    "list_backups")
        shift
        list_backups "$@"
        ;;
    "restore_backup")
        shift
        restore_backup "$@"
        ;;
    "clean_backups")
        shift
        clean_backups "$@"
        ;;
    *)
        show_help
        ;;
esac
