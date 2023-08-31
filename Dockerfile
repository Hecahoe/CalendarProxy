FROM golang:1.20-alpine3.17 as builder

# Ca-certificates are required to call HTTPS endpoints.
RUN apk update && apk add --no-cache ca-certificates tzdata alpine-sdk bash && update-ca-certificates

# Create appuser
RUN adduser -D -g '' appuser
WORKDIR /app

# compile the app
COPY cmd cmd
COPY internal internal
COPY go.* .

RUN CGO_ENABLED=0 go build -ldflags="-extldflags=-static" -o /proxy cmd/proxy/proxy.go

FROM scratch

COPY --from=builder /proxy /proxy
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd

EXPOSE 4321

CMD ["/proxy"]
