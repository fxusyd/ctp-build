build {
  name = "docker"
  sources = [
    "source.docker.alpine"
  ]
  provisioner "file" {
    sources = [
      "CTP-installer.jar", 
      "config-serveronly.xml",
      "Launcher.properties",
      "run.sh"
    ]
    destination = "/tmp/"
  }
  provisioner "shell" {
    inline = [
      "apk update",
      "apk add --no-cache tzdata",
      "mkdir -p /JavaPrograms/ && cd /JavaPrograms",
      "jar xf /tmp/CTP-installer.jar CTP",
      "mv /tmp/config-serveronly.xml /JavaPrograms/CTP/config.xml",
      "mv /tmp/Launcher.properties /JavaPrograms/CTP/",
      "rm -f /tmp/CTP-installer.jar"
    ]    
  }
  post-processor "docker-tag" {
    repository = var.repo
    tags = var.tag
  }
}
variable "repo" {
  type = string
  # default = "ghcr.io/australian-imaging-service/mirc-ctp"
}
variable "tag" {
  type = list(string)
}
source "docker" "alpine" {
  image = "openjdk:8u212-jdk-alpine3.9"
  commit  = true
  changes = [
    "LABEL org.opencontainers.image.source https://github.com/australian-imaging-service/ctp-build",
    "USER root",
    "EXPOSE 1080 1443 25055",
    "WORKDIR /JavaPrograms/CTP",
    "ENTRYPOINT [\"/bin/sh\", \"/tmp/run.sh\"]"
  ]
}
