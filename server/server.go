package main

import (
	"encoding/json"
	"log"
	"sync"

	"github.com/gorilla/websocket"
)

const (
	ID_LOGIN            = "login"
	ID_LOGIN_RESP       = "login_resp"
	ID_FRIEND_LIST      = "friend_list"
	ID_FRIEND_LIST_RESP = "friend_list_resp"
	ID_MESSAGE          = "message"
	ID_RECV_MESSAGE     = "recv_message"

	ID_CREATE_GROUP     = "create_group"
	ID_CREATE_GROUP_ACK = "create_group_ack"

	ID_JOIN_GROUP      = "join_group"
	ID_JOIN_GROUP_RESP = "join_group_resp"

	ID_LIST_GROUP     = "list_group"
	ID_LIST_GROUP_ACK = "list_group_ack"

	ID_GROUP_CHAT      = "group_chat"
	ID_RECV_GROUP_CHAT = "recv_group_chat"
)

type HANDLER func(req []byte, data interface{}) (string, error)

type Client struct {
	Name string
}

func (this *Server) login(req []byte, data interface{}) (string, error) {

	return "", nil
}

func (this *Server) friend_list(req []byte, data interface{}) (string, error) {
	return "", nil
}

type Server struct {
	sync.Mutex
	clients  map[string]*Client
	handlers map[string]HANDLER
}

type GeneralCmd struct {
	Action string `json:"action"`
}

func NewServer() *Server {
	srv := &Server{}
	srv.InitServer()

	return srv
}

func (this *Server) InitServer() {
	this.clients = make(map[string]*Client)
	this.handlers = make(map[string]HANDLER)

	this.handlers[ID_LOGIN] = this.login
}

func (this *Server) clientGo(conn *websocket.Conn) {
	for {
		_, req, err := conn.ReadMessage()
		if err != nil {
			log.Printf("sth happened:%v \n", err)
			break
		}

		cmd := &GeneralCmd{}
		err = json.Unmarshal(req, cmd)
		if err != nil {
			log.Printf("err %v\n", err)
			return
		}

		log.Printf("general cmd:%v\n", cmd.Action)

		handler := this.handlers[cmd.Action]
		if handler == nil {
			log.Printf("undefined: %v\n", cmd.Action)
			return
		}

		resp, err := handler(req, "")

		log.Printf("resp: %v\n", resp)
		if err != nil {
			conn.WriteMessage(websocket.TextMessage, []byte(resp))
		}
	}
}
