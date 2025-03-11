ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION}

WORKDIR /root/

# Add libcuda dummy dependency
RUN printf "\
Package: libcuda1-dummy\n\
Maintainer: Lambda Labs <software@lambdalabs.com>\n\
Version: 12.8\n\
Provides: libcuda1 (= 570)\n\
 , libcuda-12.8-1\n\
 , libnvidia-ml1 (= 570)\n\
" > control

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install --yes equivs && \
	equivs-build control && \
	dpkg -i libcuda1-dummy_12.8_all.deb && \
	rm control libcuda1-dummy_12.8* && \
	apt-get remove --yes --purge --autoremove equivs && \
	rm -rf /var/lib/apt/lists/*

# Install pre-requisites
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install --yes lsb-release gnupg && \
	rm -rf /var/lib/apt/lists/*

# Setup GPG key
RUN printf -- "\
-----BEGIN PGP PUBLIC KEY BLOCK-----\n\
\n\
mQINBFrFv5kBEADLAYqKVCC0T+bOGMQ2duQ/XN/iT/F+I4B/qjPGBNC84oLtTfK7\n\
Ig0ctPKVVbOOKbXD1U/+dy/guJRF2G9nzxrod1n02wonzig3/qDzTS0iaDcBlWF9\n\
sdVWppQ/e7LrCKz+2ywPDnzE1UAf3R8YMiB+Ve6SDndLXpcjdtvx8yhJkNBP6EAA\n\
kfOugrmUBwuEH6mQG0NfrfcybM5KWc1K7NmNgFcH4LnmqyVLTHEIJc2afZl3Q4aa\n\
CKwr2lwwihXQRb47GWaZictFfp2fswWl2HuohTIfTboyzLEE7goqys+KYoy1Td9w\n\
/NhKnik4t9L5ur8/CbAFtEapCxHTWV8ONe8GkgEoyI478c88g3zW9Hyu8CdYpjqr\n\
2+jlIHGWKevdYBosVSfAqEw1oDtsG/ptJcymZ+YMhirJb8201MhR8uJajd+5e3eA\n\
O4fYcXGr9NDcqvma26Vb35A1o85u3ccJpeIozZvMnBlunsrBtT2zSpKAuTVvPOCe\n\
jDcLIDj4XzF0bkDkbJsBujYpTx7mDC9HnHagH5JFYww6Vtm87LPss4Pf8uGeoY5B\n\
YmkutK2VAFzyDZpn3WZatDpG1TdyeyNuSW0yVNi1ZvXJSPyEmnitzjEJ1X3X8Ndh\n\
1NGEh11ry7WyorK4+C6MW0wK3mGp/aqwvfBa1lqekwZQhGX9GpQe3PrM6QARAQAB\n\
tD5MYW1iZGEgTGFicyAoUmVwb3NpdG9yeSBTaWduaW5nIEtleSkgPHNvZnR3YXJl\n\
QGxhbWJkYWxhYnMuY29tPokCTgQTAQoAOBYhBKMQ7rtPgwa6dMlZmaU9jyaeiloT\n\
BQJaxb+ZAhsDBQsJCAcDBRUKCQgLBRYCAwEAAh4BAheAAAoJEKU9jyaeiloTiUUQ\n\
AIxGlkNaxm08fsNwuyiubCgOVL4d69aUCxStx+YpL9u5eJDrrCs5XkmlE0fr2coV\n\
MrTWohPjhz65So15F2xBebf4PN13qwKnoYQePZ+y/0xpgomKyd2sWTahjAwkMbuT\n\
hYhrX+n8XP/KIAVPmQJQ010u6C/n7CvGkTNURM64ig6Tt92Mfrmz/sUEZbo/48Ef\n\
SntY4CzBUdyZ3ifP9h1Qhp74t7tTh/uPeBdYPRD/i66Mx1D/q8I1ZYV4+4pVjXor\n\
zC1z6+a2gGFgptAqVTzDOq74YEkEIlAxaLGHq4DhXgkZ/por1kGRO0BrDz1QdTih\n\
bdzRKUrV1TKR3pCvlYWP0d1znFkGP7wtuAHAPJruQLQHsqqwIRHFHw0KTKvQOLz4\n\
7wOCII4EzohQPXBZh8tWJwVbVkVTM1gtCDbn853ldPxplocRN/cXGcq9ht/a9z4k\n\
JVldCp1+9JAY81UWLZfnid1wcWGOGazztZmbaCHY5d04yA45IqksPFB8I6T3hZuO\n\
D+vS4I2Zxv0kq6qkF+UBdu/jyTHJ887PwFBKKAsZIvxI6U4rWRqexplgaTM8CIx8\n\
8EK3WlhRiW7KTJLd/Hs0iJxVWPEdoY8px8cNrAAovBPgoX8XR9DZEO1UxysIsU2h\n\
vcAqOJpavozl4MwEXd0WBT7cDfmR/xz/tZkuK3TiVp9H\n\
=9oLr\n\
-----END PGP PUBLIC KEY BLOCK-----\n\
" > lambda.gpg

RUN gpg --dearmor -o /etc/apt/trusted.gpg.d/lambda.gpg < lambda.gpg && \
	rm lambda.gpg

# Setup repository
RUN printf "\
deb http://archive.lambdalabs.com/ubuntu $(lsb_release -cs) main\n\
" > /etc/apt/sources.list.d/lambda.list

RUN printf "\
Package: *\n\
Pin: origin archive.lambdalabs.com\n\
Pin-Priority: 1001\n\
" > /etc/apt/preferences.d/lambda

# Install lambda-stack packages
RUN apt-get update && \
	echo "cudnn cudnn/license_preseed select ACCEPT" | debconf-set-selections && \
	DEBIAN_FRONTEND=noninteractive \
		apt-get install \
		--yes \
		--no-install-recommends \
		--option "Acquire::http::No-Cache=true" \
		--option "Acquire::http::Pipeline-Depth=0" \
		lambda-stack-cuda && \
	rm -rf /var/lib/apt/lists/*

# Let pip break system packages
RUN printf "\
[global]\n\
break-system-packages = true\n\
" > /etc/pip.conf

# Setup for nvidia-docker
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=12.8"
