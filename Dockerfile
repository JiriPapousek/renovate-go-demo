# Build stage
FROM registry.access.redhat.com/ubi9/go-toolset:1.25.5-1769430014 AS builder

COPY . .

USER 0

# Build the application
RUN go build -o /opt/app-root/src/server

# Runtime stage
FROM registry.access.redhat.com/ubi9/ubi-micro:latest

# Copy the binary from builder
COPY --from=builder /opt/app-root/src/server .

# copy the certificates from builder image
COPY --from=builder /etc/ssl /etc/ssl
COPY --from=builder /etc/pki /etc/pki

USER 1001

EXPOSE 8080

CMD ["./server"]
