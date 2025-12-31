# Build stage
FROM golang:1.25.5 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main main.go

# Run stage
FROM alpine:3.19
WORKDIR /app

COPY --from=builder /app/main .
COPY app.env .
COPY start.sh .
COPY wait-for.sh .
COPY db/migration ./db/migration

RUN chmod +x /app/main /app/start.sh /app/wait-for.sh

EXPOSE 8080 9090
ENTRYPOINT ["/app/start.sh"]
CMD ["/app/main"]
