output "bastion_public_ip" {
  description = "Public IP address of the Bastion Host (srv-bst-01)"
  value       = oci_core_instance.srv_bst_01.public_ip
}

output "bastion_ssh" {
  description = "SSH connection command for the Bastion Host (srv-bst-01)"
  value       = "ssh opc@${oci_core_instance.srv_bst_01.public_ip}"
}

output "master_private_ip" {
  description = "Private IP address of the Master Node (srv-k8s-01)"
  value       = oci_core_instance.srv_k8s_01.create_vnic_details[0].private_ip
}

output "worker_private_ips" {
  description = "Private IP addresses of the Worker Nodes (srv-k8s-02, srv-k8s-03)"
  value       = oci_core_instance.srv_k8s_worker[*].create_vnic_details[0].private_ip
}

output "ssh_master_via_bastion" {
  description = "SSH ProxyJump connection command for the Private Master Node (srv-k8s-01)"
  value       = "ssh -J opc@${oci_core_instance.srv_bst_01.public_ip} opc@${oci_core_instance.srv_k8s_01.create_vnic_details[0].private_ip}"
}

output "ssh_workers_via_bastion" {
  description = "SSH ProxyJump connection commands for the Private Worker Nodes (srv-k8s-02, srv-k8s-03)"
  value = [
    for instance in oci_core_instance.srv_k8s_worker :
    "ssh -J opc@${oci_core_instance.srv_bst_01.public_ip} opc@${instance.create_vnic_details[0].private_ip}"
  ]
}

output "kubeadm_init_command" {
  description = "Command to initialize the cluster on the Master Node (srv-k8s-01)"
  value       = "sudo kubeadm init --apiserver-advertise-address=10.0.2.11 --pod-network-cidr=10.244.0.0/16"
}
