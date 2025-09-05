ARG BUILDPLATFORM
FROM --platform="${BUILDPLATFORM}" golang:1.25.1 AS vendor
WORKDIR /build/

COPY --link --parents go.mod .
COPY --link --parents go.sum .
COPY --link --parents vendor .

ARG TARGETARCH
ARG TARGETOS
RUN --network=none \
    CGO_ENABLED=0 \
    GOARCH="${TARGETARCH}" \
    GOOS="${TARGETOS}" \
    go build -C vendor -v ./...

FROM --platform="${BUILDPLATFORM}" vendor AS build

COPY --link --parents ** .

ARG OTEL_VCS_CHANGE_ID
ARG OTEL_VCS_OWNER_NAME
ARG OTEL_VCS_REF_BASE_NAME
ARG OTEL_VCS_REF_BASE_REVISION
ARG OTEL_VCS_REF_BASE_TYPE
ARG OTEL_VCS_REF_HEAD_NAME
ARG OTEL_VCS_REF_HEAD_REVISION
ARG OTEL_VCS_REF_HEAD_TYPE
ARG OTEL_VCS_REPOSITORY_NAME
ARG OTEL_VCS_REPOSITORY_URL_FULL
ARG LDFLAGS="-s -w \
-X=go.austindrenski.io/gotter/utils/otel.OTEL_VCS_CHANGE_ID=${OTEL_VCS_CHANGE_ID} \
-X=go.austindrenski.io/gotter/utils/otel.OTEL_VCS_OWNER_NAME=${OTEL_VCS_OWNER_NAME} \
-X=go.austindrenski.io/gotter/utils/otel.OTEL_VCS_REF_BASE_NAME=${OTEL_VCS_REF_BASE_NAME} \
-X=go.austindrenski.io/gotter/utils/otel.OTEL_VCS_REF_BASE_REVISION=${OTEL_VCS_REF_BASE_REVISION} \
-X=go.austindrenski.io/gotter/utils/otel.OTEL_VCS_REF_BASE_TYPE=${OTEL_VCS_REF_BASE_TYPE} \
-X=go.austindrenski.io/gotter/utils/otel.OTEL_VCS_REF_HEAD_NAME=${OTEL_VCS_REF_HEAD_NAME} \
-X=go.austindrenski.io/gotter/utils/otel.OTEL_VCS_REF_HEAD_REVISION=${OTEL_VCS_REF_HEAD_REVISION} \
-X=go.austindrenski.io/gotter/utils/otel.OTEL_VCS_REF_HEAD_TYPE=${OTEL_VCS_REF_HEAD_TYPE} \
-X=go.austindrenski.io/gotter/utils/otel.OTEL_VCS_REPOSITORY_NAME=${OTEL_VCS_REPOSITORY_NAME} \
-X=go.austindrenski.io/gotter/utils/otel.OTEL_VCS_REPOSITORY_URL_FULL=${OTEL_VCS_REPOSITORY_URL_FULL}"
RUN --network=none \
    CGO_ENABLED=0 \
    GOARCH="${TARGETARCH}" \
    GOOS="${TARGETOS}" \
    go build -ldflags="${LDFLAGS}" -o /app/

FROM scratch AS gotter
COPY --from=build /app/* /
ENTRYPOINT ["/gotter"]
