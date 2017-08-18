FROM golang:1.8-nanoserver AS builder
WORKDIR /go/src/hello-world
COPY *.go ./
RUN go build

FROM microsoft/nanoserver
WORKDIR /app
COPY --from=builder /go/src/hello-world/hello-world.exe ./
EXPOSE 8888
ENTRYPOINT ["/app/hello-world.exe"]
