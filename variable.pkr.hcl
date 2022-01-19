# Azure variables
variable "az_login" {
  type = map(string)
  default = {
    client_id       = null
    client_secret   = null
    subscription_id = null
    tenant_id       = null
  }
}

# When creating a managed image the following additional options are (required):
variable "managed_image_name" {
  type        = string
  description = "Specify the managed image name where the result of the Packer build will be saved. The image name must not exist ahead of time, and will not be overwritten. If this value is set, the value managed_image_resource_group_name must also be set"
  default     = "rhel-7"
}
variable "managed_image_resource_group_name" {
  type        = string
  description = "Specify the managed image resource group name where the result of the Packer build will be saved. The resource group must already exist. If this value is set, the value managed_image_name must also be set."
  default     = ""
}

# General variables
variable "os_type" {
  type        = string
  description = "The OS type to use as the base image"
  default     = "Linux"
}
variable "vm_size" {
  type        = string
  description = "The instance type to use while building the managed instance"
  default     = "Standard_D2_v3"
}
variable "location" {
  type        = string
  description = "The location to create the Packer image in"
  default     = "East US 2"
}
variable "os_disk_size_gb" {
  type        = string
  description = "The Size of the VM"
  default     = "50"
}

variable "docker_version" {
  type        = string
  description = "Docker Version to install on the kubernetes nodes"
  default     = "docker-ce-20.10.5-3.el7.x86_64"
}

variable "admin_username" {
  type        = string
  description = "Azure user for kubernetes nodes"
  default     = "platformsadmin"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group under which the final artifact will be stored (required)"
  default     = "US_NON_PROD_UE2_SANDBOX_k8s"
}

variable "storage_account" {
  type        = string
  description = "Storage account where images will be maintained."
  default     = "use2k8ssandstorage"
}

variable "network_info" {
  type = map(string)
  default = {
    virtual_network_resource_group_name = "US_NONPROD_DEVOPS_EUS2_VNET_RG"
    virtual_network_name                = "US_NONPROD_DEVOPS_EUS2_VNET"
    virtual_network_subnet_name         = "k8Subnet"
  }
}

variable "shared_image_gallery" {
  type = map(string)
  default = {
    subscription    = "US-NONPROD-DEVOPS"
    resource_group  = "US_NON_PROD_UE2_SANDBOX_k8s"
    gallery_name    = "use2k8ssandtf"
    image_name      = "rhel-7"
    image_version   = "0.0.0"
  }
}

variable "azure_tags" {
  type = map(string)
  default = {
    environment = "NONProd"
    Application = "Sandbox-Rancher"
    Compliance  = "N/A"
    ValueStream = "Shared Service: Strategy & Architecture"
  }
}

variable "shared_image_gallery_destination" {
  description = "The name of the Shared Image Gallery under which the managed image will be published as Shared Gallery Image version."
  default = {
    subscription         = "US-NONPROD-DEVOPS"
    resource_group       = "US_NON_PROD_UE2_SANDBOX_k8s"
    gallery_name         = "use2k8ssandtf"
    image_name           = "rhel-7"
    image_version        = "0.0.1"
    replication_regions  = ["eastus2"]
    storage_account_type = "Standard_LRS"
  }
}