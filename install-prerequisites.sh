#!/usr/bin/env bash
# Kubernetes lablari icin arac kurulumu (Ubuntu 22.04/24.04).
# Surumler sabittir; herkes ayni araclarla calisir. Betik tekrar calistirilabilir:
# dogru surum kuruluysa atlar, farkli surum varsa sabit surumu kurar.
set -euo pipefail

KUBECTL_VERSION="v1.37.2"
KIND_VERSION="v0.33.0"
HELM_VERSION="v4.3.2"
ARCH="$(dpkg --print-architecture)"

echo ">>> [1/6] Temel paketler"
sudo apt-get update -y -q
sudo apt-get install -y -q ca-certificates curl gnupg git jq conntrack

echo ">>> [2/6] Kernel inotify limitleri (Kind node'lari icin)"
printf 'fs.inotify.max_user_watches=524288\nfs.inotify.max_user_instances=512\n' \
  | sudo tee /etc/sysctl.d/99-kind.conf >/dev/null
# Yalnizca bu dosyayi uygula. "sysctl --system" tum dosyalari yeniden yukler ve bazi bulut
# imajlarindaki net.ipv4.ip_forward=0 ayari Docker'in actigi yonlendirmeyi kapatir.
sudo sysctl -q -p /etc/sysctl.d/99-kind.conf

echo ">>> [3/6] Docker"
if command -v docker >/dev/null 2>&1; then
  echo "Docker kurulu: $(docker --version)"
else
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update -y -q
  sudo apt-get install -y -q docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable --now docker
fi
sudo usermod -aG docker "$USER"

echo ">>> [4/6] kubectl ${KUBECTL_VERSION}"
if [ "$(kubectl version --client -o json 2>/dev/null | jq -r .clientVersion.gitVersion)" = "${KUBECTL_VERSION}" ]; then
  echo "kubectl ${KUBECTL_VERSION} kurulu"
else
  curl -fsSLo /tmp/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
  sudo install -m 0755 /tmp/kubectl /usr/local/bin/kubectl && rm -f /tmp/kubectl
fi

echo ">>> [5/6] kind ${KIND_VERSION}"
if [ "$(kind version 2>/dev/null | awk '{print $2}')" = "${KIND_VERSION}" ]; then
  echo "kind ${KIND_VERSION} kurulu"
else
  curl -fsSLo /tmp/kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${ARCH}"
  sudo install -m 0755 /tmp/kind /usr/local/bin/kind && rm -f /tmp/kind
fi

echo ">>> [6/6] helm ${HELM_VERSION}"
if [ "$(helm version --template '{{.Version}}' 2>/dev/null)" = "${HELM_VERSION}" ]; then
  echo "helm ${HELM_VERSION} kurulu"
else
  curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH}.tar.gz" | tar -xz -C /tmp
  sudo install -m 0755 "/tmp/linux-${ARCH}/helm" /usr/local/bin/helm && rm -rf "/tmp/linux-${ARCH}"
fi

echo ">>> Static PV host dizini"
sudo mkdir -p /opt/k8s-labs/static-pv
sudo chmod 0777 /opt/k8s-labs/static-pv

echo
kubectl version --client | head -1
kind version
helm version --short
echo "Hazir. Docker grubu yeni eklendiyse oturumu kapatip yeniden acin, ardindan cluster'i olusturun:"
echo "  cd ~/k8s-labs && kind create cluster --config kind-cluster.yaml"
