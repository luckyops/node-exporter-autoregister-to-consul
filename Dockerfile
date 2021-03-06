ARG ARCH="amd64"
ARG OS="linux"
FROM quay.io/prometheus/busybox-${OS}-${ARCH}:glibc as builder
ADD curl-7.30.0.ermine.tar.bz2 /bin/.
RUN mv /bin/curl-7.30.0.ermine/curl.ermine /bin/curl \
    && rm -Rf /bin/curl-7.30.0.ermine

ARG ARCH="amd64"
ARG OS="linux"
FROM quay.io/prometheus/node-exporter:latest
COPY --from=builder /bin/curl /bin/curl
ADD ./register.sh /tmp/.
ADD ./deregister.sh /tmp/.
EXPOSE      9100
USER        nobody
ENTRYPOINT  [ "/bin/node_exporter" ]