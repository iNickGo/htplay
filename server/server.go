package main

import (
	"encoding/json"
	"errors"
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

const (
	STATUS_OK     = "OK"
	STATUS_FAILED = "FAILED"
	EMPTY_RESP    = ""
)

type HANDLER func(req []byte, data interface{}) (interface{}, error)

type Client struct {
	Name    string
	Friends map[string]*Friend
	Conn    *websocket.Conn
}

func (this *Server) GetClient(name string) *Client {

	this.RLock()
	defer this.RUnlock()

	client := this.clients[name]
	if client != nil {
		return client
	}

	return nil
}

func (this *Server) AddClient(client *Client) {
	if client == nil {
		return
	}

	defer log.Printf("add client name: %v\n", client.Name)
	this.Lock()
	defer this.Unlock()

	this.clients[client.Name] = client
}

func (this *Server) login(req []byte, data interface{}) (interface{}, error) {
	cmd := &Login{}
	json.Unmarshal(req, cmd)

	if len(cmd.Username) == 0 {
		return EMPTY_RESP, errors.New("parameter error")

	}

	respCmd := &LoginResp{Action: ID_LOGIN_RESP}
	respCmd.Status = STATUS_OK
	respCmd.Username = cmd.Username

	//todo: check login
	client := &Client{Name: cmd.Username}
	client.Friends = make(map[string]*Friend)
	client.Conn = data.(*websocket.Conn)

	this.AddClient(client)

	resp := &LoginResp{Action: ID_LOGIN_RESP, Status: STATUS_OK}

	return resp, nil
}

func (this *Server) message(req []byte, data interface{}) (interface{}, error) {
	cmd := &Message{}
	json.Unmarshal(req, cmd)

	//cmd.To

	to := this.GetClient(cmd.To)
	if to == nil {
		return nil, errors.New("to not found")
	}

	recvMsg := &RecvMessage{Action: ID_RECV_MESSAGE}
	recvMsg.From = cmd.From
	recvMsg.Message = cmd.Message

	resp, _ := json.Marshal(recvMsg)
	to.Conn.WriteMessage(websocket.TextMessage, resp)

	return nil, nil
}

func (this *Server) friend_list(req []byte, data interface{}) (interface{}, error) {
	cmd := &FriendList{}
	json.Unmarshal(req, cmd)

	resp := &FriendListResp{Action: ID_FRIEND_LIST_RESP}
	resp.List = make([]Friend, 0)
	//fake
	for k, v := range this.clients {
		log.Printf("%v %v\n", k, v.Name)
		friend := Friend{}
		//friend.ID = v.Name
		friend.Nickname = v.Name

		resp.List = append(resp.List, friend)
	}

	return resp, nil
}

type Server struct {
	sync.RWMutex
	clients  map[string]*Client
	handlers map[string]HANDLER
}

type GeneralCmd struct {
	Action string `json:"action"`
}

type GeneralResp struct {
	Action string `json:"action"`
	Status string `json:"status"`
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
	this.handlers[ID_FRIEND_LIST] = this.friend_list
	this.handlers[ID_MESSAGE] = this.message
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

		resp, err := handler(req, conn)

		showErr(err)
		if err != nil {
			genResp := &GeneralResp{Action: cmd.Action, Status: STATUS_FAILED}
			errResp, _ := json.Marshal(genResp)
			resp = string(errResp)
		}

		if resp != nil {
			jsonResp, err := json.Marshal(resp)
			if err == nil {
				showErr(err)
			}
			log.Printf("resp: %v\n", string(jsonResp))
			conn.WriteMessage(websocket.TextMessage, jsonResp)

		}

	}
}
