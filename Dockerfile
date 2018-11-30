FROM alpine:3.8

LABEL MAINTAINER="Alexander Pinnecke <alex@alexanderpinnecke.de>"

# current TF versions: https://www.terraform.io/downloads.html
# checksums at: https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_SHA256SUMS

ENV \
  KUBECTL_VERSION=v1.11.5 \
  HELM_VERSION=v2.11.0 \
  HELMFILE_VERSION=v0.40.3 \
  TERRAFORM_VERSION=0.11.10 \
  TERRAFORM_SHA256SUM=43543a0e56e31b0952ea3623521917e060f2718ab06fe2b2d506cfaa14d54527

RUN apk add --update --no-cache bash curl wget ca-certificates openssh git \
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
