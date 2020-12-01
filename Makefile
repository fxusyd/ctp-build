all : .state_ctp-docker .state_ctp-ovf .state_ctp-vagrant .state_ctp-lxd

.state_ctp : mirc-ctp.json mirc-ctp.service src/CTP.tar.gz src/linux-x86_64 nocloud.iso
	packer build mirc-ctp.json && touch state/mirc-ctp

DE_FILES = $(shell find docker-entrypoint.d -type f)
.state_ctp-docker : mirc-ctp.json CTP-installer.jar docker-entrypoint.sh docker-entrypoint.d $(DE_FILES)
	packer build -only=docker mirc-ctp.json
	touch .state_ctp-docker

.state_ctp-ovf : mirc-ctp.json mirc-ctp.service CTP-installer.jar focal-server-cloudimg-amd64.ova nocloud.iso
	packer build -only=virtualbox-ovf mirc-ctp.json
	touch .state_ctp-ovf

.state_ctp-vagrant : mirc-ctp.json mirc-ctp.service CTP-installer.jar
	packer build -only=vagrant mirc-ctp.json
	touch .state_ctp-vagrant

.state_ctp-lxd : mirc-ctp.json mirc-ctp.service CTP-installer.jar
	packer build -only=lxd mirc-ctp.json
	touch .state_ctp-lxd

CTP-installer.jar :
	curl -L -o./CTP-installer.jar http://mirc.rsna.org/download/CTP-installer.jar

focal-server-cloudimg-amd64.ova :
	curl -L -o./focal-server-cloudimg-amd64.ova https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.ova

nocloud.iso : user-data meta-data
	genisoimage -output nocloud.iso -volid cidata -joliet -rock -input-charset utf-8 user-data meta-data

.PHONY: clean
clean :
	rm -f CTP-installer.jar
	rm -f focal-server-cloudimg-amd64.ova
	rm -f nocloud.iso
	rm -f .state_*
