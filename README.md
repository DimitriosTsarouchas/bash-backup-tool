# 🔄 bash-backup-tool

[![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/DimitriosTsarouchas/bash-backup-tool/graphs/commit-activity)

A lightweight, zero-dependency Bash utility for creating and managing file backups with timestamps.

## ✨ Features

- 🔖 Automatic timestamped versioning
- 🔍 Easy backup listing and management
- ⚡️ Zero external dependencies
- 🛡️ Built-in error handling and validation
- 💾 Restore previous versions easily
- 🧹 Clean up old backups while keeping N most recent versions

## 🚀 Installation

### Option 1: Direct Download

```bash
curl -o ~/.backup-tools.sh https://raw.githubusercontent.com/DimitriosTsarouchas/bash-backup-tool/main/backup-tools.sh
chmod +x backup-tools.sh
./backup-tools.sh -h
```

### Option 2: Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/DimitriosTsarouchas/bash-backup-tool.git
```

2. Add to your shell configuration:
```bash
chmod +x backup-tools.sh
./backup-tools.sh -h
```

## 📖 Usage

### Create a Backup

```bash
# Basic usage
./backup-tools.sh backup config.json
# Output: [OK   ] 2024-11-22 14:30:00 - Created backup: config.json.backup-20241122_143000

# The function will validate the file exists
./backup-tools.sh backup nonexistent.txt
# Output: [ERROR] 2024-11-22 14:30:00 - File 'nonexistent.txt' not found
```

### List Backups

```bash
./backup-tools.sh list_backups config.json
# Shows all backups of config.json with timestamps and sizes
```

### Restore a Backup

```bash
./backup-tools.sh restore_backup config.json.backup-20241122_143000
# Prompts for confirmation if original file exists
```

### Clean Old Backups

```bash
# Keep the 5 most recent backups and remove older ones
./backup-tools.sh clean_backups config.json 5
```

## 🌟 Advanced Features

- Colored output for better readability
- Timestamp-based versioning
- File size information
- Interactive prompts for potentially destructive operations
- Comprehensive error handling
- Logging with timestamps

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⭐️ Show your support

Give a ⭐️ if this project helped you!

## 🤝 Author

**Dimitrios Tsarouchas**
* GitHub: [@DimitriosTsarouchas](https://github.com/DimitriosTsarouchas)
