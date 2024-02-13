FROM --platform=${BUILDPLATFORM} golang:1.22-bookworm@sha256:ec75c446b58317793746901bbff9127da1c85f90e08b45dcb3c9ff6291110125 AS builder

WORKDIR /src/

COPY . .

ARG VERSION

RUN case ${TARGETPLATFORM} in \
         "linux/amd64")  GOARCH=amd64  ;; \
         # arm64 and arm64v8 are equivilant in go and do not require a goarm
         # https://github.com/golang/go/wiki/GoArm
         "linux/arm64" | "linux/arm/v8")  GOARCH=arm64  ;; \
         "linux/ppc64le")  GOARCH=ppc64le  ;; \
         "linux/arm/v6") GOARCH=arm GOARM=6  ;; \
         "linux/arm/v7") GOARCH=arm GOARM=7 ;; \
    esac && \
    GOARCH=${GOARCH} VERSION=${VERSION} make build

FROM gcr.io/distroless/static:nonroot@sha256:6a3500b086c2856fbc189f5d11351bdbcf7c4dc5673c2b6070aac9d607da90d7

COPY --from=builder /src/version /bin/version

ARG CREATED
ARG AUTHORS="Koen van Zuijlen <8818390+kvanzuijlen@users.noreply.github.com>"
ARG URL="https://github.com/version-cli/version"
ARG DOCUMENTATION="https://github.com/version-cli/version"
ARG SOURCE="https://github.com/version-cli/version"
ARG VERSION
ARG REVISION
ARG VENDOR="version-cli"
ARG LICENSES="GNU GPLv3"
ARG TITLE="version"
ARG DESCRIPTION="A simple CLI tool to deal with version numbers."
ARG BASE_IMAGE="gcr.io/distroless/static:nonroot"
ARG BASE_IMAGE_DIGEST="sha256:6a3500b086c2856fbc189f5d11351bdbcf7c4dc5673c2b6070aac9d607da90d7"

LABEL authors="kvanzuijlen" \
    org.opencontainers.image.created=${CREATED} \
    org.opencontainers.image.authors=${AUTHORS} \
    org.opencontainers.image.url=${URL} \
    org.opencontainers.image.documentation=${DOCUMENTATION} \
    org.opencontainers.image.source=${SOURCE} \
    org.opencontainers.image.version=${VERSION} \
    org.opencontainers.image.revision=${REVISION} \
    org.opencontainers.image.vendor=${VENDOR} \
    org.opencontainers.image.licenses=${LICENSES} \
    org.opencontainers.image.ref.name=v${VERSION} \
    org.opencontainers.image.title=${TITLE} \
    org.opencontainers.image.description=${DESCRIPTION} \
    org.opencontainers.image.base.digest=${BASE_IMAGE_DIGEST} \
    org.opencontainers.image.base.name=${BASE_IMAGE}

ENTRYPOINT ["/bin/version"]
