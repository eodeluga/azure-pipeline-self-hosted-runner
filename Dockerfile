FROM ubuntu:22.04
ENV TARGETARCH="linux-x64"
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=lts/*
# Also can be "linux-arm", "linux-arm64".

# Install dependencies
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y curl git jq libicu70 && \
  rm -rf /var/lib/apt/lists/*
  
# Install Node and yarn
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/refs/heads/master/install.sh | bash && \
  . "$NVM_DIR/nvm.sh" && \
  nvm install $NODE_VERSION && \
  nvm use $NODE_VERSION && \
  nvm alias default $NODE_VERSION && \
  npm install -g yarn
  
# Create symlinks for node, npm, and yarn
RUN ln -s /root/.nvm/versions/node/$(ls /root/.nvm/versions/node)/bin/node /usr/local/bin/node && \
  ln -s /root/.nvm/versions/node/$(ls /root/.nvm/versions/node)/bin/npm /usr/local/bin/npm && \
  ln -s /root/.nvm/versions/node/$(ls /root/.nvm/versions/node)/bin/yarn /usr/local/bin/yarn

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
