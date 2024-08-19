<div align="center">
  <img src="./docs/logo.svg" alt="nva logo" style="max-width: 100%; height: auto;">
</div>

# Node Version Admin (NVA)
![Static Badge](https://img.shields.io/badge/version-1.2.0-brightgreen?style=flat)

NVA (Node Version Admin) is a specialized tool designed with system administrators in mind, offering a streamlined approach to managing Node.js versions in server environments.

## Key Features
- System-wide Node.js version management
- Optimized for Debian-based server environments
- Lightweight and easy to use
- Automatic update and cleanup capabilities
- Cached version lookup for faster operations
- Sysadmin-centric design for server environments
- Dedicated install and uninstall scripts
- Bash completion support for improved usability

## Installation

<div align="center">
  <img src="./docs/install.svg" alt="install nva" style="max-width: 100%; height: auto;">
</div>


Choose one of the following methods:

#### 1. Using curl
```bash
curl -so- https://raw.githubusercontent.com/Watchdog0x/nva/main/install.sh | sudo bash
```

#### 2. Using wget
```bash
wget -qO- https://raw.githubusercontent.com/Watchdog0x/nva/main/install.sh | sudo bash
```

## Usage

### First-time setup
After installation, run:
```bash
sudo nva -i 20.16.0 -s 20.16.0 -l
```

Output:
```
Node.js version 20.16.0 downloaded successfully to /opt/nva/nodejs
Node.js version 20.16.0 extracted successfully
Node.js version 20.16.0 has been set successfully.
Available Node.js versions installed on your system:
* Node.js 20.16.0 (Running)
```

> [!NOTE] 
> Use `-i` to install, `-s` to set the Node.js version, and `-l` to list installed versions.

> [!IMPORTANT]
> The global installation path for npm packages (npm install -g) is /usr/local. Ensure users have necessary permissions or run npm commands with elevated privileges.

### Command syntax
```bash
nva [OPTIONS]
```

Options:
- `-i, --install`: Install a specific Node.js version
- `-l, --list`: List available Node.js versions on your system
- `-s, --set`: Set the active Node.js version
- `-r, --remove`: Remove an installed Node.js version
- `-p, --patch`: Update all installed Node.js versions to the latest
  - Subcommand `clean` removes old versions
- `-v, --version`: Print the version of NVA
- `-h, --help`: Display the help message

## Automatic Updates

Set up a cron job for automatic updates:

1. Open the crontab editor:
   ```bash
   sudo crontab -e
   ```

2. Add a daily update job (runs at midnight):
   ```bash
   0 0 * * * /path/to/nva-script/nva -p >> /var/log/nva-update.log 2>&1
   ```

> [!NOTE] 
> When using `sudo crontab -e`, you can add the `clean` option for automatic cleanup. Use responsibly with appropriate permissions.

## Uninstallation

Choose one of the following methods:

#### 1. Using curl
```bash
curl -so- https://raw.githubusercontent.com/Watchdog0x/nva/main/uninstall.sh | sudo bash
```

#### 2. Using wget
```bash
wget -qO- https://raw.githubusercontent.com/Watchdog0x/nva/main/uninstall.sh | sudo bash
```

#### 3. Local uninstall
```bash
sudo bash /opt/nva/uninstall.sh
```

## About 
NVA stands out as a robust solution for sysadmins who need a reliable, efficient, and fast way to manage Node.js versions across their server infrastructure. By focusing on system-wide management and implementing features like version caching, NVA offers a unique toolset specifically tailored to the needs of server environment maintenance and administration.

### Detailed Feature Breakdown:

1. **System-wide Management**: 
   - Manages Node.js versions at the system level, ensuring consistency across all users.
   - Allows easy switching between different Node.js versions for the entire system.

2. **Debian Optimization**: 
   - Tailored for Debian and its derivatives (e.g., Ubuntu).
   - Integrates smoothly with Debian-based system management practices.

3. **Lightweight Design**:
   - Minimizes system overhead.
   - Ensures quick operations, crucial for server environments.

4. **Automatic Maintenance**:
   - Features automatic updates to keep Node.js versions current.
   - Includes cleanup capabilities to manage disk space efficiently.

5. **Cached Version Lookup**:
   - Implements a caching mechanism for Node.js version information.
   - Provides significantly faster lookup times for available versions.
   - Reduces network dependency for version checks.

6. **Sysadmin-Centric Approach**:
   - Designed with the specific needs of system administrators in mind.
   - Focuses on stability and consistency in server environments.

7. **Easy Deployment**:
   - Includes dedicated install and uninstall scripts.
   - Simplifies the process of setting up and removing NVA.

8. **Enhanced CLI Experience**:
   - Supports bash completion for faster and more accurate command entry.
   - Improves overall usability in command-line interfaces.


## Contributing
We welcome contributions! Please feel free to open issues, submit pull requests, or provide suggestions.

## License
This project is licensed under the MIT License.
