
#!/usr/bin/env bash 
set -ex 
 
function delete() { 
    multipass delete --purge $1 
} 
 
function init_docker() { 
    NAME=$1 
    multipass exec $NAME -- sh -c "sudo rm -f /etc/apt/sources.list.d/docker.list" 
    multipass exec $NAME -- sh -c "sudo rm -f /etc/apt/keyrings/docker.gpg" 
    # multipass exec $NAME -- sh -c "sudo apt-get remove docker docker-engine docker.io containerd runc" 
    multipass exec $NAME -- sh -c "sudo apt-get update" 
    multipass exec $NAME -- sh -c "sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common" 
    multipass exec $NAME -- sh -c "sudo apt-get install \ 
                                    ca-certificates \ 
                                    curl \ 
                                    gnupg \ 
                                    lsb-release" 
    multipass exec $NAME -- sh -c "sudo mkdir -p /etc/apt/keyrings" 
    multipass exec $NAME -- sh -c "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg" 
    multipass exec $NAME -- sh -c "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null" 
    multipass exec $NAME -- sh -c "sleep 1" 
    multipass exec $NAME -- sh -c "sudo apt-get update" 
    multipass exec $NAME -- sh -c "sudo chmod a+r /etc/apt/keyrings/docker.gpg" 
    multipass exec $NAME -- sh -c "sudo apt-get update" 
    multipass exec $NAME -- sh -c "sudo apt-get install -y docker-ce" 
} 
 
function init_k8s() { 
    NAME=$1 
    multipass exec $NAME -- sh -c "sudo apt-get update" 
    multipass exec $NAME -- sh -c "sudo apt-get install -y apt-transport-https ca-certificates curl" 
    multipass exec $NAME -- sh -c "sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg" 
    multipass exec $NAME -- sh -c "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list" 
    multipass exec $NAME -- sh -c "sudo apt-get update" 
    multipass exec $NAME -- sh -c "sudo apt-get install -y kubelet kubeadm kubectl" 
    multipass exec $NAME -- sh -c "sudo apt-mark hold kubelet kubeadm kubectl" 
} 
 
function install() { 
    NAME=$1 
    multipass launch --name $NAME --mem 2G 
    init_docker $1 
    init_k8s $1 
} 
 
COMMAND=$1 
SUB_COMMAND=$2 
 
case $COMMAND in 
"del") 
    delete $SUB_COMMAND 
    ;; 
"init") 
    install $SUB_COMMAND 
    ;; 
"init_docker") 
    init_docker $SUB_COMMAND 
    ;; 
"init_k8s") 
    init_k8s $SUB_COMMAND 
    ;; 
"list") 
    multipass $* 
esac 