# Kubeadm the final version
- ansible-playbook -i inventory configure-prerequisites.yaml
- ansible-playbook -i inventory install-containerd.yaml
- ansible-playbook -i inventory kubeadm.yaml
- ansible-playbook -i inventory kubernetes.yaml


