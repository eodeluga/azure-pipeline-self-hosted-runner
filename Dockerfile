FROM node:22-bookworm
ENV TARGETARCH="linux-x64"
# Also can be "linux-arm", "linux-arm64".

# Install dependencies
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y curl git jq libicu72 ca-certificates gnupg lsb-release && \
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  apt-get update && \
  apt-get install -y docker-ce-cli && \
  rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Create agent directory
WORKDIR /azp/

# Copy the agent start script to image
COPY ./azp-start.sh ./
RUN chmod +x ./azp-start.sh
    
USER agent

ENTRYPOINT ["/azp/azp-start.sh"]
CMD []
