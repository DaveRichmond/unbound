FROM ubuntu:focal AS build
RUN apt update && \
	apt install -y build-essential gcc libssl-dev libexpat1-dev
COPY . /build
WORKDIR /build
RUN ./configure --with-conf-file=/unbound/unbound.conf \
	--with-pidfile=/unbound/unbound.pid \
	--with-run-dir=/unbound \
	--with-chroot-dir=/unbound \
	--with-rootkey-file=/unbound/root.key \
	--with-rootcert=/unbound/icannbundle.pem
RUN make
RUN make install

FROM ubuntu:focal
RUN apt update && \
	apt install -y libssl1.1 libexpat1 && \
	apt clean && \
	rm -Rf /var/lib/apt/*
RUN useradd -d /unbound unbound

COPY --from=build /usr/local /usr/local
COPY --from=build /unbound /unbound

CMD ["/usr/local/sbin/unbound", "-v"]

