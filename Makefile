source = https://github.com/johnperry/CTP.git
repo = ghcr.io/australian-imaging-service/mirc-ctp
tag = $(shell cat latest-build)

all : .state_ctp-docker .state_ctp-ovf .state_ctp-vagrant .state_ctp-lxd

.state_ctp : mirc-ctp.json mirc-ctp.service src/CTP.tar.gz src/linux-x86_64 nocloud.iso
	packer build mirc-ctp.json && touch state/mirc-ctp

.state_ctp-docker: ctp.pkr.hcl CTP-installer.jar
	packer build -var='repo=$(repo)' -var='tag=["$(tag)"]' ctp.pkr.hcl
	# touch .state_ctp-docker
	
.state_ctp-ovf : mirc-ctp.json mirc-ctp.service CTP-installer.jar focal-server-cloudimg-amd64.ova nocloud.iso
	packer build -only=virtualbox-ovf mirc-ctp.json
	touch .state_ctp-ovf

.state_ctp-vagrant : mirc-ctp.json mirc-ctp.service CTP-installer.jar
	packer build -only=vagrant mirc-ctp.json
	touch .state_ctp-vagrant

.state_ctp-lxd : mirc-ctp.json mirc-ctp.service CTP-installer.jar
	packer build -only=lxd mirc-ctp.json
	touch .state_ctp-lxd

CTP-installer.jar: 
	git clone $(source)
	# cp -r CTP-old CTP
	cd CTP; \
	version=$$(git log -n 1 --date=format:'%Y%m%d' products/CTP-installer.jar | grep Date | cut -d ' ' -f 4); \
	echo $$version > ../latest-build
	mv CTP/products/CTP-installer.jar ./
	rm -fr CTP

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
	rm -f latest-build