
# arm64で動かしたいバイナリを考える

今回AWS LambdaでGraviton2でgoバイナリ動かしたいときのいい感じのDockerfileを考える


```Dockefile
FROM --platform=$BUILDPLATFORM golang:1.22-bookworm as builder
ARG TARGETARCH
WORKDIR /go/src/lambda
COPY go.mod go.sum ./
RUN go mod download
COPY ./ .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -a -o /main .

FROM gcr.io/distroless/base-debian12:nonroot
WORKDIR /app
COPY --from=builder /main /main
ENTRYPOINT [ "/main" ]
```
