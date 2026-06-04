resource "null_resource" "install_minikube" {

  depends_on = [
    aws_instance.k8s
  ]

  connection {

    type = "ssh"

    user = "ubuntu"

    host = aws_instance.k8s.public_ip

    private_key = tls_private_key.ssh.private_key_pem

  }

  provisioner "file" {

    source = "scripts/install_minikube.sh"

    destination = "/tmp/install_minikube.sh"

  }

  provisioner "remote-exec" {

    inline = [

      "chmod +x /tmp/install_minikube.sh",

      "/tmp/install_minikube.sh"

    ]

  }

}
