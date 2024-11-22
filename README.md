# 🔄 bash-backup-tool

[![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/YourUsername/bash-backup-tool/graphs/commit-activity)

A lightweight, zero-dependency Bash utility for creating timestamped file backups with simple commands.

## ✨ Features

- 🔖 Automatic timestamped versioning
- 🔍 Easy backup listing and management
- ⚡️ Zero external dependencies
- 🛡️ Built-in error handling and validation
- 💾 Restore previous versions easily

## 🚀 Installation

### Option 1: Direct Download

```bash
curl -o ~/.backup-tools.sh https://raw.githubusercontent.com/YourUsername/bash-backup-tool/main/backup-tools.sh
echo 'source ~/.backup-tools.sh' >> ~/.bashrc
source ~/.bashrc
```

### Option 2: Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/YourUsername/bash-backup-tool.git
```

2. Add to your shell configuration:
```bash
echo 'source /path/to/bash-backup-tool/backup-tools.sh' >> ~/.bashrc
source ~/.bashrc
```

## 📖 Usage

### Create a Backup

```bash
# Basic usage
backup config.json
# Output: Backup created successfully: config.json.backup-20241122_143000

# The function will validate the file exists
backup nonexistent.txt
# Output: Error: File 'nonexistent.txt' not found
```

### List Backups

```bash
list_backups config.json
# Output: Shows all backups of config.json with timestamps
```

### Restore a Backup

```bash
restore_backup config.json.backup-20241122_143000
# Output: Restored config.json.backup-20241122_143000 to config.json
```

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
