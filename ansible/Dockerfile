FROM debian:stable-slim

RUN set -eux; \
	apt-get update; \
	apt-get --no-install-recommends --auto-remove -qq install \
		ansible \
		libcompress-zlib-perl libexception-class-perl liblist-allutils-perl libfrontier-rpc-perl libjson-xs-perl libcrypt-ssleay-perl \
		;\
