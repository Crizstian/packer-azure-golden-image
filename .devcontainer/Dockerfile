FROM alpine:edge
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
ARG TERRAFORM_VERSION=1.1.2
ARG PACKER_VERSION=1.7.8

RUN apk update && \
  apk add --no-cache sudo~=1 curl~=7 jq~=1 coreutils~=9 findutils~=4 moreutils~=0 unzip~=6 && \
  apk add --no-cache consul~=1 alpine-sdk~=1 make~=4 musl-dev~=1 go~=1 just~=0 bash~=5 bash-completion~=2 git~=2 openssl~=1

################################
# Install Terraform
################################
WORKDIR /tmp
RUN curl -O -L https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  # Unzip
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  # Move to local bin
  mv terraform /usr/local/bin/ && \
  # Make it executable
  chmod +x /usr/local/bin/terraform && \
  # Check that it's installed
  terraform --version

################################
# Install Packer
################################
WORKDIR /tmp
RUN curl -O -L https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
  # Unzip
  unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
  # Move to local bin
  mv packer /usr/local/bin/ && \
  # Make it executable
  chmod +x /usr/local/bin/packer && \
  # Check that it's installed
  packer --version

################################
# Create vscode user
################################
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG UID="1000"
ARG USER="vscode"
ENV USER ${USER}
ENV HOME="/home/${USER}"
ENV SHELL="/bin/bash"
RUN adduser \
  --disabled-password \
  --home "${HOME}" \
  --uid ${UID} \
  --shell "${SHELL}" \
  ${USER} \
  && \
  echo "${USER}:${USER}" | chpasswd

# this ensures vscode user can switch to su without password
USER root
# store output of printenv into "/tmp/1.txt"
# store output of whoami into "/etc/1.txt" 
RUN \
  addgroup sudo > /dev/null 2>&1 || true ; \
  adduser "${USER}" sudo \
  && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
  && visudo --check > /dev/null 2>&1
# ────────────────────────────────────────────────────────────────────────────────
ENV PATH="$PATH:$HOME/.local/bin"
ENV GOPATH="/usr/local/go"
ENV PATH="$PATH:$GOPATH/bin"
# ────────────────────────────────────────────────────────────────────────────────
################################
# Install Go toolchain
################################
USER root
RUN \
  curl -O https://dl.google.com/go/go1.17.3.linux-amd64.tar.gz ; \
  tar xvf go1.17.3.linux-amd64.tar.gz ; \
  chown -R root:root ./go ; \ 
  mv go /usr/local/go ; \
  chown -R "$(id -u ${USER}):$(id -g ${USER})" $GOPATH
USER "${USER}"
# ───────────────────────────────────────────────────────────
# [ NOTE ] => build terrascan binary and store it under
# /tmp/terrascan/bin/terrascan
RUN \
  rm -rf "/tmp/terrascan" \
  && git clone "https://github.com/accurics/terrascan" "/tmp/terrascan" \
  && make -C "/tmp/terrascan" build
# ───────────────────────────────────────────────────────────
# [ NOTE ] => move terrascan to /usr/local/bin/terrascan
USER root
RUN \
  mv -f "/tmp/terrascan/bin/terrascan" "/usr/local/bin/terrascan" \
  && terrascan version \
  && rm -rf "/tmp/terrascan"

################################
# Install tflint, tfsec
################################
USER root
RUN \
  curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash \
  && go install github.com/aquasecurity/tfsec/cmd/tfsec@latest 
# ───────────────────────────────────────────────────────────
################################
# Install pre-commit, checkov
################################
# USER root
# RUN \
#   apk add --no-cache util-linux~=2 libffi-dev~=3 python3-dev~=3 py3-cffi~=1 gcc~=11 py3-cryptography~=3 \
#   && pip3 install --no-cache-dir pre-commit==2.16.0 checkov==2.0.693
# finalize
USER "${USER}"
RUN \
  terrascan init    
WORKDIR "/workspace"
ENTRYPOINT ["/bin/bash"]
