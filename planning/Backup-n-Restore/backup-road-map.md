Here is a phased implementation roadmap to deploy both backup strategies, starting with the immediate, zero-trust script and evolving into a space-efficient snapshot system.

### Phase 1: Foundational Zero-Trust Pull Backups

This phase establishes immediate data safety using native tools without modifying the server. Running this locally on the M4 Pro MacBook ensures fast local compression handling when the archives hit the disk, and the NordVPN Meshnet routing allows backups to execute securely whether the laptop is docked at the Canyon Lake house or on a remote network.

* **Step 1: SSH and Directory Provisioning**
* Verify seamless SSH authentication from the Mac to `silver-worker` over the Meshnet tunnel.
* Create a local destination directory on the Mac's hard drive to receive the incoming data.


* **Step 2: Scripting the Remote Dump**
* Draft a bash script on the Mac to handle remote execution.
* The script will connect to `silver-worker`, invoke the live database dump, package the configuration files into an archive, and securely pull the data across via `rsync`.


* **Step 3: macOS Native Scheduling**
* Avoid `cron`, as it skips scheduled tasks if the machine is asleep.
* Create a `.plist` file in `~/Library/LaunchAgents` using macOS `launchd`. By utilizing the `StartCalendarInterval` key, the daemon ensures the backup script runs at the exact scheduled time, or immediately upon waking if the laptop was asleep during the window.



---

### Phase 2: Advancing to Restic for Deduplicated Snapshots

Once the foundational pull strategy is stable, you can migrate to Restic (or BorgBackup) for highly space-efficient, versioned rollbacks. This phase shifts the architecture from a Mac "pull" to a server "push" via SFTP.

* **Step 1: CLI Environment Initialization**
* Install the Restic CLI binary on both `silver-worker` and the Mac workstation.
* Enable the Remote Login (SSH/SFTP) service on the Mac via System Settings to allow it to act as a secure destination server.


* **Step 2: Repository Creation & Meshnet Routing**
* Initialize an encrypted Restic repository in a dedicated directory on the Mac.
* Configure `silver-worker` to authenticate to the Mac's Meshnet IP using a restricted SSH key.


* **Step 3: Automated SFTP Push & Pruning**
* Create a scheduled job on `silver-worker` to execute the snapshot command, pushing the database dumps and configuration state to the Mac's SFTP backend.
* Implement an automated retention policy (e.g., keeping 14 daily and 4 weekly snapshots) to prune redundant data and keep storage costs down automatically.



Which specific configuration files and directories on `silver-worker` do you want to target first for the Phase 1 `rsync` script?