# Beginner's Guide: DevOps Concepts for Your R/Python Project

This guide explains every concept used in the DevOps setup we just built.

---

## 1. Git and Version Control

**What it is:** Git is a system that saves snapshots of your files over time. Every time you "commit," Git stores the exact state of all tracked files. You can go back to any previous snapshot whenever you want.

**Why you won't lose versions:** Every commit is permanent. Even if you delete a file, the old version still exists in Git history. You can always recover it.

**Key commands:**
- `git add <file>` — stage a file (mark it to be included in the next snapshot)
- `git commit -m "message"` — save a snapshot with a description
- `git log` — see all your past snapshots
- `git checkout <commit-id> -- <file>` — restore a file from a past snapshot
- `git branch` — see/create parallel versions of your project (explained below)

### Branches

A **branch** is a parallel copy of your project. You can experiment on a branch without affecting your main code. If the experiment works, you merge it back. If it doesn't, you delete the branch — main code is untouched.

```
master:  A --- B --- C --- F  (stable code)
                \       /
feature:         D --- E      (experiment, then merge back)
```

### .gitignore

A file that tells Git which files to **never track**. This prevents junk files (caches, temporary data, secrets) from cluttering your history.

Example from your project:
```
.Rhistory    # R session history — not useful to version
__pycache__/ # Python's compiled bytecode cache
.env         # Secret keys — NEVER commit these
```

---

## 2. Docker (Your Sandbox)

### The Problem Docker Solves

Imagine you write an R script that uses `ggplot2 v3.4`. Your colleague has `ggplot2 v3.5`. Your script breaks on their machine. Or worse — you upgrade a package on your laptop and it breaks your *own* old project.

**Docker solves this** by putting your code inside a **container** — a lightweight, isolated mini-computer with its own R, Python, and packages. It works the same everywhere.

### Key Concepts

| Concept | Analogy | What it is |
|---------|---------|------------|
| **Image** | A recipe | A blueprint describing what software to install. Defined in the `Dockerfile`. |
| **Container** | A dish made from the recipe | A running instance of an image. You can create, start, stop, and destroy containers without affecting your real computer. |
| **Dockerfile** | The recipe card | A text file with step-by-step instructions to build an image. |
| **Volume** | A shared folder | A folder on your real computer that is visible inside the container. Changes go both ways. |

### Your Dockerfile Explained (line by line)

```dockerfile
FROM rocker/r-ver:4.3.2
```
Start from an existing image that already has R 4.3.2 installed. You don't build from scratch — you build on top of what others have made.

```dockerfile
RUN apt-get update && apt-get install -y python3 python3-pip python3-venv
```
Install Python 3 inside the image. `RUN` executes a command during the build.

```dockerfile
WORKDIR /app
```
Set the default directory inside the container to `/app`.

```dockerfile
COPY scripts/ ./scripts/
```
Copy your `scripts/` folder from your computer into the image.

```dockerfile
CMD ["bash"]
```
When the container starts, open a bash shell by default.

### Docker Compose

Docker Compose is a tool that simplifies running Docker. Instead of typing long `docker run` commands with many flags, you define everything in `docker-compose.yml` and run simple commands:

```bash
docker compose build              # Build the image
docker compose run sandbox        # Start a container and drop into a shell
docker compose run sandbox Rscript scripts/Test.R  # Run a specific script
```

The `volumes` setting in your `docker-compose.yml` means your `scripts/` folder is **shared** between your computer and the container. Edit a file locally, and the change is instantly available inside the container — no rebuilding needed.

### .dockerignore

Like `.gitignore` but for Docker. Tells Docker which files to skip when building images. You don't want your `.git/` history (which can be huge) or PDFs inside the container — they just waste space.

---

## 3. CI/CD (Continuous Integration / Continuous Deployment)

### What CI Means

**Continuous Integration** = every time you push code, a server automatically:
1. Grabs your latest code
2. Builds it
3. Runs tests or scripts
4. Reports whether everything passed or failed

You get an email/notification if something breaks. You catch bugs immediately instead of discovering them weeks later.

### What CD Means

**Continuous Deployment** = after CI passes, automatically deploy (publish) your code to a server. We haven't set this up — it's a future step when you have something to deploy.

### GitHub Actions (Your CI Tool)

GitHub Actions is GitHub's built-in CI/CD system. It's free for public repos and has generous free minutes for private repos.

**How it works:**
1. You define a **workflow** in `.github/workflows/ci.yml`
2. GitHub watches for **triggers** (push, pull request)
3. When triggered, GitHub spins up a fresh virtual machine
4. It runs your steps in order
5. You see green (passed) or red (failed) on your repo page

### Your ci.yml Explained

```yaml
on:
  push:
    branches: [master, main]
  pull_request:
    branches: [master, main]
```
**Trigger:** Run this workflow whenever someone pushes to master/main or opens a pull request targeting those branches.

```yaml
runs-on: ubuntu-latest
```
**Machine:** Use a fresh Ubuntu Linux virtual machine.

```yaml
- uses: actions/checkout@v4
```
**Step 1:** Download your repository's code onto the virtual machine.

```yaml
- run: docker compose build
```
**Step 2:** Build your Docker image (same as you'd do locally).

```yaml
- run: docker compose run sandbox Rscript scripts/Test.R
```
**Step 3:** Run your R script inside the container. If the script errors out, the CI fails and you get notified.

```yaml
- continue-on-error: true
  run: docker compose run sandbox R -e "lintr::lint_dir(...)"
```
**Step 4:** Lint (check code style) your R scripts. `continue-on-error: true` means style warnings won't block your pipeline — they're just informational.

---

## 4. How It All Fits Together

```
You write code locally
        |
        v
git commit + git push  ------>  GitHub receives your code
        |                              |
        v                              v
  Local testing              GitHub Actions CI runs:
  with Docker:                 1. Builds Docker image
  docker compose run ...       2. Runs scripts
                               3. Reports pass/fail
```

- **Git** ensures you never lose a version
- **Docker** ensures your code runs the same everywhere
- **GitHub Actions** ensures broken code is caught immediately

---

## 5. Quick Reference: Commands You'll Use

| Task | Command |
|------|---------|
| Save your work | `git add <files>` then `git commit -m "description"` |
| Push to GitHub | `git push` |
| See history | `git log --oneline` |
| Restore old file | `git checkout <commit-id> -- <file>` |
| Build sandbox | `docker compose build` |
| Run R script | `docker compose run sandbox Rscript scripts/Test.R` |
| Run Python script | `docker compose run sandbox python3 scripts/script.py` |
| Interactive shell | `docker compose run sandbox` |
| See CI results | Check your repo on github.com, look for green/red icons on commits |

---

## 6. Glossary

| Term | Meaning |
|------|---------|
| **Repository (repo)** | A project folder tracked by Git |
| **Commit** | A saved snapshot of your files |
| **Branch** | A parallel version of your project for experimentation |
| **Merge** | Combining a branch back into the main code |
| **Pull Request (PR)** | A request to merge a branch — lets others review your changes first |
| **Image** | A Docker blueprint (built from a Dockerfile) |
| **Container** | A running instance of an image — your isolated sandbox |
| **Volume** | A shared folder between your computer and a container |
| **Pipeline** | A sequence of automated steps (build, test, deploy) |
| **Lint** | Automatically checking code for style issues and potential bugs |
