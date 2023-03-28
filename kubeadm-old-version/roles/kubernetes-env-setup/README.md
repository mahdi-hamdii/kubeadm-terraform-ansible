## Prepare the environments
The following Steps must be applied to each node (both master nodes and worker nodes)
#### Disable the Swap Memory
The Kubernetes requires that you disable the swap memory in the host system because the kubernetes scheduler determines the best available node on which to deploy newly created pods. If memory swapping is allowed to occur on a host system, this can lead to performance and stability issues within Kubernetes

You can disable the swap memory by deleting or commenting the swap entry in `/etc/fstab` manually or using the `sed` command

`justk8s@justk8s-master$ sudo swapoff -a && sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab`

This command disbales the swap memory and comments out the swap entry in `/etc/fstab` 

#### Configure or Disable the firewall
When running Kubernetes in an environment with strict network boundaries, such as on-premises datacenter with physical network firewalls or Virtual Networks in Public Cloud, it is useful to be aware of the ports and protocols used by Kubernetes components.

The ports used by Master Node:

| Protocol  | Direction     | Port Range    |  Purpose 
| -------   | ------------- | ------------- | -------
| TCP       | Inbound       | 6443          | Kubernetes API server
| TCP       | Inbound       | 2379-2380     | etcd server client API
| TCP       | Inbound       | 10250         | Kubelet API
| TCP       | Inbound       | 10259         | kube-scheduler
| TCP       | Inbound       | 10257         | kube-controller-manager

The ports used by Worker Nodes: 

| Protocol  | Direction     | Port Range    |  Purpose 
| -------   | ------------- | ------------- | -------
| TCP       | Inbound       | 10250         | Kubelet API
| TCP       | Inbound       | 30000-32767   | NodePort Services

You can either disable the firewall or allow the ports on each node.
###### Method 1: Add firewall rules to allow the ports used by the Kubernetes nodes
Allow the ports used by the master node:
```bash
justk8s@justk8s-master:~$ sudo ufw allow 6443/tcp
justk8s@justk8s-master:~$ sudo ufw allow 2379:2380/tcp
justk8s@justk8s-master:~$ sudo ufw allow 10250/tcp
justk8s@justk8s-master:~$ sudo ufw allow 10259/tcp
justk8s@justk8s-master:~$ sudo ufw allow 10257/tcp
````
Allow the ports used by the worker nodes:
```bash
justk8s@justk8s-worker1:~$ sudo ufw allow 10250/tcp
justk8s@justk8s-worker1:~$ sudo ufw allow 30000:32767/tcp
```
###### Method 2: Disable the firewall
``` bash
justk8s@justk8s-master:~$ sudo ufw status
Status: active

justk8s@justk8s-master:~$ sudo ufw disable
Firewall stopped and disabled on system startup

justk8s@justk8s-master:~$ sudo ufw status
Status: inactive
```
#### Installing Docker Engine
Kubernetes requires you to install a container runtime to work correctly.There are many available options like containerd, CRI-O, Docker etc

By default, Kubernetes uses the Container Runtime Interface (CRI) to interface with your chosen container runtime.If you don't specify a runtime, kubeadm automatically tries to detect an installed container runtime by scanning through a list of known endpoints.

You must install the Docker Engine on each node! 

##### 1- Set up the repository 
```bash
justk8s@justk8s-master:~$ sudo apt update
justk8s@justk8s-master:~$ sudo apt install ca-certificates curl gnupg lsb-release
```
##### 2- Add Docker's official GPG key
```bash
justk8s@justk8s-master:~$ sudo mkdir -p /etc/apt/keyrings
justk8s@justk8s-master:~$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
##### 3- Add the stable repository using the following command:
```bash
justk8s@justk8s-master:~$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
##### 4- Install the docker container
```bash
justk8s@justk8s-master:~$ sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io -y
``` 

##### 5- Make sure that the docker will work on system startup
```bash
justk8s@justk8s-master:~$ sudo systemctl enable --now docker 
```
##### 6- Configuring Cgroup Driver:  
The Cgroup Driver must be configured to let the kubelet process work correctly
```bash
justk8s@justk8s-master:~$ cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
```
##### 7- Restart the docker service to make sure the new configuration is applied
```bash
justk8s@justk8s-master:~$ sudo systemctl daemon-reload && sudo systemctl restart docker
```
#### Installing kubernetes (kubeadm, kubelet, and kubectl):

``` bash
# Install the following dependency required by Kubernetes on each node
justk8s@justk8s-master:~$ sudo apt install apt-transport-https

# Download the Google Cloud public signing key:
justk8s@justk8s-master:~$ sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository:
justk8s@justk8s-master:~$ echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update the apt package index and install kubeadm, kubelet, and kubeclt
justk8s@justk8s-master:~$ sudo apt update && sudo apt install -y kubelet=1.23.1-00 kubectl=1.23.1-00 kubeadm=1.23.1-00
```
