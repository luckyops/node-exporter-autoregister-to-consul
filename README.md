# node-exporter-autoregister-to-consul


### Install consul
```bash
helm install consul stable/consul -n=consul
```
### Install note-exporter
```bash
git clone https://github.com/luckyops/node-exporter-autoregister-to-consul.git
cd node-exporter-autoregister-to-consul
helm install node-exporter -f ./prometheus-node-exporter/values.yaml ./prometheus-node-exporter -n=consul
```

### 转发端口进行访问测试
```bash
kubectl port-forward consul-0 8500:8500 -n=consul
```

### 查看集群内的dns是怎么搞的
```bash
kubectl run curl --image=radial/busyboxplus:curl -n=consul -i --tty
kubectl run dig  --image=tutum/dnsutils:latest -n=consul -i --tty
dig consul.consul.svc.cluster.local
```
###  删除curl测试pods,deployments
```bash
kubectl delete deployments.apps curl -n=consul
```
###  consul删除service
```bash
consul services deregister -id=node_exporter
```

#### consul有关于服务失效后自动清理的讨论
https://github.com/hashicorp/consul/issues/1188
#### A simple service clean tool for Consul.
https://github.com/Gozap/cclean


#### exporter的yaml新增了几个env
```bash
          - name: MY_POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: MY_POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: MY_POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
```

#### Q&A:
1、helm安装consul到consul 的k8s集群
helm install consul stable/consul -n=consul
重新安装出现错误
```
Error: cannot re-use a name that is still in use
```
原因是因为secret在原namespace里面没有被删除干净
执行
```
kubectl -n consul delete secret -lname=consul`
kubectl -n consul delete po,svc --all
```


2、我在使用以busybox为基础的镜像，curl访问k8s集群内的某地址，通过k8s的内置dns返回结果，同环境的其他镜像可以返回相应ip地址，所以判定k8s的dns没问题，curl报错
```bash
/ $ curl -vvvvvv consul.consul.svc.cluster.local
* getaddrinfo(3) failed for consul.consul.svc.cluster.local:80
* Couldn't resolve host 'consul.consul.svc.cluster.local'
* Closing connection 0
curl: (6) Couldn't resolve host 'consul.consul.svc.cluster.local'
```
分析原因为：

这个busybox用的网络是hostNetwork: true, 需要配置 dnsPolicy: ClusterFirstWithHostNet 才能将容器的dns指向到k8s集群的dns,要不然会使用容器所在宿主机的/etc/resolv.conf文件下的配置


最后解决方案为：

修改helm包的value.yaml
```bash
hostNetwork: false
```
