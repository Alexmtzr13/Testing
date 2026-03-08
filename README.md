# Testing

R and Python project with Docker-based development sandbox and GitHub Actions CI/CD.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your machine
- [Docker Compose](https://docs.docker.com/compose/install/) (included with Docker Desktop)

## Getting Started

### Build the sandbox

```bash
docker compose build
```

### Run an R script

```bash
docker compose run sandbox Rscript scripts/Test.R
```

### Run a Python script

```bash
docker compose run sandbox python3 scripts/your_script.py
```

### Open an interactive shell

```bash
docker compose run sandbox
```

This drops you into a bash shell inside the container with R and Python available.

## Project Structure

```
.
├── scripts/          # All R and Python scripts go here
│   └── Test.R
├── Dockerfile        # Defines the R + Python environment
├── docker-compose.yml
└── .github/workflows/ci.yml  # CI/CD pipeline
```

## CI/CD

GitHub Actions automatically runs on every push or pull request to `master`/`main`:

1. Builds the Docker image
2. Runs all R scripts in `scripts/`
3. Lints R code (non-blocking warnings)

## Next Steps

As your project grows, consider adding:

- **R packages**: Add `install.packages(...)` lines to the Dockerfile
- **Python packages**: Create a `requirements.txt` and add `COPY requirements.txt . && RUN pip install -r requirements.txt` to the Dockerfile
- **`renv`**: For reproducible R package management (`renv::init()`)
- **Python linting**: Add a `ruff` or `flake8` step to CI when you add `.py` files
