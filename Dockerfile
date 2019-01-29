FROM golang:alpine as builder

WORKDIR /go/src/github.com/terraform-providers/terraform-provider-vault/

RUN apk add --no-cache git make \
  && mkdir -p /root/.terraform.d/plugins \
  && git clone https://github.com/terraform-providers/terraform-provider-vault.git . \
  && echo "Building terraform-provider-vault ..." \
  && CGO_ENABLED=0 go build -a -ldflags '-s' -installsuffix cgo -o /root/.terraform.d/plugins/linux_amd64/terraform-provider-vault_v1.5.0 .

FROM alpine:3.8

LABEL MAINTAINER="Alexander Pinnecke <alex@alexanderpinnecke.de>"

# current TF versions: https://www.terraform.io/downloads.html
# checksums at: https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_SHA256SUMS

ENV \
  KUBECTL_VERSION=v1.11.5 \
  HELM_VERSION=v2.12.1 \
  HELMFILE_VERSION=v0.40.3 \
  TERRAFORM_VERSION=0.11.11 \
  TERRAFORM_SHA256SUM=94504f4a67bad612b5c8e3a4b7ce6ca2772b3c1559630dfd71e9c519e3d6149c

RUN apk add --update --no-cache \
    jq \
    bash \
    curl \
    wget \
    ca-certificates \
    openssh \
    openssl \
    git \
  && apk add --update --no-cache --virtual deps gettext tar gzip \
  && echo "Installing kubectl version ${KUBECTL_VERSION}" \
  && curl -f -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
  \
  && echo "Installing helm version ${HELM_VERSION}" \
  && curl -f -L https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar xz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf linux-amd64 \
  \
  && echo "Installing helmfile version ${HELMFILE_VERSION}" \
  && curl -f -L https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64 -o usr/local/bin/helmfile \
    && chmod +x /usr/local/bin/helmfile \
  \
  && echo "Installing terraform version ${TERRAFORM_VERSION}" \
  && curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin \
    && rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && apk del --purge deps


RUN mkdir -p /root/.terraform.d/plugins
COPY --from=builder /root/.terraform.d/plugins /root/.terraform.d/plugins
