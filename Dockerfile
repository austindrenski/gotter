ARG BUILDPLATFORM
FROM --platform="${BUILDPLATFORM}" golang:1.25.1 AS build
WORKDIR /build/

COPY --link --parents go.mod .
COPY --link --parents go.sum .
COPY --link --parents vendor .
COPY --link --parents ** .

ARG TARGETARCH
ARG TARGETOS
RUN --network=none \
    CGO_ENABLED=0 \
    GOARCH="${TARGETARCH}" \
    GOOS="${TARGETOS}" \
    go build -ldflags="-s -w" -o /app/

FROM scratch AS runtime
COPY --from=build /app/* /usr/local/bin/

FROM runtime AS gotter
ENTRYPOINT ["gotter"]
