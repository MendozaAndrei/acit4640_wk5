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
    "source.amazon-ebs.debian"
  ]
  
  # https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/provisioner
  provisioner "shell" {
    inline = [
      "echo creating directories",
      # create directories for website content
      "sudo mkdir -p /web/html",
  # set ownership for web files
  "sudo chown -R admin:admin /web"
    ]
  }

  # run the installer
  provisioner "shell" {
    script = "scripts/install-nginx"
  }

  #Upload files
  provisioner "file" {
    source      = "files/index.html"
    destination = "/web/html/index.html"
  }

  #Temporary location for nginx.conf
  provisioner "file" {
    source      = "files/nginx.conf"
    destination = "/home/admin/nginx.conf"
  }

  # Move nginx config into place and restart nginx
  provisioner "shell" {
    inline = [
      # move nginx.conf into place and enable the site
      "sudo mv /home/admin/nginx.conf /etc/nginx/sites-available/nginx.conf",
      "sudo rm -f /etc/nginx/sites-enabled/*",
      "sudo ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/",

      # ensure site root exists and index.html is in place (file provisioner wrote /web/html/index.html)
      "sudo chown -R admin:admin /web/html",

      #Restart 
      "sudo systemctl restart nginx"
    ]
  }
}

