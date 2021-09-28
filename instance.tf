#get the data from the app VM WS
data "terraform_remote_state" "appvm" {
  backend = "remote"
  config = {
    organization = var.org
    workspaces = {
      name = var.appvmwsname
    }
  }
}

data "terraform_remote_state" "global" {
  backend = "remote"
  config = {
    organization = var.org
    workspaces = {
      name = var.globalwsname
    }
  }
}


variable "org" {
  type = string
}

resource "null_resource" "vm_node_init" {
  triggers = {
        trig = var.trigcount
  }

  provisioner "file" {
    source = "scripts/"
    destination = "/tmp"
    connection {
      type = "ssh"
      host = "${local.appvmip}" 
      user = "root"
      password = "${local.root_password}"
      port = "22"
      agent = false
    }
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/appdremove.sh",
        "/tmp/appdremove.sh"
    ]
    connection {
      type = "ssh"
      host = "${local.appvmip}"
      user = "root"
      password = "${local.root_password}"
      port = "22"
      agent = false
    }
  }

}

locals {
  appvmip = data.terraform_remote_state.appvm.outputs.vm_ip[0]
  root_password = yamldecode(data.terraform_remote_state.global.outputs.root_password)
}

