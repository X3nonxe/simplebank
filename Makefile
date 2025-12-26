DB_URL=postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable

# =========================
# Docker & Infrastructure
# =========================
network:
	docker network create bank-network || true

postgres:
	docker run --name postgres-dev \
		-p 5432:5432 \
		-e POSTGRES_USER=root \
		-e POSTGRES_PASSWORD=secret \
		--network bank-network \
		-d postgres:17-alpine

redis:
	docker run --name redis \
		-p 6379:6379 \
		--network bank-network \
		-d redis:7-alpine

createdb:
	docker exec -it postgres-dev createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres-dev dropdb simple_bank

# =========================
# Migration
# =========================
migrateup:
	migrate -path migrations -database "$(DB_URL)" -verbose up

migrateup1:
	migrate -path migrations -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -path migrations -database "$(DB_URL)" -verbose down

migratedown1:
	migrate -path migrations -database "$(DB_URL)" -verbose down 1

new_migration:
	migrate create -ext sql -dir migrations -seq $(name)

# =========================
# SQLC
# =========================
sqlc:
	sqlc generate

# =========================
# Testing
# =========================
test:
	go test -v -cover ./...

test-db:
	go test -v ./internal/repository/postgres/...

# =========================
# Application
# =========================
server:
	go run ./cmd/server/main.go

# =========================
# Mock
# =========================
mock:
	mockgen -package mockrepo \
		-destination internal/repository/mock/user_repository.go \
		github.com/techschool/simplebank/internal/domain/repository UserRepository

# =========================
# Proto & gRPC
# =========================
proto:
	rm -f pb/*.go
	rm -f doc/swagger/*.swagger.json
	protoc --proto_path=proto \
		--go_out=pb --go_opt=paths=source_relative \
		--go-grpc_out=pb --go-grpc_opt=paths=source_relative \
		--grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
		--openapiv2_out=doc/swagger \
		--openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
		proto/*.proto
	statik -src=./doc/swagger -dest=./doc

# =========================
# Tools
# =========================
evans:
	evans --host localhost --port 9090 -r repl

# =========================
# Documentation
# =========================
db_docs:
	dbdocs build doc/db.dbml

db_schema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

.PHONY: \
	network postgres redis createdb dropdb \
	migrateup migratedown migrateup1 migratedown1 new_migration \
	sqlc test test-db server mock proto evans db_docs db_schema
