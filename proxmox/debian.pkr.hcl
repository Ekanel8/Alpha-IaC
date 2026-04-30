packer {
    required_plugins {
        virtualbox = {
          version = "~> 1"
          source  = "github.com/hashicorp/virtualbox"
        }
    }
}

variable "image_version" { default = "2026.04" }
variable "vm_name" { default = "Debian-template" }
variable "iso_url" { default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.4.0-amd64-netinst.iso" }
variable "iso_checksum" { default = "sha256:0b813535dd76f2ea96eff908c65e8521512c92a0631fd41c95756ffd7d4896dc" }

variable "ssh_username" { default = "packer" }
variable "ssh_password" { default = "packer" }

variable "disk_size" { default = "10000" }
variable "vram"      { default = "16" }
variable "cpus"      { default = "2" }
variable "memory"    { default = "2048" }

source "virtualbox-iso" "base" {
  guest_os_type      = "Debian_64"
  headless           = true
  iso_url            = var.iso_url
  iso_checksum       = var.iso_checksum
  disk_size          = var.disk_size
  http_directory     = "http"
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "30m"

  output_directory  = "output/${var.vm_name}-${var.image_version}"
  shutdown_command   = "sudo systemctl poweroff"

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--memory", "${var.memory}"],
    ["modifyvm", "{{.Name}}", "--cpus", "${var.cpus}"],
    ["modifyvm", "{{.Name}}", "--vram", "${var.vram}"],
  ]

  boot_wait = "5s"
  boot_command = [
    "<esc><wait>",
    "auto priority=critical preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
    "<enter>"
  ]
}

build {
  name = "Debian_template"
  sources = ["source.virtualbox-iso.base"]
  provisioner "shell" {
    inline = [
      "sudo apt-get -y dist-upgrade",
      "sudo apt-get -y autoremove --purge",
      "sudo apt-get clean"
    ]
  }
  provisioner "shell" {
    inline = [
      "sudo rm -f /etc/ssh/ssh_host_*",
      "sudo truncate -s0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id",
      "sudo ln -s /etc/machine-id /var/lib/dbus/machine-id || true",
      "sudo find /var/log -type f -exec truncate -s0 {} +",
      "sudo rm -rf /tmp/* /var/tmp/*"
    ]
  }
}
