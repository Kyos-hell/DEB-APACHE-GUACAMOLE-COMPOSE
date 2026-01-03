# 🚀 DEB-APACHE-GUACAMOLE-COMPOSE

![Docker](https://img.shields.io/badge/Docker-24.0-blue?logo=docker)
![Docker Compose](https://img.shields.io/badge/Docker%20Compose-2.x-blue?logo=docker)
![Debian](https://img.shields.io/badge/Debian-12-red)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-green?logo=github)

A **personal implementation of Apache Guacamole** on Debian using Docker Compose.  
This project provides a **remote access bastion** to centralize and secure access to your services and VMs.  
Designed for **learning, experimentation, and DevOps/IaC practice** with integrated **CI/CD pipelines** for automated testing and deployment.

---

## Project Structure

```text
DEB-APACHE-GUACAMOLE-COMPOSE/
│
├─ .github/
│  └─ workflows/
│     ├─ build.yml                          # Multi-image build pipeline
│     └─ smoke-tests-full-stack.yml         # Integration & smoke tests
│     
├─ guacamole-tomcat/
│  ├─ Dockerfile
│  └─ docker-entrypoint.sh
│
├─ guacd/
│  ├─ Dockerfile
│  └─ docker-entrypoint.sh
│
├─ mariadb-guacamole/
│  ├─ Dockerfile
│  ├─ docker-entrypoint.sh
│  └─ init/
│     ├─ 000-create-table.sql
│     ├─ 001-create-schema.sql
│     └─ 002-create-admin-user.sql
│
├─ docker-compose.yml
├─ instruction.txt
└─ README.md
```

---

## 🎯 Project Goals

- Deploy a **complete Guacamole bastion** (Tomcat + guacd + MariaDB) on Debian via Docker Compose.
- Learn **Dockerfile creation and hardening**.
- Structure a project for **IaC and DevOps best practices**.
- Document and version for **sharing on GitHub**.

---

## 🛠️ Roadmap / Improvements

### Security

- Automatic Docker image updates  
- Secure passwords and environment variables  
- Reduce container permissions
- add https  

### Dockerfile Optimization

- Reduce image size  
- Minimize unnecessary layers  
- Optimize build times  
- Multi stage integration

### Automation / CI-CD

- Integrate with GitHub Actions or GitLab CI  
- Build & container startup tests  
- Auto-deploy to a sandbox environment  

### Documentation & Readability

- Network & architecture diagrams  
- Step-by-step deployment instructions  
- Multi-environment configuration examples

---

## ⚡ Installation

### Local Development

1. Clone the repository:

```bash
git clone https://github.com/YOUR-USERNAME/DEB-APACHE-GUACAMOLE-COMPOSE.git
cd DEB-APACHE-GUACAMOLE-COMPOSE
```

2. Build and start the containers:

```bash
docker-compose up -d --build
```

3. Access Guacamole at: `http://<your-ip>:8080/guacamole`

### Default Credentials
- **Username:** admin
- **Password:** admin
- **Default Guacamole Server:** localhost:4822

---

## 🔄 CI/CD Workflows

### 1️⃣ **Build Pipeline** (`build.yml`)

Automated building and publishing of Docker images to GitHub Container Registry (GHCR).

**Trigger:** 
- Push to `main` or `dev` branches
- Pull requests targeting `main` or `dev`
- Manual trigger via `workflow_dispatch`

**Workflow Overview:**

```
┌─────────────────────────────────────────────────────────────────┐
│                     BUILD PIPELINE                              │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PUSH/PR Event                                                  │
│         │                                                       │
│         ├──────────────────────────────────────────────┐        │
│         │                                              │        │
│         ▼                                              ▼        │
│    ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │        │
│    │   MariaDB    │  │   Guacd      │  │ Guacamole  │ │        │
│    │   Image      │  │   Image      │  │  Tomcat    │ │        │
│    │   Build      │  │   Build      │  │  Image     │ │        │
│    │   (:ci tag)  │  │   (:ci tag)  │  │  Build     │ │        │
│    │              │  │              │  │  (:ci tag) │ │        │
│    └────────┬─────┘  └────────┬─────┘  └────────┬───┘ │        │
│             │                 │                 │     │        │
│             ▼                 ▼                 ▼     │        │
│    ┌──────────────────────────────────────────────┐   │        │
│    │  Push to GHCR (if not forked PR)            │   │        │
│    │  Tag: ci-{commit-sha}                       │   │        │
│    │  ghcr.io/owner/mariadb-guacamole:ci-{sha}  │   │        │
│    │  ghcr.io/owner/guacd:ci-{sha}              │   │        │
│    │  ghcr.io/owner/guacamole:ci-{sha}          │   │        │
│    └────────┬─────────────────────────────────────┘   │        │
│             │                                         │        │
│             └─────────────┬──────────────────────────┘        │
│                           │                                   │
│                           ▼                                   │
│              ┌─────────────────────────────┐                 │
│              │  Also tag :latest on main   │                 │
│              │  (if building on main)      │                 │
│              └─────────────────────────────┘                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Key Features:**
- ✅ **Smart Change Detection:** Only rebuilds images if their code changed
- ✅ **Always builds on main:** Ensures `:latest` tags stay current
- ✅ **Avoids pushing from forks:** Security measure for untrusted PRs
- ✅ **Fallback logic:** Uses `:latest` tag if CI build not yet available
- ✅ **Multi-stage:** 3 parallel jobs for MariaDB, Guacd, and Guacamole

---

### 2️⃣ **Smoke Tests Pipeline** (`smoke-tests-full-stack.yml`)

Automated integration and component testing of the full stack.

**Trigger:** 
- Called by `build.yml` workflow after successful image builds
- Can be triggered manually with a custom tag parameter

**Workflow Overview:**

```
┌─────────────────────────────────────────────────────────────────┐
│            SMOKE TESTS — FULL STACK                             │
│         (Integration & Component Validation)                    │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Build Pipeline Completes                                       │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────────────────────────────────────┐               │
│  │  Receive Images (ci-{sha} or :latest)       │               │
│  │  Input: TAG={commit-sha}                    │               │
│  └────────────┬────────────────────────────────┘               │
│               │                                                │
│     ┌─────────┴─────────┬────────────────────────┐             │
│     │                   │                        │             │
│     ▼                   ▼                        ▼             │
│  ┌──────────┐    ┌──────────────┐    ┌─────────────────┐      │
│  │  GUACD   │    │  MARIADB     │    │  GUACAMOLE      │      │
│  │  SMOKE   │    │  SMOKE       │    │  FULL-STACK     │      │
│  │  TEST    │    │  TEST        │    │  TEST           │      │
│  └────┬─────┘    └────┬─────────┘    └────────┬────────┘      │
│       │               │                        │               │
│       ▼               ▼                        ▼               │
│   ┌────────┐   ┌──────────────┐   ┌──────────────────┐        │
│   │Pull CI │   │Pull CI       │   │Pull 3 images     │        │
│   │image   │   │image w/      │   │setup full stack  │        │
│   │:4822   │   │fallback      │   │network & wait    │        │
│   │listen  │   │              │   │for all services  │        │
│   └────┬───┘   └────┬─────────┘   └────────┬────────┘        │
│        │            │                       │                 │
│        ▼            ▼                       ▼                 │
│   ┌────────┐   ┌─────────────┐   ┌──────────────────┐        │
│   │Run     │   │Run & verify │   │Test API calls    │        │
│   │verify  │   │database     │   │HTTP:8080 access  │        │
│   │process │   │ready + data │   │user creation     │        │
│   │running │   │loaded       │   │connection config │        │
│   └────┬───┘   └────┬────────┘   └────────┬────────┘        │
│        │            │                      │                 │
│        └─────┬──────┴──────────────────────┘                 │
│              │                                               │
│              ▼                                               │
│        ┌──────────────┐                                     │
│        │  Cleanup     │                                     │
│        │  Remove test │                                     │
│        │  containers  │                                     │
│        └────────┬─────┘                                     │
│                 │                                           │
│        ┌────────▼──────────┐                               │
│        │ PASS / FAIL       │                               │
│        │ Workflow Status   │                               │
│        └───────────────────┘                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Test Jobs:**

1. **smoke-guacd**
   - Pulls guacd image (CI tag or latest)
   - Verifies container starts
   - Checks port 4822 is listening
   - Expected: ✅ Guacamole server ready for connections

2. **smoke-mariadb**
   - Pulls MariaDB image (CI tag or latest)
   - Sets up environment (MYSQL_ROOT_PASSWORD, database, user)
   - Verifies database is ready and accepting connections
   - Expected: ✅ Database initialized with Guacamole schema

3. **smoke-guacamole** *(full stack test)*
   - Pulls all 3 images
   - Creates Docker network
   - Starts MariaDB → Guacd → Guacamole (in order)
   - Waits for service dependencies
   - Tests HTTP endpoint (port 8080)
   - Creates test user & connection configuration
   - Expected: ✅ Full Guacamole bastion operational

**Key Features:**
- ✅ **Parallel testing:** guacd & mariadb tested independently
- ✅ **Fallback mechanism:** Uses `:latest` if CI image not yet available
- ✅ **Retry logic:** Pulls images with 12 retries (2 min wait)
- ✅ **Automatic cleanup:** Removes test containers even if tests fail
- ✅ **Comprehensive validation:** Tests ports, processes, databases, APIs

---

## 📊 Full CI/CD Flow

```
DEVELOPER PUSH/PR
       │
       ▼
  ┌─────────────────────┐
  │  Trigger: build.yml │
  └──────────┬──────────┘
             │
       ┌─────┴────┬─────────────┐
       ▼          ▼             ▼
    MariaDB    Guacd       Guacamole
    Build      Build        Build
       │          │             │
       └─────┬────┴─────────────┘
             │
             ▼
      Push to GHCR
      (ci-{sha} tags)
             │
             ▼
  ┌─────────────────────────────┐
  │ Trigger: smoke-tests        │
  │ (with TAG={commit-sha})     │
  └──────────┬──────────────────┘
             │
       ┌─────┴─────┬──────────────┐
       ▼           ▼              ▼
    guacd      mariadb      full-stack
    smoke      smoke        integration
    test       test         test
       │           │              │
       └─────┬─────┴──────────────┘
             │
       ┌─────▼──────────────────┐
       │  All tests passed? ✅   │
       └────────────────────────┘
             │
             ├─ YES → Deploy ready
             └─ NO  → Alert maintainers
```

---

## Prerequisites
 
- Docker >= 24.0
- Docker Compose >= 2.x
- Ports 8080 (Guacamole), 4822 (guacd), and 3306 (MariaDB) available locally
- Optional: GitHub account & Docker registry for CI/CD

---

## 🛠️ Local Testing

### Run Smoke Tests Locally

You can simulate the CI/CD smoke tests locally:

```bash
# Start services
docker-compose up -d --build

# Test guacd connectivity
docker exec guacd ss -ltn | grep 4822

# Test MariaDB
docker exec mariadb-guacamole mysqladmin ping -uroot -prootpassword

# Test Guacamole web interface
curl -s http://localhost:8080/guacamole/ | head -20

# View logs
docker-compose logs -f

# Cleanup
docker-compose down
```

---

## 📋 Service Architecture

### Service Dependencies

```
┌─────────────────────────────────────────┐
│        GUACAMOLE-TOMCAT (8080)          │
│         Web Interface (Java/Tomcat)     │
└────────────┬─────────────────┬──────────┘
             │                 │
             ▼                 ▼
    ┌──────────────┐   ┌──────────────────┐
    │   GUACD      │   │  MARIADB         │
    │  (4822)      │   │  (3306)          │
    │ Proxy Server │   │ Database         │
    └──────────────┘   └──────────────────┘
```

### Network Mode
- **Bridge network:** Custom Docker network for inter-service communication
- **Port Mappings:**
  - Guacamole Tomcat: `8080:8080`
  - Guacd: `4822:4822`
  - MariaDB: `3306:3306`

---

## 🔐 Security Considerations

**Current State:**
- Default credentials used for quick setup
- Passwords hardcoded in compose file
- No HTTPS configured
- Basic container isolation

**Recommended Improvements:**
- Use `.env` files for credentials (see roadmap)
- Enable HTTPS with reverse proxy (Nginx)
- Implement least-privilege user permissions
- Use secrets management (Docker Secrets or external vaults)
- Regular security audits of Dockerfiles
- Keep base images updated

---

## 🤝 Contributing

This project is **experimental (v1.0.0)** and mainly intended as a learning journey.  
Any suggestions, feedback, or contributions are **very welcome** to help improve the codebase and adopt best practices.

Examples of contributions could include:

- 🔒 Improving container security & hardening
- ⚡ Optimizing Dockerfiles and build processes
- 🔄 Enhancing CI/CD pipelines
- 📚 Improving documentation & diagrams
- 🐛 Reporting bugs or edge cases
- 💡 Sharing DevOps/IaC best practices

---

## 📜 License

This project is provided as-is for educational and experimental purposes.

---

## 📞 Support

For questions or issues, please open a GitHub issue with:
- Description of the problem
- Steps to reproduce
- Docker/system version info
- Relevant logs
