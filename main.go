package main

import (
	"database/sql"
	"log"

	_ "github.com/lib/pq"

	"github.com/X3nonxe/simplebank/api"
	db "github.com/X3nonxe/simplebank/db/sqlc"
	"github.com/X3nonxe/simplebank/util"
)

func main() {
	config, err := util.LoadConfig(".")
	if err != nil {
		log.Fatal("cannot load config:", err)
	}
	conn, err := sql.Open(config.DBDriver, config.DBSource)
	if err != nil {
		log.Fatal("cannot connect to database:", err)
	}

	store := db.NewStore(conn)
	server := api.NewServer(store)

	err = server.Run(config.ServerAddress)
	if err != nil {
		log.Fatal("cannot start server:", err)
	}
}
