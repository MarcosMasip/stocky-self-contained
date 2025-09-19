# Stocky (Self‑Contained Offline Fork)

A streamlined fork delivering the full application (Spring Boot API + Angular UI + embedded H2) from a **single command**. After the first build (downloads dependencies once), you can work **fully offline** on macOS / Linux / Windows.

Core goals:
1. Single build pipeline — Maven drives Angular build and packages UI into the backend JAR.
2. Project‑relative H2 (no global paths): `stocky-api/data/h2`.
3. Automatic seeding (roles, permissions, settings, company placeholder, admin user).
4. Zero external telemetry by default (Amplitude & Rollbar opt‑in only).
5. Cross‑platform scripts: `run.sh`, `run.ps1`, `run.bat`, plus one‑shot launchers `stocky`, `stocky.cmd`.

---
## Quick Start

Fresh clone or already inside the repo — the process is the same:

macOS / Linux:
```bash
git clone <your-fork-url> stocky-self-contained && cd stocky-self-contained
chmod +x run.sh 2>/dev/null || true
./run.sh start
```
Windows (PowerShell):
```powershell
git clone <your-fork-url> stocky-self-contained
cd stocky-self-contained
./run.ps1 start
```
PowerShell policy blocked?
```powershell
powershell -ExecutionPolicy Bypass -File .\run.ps1 start
```
Windows (CMD):
```bat
git clone <your-fork-url> stocky-self-contained
cd stocky-self-contained
run.bat start
```

Open http://localhost:8080 and log in:
```
admin / admin123
```
First run = full dependency + Angular build. Subsequent runs reuse caches; you can disconnect.

---
### One‑Line Launcher (Alternative)
macOS / Linux:
```bash
git clone <your-fork-url> stocky-self-contained && cd stocky-self-contained && ./stocky
```
Windows:
```bat
git clone <your-fork-url> stocky-self-contained && cd stocky-self-contained && stocky.cmd
```

---

---
## Detailed First Run (What to Expect)

### macOS / Linux (Fresh Clone)
```bash
# 1. Clone the repository (FIRST RUN ONLY)
git clone <your-fork-url> stocky-self-contained
# Expected: Creates directory 'stocky-self-contained' with project files.

# 2. Enter the project directory (FIRST RUN ONLY)
cd stocky-self-contained
# Expected: Your shell prompt path ends in /stocky-self-contained

# 3. Ensure run script is executable (may be already) (FIRST RUN ONLY)
chmod +x run.sh
# Expected: No output on success.

# 4. Start the full stack (build + seed + run)
./run.sh start
# Expected (FIRST RUN):
#   - Java 21 check passes (or helpful error if <21)
#   - Maven downloads backend + plugin dependencies
#   - frontend-maven-plugin provisions a pinned Node 18
#   - npm ci executes (deterministic install)
#   - Angular production build emits hashed bundles
#   - Bundles copied into backend classpath static/
#   - Spring Boot starts with profile=offline (port 8080)
#   - Seeder logs multiple "seed ..." lines then '[offline] Seed checks completed.'
#   - Ready when: 'Tomcat started on port 8080' + 'Started StockyApplication'
```

### Subsequent Run (Any Platform)
```bash
./run.sh start
# Expected: Skips dependency downloads unless sources changed; starts much faster.
```

Windows specifics covered above in Quick Start.

### After Successful Start
Open http://localhost:8080 in a browser.
Expected: Login page loads. Use admin / admin123. After login you see dashboard modules.

### Smoke Test (Optional)
Run in a second terminal while the app is running:
```bash
curl -I http://localhost:8080/ | grep '200'
# Expected: HTTP/1.1 200 indicates the index.html served.

curl -s http://localhost:8080/ | grep -i '<title'
# Expected: Prints the <title> tag from the Angular index.
```

### Reset / Fresh Seed
```bash
./run.sh clean && ./run.sh start
# Expected: Rebuild + reseed. Previous data removed.
```

### Offline Verification
```bash
# 1. Start once online (as above)
# 2. Turn off Wi-Fi / disconnect network
./run.sh start
# Expected: Starts without needing to download anything; UI still loads locally.
```

---
## First Run vs Subsequent Runs
| Step | First Run | Subsequent |
|------|-----------|------------|
| Clone repo | Required | Skip |
| chmod +x run.sh | Maybe | Skip |
| Dependency download (Maven + npm) | Yes | Only if versions changed |
| Angular build | Yes | Incremental / only if sources changed |
| H2 directory creation | Yes | Directory reused |
| Seeding core data | Yes | Only runs once unless you cleaned data |
| Application startup | Yes | Yes |

---
## Java 21 Prerequisite
You need a JDK 21 (LTS) installation available on PATH. Check:
```bash
java -version
```
Expect: `openjdk 21.*` (Temurin, Oracle, or any distribution). If not:

macOS (Homebrew):
```bash
brew install --cask temurin
```
Linux (Debian/Ubuntu):
```bash
sudo apt update && sudo apt install -y openjdk-21-jdk
```
Windows (winget):
```powershell
winget install EclipseAdoptium.Temurin.21.JDK
```
If multiple JDKs are installed, export JAVA_HOME or adjust PATH before running `./run.sh start`.

---

---
---
## What’s Included

| Component | Technology | How it Runs Here |
|-----------|------------|------------------|
| Backend API | Spring Boot (Java 21) | Single fat JAR serves REST + static UI |
| Frontend UI | Angular (built via Maven) | Copied into `static/` and served by backend |
| Database | H2 file-based | Data stored in `stocky-api/data/h2` |
| Auth & Seed | Existing seeders + offline runner | Auto-run on startup (offline profile) |
| Mobile Wrapper | Flutter WebView | Points to http://127.0.0.1:8080/ |
| Telemetry | Amplitude + Rollbar (gated) | Disabled unless `window.ENABLE_TELEMETRY=true` |

---
## What The Run Script Does (Bootstrap Flow)

When you invoke `./run.sh start` (or platform equivalent) on the FIRST run it will:
1. Verify JDK 21+ is available (`java -version`).
2. Invoke the Maven Wrapper (downloads Maven if missing).
3. Download backend dependencies into the local Maven cache.
4. Download a pinned Node.js + npm (via `frontend-maven-plugin`) — no global Node install needed.
5. Run `npm ci` in `stocky-web` (reproducible, lockfile‑based install).
6. Build the Angular production bundle.
7. Copy the built bundle into the Spring Boot `static/` resources.
8. Package a single runnable JAR: `stocky-api/target/stocky-api.jar`.
9. Create the local H2 data directory (`stocky-api/data/h2`).
10. Start Spring Boot with the `offline` profile.
11. Run the offline seed runner (permissions, settings, company placeholder, admin user).

Subsequent `start` runs skip steps already satisfied (rebuild only if sources changed) and reuse the downloaded dependencies — so they are fully offline.

## Run Script Commands

`./run.sh` (macOS/Linux) / `run.ps1` (PowerShell) / `run.bat` (CMD):

| Command | Description |
|---------|-------------|
| `start` | Build if needed then launch the app (default) |
| `setup` | Only build (no run) |
| `clean` | Remove build outputs and local H2 data |
| `help`  | Show usage |

Example:
```bash
./run.sh clean && ./run.sh start
```

---
## Offline Profile

The application runs with the `offline` Spring profile:

Key properties (`application-offline.properties`):
- H2 path: `jdbc:h2:file:./data/h2/stocky`
- Auto schema update (`ddl-auto=update`)
- Seed user: `admin / admin123`
- Telemetry flag default: disabled

To reset all data, run:
```bash
./run.sh clean
```

---
## Re‑Enabling Telemetry (Optional)
If you need Amplitude / Rollbar during a production build you can inject at runtime (e.g. in `index.html` before Angular boot):
```html
<script>window.ENABLE_TELEMETRY = true;</script>
```
Or add a custom environment that sets this flag before building (advanced). By default nothing external is contacted.

---
## Flutter Mobile Wrapper (Optional)
`stocky-mobile` is provided as a convenience WebView shell (NOT part of the Maven reactor: root POM modules list only `stocky-web`, `stocky-api`). To try it:
```bash
cd stocky-mobile
flutter pub get
flutter run -d macos   # or another device/emulator
```
Backend must be running first (localhost:8080).

---
## Screenshots

See a Live Demo Here: [stocky.jamesaworo.me](https://stocky.jamesaworo.me)

-   Login screen

<div  align="center">
 <img src="screens/01-login.png" width="50%">
</div>

-   Setup Company

<div  align="center">
 <img src="screens/02-company-profile.png" width="50%">
</div>

-   Manage products

<div  align="center">
 <img src="screens/03-manage-product.png" width="50%">
</div>

-   Add products

<div  align="center">
 <img src="screens/04-add-product.png" width="50%">
</div>

-   Sales Point

<div  align="center">
 <img src="screens/05-sales-point.png" width="50%">
</div>

-   Sales Point (Dark Mode)

<div  align="center">
 <img src="screens/06-sales-point-dark.png" width="50%">
</div>

-   Stock Settings (Dark Mode)

<div  align="center">
 <img src="screens/07-stock-settings-dark.png" width="50%">
</div>

-   Add expenses

<div  align="center">
 <img src="screens/08-add-expenses-dark.png" width="50%">
</div>

## Core Features
- Authentication & authorization (JWT + roles/permissions)
- Inventory & stock management
- Company / customers / employees
- Products & product categories
- Sales & reporting (JasperReports templates retained)
- Settings & configuration
- Search & filtering

---
## Technology Stack

| Layer | Tech | Notes |
|-------|------|-------|
| Backend | Spring Boot 3.3.x | Serves REST + Angular dist from one JAR |
| Java | 21 | Single target (no mixed source levels) |
| Frontend | Angular 15 | Built via Maven; no separate Node install required |
| TypeScript | 4.x (Angular ecosystem) | Managed by Angular build | 
| Build Orchestration | Maven + frontend-maven-plugin | Pinned Node 18 for reproducibility |
| Database | H2 (file-based) | Stored under `stocky-api/data/h2` |
| Auth | JWT + Seeded admin | Offline profile auto-seeds |
| Reporting | JasperReports | Bundled templates retained |
| Mobile Shell | Flutter WebView | Points at `http://127.0.0.1:8080/` |
| Telemetry | Amplitude / Rollbar (gated) | Disabled unless `window.ENABLE_TELEMETRY=true` |

---
## Differences vs Upstream

| Category | Original | This Fork |
|----------|----------|-----------|
| Startup | Multiple manual commands (npm start + mvn run) | Single `./run.sh start` |
| Frontend Build | Separate Angular dev/prod step | Maven auto-builds Angular dist |
| Database Location | `~/stocky` H2 (dev) | Project-relative `./stocky-api/data/h2` |
| Telemetry | Amplitude & Rollbar active in production | Disabled by default; opt-in flag |
| Profiles | `dev`, `prod`, others | Added `offline` as default self-contained profile |
| Mobile URL | External IP in WebView | Localhost WebView |
| Java Version Handling | Mixed target/source 11 vs parent 17 | Upgraded to Java 21 release (toolchain enforced) |
| Scripts | None | `run.sh`, `run.ps1`, `run.bat` |
| Seeding | Seeders present but manual startup | Automatic via `OfflineSeedRunner` in offline profile |
| External Calls | Possible analytics/error calls | None by default |

---
## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Build fails `NoSuchFieldError JCTree` | Legacy Boot 2 + JDK 21 mismatch | Resolved by upgrading to Boot 3 + Java 21 |
| Port 8080 in use | Another service running | Stop other service or run `JAVA_OPTS="-Dserver.port=9090" ./run.sh start` |
| Empty UI / 404 | Angular dist missing | Remove `stocky-api/target` and re-run `./run.sh start` |
| H2 data reset accidentally | Deleted `data/h2` folder | Just restart; seeders recreate core data |
| H2 file lock stack traces | Previous instance still running or orphaned lock | Stop other process; ensure no Java process holds the file; optionally remove `*.lock.db` and restart |
| Windows script blocked | Execution policy | Run PowerShell as: `powershell -ExecutionPolicy Bypass -File .\run.ps1 start` |
| `permission denied: ./run.sh` | File not executable bit after clone (some OS / archive methods) | `chmod +x run.sh` or run with `bash run.sh start` |

### JDK Version Clarification
Project targets Java 21 only. Scripts will prompt if `java -version` is < 21.

Optional direct JAR run (after build):
```bash
java -jar stocky-api/target/stocky-api.jar --spring.profiles.active=offline
```

---
## Development Mode (Hot Reload)
If you want live Angular reload:
```bash
cd stocky-web
npm start
```
And in another terminal (optional for dev flow):
```bash
cd stocky-api
./mvnw spring-boot:run -Dspring-boot.run.profiles=offline
```
For normal users this is not required.

---
## Security Model & Note
All `/api/**` endpoints require a valid JWT (login issues one). Login endpoint and H2 console are open. Static Angular assets and root SPA route are publicly served. For local/offline use, change seed credentials in `application-offline.properties` or via env vars (e.g. `STOCKY_SYSTEM_USERNAME`, `STOCKY_SYSTEM_PASSWORD` if mapped) before first start.
Seed credentials are for local/offline use only. Change `stocky.system.username` and `stocky.system.password` in `application-offline.properties` (or set environment variables) if you share a machine.

---
## License
MIT — see `LICENSE`.

## Future Enhancements (Suggestions)
- Prebuilt binary archive with dependencies warmed.
- Docker offline bundle / Compose file.
- Native image build (GraalVM) for faster startup.
- PWA offline caching for the Angular UI.
- Real native Flutter screens (optional modernization).

---
## Acknowledgements
Original project by Aworo James. Fork focuses on offline ergonomics & simplified onboarding.


## Technology Badges
![Java](https://img.shields.io/badge/Java-21-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.x-brightgreen)
![Angular](https://img.shields.io/badge/Angular-15-red)
![TypeScript](https://img.shields.io/badge/TypeScript-4.x-blue)
![H2](https://img.shields.io/badge/Database-H2-lightgrey)
![Maven](https://img.shields.io/badge/Maven-3.9.x-blue)
![Node](https://img.shields.io/badge/Node-18.x-green)

## Local Usage (Recap)
All prior manual multi-step installation instructions are replaced by the single command:
```bash
./run.sh start   # or platform equivalent
```
After login you can configure the company, add products/categories, and start using sales & reporting modules.

---
## Quick API Smoke Test
After the app is running, obtain a JWT token:
```bash
curl -s -X POST http://localhost:8080/api/v1/auth/login \
	-H 'Content-Type: application/json' \
	-d '{"username":"admin","password":"admin123"}' | jq
```
Expected JSON contains a `token` field.

Use the token for an authenticated call (replace with a confirmed endpoint present in the codebase, e.g. a settings or profile endpoint):
```bash
TOKEN=<paste-token-here>
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/v1/auth/login --head
```
If unauthorized, re-check credentials or confirm seed logs.

---
## Minimal Command Cheat Sheet
| Goal | Command |
|------|---------|
| Fresh clone & run | `git clone <url> stocky-self-contained && cd stocky-self-contained && ./run.sh start` |
| Subsequent start | `./run.sh start` |
| Build only | `./run.sh setup` |
| Clean & reseed | `./run.sh clean && ./run.sh start` |
| Direct jar run | `java -jar stocky-api/target/stocky-api.jar --spring.profiles.active=offline` |
| API login test | `curl -X POST http://localhost:8080/api/v1/auth/login -H 'Content-Type: application/json' -d '{"username":"admin","password":"admin123"}'` |
| Change port | `JAVA_OPTS="-Dserver.port=9090" ./run.sh start` |

---

## Author
[Aworo James](mailto:james.aworo@outlook.com)

