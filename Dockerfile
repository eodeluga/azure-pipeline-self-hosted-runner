FROM ubuntu:22.04
ENV TARGETARCH="linux-x64"
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=lts/*
# Also can be "linux-arm", "linux-arm64".

RUN apt update && \
  apt upgrade -y && \
  apt install -y curl git jq libicu70

# Install Node
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/refs/heads/master/install.sh | bash && \
  . "$NVM_DIR/nvm.sh" && \
  nvm install $NODE_VERSION && \
  nvm use $NODE_VERSION && \
  nvm alias default $NODE_VERSION && \
  npm install -g yarn

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

WORKDIR /azp/

COPY ./azp-start.sh ./
RUN chmod +x ./azp-start.sh

# Create agent user and set up home directory
RUN useradd -m -d /home/agent agent
RUN chown -R agent:agent /azp /home/agent
RUN chmod 744 -R /azp /home/agent
USER agent
# Another option is to run the agent as root.
# ENV AGENT_ALLOW_RUNASROOT="true"

ENTRYPOINT [ "/azp/azp-start.sh" ]
CMD []
