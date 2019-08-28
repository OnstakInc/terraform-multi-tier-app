provider "vsphere" {
  user                 = "${var.vsphere_user}"
  password             = "${var.vsphere_password}"
  vsphere_server       = "${var.vsphere_server}"
  allow_unverified_ssl = true
}

# The Data sections are about determining where the virtual machine will be placed. 
# Here we are naming the vSphere DC, the cluster, datastore, virtual network and the template
# name. These are called upon later when provisioning the VM resource

data "vsphere_datacenter" "dc" {
  name = "Milpitas-DC"
}

data "vsphere_datastore" "datastore" {
  name          = "HXDatastore-01"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "HX-Cluster-01"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network_web" {
  name          = "Ansible-ACI-Integrations|Ansible-ACI-AP|LB-EPG"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network_app" {
  name          = "Ansible-ACI-Integrations|Ansible-ACI-AP|APP-EPG"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network_db" {
  name          = "Ansible-ACI-Integrations|Ansible-ACI-AP|DB-EPG"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "lb_template" {
  name          = "tec-lb-template"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "app_template" {
  name          = "tec-app-template"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "db_template" {
  name          = "tec-db-template"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# The Resource section creates the virtual machine, in this case 
# from a template
# <Initialize Virtual Machine Deployments>
resource "vsphere_virtual_machine" "lb_server01" {
  name             = "tec-lb-server-managed"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus  = 1
  memory    = 1024
  guest_id  = "${data.vsphere_virtual_machine.lb_template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.lb_template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network_web.id}"
    adapter_type = "${data.vsphere_virtual_machine.lb_template.network_interface_types[0]}"
  }

  disk {
    label            = "tec_lb_server_disk0"
    size             = "${data.vsphere_virtual_machine.lb_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.lb_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.lb_template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.lb_template.id}"

    customize {
      linux_options {
        host_name = "tec-lb-server-managed"
        domain    = "onstak.local"
      }

      network_interface {
        ipv4_address    = "172.16.164.10"
        ipv4_netmask    = 24
      }
      
      dns_server_list = ["10.3.1.102"]

      ipv4_gateway = "172.16.164.254"
    }
  }
}

resource "vsphere_virtual_machine" "app_server01" {
  name             = "tec-app-orders-server-managed"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus  = 1
  memory    = 1024
  guest_id  = "${data.vsphere_virtual_machine.app_template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.app_template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network_app.id}"
    adapter_type = "${data.vsphere_virtual_machine.app_template.network_interface_types[0]}"
  }

  disk {
    label            = "tec_app_server_disk0"
    size             = "${data.vsphere_virtual_machine.app_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.app_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.app_template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.app_template.id}"

    customize {
      linux_options {
        host_name = "tec-app-orders-server-managed"
        domain    = "onstak.local"
      }

      network_interface {
        ipv4_address    = "172.16.165.11"
        ipv4_netmask    = 24
      }
      
      dns_server_list = ["10.3.1.102"]

      ipv4_gateway = "172.16.165.254"
    }
  }
}

resource "vsphere_virtual_machine" "app_server02" {
  name             = "tec-app-shop-server-managed"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus  = 1
  memory    = 1024
  guest_id  = "${data.vsphere_virtual_machine.app_template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.app_template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network_app.id}"
    adapter_type = "${data.vsphere_virtual_machine.app_template.network_interface_types[0]}"
  }

  disk {
    label            = "tec_app_server_disk0"
    size             = "${data.vsphere_virtual_machine.app_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.app_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.app_template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.app_template.id}"

    customize {
      linux_options {
        host_name = "tec-app-shop-server-managed"
        domain    = "onstak.local"
      }

      network_interface {
        ipv4_address    = "172.16.165.12"
        ipv4_netmask    = 24
      }
      
      dns_server_list = ["10.3.1.102"]

      ipv4_gateway = "172.16.165.254"
    }
  }
}

resource "vsphere_virtual_machine" "app_server03" {
  name             = "tec-app-cart-server-managed"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus  = 1
  memory    = 1024
  guest_id  = "${data.vsphere_virtual_machine.app_template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.app_template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network_app.id}"
    adapter_type = "${data.vsphere_virtual_machine.app_template.network_interface_types[0]}"
  }

  disk {
    label            = "tec_app_server_disk0"
    size             = "${data.vsphere_virtual_machine.app_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.app_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.app_template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.app_template.id}"

    customize {
      linux_options {
        host_name = "tec-app-cart-server-managed"
        domain    = "onstak.local"
      }

      network_interface {
        ipv4_address    = "172.16.165.13"
        ipv4_netmask    = 24
      }
      
      dns_server_list = ["10.3.1.102"]

      ipv4_gateway = "172.16.165.254"
    }
  }
}

resource "vsphere_virtual_machine" "db_server01" {
  name             = "tec-db-server-managed"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus  = 1
  memory    = 1024
  guest_id  = "${data.vsphere_virtual_machine.db_template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.db_template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network_db.id}"
    adapter_type = "${data.vsphere_virtual_machine.db_template.network_interface_types[0]}"
  }

  disk {
    label            = "tec_db_server_disk0"
    size             = "${data.vsphere_virtual_machine.db_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.db_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.db_template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.db_template.id}"

    customize {
      linux_options {
        host_name = "tec-db-server-managed"
        domain    = "onstak.local"
      }

      network_interface {
        ipv4_address    = "172.16.166.10"
        ipv4_netmask    = 24
      }
      
      dns_server_list = ["10.3.1.102"]

      ipv4_gateway = "172.16.166.254"
    }
  }
}
