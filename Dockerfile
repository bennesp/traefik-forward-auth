# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS builder

ARG TARGETOS
ARG TARGETARCH

# Setup
WORKDIR /src

# Add libraries
RUN apk add --no-cache git

# Cache dependencies separately from source code.
COPY go.mod go.sum ./
RUN go mod download

# Cross-compile natively for the requested output platform. The builder always
# runs on BUILDPLATFORM, so arm64 images do not require QEMU emulation.
COPY . .
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags="-s -w" -o /traefik-forward-auth ./cmd

# Copy into scratch container
FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /traefik-forward-auth /traefik-forward-auth
ENTRYPOINT ["/traefik-forward-auth"]
