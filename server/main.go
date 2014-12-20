package main

import (
	"log"
	"net/http"
	"os"
	"os/signal"
	"runtime"
	"syscall"

	"github.com/gorilla/websocket"
)

var g_server *Server

type Test struct {
	Name string
}

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())

	g_server = NewServer()

	go func() {
		http.HandleFunc("/service", entry)
		err := http.ListenAndServe(":8080", nil)

		log.Printf("server listen error: %v\n", err)
		os.Exit(0)
	}()

	/*
		users := make([]DBUser, 0)
		err := g_server.FindNearPeople(-114, 51.0, 10, &users)
		showErr(err)
		log.Printf("len:%v\n", len(users))
	*/

	exitSig := make(chan os.Signal)
	signal.Notify(exitSig, os.Kill, os.Interrupt, syscall.SIGTERM)
	<-exitSig
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
