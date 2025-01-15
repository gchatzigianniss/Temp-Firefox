# Temp-Firefox

![Temp-Firefox Banner](https://raw.githubusercontent.com/gchatzigianniss/Temp-Firefox/refs/heads/main/banner.png)

Run an **Temp Firefox** in a Docker container (optionally) pre-installed with **uBlock Origin**.

---

## How to Use

1. **Run the script directly from GitHub**:
   ```bash
   bash <(wget -qO- https://raw.githubusercontent.com/gchatzigianniss/Temp-Firefox/refs/heads/main/main.sh)
   ```

2. Follow the prompts:
   - Choose whether to include **uBlock Origin** or run a plain Firefox.

---

This will:
- Build a temporary Docker image.
- Launch Firefox with or without the chosen extension(s).
- Automatically clean up everything after you close Firefox.

> **Note**: Ensure you have **Docker** and an **X server** (for GUI) installed. :)

--- 

### Requirements

- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)

---
