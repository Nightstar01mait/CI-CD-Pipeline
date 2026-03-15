# CI/CD Pipeline Architecture

This document describes the continuous integration and continuous deployment (CI/CD) architecture for the application, fulfilling the requirements for automated Docker image builds, configuration of deployment triggers, and version control for service builds.

## 1. Overview

The CI/CD pipeline is designed to automate the testing, building, and deployment phases of the application lifecycle. By leveraging **GitHub Actions** and **Docker**, the pipeline ensures that every change pushed to the repository is automatically validated, containerized, and optionally deployed to the target environment.

## 2. Infrastructure Components

### 2.1 Version Control System (VCS)
- **Platform**: GitHub
- **Branching Strategy**: 
  - `main`: Production-ready code.
  - Feature branches: For active development.

### 2.2 Container Registry
- **Service**: GitHub Packages (GHCR) or Docker Hub.
- **Purpose**: To securely store, manage, and version compiled Docker images.

### 2.3 CI/CD Automation Tool
- **Service**: GitHub Actions.
- **Responsibilities**: Executing automated workflows defined in `.github/workflows`.

### 2.4 Target Environment
- **Platform**: Defined Production Server / Virtual Machine (e.g., AWS EC2, DigitalOcean Droplet) accessible via SSH.
- **Runtime Environment**: Docker and Docker Compose running on the host.

## 3. Workflow Triggers

The automated pipeline incorporates several triggers to control *when* specific jobs run:

- **Pull Requests (PRs) merging to `main`**: Triggers the **CI** workflow (Linting and Testing) to ensure new code does not break existing functionality.
- **Pushes to `main`**: Triggers the full **CI/CD** workflow (Linting, Testing, Building, Pushing, and Deployment).
- **SemVer Tags (e.g., `v1.2.0`)**: Triggers a production release workflow, tagging the Docker image with a specific version for immutable rollbacks.

## 4. Pipeline Stages

The GitHub Actions workflow is broken down into the following major stages logically represented as jobs:

### Stage 1: Continuous Integration (CI)
- **Linting & Code Formatting**: Ensures code adheres to defined styling guidelines.
- **Unit Testing**: Runs the automated test suite. If any test fails, the pipeline aborts immediately, preventing faulty code from being built or deployed.

### Stage 2: Continuous Delivery / Build
- **Environment Setup**: Provisions a fresh runner to build the application.
- **Docker Image Build**: Executes `docker build`, utilizing a multi-stage `Dockerfile` to produce a minimized, production-ready image.
- **Version Tagging**: Applies strict versioning to the Docker image:
  - Commit SHA: `myapp:<git-sha>` (Unique, traceable)
  - Branch: `myapp:latest` (Reflects the current state of `main`)
  - SemVer Tag: `myapp:v1.x.x` (For specific releases)
- **Push to Registry**: Uploads the tagged images to the container registry securely using encrypted secrets.

### Stage 3: Continuous Deployment (CD)
*Note: This stage only runs if all previous stages are successful and the trigger was a merge to `main` or a new tag.*
- **Authentication**: Authenticates securely with the target server via an SSH key stored in GitHub Secrets.
- **Server Update**: Performs the following commands remotely:
  1. Pulls the latest Docker image from the registry.
  2. Creates or updates the `docker-compose.yml` configurations with the newly extracted image tag if necessary.
  3. Uses `docker compose up -d` to restart the application container with minimal downtime.
  4. Prunes dangling or unused old images (`docker image prune -a`) to maintain server storage space.

## 5. Secret and Configuration Management

To keep the pipeline secure, sensitive data will never be hardcoded in the repository. The following variables will be stored securely in **GitHub Secrets** (`Settings > Secrets and variables > Actions`):

| Secret Name | Description |
| :--- | :--- |
| `DOCKER_USERNAME` | Username for accessing the container registry. |
| `DOCKER_PASSWORD` | Password or Personal Access Token (PAT) for the registry. |
| `SSH_HOST` | The IP address or domain name of the production server. |
| `SSH_USERNAME` | The SSH username to log into the target server. |
| `SSH_PRIVATE_KEY` | The private SSH key used for authentication. |

## 6. Rollback Strategy

Because every successful build generates a uniquely tagged Docker image (via Git SHA or SemVer tag) pushed to the registry, rolling back is straightforward:
1. Revert the problematic commit in GitHub, which triggers a new build pipeline using the previous stable code.
2. (Manual Override): If CI is broken, manually SSH into the server and run `docker run` or update `docker-compose.yml` to specify the exact previous successful `<git-sha>` or version tag and restart the service.
