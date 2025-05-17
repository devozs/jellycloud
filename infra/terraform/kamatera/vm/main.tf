terraform {
  required_providers {
    kamatera = {
      source = "Kamatera/kamatera"
    }
    random = {
      source = "hashicorp/random"
    }

  }
}

provider "kamatera" {
}

resource "random_id" "network_suffix" {
  byte_length = 2
}

resource "random_id" "other_suffix" {
  byte_length = 2
}

# define the data center we will create the server and all related resources in
# see the section below "Listing available data centers" for more details
data "kamatera_datacenter" "toronto" {
  country = "Israel"
  name = "Haifa"
}

# define the server image we will create the server with
# see the section below "Listing available public images" for more details
# also see "Using a private image" if you want to use a private image you created yourself
data "kamatera_image" "ubuntu_1804" {
  datacenter_id = data.kamatera_datacenter.toronto.id
  os = "Ubuntu"
  code = "22.04 64bit"
}

# create a private network to use with the server
# resource "kamatera_network" "my_private_network" {
#   # the network must be in the same datacenter as the server
#   datacenter_id = data.kamatera_datacenter.toronto.id
#   name = "my-private-network-${random_id.network_suffix.hex}"
  
#   # define multiple subnets to use in this network
#   # this subnet shows full available subnet configurations
#   # the subnet below shows a more minimal example
#   subnet {
#     ip = "172.16.0.0"
#     bit = 23
#     description = "my first subnet"
#     dns1 = "1.2.3.4"
#     dns2 = "5.6.7.8"
#     gateway = "172.16.0.100"
#   }
  
#   # a subnet with just the minimal required configuration
#   subnet {
#     ip = "192.168.0.0"
#     bit = 23
#   }
# }

# create another private network, to show how to connect 2 networks to the server
resource "kamatera_network" "my_other_private_network" {
  datacenter_id = data.kamatera_datacenter.toronto.id
  name = "other-network-${random_id.other_suffix.hex}"
  
  subnet {
    ip = "10.0.0.0"
    bit = 23
  }
}

# this defines the server resource with most configuration options
resource "kamatera_server" "my_server" {
  name = "devozs01"
  datacenter_id = data.kamatera_datacenter.toronto.id
  cpu_type = "B"
  cpu_cores = 2
  ram_mb = 2048
  disk_sizes_gb = [15, 20]
  billing_cycle = "monthly"
  image_id = data.kamatera_image.ubuntu_1804.id
  password = "Aa123456789!"
#   startup_script = "echo hello from startup script > /var/hello.txt"
  
  # this attaches a public network to the server
  # which will also allocate a public IP
  network {
    name = "wan"
  }
  
  # # attach a private network with a specified ip
  # network {
  #   # note that the network full_name attribute needs to be used
  #   # this value is populated with the full name of the network which may be different then 
  #   # the given network name
  #   name = kamatera_network.my_private_network.full_name
  #   ip = "192.168.0.10"
  # }
  
  # # attache a private network with auto-allocated ip from the available ips in that network
  # network {
  #   name = kamatera_network.my_other_private_network.full_name
  # }
}