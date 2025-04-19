# 🐳 Azure Pipelines Self‑Hosted Runner (Dockerised)

This project builds and runs a self‑hosted Azure Pipelines agent inside a Docker container using Docker Compose.  
It’s ideal for setting up a persistent, restartable DevOps runner that connects to your Azure DevOps organisation and agent pool.

---

## ✅ Requirements

- Docker  
- Docker Compose  
- An Azure DevOps organisation and project  
- A Personal Access Token (PAT) with **Agent Pools (Read & Manage)** scope  

---

## 🚀 Getting Started

### 1. Generate a Personal Access Token (PAT)

1. Go to [Azure DevOps → **User Settings → Personal Access Tokens**](https://dev.azure.com/)  
2. Click **New Token**  
3. Select:  
   - **Scope** → *Agent Pools* → **Read & Manage**  
   - **Organisation** → *your Azure DevOps org*  
   - **Expiration** → *as needed*  
4. Click **Create**, then copy the token as it is only shown once at the end of the PAT setup process, and you’ll need it next.

  [More info on creating PATs](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)

---

### 2. Create an Agent Pool

1. In Azure DevOps, navigate to your organisation or project  
2. Go to **Project Settings → Agent Pools**  
3. Click **Add Pool**  
4. Enter a name such as **Self Hosted Pool**  
5. Save it — you’ll reference this name in the next step
6. Finally, tick the box **Grant access permission to all pipelines** under  **Pipeline permissions**

  [More info on creating Agent pools](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues)

---

### 3. Create the `.env.azure` File

In the root of the repository (next to `docker-compose.yml`), create a file called `.env.azure`. **Do not** commit this file to source control.

```env
# .env.azure
AZP_TOKEN=<your-personal-access-token>
AZP_URL=https://dev.azure.com/<your-org>
AZP_POOL='Self Hosted Pool'
AZP_AGENT_NAME='self-hosted-runner'
AZP_WORK='_work'
TARGETARCH='linux-x64'
TZ='Europe/London'
```

Replace the placeholders with your actual values:

- `<your-personal-access-token>` is the PAT you just created  
- `<your-org>` is your Azure DevOps organisation name  

---

### 4. Build and Start the Runner

From the project root (where `docker-compose.yml` lives):

```bash
docker-compose up -d --build
```

This will:

- Build the Docker image locally  
- Start the container as a self‑hosted agent  
- Register it with your Azure DevOps organisation and agent pool  

---

### 5. Verify the Agent

Once the container is running you can:

View logs:

```bash
docker logs -f azure-pipelines-agent
```

Then check **Azure DevOps → Project Settings → Agent Pools → Self Hosted Pool**.  
You should see the agent listed and available.

---

## 🔁 Restart Policy

The container is set to restart automatically unless explicitly stopped:

```yaml
restart: unless-stopped
```

This ensures the agent restarts on reboot or crash.

---

## 📂 Mounted Volumes

The following volume persists agent job data across restarts:

```yaml
./azure-agent/_work:/azp/_work
```

The host path is determined by the `AZP_WORK` value in `.env.azure`.

---

## 🧼 Tear Down

Stop the container:

```bash
docker-compose down
```

Remove all containers, images, and volumes:

```bash
docker-compose down -v --rmi all
```

---

## 🔒 `.env` File Safety

- Ensure `.env.azure` is listed in `.gitignore`  
- Never commit it to source control  
- Store it securely, as it contains secrets  

---

## 🛠 Customisation

- Change `AZP_AGENT_NAME` in `.env.azure` for a unique runner name  
- Adjust `TZ` for a different time zone  
- Extend the `Dockerfile` to add additional tools or dependencies  

---

## 📦 Docker Compose Version

This setup uses **version: '3.9'** and assumes your Docker Compose installation supports the `build.tags` field.  
If you’re using an older version, update Docker / Compose accordingly.
