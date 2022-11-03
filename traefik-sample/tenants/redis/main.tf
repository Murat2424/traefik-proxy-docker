variable "network"                {}
variable "port"                   {}
variable "tenant"                 {}
variable "IMAGE_NAME"             {}


resource "docker_service" "redis" {
    name     = "${var.tenant}"
    labels {
        label = "traefik.enable"
        value = "true"
    }
    labels {
        label = "traefik.tcp.routers.${var.tenant}.rule"
        value = "HostSNI(`*`)"
    }
    labels {
        label = "traefik.tcp.routers.${var.tenant}.entrypoints"
        value = "${var.tenant}"
    }
    labels {
        label = "traefik.tcp.services.${var.tenant}.loadbalancer.server.port"
        value = "${var.port}"
    }
    labels {
        label = "traefik.network"
        value = "${var.network}"
    }
#    labels {
#        label = "traefik.docker.lbswarm"
#        value = "true"
#    }
    task_spec {
        container_spec {
            image = "${var.IMAGE_NAME}"
                env = {       
                  ALLOW_EMPTY_PASSWORD = "yes"

                }
                mounts {
                  source  = "/opt/redis"
                  target  = "/bitnami/redis/data"
                  type    = "bind"
                }
                hostname = "${var.tenant}"
        }
      networks = ["${var.network}"]
    }
      mode {
    replicated {
      replicas = 2
    }
  }
}


