# Use the official Ubuntu base image
FROM ubuntu:latest

# Install required system dependencies
RUN apt update && \
    apt install -y \
    libcurl4-openssl-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Get Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc

# Set environment variables for Rust
ENV PATH="/root/.cargo/bin:${PATH}"

# Install R
RUN add-apt-repository -y ppa:c2d4u.team/c2d4u4.0+ && \
    apt update && apt install -y \
    apt install -y r-base

# Install R packages
RUN R -e "install.packages('remotes'); remotes::install_github('r-lib/actions');"
RUN R -e "install.packages('sf');"

# Set working directory
WORKDIR /workspace

# Define the entry point
CMD ["bash"]
