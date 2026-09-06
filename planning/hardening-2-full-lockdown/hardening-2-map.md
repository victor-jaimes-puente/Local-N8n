Here is a phased roadmap to implement device restriction, Docker privilege hardening, and a true zero-inbound architecture.

---

### Phase 1: Immediate Inbound Lockdown (Quick Win) — [COMPLETED]

**Goal:** Stop trusting the entire Meshnet network. Only permit traffic from your specific Mac.

* **Step 1: Identify and Remove Wide-Open Rules**
* Find the existing rules that allow `Anywhere` on the `nordlynx` interface:
```bash
sudo ufw status numbered

```


* Delete the broad rules for ports 22, 80, and 443.


* **Step 2: Add Strict Source IP Rules**
* Bind access exclusively to your Mac's Meshnet IP (`100.84.79.144`):
```bash
sudo ufw allow in on nordlynx from 100.84.79.144 to any port 22 proto tcp
sudo ufw allow in on nordlynx from 100.84.79.144 to any port 80 proto tcp
sudo ufw allow in on nordlynx from 100.84.79.144 to any port 443 proto tcp

```




* **Verification:** Run `sudo ufw status verbose`. Ensure all `nordlynx` rules show `From: 100.84.79.144` instead of `Anywhere`. Attempt an SSH connection from another phone or laptop on the Meshnet to confirm it hangs and gets dropped.

---

### Phase 2: Contain the Docker "Master Key" (Privilege Boundary Hardening) — [COMPLETED]

**Goal:** Break the direct link between unprivileged shell execution and gaining host root access via the Docker daemon socket, while completely decommissioning the legacy sandbox stack.

* **Step 1: Decommission the Code Sandbox & Sysbox Stack**
  * Stopped and permanently removed all sandbox containers (`sandbox-api-1`, `sandbox-runner-1`, `sandbox-tls-init-1`), images, volumes, and networks (`cd sandbox && docker compose down -v --rmi all --remove-orphans`).
  * Stopped, disabled, and removed `/etc/systemd/system/local-n8n-sandbox.service`.
  * Stopped and disabled `sysbox.service` on the host.
  * Executed `sudo systemctl daemon-reload`.

* **Step 2: Revoke Docker Group Membership ("Revoke the Club Card")**
  * Removed user `silver-worker` from the system `docker` group:
  ```bash
  sudo gpasswd -d silver-worker docker
  ```
  * Unprivileged execution of `docker` commands now immediately fails:
  ```bash
  $ docker ps
  permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
  ```
  * Running administrative Docker actions now strictly requires `sudo` with the user password.

* **Step 3: Preserve Systemd Autostart & Service Management**
  * Retained rootful Docker daemon so database volumes (`/var/lib/docker/volumes/`) and stack services remain stable without migration risks.
  * Preserved `Group=docker` inside `/etc/systemd/system/local-n8n*.service` so systemd initiates containers headlessly at boot with proper socket permissions.
  * Configured `/etc/sudoers.d/silver-worker-systemctl` (`silver-worker ALL=(ALL) NOPASSWD: /usr/bin/systemctl`) to allow management of system services without exposing raw Docker socket access.

* **Verification:**
  * Confirmed `docker run --privileged -v /:/host ubuntu:22.04 chroot /host id` is rejected with `permission denied`.
  * Tested `sudo systemctl restart local-n8n.service` and confirmed clean startup under Doppler secret injection.
  * Verified health of Caddy reverse proxy (`200 OK`), n8n UI, and MCP server (`200 OK`).

---

### Phase 3: Transition to True Zero-Inbound (Outbound-Only)

**Goal:** Shut down all incoming listening ports (`22`, `80`, `443`). Make the server strictly reach outward.

* **Step 1: Choose an Outbound Connection Broker**
* Pick an outbound control plane so you can manage the machine without open inbound ports:
* **Tailscale SSH:** The node dials outward to Tailscale's coordination server. Connections require web authentication / MFA, bypassing traditional open port 22 listeners.
* **Reverse SSH Tunnel / AutoSSH:** The server establishes an outbound connection to an external relay you control, forwarding remote shell access securely back through that tunnel.




* **Step 2: Terminate Host Web Ingress (Ports 80 & 443)**
* Move web traffic off the host network entirely. Access internal web UIs (n8n, APIs) via SSH local port forwarding through your secure outbound session:
```bash
ssh -L 8080:127.0.0.1:80 silver-worker

```




* **Step 3: Close All Firewall Ingress**
* Once the outbound connection is running and verified, delete the UFW allow rules entirely:
```bash
sudo ufw delete allow in on nordlynx from 100.84.79.144 to any port 22 proto tcp
sudo ufw delete allow in on nordlynx from 100.84.79.144 to any port 80 proto tcp
sudo ufw delete allow in on nordlynx from 100.84.79.144 to any port 443 proto tcp

```


* Set UFW to drop 100% of all incoming packets on all interfaces:
```bash
sudo ufw default deny incoming

```




* **Verification:** Run `sudo ss -tulpn`. The server should have zero public or VPN interfaces in `LISTEN` state for external services. Scanning the machine from your Mac will show all ports as filtered or closed.

---

### Rollout Summary

| Phase | Action | Outcome | Risk Level |
| --- | --- | --- | --- |
| **Phase 1** | UFW source IP lock | Compromised Meshnet peers are completely blocked | **Completed** |
| **Phase 2** | Socket revocation & Sandbox decommissioning | Unprivileged shell cannot access Docker socket or escape to host root | **Completed** |
| **Phase 3** | Zero-inbound tunnel | All listening doors closed; server only talks outward | **High** (Requires outbound broker setup before closing port 22) |