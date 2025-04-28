FROM node:22-bookworm
ENV TARGETARCH="linux-x64"
# Also can be "linux-arm", "linux-arm64".

# Install dependencies
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y curl git jq libicu72 && \
  rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Create agent user with host-matching UID/GID
ARG HOST_UID=1000
ARG HOST_GID=1000
RUN groupadd -g $HOST_GID agent && \
  useradd -u $HOST_UID -g $HOST_GID -m -d /home/agent agent

# Create agent directory
WORKDIR /azp/

# Copy the agent start script to image
COPY ./azp-start.sh ./
RUN chmod +x ./azp-start.sh && \
    chown -R agent:agent /azp /home/agent

ENTRYPOINT ["/azp/azp-start.sh"]
CMD []
