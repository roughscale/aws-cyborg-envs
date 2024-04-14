data "template_cloudinit_config" "external0" {
  gzip          = true
  base64_encode = true

  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/external_cloudinit.tmpl",{
        hostname                     = "External0"
    })
  }
}

data "template_cloudinit_config" "internal0" {
  gzip          = true
  base64_encode = true

  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/internal_linux_cloudinit.tmpl",{
        hostname                     = "Internal0"
        pi_password                  = var.pi_password
        vagrant_password             = var.vagrant_password
    })
  }
}

data "template_cloudinit_config" "internal1" {
  gzip          = true
  base64_encode = true

  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/internal_win_cloudinit.tmpl",{
        hostname                     = "Internal1"
    })
  }
}

data "template_cloudinit_config" "internal2" {
  gzip          = true
  base64_encode = true

  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/internal_linux_cloudinit.tmpl",{
        hostname                     = "Internal2"
        pi_password                  = var.pi_password
        vagrant_password             = var.vagrant_password
    })
  }
}

