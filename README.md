### Minecraft Auto-Pause Script

The **Minecraft Auto-Pause Script** is a Bash script designed to manage the state of your Minecraft server based on player activity. This script monitors the number of connected players and automatically pauses the server if no players are active for a specified timeout duration. It also allows for resuming the server when players reconnect.

#### Key Features:

- **Automatic Pausing**: The script pauses the Minecraft server process when there are no players connected for a defined period (configured via `INACTIVITY_TIMEOUT`).

- **Auto-Resume**: Once players reconnect, the script automatically resumes the server.

- **RCON Integration**: It utilizes the `mcrcon` tool to check player connections, ensuring accurate monitoring of active sessions.

- **Configurable Parameters**: Users can easily adjust settings like timeout duration, check interval, RCON port, password, and the path to the server JAR file.

- **Graceful Handling**: The script creates a temporary `.paused` file to track the server's paused state, allowing for safe resumption.

#### Usage:

1. **Configuration**: Modify the script variables at the beginning of the script to set your desired timeout, RCON settings, and server JAR name.

2. **Execution**: Run the script in a terminal. It will continuously monitor the server state and manage the pausing and resuming as needed.

This script is particularly useful for users running multiple Java applications, as it specifically targets the Minecraft server process, allowing other Java applications to run uninterrupted.

#### Requirements:
```
sudo apt install knockd  
```
[mcrcon](https://github.com/Tiiffi/mcrcon)  
```
sudo apt install screen
```

#### Installation:
1. Install **knockd** and **mcrcon**.
2. Copy the contents of **knockd.conf** into **/etc/knockd.conf** and adjust the path for **knockd_resume.sh**.
3. Copy **knockd_resume.sh** and **start_and_monitor.sh** into a directory that is accessible to all users and make them executable. Adjust the path and settings accordingly.
4. Apply the settings using: 
   ```
   sudo systemctl restart knockd  
   ```
5. Execute the **knockd_resume.sh** script, preferably in a **screen** session.

Inspired by [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server).
