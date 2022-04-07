build {
  name = "ctp"
  sources = [
    "source.docker.ctp"
  ]
  provisioner "file" {
    sources = [
      "CTP-installer.jar", 
      "config-serveronly.xml",
      "Launcher.properties",
      "entrypoint.sh"
    ]
    destination = "/tmp/"
  }
  provisioner "shell" {
    inline = [
      "apt update",
      "mkdir -p /JavaPrograms/ && cd /JavaPrograms",
      "jar xf /tmp/CTP-installer.jar CTP",
      "mv /tmp/config-serveronly.xml /JavaPrograms/CTP/config.xml",
      "mv /tmp/Launcher.properties /JavaPrograms/CTP/",
      "rm -f /tmp/CTP-installer.jar"
    ]    
  }
  post-processors {
    post-processor "docker-tag" {
      repository = var.repo
      tags = var.tag
    }
    # post-processor "docker-push" {
    #   only = ["docker.ctp"]
    # }
  }
}
variable "repo" {
  type = string
}
variable "tag" {
  type = list(string)
}
source "docker" "ctp" {
  image = "openjdk:8u322-jdk-slim-bullseye"
  commit  = true
  changes = [
    "LABEL org.opencontainers.image.source https://github.com/australian-imaging-service/ctp-build",
    "USER root",
    "EXPOSE 1080 1443 25055",
    "WORKDIR /JavaPrograms/CTP",
    "ENTRYPOINT [\"/bin/bash\", \"/tmp/entrypoint.sh\"]"
  ]
}