# Use the official Ubuntu base image
FROM ghcr.io/geocompx/docker
ENV DEBIAN_FRONTEND=noninteractive

# Get Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc

# Set environment variables for Rust
ENV PATH="/root/.cargo/bin:${PATH}"

# Install R packages
RUN R -e "install.packages('remotes')"
RUN R -e "install.packages('rsgeo', repos = c('https://josiahparry.r-universe.dev', 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('robinlovelace/opengeohub2023')"

# Set working directory
WORKDIR /workspace

# Define the entry point
CMD ["bash"]
