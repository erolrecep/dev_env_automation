# Dockerfile for testing dev_env_automation in a clean Linux environment
FROM ubuntu:24.04

# Prevent interactive prompts during apt installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential tools: sudo, curl, wget, git, make, build-essential
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    git \
    make \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create a test user with sudo privileges
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# Set default shell to bash
CMD ["/bin/bash"]
