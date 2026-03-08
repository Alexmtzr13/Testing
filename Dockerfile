FROM rocker/r-ver:4.3.2

# Install Python 3 and pip
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy scripts into the container
COPY scripts/ ./scripts/

# Default: open a bash shell
CMD ["bash"]
