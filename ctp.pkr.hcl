build {
  name = "docker"
  sources = [
    "source.docker.alpine"
  ]
  provisioner "file" {
    sources = [
      "CTP-installer.jar", 
      "config-serveronly.xml",
    ]
    destination = "/tmp/"
  }
  provisioner "shell" {
    inline = [
      "apk update",
      "apk add --no-cache openjdk11 tzdata",
      "ln -s /usr/share/zoneinfo/Australia/Sydney /etc/localtime",
      "mkdir -p /JavaPrograms/ && cd /JavaPrograms",
      "jar xf /tmp/CTP-installer.jar CTP",
      "mv /tmp/config-serveronly.xml /JavaPrograms/CTP/config.xml",
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
  image   = "alpine"
  commit  = true
  changes = [
    "USER root",
    "EXPOSE 1080 1443 25055",
    "WORKDIR /JavaPrograms/CTP",
    "ENTRYPOINT [\"java\", \"-jar\", \"/JavaPrograms/CTP/Runner.jar\"]",
  ]
}
