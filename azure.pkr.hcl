packer {
  required_plugins {
    azure = {
      version = "1.0.2"
      source  = "github.com/hashicorp/azure"
    }
  }
}

source "azure-arm" "k8s" {
  # Login vars
  subscription_id = var.az_login.subscription_id
  client_id       = var.az_login.client_id
  client_secret   = var.az_login.client_secret
  tenant_id       = var.az_login.tenant_id

  managed_image_name                = var.managed_image_name
  managed_image_resource_group_name = var.shared_image_gallery.resource_group

  # Instance vars
  vm_size         = var.vm_size
  location        = var.location
  os_type         = var.os_type
  os_disk_size_gb = var.os_disk_size_gb

  # Network vars
  virtual_network_resource_group_name = var.network_info.virtual_network_resource_group_name
  virtual_network_name                = var.network_info.virtual_network_name
  virtual_network_subnet_name         = var.network_info.virtual_network_subnet_name

  shared_image_gallery {
    subscription   = var.az_login.subscription_id
    resource_group = var.shared_image_gallery.resource_group
    gallery_name   = var.shared_image_gallery.gallery_name
    image_name     = var.shared_image_gallery.image_name
    image_version  = var.shared_image_gallery.image_version
  }

  # Store image in gallery
  shared_image_gallery_destination {
    subscription         = var.az_login.subscription_id
    resource_group       = var.shared_image_gallery_destination.resource_group
    gallery_name         = var.shared_image_gallery_destination.gallery_name
    image_name           = var.shared_image_gallery_destination.image_name
    image_version        = var.shared_image_gallery_destination.image_version
    replication_regions  = var.shared_image_gallery_destination.replication_regions
    storage_account_type = var.shared_image_gallery_destination.storage_account_type
  }

  azure_tags = {
    environment = var.azure_tags.environment
    Application = var.azure_tags.Application
    Compliance  = var.azure_tags.Compliance
    ValueStream = var.azure_tags.ValueStream
  }
}

build {
  sources = ["source.azure-arm.k8s"]

# Update QA certificates
  provisioner "file" {
    source      = "./contrib/certs/ca_certs.pem"
    destination = "/tmp/ca_certs.pem"
  }

  provisioner "shell" {
    script = "./contrib/scripts/install_ansible.sh"
  }

  provisioner "ansible-local" {
    playbook_file = "./ansible/main.yml"

    extra_arguments = [
      "--extra-vars",
      "'packer_build=true docker_version=${var.docker_version} admin_username=${var.admin_username}' os_type=${var.managed_image_name}'",
    ]
  }
}