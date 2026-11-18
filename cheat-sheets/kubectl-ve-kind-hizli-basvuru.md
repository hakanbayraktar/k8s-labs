# kubectl, Kind ve Helm Hızlı Başvuru

Komutlar konuya göre gruplanmıştır. `<pod>`, `<ns>`, `<deploy>` gibi alanları kendi değerlerinizle değiştirin. Sorun giderme bölümü en sondadır.

## 1. Kind ve Cluster

| Komut | Ne yapar |
|---|---|
| `kind create cluster --config kind-cluster.yaml` | Yapılandırma dosyasıyla cluster oluşturur |
| `kind create cluster --name test --wait 120s` | Tek node'lu geçici cluster oluşturur ve hazır olmasını bekler |
| `kind get clusters` | Docker üzerindeki Kind cluster'larını listeler |
| `kind get nodes --name k8s-labs` | Cluster'ın node container'larını listeler |
| `kind get kubeconfig --name k8s-labs` | Kubeconfig'i yeniden üretir (kaybolursa) |
| `kind load docker-image app:1.0 --name k8s-labs` | Yerel imajı registry'siz node'lara kopyalar |
| `kind export logs ./kind-logs --name k8s-labs` | Node ve kubelet loglarını dışa aktarır |
| `kind delete cluster --name test` | Cluster'ı siler |
| `docker exec -it k8s-labs-worker bash` | Node container'ının içine girer |
| `docker exec k8s-labs-worker crictl images` | Node'daki container imajlarını listeler |
| `docker exec k8s-labs-worker crictl ps` | Node'da çalışan container'ları listeler |
| `kubectl cluster-info` | API sunucusu ve CoreDNS adresleri |
| `kubectl version` | İstemci ve sunucu sürümü |
| `kubectl get nodes -o wide` | Node'lar, IP'leri, sürümleri |
| `kubectl get componentstatuses` yerine `kubectl get --raw='/readyz?verbose'` | API sunucusu sağlık kontrolleri |

## 2. Kubeconfig ve Context

| Komut | Ne yapar |
|---|---|
| `kubectl config get-contexts` | Bütün context'ler; aktif olan `*` ile |
| `kubectl config current-context` | Aktif context |
| `kubectl config use-context kind-k8s-labs` | Context değiştirir |
| `kubectl config set-context --current --namespace=<ns>` | Aktif context'in varsayılan namespace'ini ayarlar |
| `kubectl config view --minify` | Yalnızca aktif context'in ayarları (sırlar gizli) |
| `kubectl --context kind-test get pods` | Aktif context'i değiştirmeden başka cluster'a komut |
| `kubectl --kubeconfig ./dosya.yaml get nodes` | Başka bir kubeconfig dosyasıyla çalışır |
| `KUBECONFIG=a.yaml:b.yaml kubectl config view --flatten > birlesik.yaml` | Kubeconfig dosyalarını birleştirir |

## 3. Namespace

| Komut | Ne yapar |
|---|---|
| `kubectl get namespaces` | Namespace listesi |
| `kubectl create namespace <ns>` | Namespace oluşturur |
| `kubectl get all -n <ns>` | Namespace'teki temel kaynaklar |
| `kubectl get pods -A` | Bütün namespace'lerdeki Pod'lar |
| `kubectl delete namespace <ns>` | Namespace'i ve içindeki her şeyi siler |
| `kubectl api-resources --namespaced=false` | Namespace'e bağlı olmayan kaynak türleri (Node, PV, StorageClass ...) |

## 4. Kaynakları Listeleme ve İnceleme

| Komut | Ne yapar |
|---|---|
| `kubectl get pods` | Pod listesi |
| `kubectl get pods -o wide` | IP ve node bilgisiyle |
| `kubectl get pod <pod> -o yaml` | API'de saklanan tam tanım ve durum |
| `kubectl get deploy,rs,pods,svc -n <ns>` | Birden çok türü tek komutta listeler |
| `kubectl get pods -w` | Değişiklikleri canlı izler (`Ctrl+C` ile çıkılır) |
| `kubectl describe pod <pod>` | Ayrıntı ve en altta **Events** |
| `kubectl describe node <node>` | Node kapasitesi, ayrılmış kaynaklar, taint'ler |
| `kubectl explain deployment.spec.strategy` | Bir alanın açıklaması |
| `kubectl explain pod.spec --recursive \| less` | Bütün alt alanlar |
| `kubectl api-resources` | Kaynak türleri ve kısa adları (`po`, `deploy`, `svc`, `cm`, `pvc` ...) |

## 5. Çıktı Biçimleri ve Filtreleme

| Komut | Ne yapar |
|---|---|
| `kubectl get pods --show-labels` | Label'ları gösterir |
| `kubectl get pods -L app,tier` | Seçilen label'ları sütun olarak gösterir |
| `kubectl get pods -l app=web` | Label'a göre seçer |
| `kubectl get pods -l 'tier in (web,api)'` | Liste tabanlı seçim |
| `kubectl get pods --field-selector status.phase=Pending` | Alana göre seçer |
| `kubectl get pods --field-selector spec.nodeName=<node>` | Bir node'daki Pod'lar |
| `kubectl get pods --sort-by=.metadata.creationTimestamp` | Oluşturulma zamanına göre sıralar |
| `kubectl get pods -o name` | Yalnızca `pod/ad` biçiminde |
| `kubectl get pod <pod> -o jsonpath='{.status.podIP}'` | Tek bir alanı yazdırır |
| `kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}'` | Liste üzerinde döngü |
| `kubectl get pods -o custom-columns='AD:.metadata.name,IMAJ:.spec.containers[0].image'` | Kendi sütunlarınız |
| `kubectl get deploy <deploy> -o yaml > yedek.yaml` | Kaynağı dosyaya alır |

## 6. Label ve Annotation

| Komut | Ne yapar |
|---|---|
| `kubectl label pod <pod> env=test` | Label ekler |
| `kubectl label pod <pod> env=prod --overwrite` | Label değiştirir |
| `kubectl label pod <pod> env-` | Label siler |
| `kubectl label node <node> disk=ssd` | Node'a label ekler |
| `kubectl annotate deploy <deploy> kubernetes.io/change-cause="v2"` | Annotation ekler (rollout geçmişinde görünür) |

## 7. Pod ile Çalışma

| Komut | Ne yapar |
|---|---|
| `kubectl run web --image=nginx:1.30-alpine` | Tek Pod çalıştırır |
| `kubectl run tmp --rm -it --image=busybox:1.37 -- sh` | Geçici kabuk Pod'u; çıkınca silinir |
| `kubectl logs <pod>` | Container logu |
| `kubectl logs <pod> -c <container>` | Çok container'lı Pod'da belirli container |
| `kubectl logs <pod> --previous` | Çöküp yeniden başlayan container'ın önceki logu |
| `kubectl logs -f <pod> --since=10m --tail=50` | Canlı izler, son 10 dakika, son 50 satır |
| `kubectl logs -l app=web --all-containers --prefix` | Label'a uyan bütün Pod'ların logları |
| `kubectl logs deploy/<deploy>` | Deployment'ın bir Pod'unun logu |
| `kubectl exec <pod> -- env` | Tek komut çalıştırır |
| `kubectl exec -it <pod> -- sh` | Etkileşimli kabuk |
| `kubectl exec deploy/<deploy> -- cat /etc/hosts` | Deployment'ın bir Pod'unda komut |
| `kubectl cp <pod>:/etc/nginx/nginx.conf ./nginx.conf` | Pod'dan dosya kopyalar |
| `kubectl cp ./dosya.txt <pod>:/tmp/` | Pod'a dosya kopyalar |
| `kubectl port-forward pod/<pod> 8080:80` | Yerel 8080'i Pod'un 80 portuna bağlar |
| `kubectl port-forward svc/<svc> 8080:80` | Service'e bağlar |
| `kubectl debug -it <pod> --image=busybox:1.37 --target=<container>` | Çalışan Pod'a geçici hata ayıklama container'ı ekler |
| `kubectl debug node/<node> -it --image=busybox:1.37` | Node üzerinde hata ayıklama Pod'u açar |
| `kubectl delete pod <pod> --grace-period=0 --force` | Takılan Pod'u zorla siler (son çare) |

## 8. Deployment, ReplicaSet ve Rollout

| Komut | Ne yapar |
|---|---|
| `kubectl create deployment web --image=nginx:1.30-alpine --replicas=3` | Deployment oluşturur |
| `kubectl scale deploy/<deploy> --replicas=5` | Replica sayısını değiştirir |
| `kubectl set image deploy/<deploy> <container>=nginx:1.31-alpine` | İmajı günceller |
| `kubectl set env deploy/<deploy> LOG_LEVEL=debug` | Ortam değişkeni ekler veya değiştirir |
| `kubectl set resources deploy/<deploy> --requests=cpu=100m,memory=64Mi` | Kaynak isteklerini değiştirir |
| `kubectl rollout status deploy/<deploy>` | Güncelleme bitene kadar bekler |
| `kubectl rollout history deploy/<deploy>` | Revizyon geçmişi |
| `kubectl rollout history deploy/<deploy> --revision=2` | Bir revizyonun ayrıntısı |
| `kubectl rollout undo deploy/<deploy>` | Önceki revizyona döner |
| `kubectl rollout undo deploy/<deploy> --to-revision=1` | Belirli revizyona döner |
| `kubectl rollout restart deploy/<deploy>` | Pod'ları sırayla yeniden oluşturur (ConfigMap değişikliği sonrası) |
| `kubectl rollout pause deploy/<deploy>` / `resume` | Güncellemeyi durdurur / devam ettirir |
| `kubectl get rs -l app=web` | Deployment'ın ReplicaSet'leri |
| `kubectl autoscale deploy/<deploy> --min=1 --max=5 --cpu-percent=50` | HPA oluşturur |
| `kubectl get hpa` | HPA hedefi ve mevcut kullanım |

## 9. StatefulSet, DaemonSet, Job

| Komut | Ne yapar |
|---|---|
| `kubectl get statefulset` | StatefulSet listesi |
| `kubectl rollout status statefulset/<sts>` | StatefulSet güncellemesini bekler |
| `kubectl scale statefulset/<sts> --replicas=0` | Pod'ları siler, PVC'leri korur |
| `kubectl get daemonset -A` | Bütün DaemonSet'ler (kube-proxy, kindnet ...) |
| `kubectl create job hello --image=busybox:1.37 -- echo merhaba` | Tek seferlik Job |
| `kubectl create cronjob hello --image=busybox:1.37 --schedule="*/5 * * * *" -- date` | Zamanlanmış Job |
| `kubectl get jobs,cronjobs` | Job durumları |

## 10. Service, DNS ve Ağ

| Komut | Ne yapar |
|---|---|
| `kubectl expose deploy/<deploy> --port=80 --target-port=8080` | ClusterIP Service oluşturur |
| `kubectl expose deploy/<deploy> --type=NodePort --port=80` | NodePort Service oluşturur |
| `kubectl get svc -o wide` | Service'ler ve selector'ları |
| `kubectl get endpointslice -l kubernetes.io/service-name=<svc>` | Service'in trafik gönderdiği Pod adresleri |
| `kubectl run tmp --rm -it --image=busybox:1.37 -- nslookup <svc>.<ns>.svc.cluster.local` | DNS çözümlemesini test eder |
| `kubectl run tmp --rm -it --image=busybox:1.37 -- wget -qO- http://<svc>` | Service'e cluster içinden istek |
| `kubectl exec <pod> -- cat /etc/resolv.conf` | Pod'un DNS ayarı ve arama listesi |
| `kubectl get pods -n kube-system -l k8s-app=kube-dns` | CoreDNS Pod'ları |
| `kubectl get ingress -A` | Ingress kuralları |
| `kubectl get gatewayclass,gateway,httproute -A` | Gateway API nesneleri |
| `curl -H "Host: <alan-adi>" http://127.0.0.1:19001/` | DNS olmadan Ingress/Gateway kuralını test eder |

## 11. ConfigMap ve Secret

| Komut | Ne yapar |
|---|---|
| `kubectl create configmap app --from-literal=MODE=test` | Anahtar-değerden ConfigMap |
| `kubectl create configmap app --from-file=app.properties` | Dosyadan ConfigMap |
| `kubectl create secret generic db --from-literal=PASSWORD='...'` | Secret oluşturur |
| `kubectl create secret docker-registry regcred --docker-server=... --docker-username=... --docker-password=...` | Private registry kimliği |
| `kubectl get secret db -o jsonpath='{.data.PASSWORD}' \| base64 -d` | Secret değerini çözer |
| `kubectl create configmap app --from-file=app.properties --dry-run=client -o yaml \| kubectl apply -f -` | Var olan ConfigMap'i dosyadan günceller |

## 12. Depolama

| Komut | Ne yapar |
|---|---|
| `kubectl get storageclass` | StorageClass'lar; varsayılan `(default)` ile işaretli |
| `kubectl get pvc -A` | PVC'ler ve bağlandıkları PV |
| `kubectl get pv` | PV'ler, reclaim policy ve durumları |
| `kubectl describe pvc <pvc>` | `Pending` nedeni Events'te |
| `kubectl get pv <pv> -o jsonpath='{.spec.nodeAffinity}'` | Yerel diskin hangi node'da olduğu |
| `kubectl get csidriver` | Kurulu CSI depolama sürücüleri |

## 13. Node ve Scheduling

| Komut | Ne yapar |
|---|---|
| `kubectl top nodes` / `kubectl top pods -A` | Anlık kaynak kullanımı (metrics-server gerekir) |
| `kubectl describe node <node> \| grep -A8 'Allocated resources'` | Node'da ayrılmış requests ve limits |
| `kubectl taint node <node> dedicated=egitim:NoSchedule` | Taint ekler |
| `kubectl taint node <node> dedicated=egitim:NoSchedule-` | Taint kaldırır |
| `kubectl cordon <node>` | Yeni Pod yerleşimini durdurur |
| `kubectl drain <node> --ignore-daemonsets --delete-emptydir-data` | Node'u boşaltır |
| `kubectl uncordon <node>` | Node'u tekrar kullanıma açar |
| `kubectl get pdb -A` | PodDisruptionBudget'lar ve izin verilen kesinti |

## 14. RBAC ve Güvenlik

| Komut | Ne yapar |
|---|---|
| `kubectl auth can-i list pods` | Kendi yetkinizi sorgular |
| `kubectl auth can-i delete pods --as=system:serviceaccount:<ns>:<sa> -n <ns>` | Başka kimlik adına sorgular |
| `kubectl auth can-i --list --as=system:serviceaccount:<ns>:<sa> -n <ns>` | Kimliğin bütün izinleri |
| `kubectl auth whoami` | Hangi kimlikle bağlı olduğunuz |
| `kubectl create serviceaccount <sa>` | ServiceAccount oluşturur |
| `kubectl create role pod-reader --verb=get,list --resource=pods` | Role oluşturur |
| `kubectl create rolebinding rb --role=pod-reader --serviceaccount=<ns>:<sa>` | RoleBinding oluşturur |
| `kubectl create token <sa> --duration=1h` | Süreli token üretir |
| `kubectl label ns <ns> pod-security.kubernetes.io/enforce=restricted` | Pod Security Admission seviyesi |

## 15. YAML ile Çalışma

| Komut | Ne yapar |
|---|---|
| `kubectl apply -f dosya.yaml` | Oluşturur veya günceller (declarative) |
| `kubectl apply -f klasor/` | Klasördeki bütün manifestler |
| `kubectl diff -f dosya.yaml` | Uygulamadan önce farkı gösterir |
| `kubectl apply -f dosya.yaml --dry-run=server` | API doğrulamasıyla dener, kaydetmez |
| `kubectl create deployment web --image=nginx --dry-run=client -o yaml > web.yaml` | Komuttan YAML şablonu üretir |
| `kubectl replace --force -f pod.yaml` | Değiştirilemeyen alanlar için silip yeniden oluşturur |
| `kubectl patch deploy <deploy> -p '{"spec":{"replicas":2}}'` | Kısmi güncelleme |
| `kubectl edit deploy <deploy>` | Canlı nesneyi editörde açar |
| `kubectl delete -f dosya.yaml` | Dosyadaki kaynakları siler |
| `kubectl wait --for=condition=Ready pod -l app=web --timeout=120s` | Koşul sağlanana kadar bekler |

## 16. Helm

| Komut | Ne yapar |
|---|---|
| `helm repo add bitnami https://charts.bitnami.com/bitnami` | Repository ekler |
| `helm repo update` | Chart listelerini günceller |
| `helm search repo wordpress --versions` | Chart ve sürümlerini arar |
| `helm show values <repo>/<chart> --version <v>` | Değiştirilebilir değerler |
| `helm pull <repo>/<chart> --version <v> --untar` | Chart'ı indirip açar |
| `helm template <release> <chart> -f values.yaml` | Manifestleri cluster'a göndermeden üretir |
| `helm install <release> <chart> -n <ns> --create-namespace -f values.yaml --wait` | Kurar |
| `helm upgrade --install <release> <chart> -f values.yaml` | Yoksa kurar, varsa günceller |
| `helm list -A` | Bütün release'ler |
| `helm status <release> -n <ns>` | Release durumu ve notları |
| `helm get values <release> -n <ns> --revision 2` | Bir revizyonun değerleri |
| `helm get manifest <release> -n <ns>` | Cluster'a gönderilen manifestler |
| `helm history <release> -n <ns>` | Revizyon geçmişi |
| `helm rollback <release> 1 -n <ns>` | Revizyona döner |
| `helm uninstall <release> -n <ns>` | Kaldırır (StatefulSet PVC'leri kalır) |
| `helm create <chart>` / `helm lint <chart>` / `helm package <chart>` | Chart oluşturur / denetler / paketler |
| `helm test <release> -n <ns>` | Chart'ın test Pod'larını çalıştırır |

## 17. Sorun Giderme

### Teşhis sırası

Bir uygulama çalışmadığında aşağıdaki sırayla ilerleyin; her adım bir sonrakinin nereye bakacağını söyler:

| Adım | Komut | Ne arıyorsunuz |
|---|---|---|
| 1 | `kubectl get pods -n <ns> -o wide` | `STATUS`, `READY`, `RESTARTS`, hangi node |
| 2 | `kubectl describe pod <pod> -n <ns>` | En alttaki Events; `State` ve `Last State`, `Exit Code` |
| 3 | `kubectl get events -n <ns> --sort-by=.lastTimestamp` | Namespace'teki son olaylar |
| 4 | `kubectl get events -n <ns> --field-selector type=Warning` | Yalnızca uyarılar |
| 5 | `kubectl logs <pod> -n <ns>` ve `--previous` | Uygulamanın kendi hata mesajı |
| 6 | `kubectl exec -it <pod> -n <ns> -- sh` veya `kubectl debug` | İçeriden ağ, dosya, ortam değişkeni kontrolü |
| 7 | `kubectl get endpointslice -n <ns>` ve `kubectl describe svc` | Trafik doğru Pod'lara gidiyor mu |

### Belirtiye göre hızlı tablo

| Belirti | Bakılacak yer | Tipik neden | Çözüm |
|---|---|---|---|
| `Pending` | `describe pod` → Events: `FailedScheduling` | Yetersiz CPU/bellek requests, uymayan `nodeSelector`, tolere edilmeyen taint, bağlanamayan PVC | Requests'i düşür, label/taint'i düzelt, PVC'yi kontrol et |
| `ImagePullBackOff` / `ErrImagePull` | `describe pod` → Events: `Failed to pull image` | Yanlış ad veya tag (`not found`), private registry (`authorization failed`), ağ erişimi yok | İmaj adını düzelt, `imagePullSecrets` ekle, node'dan registry erişimini kontrol et |
| `ErrImageNeverPull` veya yerel imaj bulunamıyor | `describe pod` | Kind node'larına imaj yüklenmemiş | `kind load docker-image <imaj> --name k8s-labs` |
| `CrashLoopBackOff` | `logs` ve `logs --previous`, `Exit Code` | Uygulama hata ile çıkıyor: eksik ayar, yanlış komut, bağlanamayan bağımlılık | Logdaki hatayı düzelt; komut ve ortam değişkenlerini kontrol et |
| `OOMKilled`, `Exit Code: 137` | `describe pod` → `Last State` | Bellek limiti aşıldı | Limiti gerçek ihtiyaca göre artır veya bellek kullanımını düşür |
| `CreateContainerConfigError` | `describe pod` → Events | Pod'un istediği ConfigMap veya Secret ya da anahtar yok | Eksik nesneyi oluştur; Pod kendiliğinden başlar |
| `Running` ama `0/1` | `describe pod` → `Readiness probe failed` | Readiness yolu/portu yanlış, uygulama hazır değil, bağımlılığa ulaşamıyor | Probe'u ve bağımlılığı kontrol et |
| `RESTARTS` artıyor, logda hata yok | `describe pod` → `Liveness probe failed` | Liveness çok sıkı veya açılış uzun | `startupProbe` ekle, eşikleri gevşet |
| `Terminating`'de kalan Pod | `describe pod`, node durumu | Node erişilemiyor, bağlı disk ayrılamıyor, finalizer | Node'u ve depolamayı kontrol et; son çare `--grace-period=0 --force` |
| Service'e istek: `Connection refused` | `get endpointslice` | Hazır Pod yok veya selector Pod label'larıyla eşleşmiyor | Selector ve label'ı eşle, readiness'i düzelt |
| Service'e istek: zaman aşımı | `targetPort`, uygulamanın dinlediği port | `targetPort` yanlış, uygulama `127.0.0.1`'de dinliyor | `targetPort`'u düzelt, uygulamayı `0.0.0.0`'da dinlet |
| DNS adı çözülmüyor (`bad address`) | `nslookup <svc>.<ns>.svc.cluster.local` | Farklı namespace'ten kısa ad kullanıldı, Service yok, CoreDNS sorunu | `<svc>.<ns>` biçimini kullan; `kubectl get pods -n kube-system -l k8s-app=kube-dns` |
| Ingress/Gateway `404` | `get ingress` / `get httproute`, `Host` başlığı | Alan adı kuralla eşleşmiyor, yanlış `ingressClassName`, controller yok | `curl -H "Host: ..."` ile dene, sınıf adını ve controller Pod'unu kontrol et |
| Ingress/Gateway `502` / `503` | Hedef Service'in EndpointSlice'ı | Arka uçta hazır Pod yok, port yanlış | Service ve Pod'ları kontrol et |
| PVC `Pending` | `describe pvc` | StorageClass yok, `WaitForFirstConsumer` (Pod bekliyor), statik PV ile boyut/erişim modu uyumsuz | Pod'u oluştur, StorageClass adını ve PV özelliklerini kontrol et |
| Node `NotReady` | `describe node` → Conditions | Kubelet durdu, disk veya bellek baskısı, ağ eklentisi | `docker exec <node> journalctl -u kubelet`, node kaynaklarını kontrol et |
| Deployment `READY 3/5`, hata görünmüyor | `describe rs -l app=<app>` | ResourceQuota aşıldı, admission reddi | Kota ve LimitRange'i kontrol et |
| `Forbidden` (403) | `kubectl auth can-i ... --as=...` | RBAC izni yok | Role ve RoleBinding'i kontrol et |
| `violates PodSecurity` | Hata mesajındaki alan listesi | Namespace `restricted` ve Pod securityContext eksik | `runAsNonRoot`, `allowPrivilegeEscalation: false`, `capabilities.drop: ["ALL"]`, `seccompProfile` |

### Kind'e özgü durumlar

| Belirti | Neden | Çözüm |
|---|---|---|
| Cluster oluşturulurken `too many open files` veya node'lar kararsız | Kernel inotify limitleri düşük | `install-prerequisites.sh` çalıştırın (limitleri `/etc/sysctl.d/99-kind.conf` ile artırır) |
| `kind create` sırasında `port is already allocated` | Host portu başka bir uygulamada | `ss -ltnp \| grep <port>` ile bulun, durdurun veya `kind-cluster.yaml`'daki portu değiştirin |
| Pod'lar imaj çekemiyor, host'ta `docker pull` çalışıyor | Container'ların internet erişimi yok (ör. `net.ipv4.ip_forward=0`) | `sysctl net.ipv4.ip_forward` değeri `1` olmalı; Docker servisi açılışta bunu ayarlar |
| Kubeconfig kayboldu | `~/.kube/config` silindi | `kind get kubeconfig --name k8s-labs > ~/.kube/config` |
| NodePort'a sunucudan erişilemiyor | Port `kind-cluster.yaml`'da eşlenmemiş | Eşlenen portlar: 30086-30088; diğer portlar için `port-forward` kullanın |
