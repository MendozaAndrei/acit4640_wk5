# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  required_plugins {
    amazon = {
      version = ">= 1.5"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "debian" {
  ami_name      = "web-nginx-aws"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "debian-*-amd64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["136693071363"]
  }
  ssh_username = "admin"
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "web-nginx"
  sources = [
    # COMPLETE ME Use the source defined above
    "source.amazon-ebs.debian"
  ]
  
  # https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/provisioner
  provisioner "shell" {
    inline = [
      "echo creating directories",
      # create directories for website content and a temp location for files
      "sudo mkdir -p /web/html /tmp/web",
      # try to set ownership so the default user can manage files; don't fail the build if group doesn't exist
      "sudo chown -R admin:admin /web /tmp/web || true"
    ]
  }

  provisioner "file" {
    source      = "files/index.html"
    destination = "/tmp/web/index.html"
  }

  provisioner "file" {
    source      = "files/nginx.conf"
    destination = "/tmp/web/nginx.conf"
  }

  # upload the helper scripts and run them to install and configure nginx
  provisioner "file" {
    source      = "scripts/install-nginx"
    destination = "/tmp/install-nginx"
  }

  provisioner "file" {
    source      = "scripts/setup-nginx"
    destination = "/tmp/setup-nginx"
  }

  provisioner "shell" {
    inline = [
      "sudo chmod +x /tmp/install-nginx /tmp/setup-nginx || true",
      "sudo /tmp/install-nginx",
      "sudo /tmp/setup-nginx",
      # copy website content into the configured web root and set ownership
      "sudo mkdir -p /web/html",
      "sudo cp /tmp/web/index.html /web/html/index.html",
      "sudo chown -R admin:admin /web/html || true",
      # ensure nginx is running and pick up the configuration
      "sudo systemctl restart nginx || sudo service nginx restart || true"
    ]
  }
}

