source "proxmox-iso" "base" {
  proxmox_url               = "${var.proxmox_api_url}"
  username                  = "${var.proxmox_api_token_id}"
  token                     = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify  = true

  node                      = "proxmox"
  vm_id                     = "110"
  vm_name                   = "debian"
  template_description      = "debian"

  iso_file                  = "local:iso/debian-13.4.0-amd64-netinst.iso"
  iso_storage_pool          = "local"
  unmount_iso               = true
  qemu_agent                = true

  scsi_controller           = "virtio-scsi-pci"

  cores                     = "2"
  sockets                   = "1"
  memory                    = "2048"

  cloud_init                = true
  cloud_init_storage_pool   = "local-lvm"

  vga {
    type                    = "virtio"
  }

  disks {
    disk_size               = "20G"
    format                  = "raw"
    storage_pool            = "local-lvm"
    type                    = "virtio"
  }

  network_adapters {
    model                   = "virtio"
    bridge                  = "vmbr0"
    firewall                = "false"
  }

 boot_wait = "5s"
  boot_command = [
    "<esc><wait>",
    "auto priority=critical preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
    "<enter>"
  ]

  http_directory = "http"
  http_bind_address = "192.168.0.162"

  ssh_username              = "${var.ssh_username}"
  ssh_password              = "${var.ssh_password}"

  ssh_timeout               = "30m"
  ssh_pty                   = true
  ssh_handshake_attempts    = 15
}

build {

  name    = "debian"
  sources = [
      "proxmox-iso.base"
  ]

  provisioner "shell" {
      inline = [
          "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
          "sudo rm /etc/ssh/ssh_host_*",
          "sudo truncate -s 0 /etc/machine-id",
          "sudo apt -y autoremove --purge",
          "sudo apt -y clean",
          "sudo apt -y autoclean",
          "sudo cloud-init clean",
          "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
          "sudo rm -f /etc/netplan/00-installer-config.yaml",
          "sudo sync"
      ]
  }
}