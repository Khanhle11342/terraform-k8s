resource "null_resource" "deploy_app" {

  depends_on = [
    null_resource.install_minikube
  ]

  connection {

    type = "ssh"

    user = "ubuntu"

    host = aws_instance.k8s.public_ip

    private_key = tls_private_key.ssh.private_key_pem

  }

  provisioner "file" {

    source = "manifests"

    destination = "/home/ubuntu"

  }

  provisioner "remote-exec" {

    inline = [

      "kubectl apply -f /home/ubuntu/manifests/deployment.yaml",

      "kubectl apply -f /home/ubuntu/manifests/service.yaml"

    ]

  }

}
