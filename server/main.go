package main

import (
	"log"
	"net/http"
	"runtime"

	"github.com/gorilla/websocket"
)

var g_server *Server

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())

	g_server = NewServer()

	http.HandleFunc("/ws", entry)
	err := http.ListenAndServe(":8080", nil)

	log.Printf("server listen error: %v\n", err)
}

func showErr(err error) {
	if err != nil {
		log.Printf("err:%v\n", err)
	}
}

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true },
}

func entry(resp http.ResponseWriter, req *http.Request) {
	var err error
	var clientConn *websocket.Conn
	clientConn, err = upgrader.Upgrade(resp, req, nil)
	if err != nil {
		showErr(err)
		return

	}
	g_server.clientGo(clientConn)
}
