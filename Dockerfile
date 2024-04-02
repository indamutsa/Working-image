# Use Alpine Linux as the base image
FROM alpine:3.19.1

# Set the working directory
WORKDIR /work

COPY confirm_rm_rf.sh /cmd/confirm_rm_rf.sh

# Install necessary packages
RUN apk update && \
    apk add --no-cache docker curl wget python3 py3-pip python3-dev libffi-dev openssl-dev gcc libc-dev make zip bash openssl git mongodb-tools openssl git docker-compose zsh vim nano bash unzip npm openjdk17 openssh

# Install zsh and plugins
RUN sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" && \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    sed -i.bak 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# Install kubectl, helm, Terraform, kind, ArgoCD CLI, AWS CLI, and nvm
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/arm64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && \
    curl -LO https://get.helm.sh/helm-v3.7.2-linux-arm64.tar.gz && \
    tar -C /tmp/ -zxvf helm-v3.7.2-linux-arm64.tar.gz && \
    rm helm-v3.7.2-linux-arm64.tar.gz && \
    mv /tmp/linux-arm64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    wget https://releases.hashicorp.com/terraform/1.6.1/terraform_1.6.1_linux_arm64.zip && \
    unzip terraform_1.6.1_linux_arm64.zip && \
    mv terraform /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform && \
    rm terraform_1.6.1_linux_arm64.zip && \
    wget https://github.com/kubernetes-sigs/kind/releases/download/v0.11.1/kind-linux-arm64 && \
    chmod +x kind-linux-arm64 && \
    mv kind-linux-arm64 /usr/local/bin/kind && \
    wget https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-arm64 && \
    install -m 555 argocd-linux-arm64 /usr/bin/argocd && \
    rm argocd-linux-arm64 && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Add source lines to zshrc for nvm
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.zshrc

RUN mkdir -p /cmd && \
    chmod +x /cmd/confirm_rm_rf.sh

# Modify the zsh configuration file
RUN echo 'source $ZSH/oh-my-zsh.sh' >> ~/.zshrc && \
    echo 'source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc && \
    echo 'source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc && \
    echo 'export PATH="$PATH:/cmd"' >> ~/.zshrc && \
    echo 'alias rm="confirm_rm_rf.sh"' >> ~/.zshrc && \
    echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk' >> ~/.zshrc


RUN chown -R 1000:1000 .

# Start a zsh shell and source .zshrc
CMD ["/bin/zsh", "-c", "source ~/.zshrc; zsh"]