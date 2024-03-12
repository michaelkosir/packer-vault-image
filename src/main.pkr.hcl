source "amazon-ebs" "vault" {
  ami_name        = "packer-${var.vault}-${formatdate("YYYY.MM.DD", timestamp())}"
  ami_description = "HashiCorp Vault - Amazon Linux 2023 - Minimal"

  instance_type = "t2.micro"
  ssh_username  = "ec2-user"
  deprecate_at  = timeadd(timestamp(), "8760h") # now + 1yr
  
  source_ami_filter {
    owners      = ["amazon"]
    most_recent = true

    filters = {
      name                = "al2023-ami-minimal-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
  }

  tags = {
    Platform      = "Amazon Linux"
    OS            = "Amazon Linux 2023 Minimal"
    Vault_Version = var.vault
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Extra         = "{{ .SourceAMITags.TagName }}"
  }
}

build {
  sources = ["source.amazon-ebs.vault"]

  provisioner "file" {
    source      = "../rpm/"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline = [
      # cloud-init wait
      "sudo cloud-init status --wait",

      # rpm and pgp
      "sudo mv /tmp/RPM-GPG-KEY-hashicorp /etc/pki/rpm-gpg/",
      "sudo mv /tmp/hashicorp.repo /etc/yum.repos.d/",
      "sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-hashicorp",

      # install
      "sudo yum install -y ${var.vault}",

      # setup
      "sudo chown -R root:vault /etc/vault.d/",
      "sudo chmod 640 /etc/vault.d/*",
      "sudo rm /opt/vault/tls/*"

      # cloud-init cleanup
      "sudo cloud-init clean",
    ]
  }
}