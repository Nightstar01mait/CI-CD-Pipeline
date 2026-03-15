# CI/CD Pipeline Architecture and Implementation

**Author:** Gaurav Raj  
**Module:** Internship Task – CI/CD Pipeline & Deployment Automation  
**Status:** Task Completed

---

## Project Overview

The CI/CD Pipeline is a GitHub Actions-based system designed to automate the complete software delivery lifecycle using containerized deployments.

The system combines:

- Continuous Integration (Linting & Testing)
- Automated Docker Image Builds
- Version-Controlled Container Registry Pushes
- Automated Production Deployment via SSH

The goal of this system is to establish a fully automated, secure, and version-controlled deployment pipeline that eliminates manual release procedures.

---

## Key Features

### 1. Multi-Stage Pipeline

The pipeline executes three sequential stages:

- **Lint & Test** – Validates code quality and runs automated tests
- **Build & Push** – Builds Docker image and pushes to GitHub Container Registry
- **Deploy** – Connects to production server via SSH and deploys the new image

Each stage must pass before the next one begins.

### 2. Automated Deployment Triggers

The pipeline is configured with multiple triggers to control when specific jobs run.

| Trigger | Action |
|:---|:---|
| Pull Request to `main` | Runs CI only (Lint & Test) |
| Push to `main` | Runs full pipeline (CI + Build + Deploy) |
| SemVer Tag (e.g., `v1.0.0`) | Runs production release with version tagging |

### 3. Version Control for Docker Images

Every successful build generates uniquely tagged Docker images for traceability.

| Tag Type | Example | Purpose |
|:---|:---|:---|
| Commit SHA | `app:sha-ad132f5` | Unique, traceable to exact commit |
| Branch | `app:main` | Latest state of main branch |
| SemVer | `app:v1.0.0` | Immutable release version |

This ensures easy rollback to any previous version if needed.

### 4. Secure Secret Management

Sensitive credentials are never hardcoded in the repository. All secrets are stored securely in GitHub Actions Secrets.

| Secret Name | Description |
|:---|:---|
| `GHCR_PAT` | Personal Access Token for GitHub Container Registry |
| `SSH_HOST` | IP address of the production server |
| `SSH_USERNAME` | SSH login username for the server |
| `SSH_PRIVATE_KEY` | Private SSH key for server authentication |

### 5. Docker Containerization

The application is fully containerized using Docker and Docker Compose:

- **Dockerfile** – Defines the application build process
- **docker-compose.yml** – Orchestrates container deployment on the server
- **GHCR** – Stores built images privately in GitHub Container Registry

### 6. Automated Rollback Strategy

Because every build produces a uniquely tagged image, rollback is straightforward:

1. Revert the problematic commit in GitHub (triggers a new build with previous stable code)
2. Manual Override: SSH into server and specify a previous image tag in `docker-compose.yml`

---

## Project Structure

```
CI-CD-Pipeline
│
├── .github
│   └── workflows
│       └── deploy.yml
│
├── docs
│   └── ci_cd_architecture.md
│
├── Dockerfile
├── docker-compose.yml
├── package.json
├── package-lock.json
└── README.md
```

---

## Installation

Clone the repository:

```bash
git clone https://github.com/Nightstar01mait/CI-CD-Pipeline.git
cd CI-CD-Pipeline
```

Install dependencies:

```bash
npm install
```

---

## Configuration

### Setting Up GitHub Secrets

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

**Required Secret (for Docker image builds):**

```
GHCR_PAT → Your GitHub Personal Access Token
```

**Optional Secrets (only needed when a production server is available):**

> **Note:** The following secrets are required only when you have a deployment server (e.g., AWS EC2, DigitalOcean Droplet). Without a server, the pipeline will still successfully build and push Docker images to the registry.

```
SSH_HOST        → Your server IP address (e.g., 192.168.1.50)
SSH_USERNAME    → Your server login username (e.g., ubuntu, root)
SSH_PRIVATE_KEY → Your private SSH key for server access
```

### Generating a Personal Access Token (PAT)

1. Go to GitHub → **Settings** → **Developer settings** → **Personal access tokens**
2. Click **Generate new token (classic)**
3. Select scopes: `repo`, `write:packages`, `read:packages`
4. Copy the token and add it as `GHCR_PAT` in repository secrets

---

## Pipeline Workflow

```
Push to Main Branch
        │
        ▼
  Lint & Test (CI)
        │
        ▼
Build Docker Image
        │
        ▼
Push to GHCR Registry
        │
        ▼
SSH into Production Server
        │
        ▼
Pull Latest Image & Deploy
        │
        ▼
Application Live ✅
```

---

## Running the Pipeline

The pipeline runs **automatically** when you push code:

```bash
git add .
git commit -m "your commit message"
git push origin main
```

Then check the **Actions** tab on your GitHub repository to monitor the pipeline execution.

---

## Key Code Snippet

```yaml
# Docker Build & Push Stage
- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    context: .
    push: true
    tags: ${{ steps.meta.outputs.tags }}
    labels: ${{ steps.meta.outputs.labels }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

**Explanation:** This action builds the Docker image from the repository's `Dockerfile`, tags it with Git metadata (SHA, branch, version), and pushes it to the GitHub Container Registry. GitHub Actions cache is used to speed up subsequent builds.

---

## Technologies Used

- **Git & GitHub** – Version control and repository hosting
- **GitHub Actions** – CI/CD automation platform
- **Docker** – Application containerization
- **Docker Compose** – Multi-container orchestration
- **GitHub Container Registry (GHCR)** – Private Docker image storage
- **SSH (Appleboy Action)** – Secure remote server deployment
- **Node.js** – Application runtime

---

## Testing & Validation

- **CI Pipeline Validation:** Verified that the Lint & Test stage correctly passes or fails builds
- **Docker Build Testing:** Confirmed Docker images build successfully and push to GHCR with correct version tags
- **Integration Testing:** Monitored end-to-end workflow execution across all pipeline stages

---

## Challenges & Solutions

| Challenge | Solution |
|:---|:---|
| Missing `package-lock.json` caused CI caching failure | Initialized `package.json` and ran `npm install` to generate the lockfile |
| Secure authentication for private container registry pulls | Used PAT stored as GitHub Secret (`GHCR_PAT`) with `docker login` |
| PowerShell `&&` operator not supported for chaining commands | Used semicolons (`;`) to chain Git commands in PowerShell |
| Deploy stage failing without a server | Commented out deployment job until a server is provisioned |

---

## Future Improvements

- Add a production deployment server (AWS EC2 / DigitalOcean Droplet)
- Implement staging environment for pre-production testing
- Add Slack/Discord notifications for pipeline status
- Implement automated database migration steps
- Add container health checks and monitoring

---

## Author

**Gaurav Raj**  
BTech Computer Science and Engineering
