variable "network"                  {}
variable "tenant"                   {}
variable "IMAGE_NAME"               {}


resource "docker_service" "traefik" {
    name     = "${var.tenant}"

    task_spec {
        container_spec {
            image = "${var.IMAGE_NAME}"
            command = ["traefik"]
            args = [
		            "--api.insecure=true",
		            "--providers.docker=true",
		            "--providers.docker.swarmMode=true",
		            "--providers.docker.watch=true",
		            "--providers.docker.endpoint=unix:///var/run/docker.sock",
		            "--providers.docker.network=${var.network}",
		            "--providers.docker.exposedbydefault=false",
                "--log.level=ERROR",
                "--entrypoints.redis.address=:8086",
                ]
            mounts {
                    source      = "/var/run/docker.sock"
                    target      = "/var/run/docker.sock"
                    type        = "bind"
                }

                hostname = "${var.tenant}"

        }
  

        restart_policy = {
        condition    = "on-failure"
        delay        = "3s"
        max_attempts = 0
        window       = "10s"
    }

      networks = ["${var.network}"]

    }
      mode {
    replicated {
      replicas = "1"
    }
  }
        endpoint_spec {
      ports {
        publish_mode = "host"
        name = "web-ui"
        target_port = "8080"
        published_port = "8080"
        
      }
      ports {
        publish_mode = "host"
        name = "redis"
        target_port = "6379"
        published_port = "6379"
        
      }
    }

    
         
}