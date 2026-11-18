# Kubernetes Labları

Kubernetes'i tek bir Kind cluster'ı üzerinde, temel nesnelerden uygulama yayınlama, ölçekleme, güvenlik, Helm ve izlemeye kadar sırayla uygulatan lab serisidir. Lablar üç seviyededir ve her seviye bir öncekinin konularını kullanır:

```text
Beginner → Intermediate → Advanced
```

Katalogda `*` ile işaretli lablar eğitimde mutlaka yapılması gereken çekirdek lablardır. Diğerleri zaman kaldıkça veya eğitim sonrasında yapılabilir.

## 1. Kurulum

Lablar Ubuntu 22.04 veya 24.04 üzerinde test edilmiştir. Kurulum betiği aşağıdaki sabit sürümleri kurar; böylece herkes aynı araçlarla çalışır:

| Araç | Sürüm |
|---|---|
| kubectl | `v1.37.2` |
| kind | `v0.33.0` |
| Kubernetes (Kind node imajı) | `v1.37.0` |
| helm | `v4.3.2` |
| Docker | Kuruluysa mevcut sürüm, değilse resmi depodan güncel sürüm |

Depoyu indirip betiği çalıştırın. Betik tekrar çalıştırılabilir: doğru sürüm kuruluysa atlar.

```bash
cd ~/k8s-labs
```

```bash
bash install-prerequisites.sh
```

Betik ayrıca Kind için kernel inotify limitlerini artırır ve statik PV labı için `/opt/k8s-labs/static-pv` dizinini hazırlar. Docker grubuna yeni eklendiyseniz oturumu kapatıp yeniden açın.

Araçları doğrulayın:

```bash
kubectl version --client
```

```bash
kind version
```

```bash
helm version --short
```

## 2. Kind Cluster

`kind-cluster.yaml` bir control-plane ve iki worker node'dan oluşan `k8s-labs` cluster'ını tanımlar:

| Port (sunucu) | Cluster içi | Kullanan |
|---|---|---|
| 19001, 19002, 19003 | Control-plane `:80` (Ingress Controller) | I01, I02; Edge Nginx `-app1`, `-app2` alan adları |
| 30086, 30087, 30088 | Aynı numaralı NodePort'lar | B02 Headlamp, B06, B07, B11, A01 |
| 127.0.0.1:18084 | NodePort 30084 | Edge Nginx `-headlamp` alan adı (B02 Headlamp şu an 30086 kullanır) |
| 127.0.0.1:13000 | NodePort 30089 | A05 Grafana; Edge Nginx `-grafana` alan adı |
| 127.0.0.1:19090 | NodePort 30090 | A05 Prometheus |

Sunucudaki `/opt/k8s-labs/static-pv` dizini bütün node'lara `/mnt/k8s-labs/static-pv` olarak bağlanır (B08).

Cluster'ı oluşturun ve bütün node'ların hazır olmasını bekleyin:

```bash
kind create cluster --config kind-cluster.yaml
```

```bash
kubectl wait --for=condition=Ready nodes --all --timeout=180s
```

```bash
kubectl get nodes
```

Beklenen sonuç: üç node `Ready` ve sürüm `v1.37.0`.

Cluster zaten varsa yeniden oluşturmayın; `kind get clusters` ile kontrol edin. Her lab kendi namespace'ini kullanır ve kendi temizliğini yapar. Cluster'ı tamamen sıfırlamak gerekirse:

```text
kind delete cluster --name k8s-labs
kind create cluster --config kind-cluster.yaml
```

## 3. Lab Kataloğu

### Beginner

| Lab | Konu | Öğrenilenler |
|---|---|---|
| **B01\*** | [Cluster, kubectl ve Namespace](beginner/lab-b01-cluster-kubectl-namespace/README.md) | Kind node'ları, kubeconfig ve context, `api-resources`, `explain`, namespace, label ve selector, Events |
| B02 | [Headlamp ile Cluster'ı Görsel İzleme](beginner/lab-b02-headlamp/README.md) | Helm ile kurulum, salt-okunur token, değişiklikleri arayüzden izleme |
| **B03\*** | [İlk Pod](beginner/lab-b03-first-pod/README.md) | `run`, `describe`, `logs`, `exec`, `port-forward`, YAML üretip `apply` ile yönetme |
| B04 | [Multi-container, Init ve Sidecar](beginner/lab-b04-multi-container-init-sidecar/README.md) | Ortak ağ ve disk, init container ile bağımlılık bekleme, yerleşik sidecar |
| **B05\*** | [Deployment ve Rollout](beginner/lab-b05-deployment-rollout/README.md) | Self-healing, ReplicaSet, ölçekleme, sürüm güncelleme, rollout geçmişi ve geri alma |
| **B06\*** | [Service ve DNS](beginner/lab-b06-service-dns/README.md) | ClusterIP, EndpointSlice, yük dağıtımı, cluster DNS, NodePort, ExternalName, LoadBalancer |
| **B07\*** | [ConfigMap ve Secret](beginner/lab-b07-configmap-secret/README.md) | `envFrom`, dosya olarak bağlama, base64, ayar değişikliğinin Pod'a yansıması; isteğe bağlı private registry |
| **B08\*** | [Depolama: emptyDir, PV ve PVC](beginner/lab-b08-storage/README.md) | Statik PV, dinamik PVC, StorageClass, veri kalıcılığı, Retain ve Delete |
| **B09\*** | [StatefulSet ve MySQL](beginner/lab-b09-statefulset-mysql/README.md) | Sıralı başlatma, Headless Service, Pod başına disk, kimlik ve veri koruma |
| **B10\*** | [Pod Sorun Giderme](beginner/lab-b10-pod-troubleshooting/README.md) | CrashLoopBackOff, OOMKilled, ImagePullBackOff, Pending, CreateContainerConfigError |
| **B11\*** | [Capstone: Veritabanlı Uygulamayı Uçtan Uca Dağıtma](beginner/lab-b11-capstone/README.md) | Secret, ConfigMap, StatefulSet, Deployment, NodePort, readiness ile trafik kontrolü |

### Intermediate

| Lab | Konu | Öğrenilenler |
|---|---|---|
| **I01\*** | [Traefik ile Ingress ve Gateway API](intermediate/lab-i01-ingress-gateway-traefik/README.md) | Host ve path yönlendirme, HTTPS alan adı; isteğe bağlı Gateway API'ye kesintisiz geçiş |
| **I02\*** | [Dağıtım Stratejileri](intermediate/lab-i02-deployment-strategies/README.md) | Recreate ve RollingUpdate kesinti ölçümü, Blue-Green, ağırlıklı ve başlığa göre Canary |
| **I03\*** | [Probe'lar ve Kaynak Yönetimi](intermediate/lab-i03-probes-resources/README.md) | Startup, readiness, liveness, requests ve limits, QoS sınıfları |
| I04 | [ResourceQuota ve LimitRange](intermediate/lab-i04-resourcequota-limitrange/README.md) | Namespace bütçesi, varsayılan kaynak değerleri, kota hatasını bulma |
| I05 | [HPA ve DaemonSet](intermediate/lab-i05-hpa-daemonset/README.md) | metrics-server, CPU'ya göre otomatik ölçekleme, her node'da Pod |
| I06 | [RBAC ve securityContext](intermediate/lab-i06-rbac-securitycontext/README.md) | ServiceAccount, Role, RoleBinding, Pod içinden API, root olmayan container, Pod Security Admission |

### Advanced

| Lab | Konu | Öğrenilenler |
|---|---|---|
| **A01\*** | [Helm ile Hazır Chart Yönetimi: WordPress](advanced/lab-a01-helm-wordpress/README.md) | Repository, values, install, upgrade, history, rollback, uninstall |
| A02 | [Sıfırdan Helm Chart Yazma](advanced/lab-a02-helm-chart-from-scratch/README.md) | Chart yapısı, şablonlar, `_helpers.tpl`, şema, lint, test, paketleme |
| A03 | [NFS ile Paylaşımlı Depolama](advanced/lab-a03-nfs-rwx/README.md) | ReadWriteMany, NFS CSI sürücüsü, dinamik NFS PVC |
| A04 | [Scheduling ve Node Bakımı](advanced/lab-a04-scheduling-node-maintenance/README.md) | nodeSelector, anti-affinity, taint ve toleration, cordon, drain, PodDisruptionBudget |
| A05 | [Prometheus ve Grafana ile İzleme](advanced/lab-a05-prometheus-grafana/README.md) | Hedefler, PromQL, ServiceMonitor, alarm kuralı, Grafana panoları |

## 4. Hızlı Başvuru

Komutlar ve sorun giderme adımları için [kubectl, Kind ve Helm hızlı başvuru kılavuzuna](cheat-sheets/kubectl-ve-kind-hizli-basvuru.md) bakın.
