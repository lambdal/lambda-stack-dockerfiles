FROM ubuntu:16.04

WORKDIR /root/

# Add libcuda dummy dependency
ADD control .
RUN apt-get update && \
	apt-get install --yes equivs && \
	equivs-build control && \
	dpkg -i libcuda1-dummy_10.0_all.deb && \
	rm control libcuda1-dummy_10.0_all.deb && \
	apt-get remove --yes --purge --autoremove equivs && \
	rm -rf /var/lib/apt/lists/*

# Setup Lambda repository
ADD lambda.gpg .
RUN apt-key add lambda.gpg && \
	rm lambda.gpg && \
	echo "deb http://archive.lambdalabs.com/ubuntu xenial main" > /etc/apt/sources.list.d/lambda.list && \
	echo "cudnn cudnn/license_preseed select ACCEPT" | debconf-set-selections && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive \
		apt-get install --no-install-recommends --yes lambda-stack-cuda lambda-server && \
	rm -rf /var/lib/apt/lists/*

# Setup for nvidia-docker
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0"
