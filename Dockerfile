FROM alpine:3.7

ENV USERNAME=admin
ENV ZNCPASS=admin123

RUN addgroup -S znc -g 1000
RUN adduser -D -S -h /znc-data -s /sbin/nologin -G znc znc -u 1000

RUN apk update
RUN apk add znc znc-extra znc-modperl znc-modpython znc-modtcl ca-certificates
RUN apk add git gdb perl-dev python3-dev swig tcl-dev cyrus-sasl-dev
RUN apk add curl bash expect libcap

RUN mkdir -p /znc-data/configs
ADD /sources/znc.conf /znc-data/configs/znc.conf
ADD scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN setcap cap_net_bind_service=+ep /opt/znc/bin/znc

CMD [ "/entrypoint.sh" ]