# build image
FROM golang:1.11 as build

# required to force cgo (for sqlite driver) with cross compile
ENV CGO_ENABLED 1

# install database clients
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		mysql-client \
		postgresql-client \
		sqlite3 \
	&& rm -rf /var/lib/apt/lists/*

# development dependencies
RUN curl -fsSL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
	| sh -s v1.12.3

# copy source files
RUN git clone https://github.com/amacneil/dbmate.git /src
WORKDIR /src

# build
RUN make build

# runtime image
FROM alpine
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
COPY --from=build /src/dist/dbmate-linux-amd64 /usr/bin/dbmate
ENTRYPOINT ["/usr/bin/dbmate"]