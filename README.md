# Stocky (Self‑Contained Offline Fork)

This fork of Stocky transforms the original multi-command setup into a **single self‑contained, offline‑capable distribution**. After a one‑time dependency download, you can run the entire stack (Spring Boot API + Angular UI + embedded H2 database + optional Flutter WebView wrapper) **with a single command in one terminal** on macOS / Linux / Windows.

Core goals of this fork:
1. Zero external runtime calls by default (analytics & error reporting disabled unless explicitly re‑enabled).
2. One build pipeline (Maven orchestrates Angular build, bundles UI into the Spring Boot JAR).
3. Local file‑based H2 database stored within the project (`stocky-api/data/h2`) for easy portability.
4. Auto seeding of permissions, role, settings, company placeholder, and a default admin user.
5. Cross‑platform run scripts: `run.sh`, `run.ps1`, `run.bat`.

---
## Quick Start

Choose the scenario that matches where you are right now:

### A. You ALREADY have this repository open (you see files like `run.sh`, `stocky-api`, `stocky-web`)
Just run:
```bash
chmod +x run.sh stocky quickstart.sh 2>/dev/null || true  # first time only on macOS/Linux
./run.sh start          # macOS / Linux
```
Windows (PowerShell):
```powershell
./run.ps1 start
```
If PowerShell script execution is blocked:
```powershell
powershell -ExecutionPolicy Bypass -File .\run.ps1 start
```
Windows (classic CMD):
```bat
run.bat start
```

### B. FRESH clone (you are not in the folder yet)
```bash
git clone <your-fork-url> stocky-self-contained
cd stocky-self-contained
./run.sh start
```

Then open: http://localhost:8080

Seed credentials:
```
admin / admin123
```

> The first run is a full bootstrap (network required ONCE). Afterwards you can disconnect and keep using it entirely offline.

---
## Ultra-Short Setup (<= 3 Commands)

### Universal Launcher (All Platforms)

After cloning and entering the directory you can use a single launcher:

macOS / Linux:
```bash
git clone <your-fork-url> stocky-self-contained
cd stocky-self-contained
./stocky     # builds (first run) then runs; auto JDK 17 install if needed via quickstart.sh
```

Windows (PowerShell or CMD):
```bat
git clone <your-fork-url> stocky-self-contained
cd stocky-self-contained
stocky.cmd   # builds (first run) then runs
```

Already inside the repo? Just:
```bash
./stocky        # macOS/Linux
stocky.cmd      # Windows
```

Other actions:
```bash
./stocky setup   # build only
./stocky clean   # clean artifacts + data
```

Expected (first run): dependency download, Angular build, seeding, app at http://localhost:8080.

---

---
## Complete Command Sequence (Copy/Paste Friendly)

This section lists EXACT commands in the order you execute them, plus the expected outcome after each command so users can verify progress. Separate blocks are provided per platform. Steps marked (FIRST RUN ONLY) are not needed again once completed.

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
#   - Java 17 check passes (or helpful error if not 17)
#   - Maven downloads dependencies
#   - frontend-maven-plugin installs Node & npm into stocky-web
#   - npm ci runs (clean deterministic install)
#   - Angular production build emits dist/stocky-web
#   - Resources copied into backend static directory
#   - Spring Boot starts with profile=offline
#   - Console ends with 'Started' message and Tomcat on port 8080
```

### macOS / Linux (Subsequent Run)
```bash
./run.sh start
# Expected: Skips dependency downloads unless sources changed; starts much faster.
```

### Windows PowerShell (Fresh Clone)
```powershell
# 1. Clone (FIRST RUN ONLY)
git clone <your-fork-url> stocky-self-contained
# Expected: Creates folder with code.

# 2. Enter folder (FIRST RUN ONLY)
cd stocky-self-contained
# Expected: Path ends with stocky-self-contained>

# 3. Start full stack
./run.ps1 start
# Expected: Same sequence as macOS/Linux; final log shows Spring Boot started.

# (If execution policy error appears)
powershell -ExecutionPolicy Bypass -File .\run.ps1 start
# Expected: Script runs despite policy restrictions.
```

### Windows CMD (Fresh Clone)
```bat
git clone <your-fork-url> stocky-self-contained
cd stocky-self-contained
run.bat start
:: Expected: Similar output, culminating in Spring Boot started on 8080.
```

### After Successful Start
Open http://localhost:8080 in a browser.
Expected: Login page loads. Use admin / admin123. After login you see dashboard modules.

### Smoke Test (Optional Automation)
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
## Installing Java 17 (Examples)
You must use JDK 17 (toolchain + script enforce). Choose ONE method below.

### macOS (Homebrew)
```bash
brew install --cask temurin17
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH="$JAVA_HOME/bin:$PATH"
java -version  # Expected: version 17.x
```

### macOS (SDKMAN alternative)
```bash
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 17.0.10-tem
sdk use java 17.0.10-tem
java -version  # Expected: 17.x
```

### Ubuntu / Debian
```bash
sudo apt update
sudo apt install -y openjdk-17-jdk
java -version  # Expected: openjdk version "17..."
```

### Fedora / RHEL / CentOS (dnf)
```bash
sudo dnf install -y java-17-openjdk-devel
java -version
```

### Arch Linux
```bash
sudo pacman -S --noconfirm jdk17-openjdk
java -version
```

### Windows (winget)
```powershell
winget install EclipseAdoptium.Temurin.17.JDK
java -version
```

### Windows (Chocolatey)
```powershell
choco install temurin17 -y
refreshenv
java -version
```

---
## Why Java 17 (Rationale)

The current Spring Boot version and some transitive plugins rely on stable internal compiler tree structures present in JDK 17. With JDK 21, certain annotation-processing or plugin assumptions break (manifesting as `NoSuchFieldError` on `JCTree`). Upgrading to fully support JDK 21 would require:
1. Bumping Spring Boot & related plugins to versions known compatible with 21.
2. Verifying all third‑party libraries (JasperReports, JJWT 0.10.5, Hypersistence utilities) under 21.
3. Re-testing build (frontend-maven-plugin unaffected, but Lombok + annotation processors need validation).

Pinning to 17 guarantees a predictable, zero‑friction bootstrap. Future work could introduce a branch that upgrades Spring Boot & dependencies, then relaxes the restriction.

---

---
## One-Liner (Fresh Clone – Unix-like)
```bash
git clone <your-fork-url> stocky-self-contained && cd stocky-self-contained && ./run.sh start
```

---
## What’s Included

| Component | Technology | How it Runs Here |
|-----------|------------|------------------|
| Backend API | Spring Boot (Java 17) | Single fat JAR serves REST + static UI |
| Frontend UI | Angular (built via Maven) | Copied into `static/` and served by backend |
| Database | H2 file-based | Data stored in `stocky-api/data/h2` |
| Auth & Seed | Existing seeders + offline runner | Auto-run on startup (offline profile) |
| Mobile Wrapper | Flutter WebView | Points to http://127.0.0.1:8080/ |
| Telemetry | Amplitude + Rollbar (gated) | Disabled unless `window.ENABLE_TELEMETRY=true` |

---
## What The Run Script Actually Does (Bootstrap Flow)

When you invoke `./run.sh start` (or platform equivalent) on the FIRST run it will:
1. Verify JDK 17+ is available (`java -version`).
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

## Run Script Commands (Summary)

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
The `stocky-mobile` module embeds a WebView pointing to `http://127.0.0.1:8080/`.

Run (example):
```bash
cd stocky-mobile
flutter pub get
flutter run -d macos   # or another device/emulator
```
Ensure the backend is already running via `./run.sh start`.

---
## Original Screenshots

Below are unchanged screenshots from the original project for reference.

## Screenshot

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

## Core Features (Unchanged Functional Scope)
- Authentication & authorization (JWT + roles/permissions)
- Inventory & stock management
- Company / customers / employees
- Products & product categories
- Sales & reporting (JasperReports templates retained)
- Settings & configuration
- Search & filtering

---
## Technology Stack (Current)

| Layer | Tech | Notes |
|-------|------|-------|
| Backend | Spring Boot 2.7.x | Serves REST + Angular dist from one JAR |
| Java | 17 | Single target (no mixed source levels) |
| Frontend | Angular 15 | Built via Maven; no separate Node install required |
| TypeScript | 4.x (Angular ecosystem) | Managed by Angular build | 
| Build Orchestration | Maven + frontend-maven-plugin | Pinned Node 18 for reproducibility |
| Database | H2 (file-based) | Stored under `stocky-api/data/h2` |
| Auth | JWT + Seeded admin | Offline profile auto-seeds |
| Reporting | JasperReports | Bundled templates retained |
| Mobile Shell | Flutter WebView | Points at `http://127.0.0.1:8080/` |
| Telemetry | Amplitude / Rollbar (gated) | Disabled unless `window.ENABLE_TELEMETRY=true` |

---
## Differences vs Original Upstream

| Category | Original | This Fork |
|----------|----------|-----------|
| Startup | Multiple manual commands (npm start + mvn run) | Single `./run.sh start` |
| Frontend Build | Separate Angular dev/prod step | Maven auto-builds Angular dist |
| Database Location | `~/stocky` H2 (dev) | Project-relative `./stocky-api/data/h2` |
| Telemetry | Amplitude & Rollbar active in production | Disabled by default; opt-in flag |
| Profiles | `dev`, `prod`, others | Added `offline` as default self-contained profile |
| Mobile URL | External IP in WebView | Localhost WebView |
| Java Version Handling | Mixed target/source 11 vs parent 17 | Standardized to Java 17 release |
| Scripts | None | `run.sh`, `run.ps1`, `run.bat` |
| Seeding | Seeders present but manual startup | Automatic via `OfflineSeedRunner` in offline profile |
| External Calls | Possible analytics/error calls | None by default |

---
## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Build fails `NoSuchFieldError JCTree` | Running with JDK >17 (e.g. 21) against plugins expecting 17 internals | Switch to JDK 17 (now enforced by script + toolchain) |
| Port 8080 in use | Another service running | Stop other service or run `JAVA_OPTS="-Dserver.port=9090" ./run.sh start` |
| Empty UI / 404 | Angular dist missing | Remove `stocky-api/target` and re-run `./run.sh start` |
| H2 data reset accidentally | Deleted `data/h2` folder | Just restart; seeders recreate core data |
| Windows script blocked | Execution policy | Run PowerShell as: `powershell -ExecutionPolicy Bypass -File .\run.ps1 start` |
| `permission denied: ./run.sh` | File not executable bit after clone (some OS / archive methods) | `chmod +x run.sh` or run with `bash run.sh start` |

### JDK Version Clarification
The project compiles and runs on Java 17 (target) and usually on newer LTS (21). If you encounter classpath / plugin quirks on 21, install JDK 17 and export `JAVA_HOME` before running the script. Example:
```bash
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"
./run.sh start
```

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
## Security Note
Seed credentials are for local/offline use only. Change `stocky.system.username` and `stocky.system.password` in `application-offline.properties` (or set environment variables) if you share a machine.

---
## License
This fork remains under the original MIT License. See `LICENSE`.

---
## Future Enhancements (Planned Suggestions)
- Prebuilt binary archive with dependencies warmed.
- Docker offline bundle / Compose file.
- Native image build (GraalVM) for faster startup.
- PWA offline caching for the Angular UI.
- Real native Flutter screens (optional modernization).

---
## Acknowledgements
Original project by Aworo James. This fork focuses on offline ergonomics & simplified developer onboarding.


## Technology Badges (Current Stack)
![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7.x-brightgreen)
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

## Author

[Aworo James: james.aworo@outlook.com](james.aworo@outlook.com)

## License

Stocky is released under the MIT License.
