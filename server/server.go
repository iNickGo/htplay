package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/gorilla/websocket"
	"gopkg.in/mgo.v2"
)

const (
	ID_REGISTER      = "register"
	ID_REGISTER_RESP = "register_resp"

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
	STATUS_OK           = "OK"
	STATUS_FAILED       = "Failed"
	STATUS_UNAUTHORIZED = "UnAuthorized"
	EMPTY_RESP          = ""
)

const (
	DB_USER = "htplay"
	DB_PWD  = "htplay1234"
	DB_NAME = "htplay"
	DB_MODE = 0
	DB_IP   = "localhost"
	DB_PORT = 27017
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

type Server struct {
	sync.RWMutex
	clients  map[string]*Client
	handlers map[string]HANDLER

	session *mgo.Session
	db      string
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
	this.handlers[ID_REGISTER] = this.register

	this.initMongo(DB_IP, DB_PORT, DB_NAME, DB_USER, DB_PWD)
}

func (this *Server) initMongo(ip string, port int, db string, username string, password string) (bool, error) {
	var err error
	info := &mgo.DialInfo{}
	info.Addrs = append(info.Addrs, fmt.Sprintf("%s:%d", ip, port))
	info.Database = db
	info.Username = username
	info.Password = password
	info.Timeout = time.Second * 10

	this.session, err = mgo.DialWithInfo(info)
	if err != nil {
		return false, err
	}

	this.session.SetMode(mgo.Strong, true)

	this.db = db

	return true, nil
}

func (this *Server) sessionCopy(colName string) (*mgo.Session, *mgo.Collection, error) {
	if this.session == nil {
		return nil, nil, errors.New("not connected")

	}
	session := this.session.Copy()
	collection := session.DB(this.db).C(colName)
	return session, collection, nil
}

func (this *Server) clientGo(conn *websocket.Conn) {
	var auth bool = false
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

		//check auth
		if cmd.Action != ID_LOGIN && cmd.Action != ID_REGISTER && !auth {
			log.Printf("unauthorized request:%v\n", cmd.Action)
			genResp := &GeneralResp{Action: cmd.Action, Status: STATUS_UNAUTHORIZED}
			jsonResp, _ := json.Marshal(genResp)
			conn.WriteMessage(websocket.TextMessage, jsonResp)
			continue
		}
		resp, err := handler(req, conn)

		//error response
		showErr(err)
		if err != nil {
			genResp := &GeneralResp{Action: cmd.Action, Status: STATUS_FAILED}
			errResp, _ := json.Marshal(genResp)

			conn.WriteMessage(websocket.TextMessage, errResp)
			continue
		}

		if resp != nil {
			jsonResp, err := json.Marshal(resp)
			if err != nil {
				showErr(err)
				continue
			}

			if cmd.Action == ID_LOGIN {
				auth = true
			}

			log.Printf("resp: %v\n", string(jsonResp))
			conn.WriteMessage(websocket.TextMessage, jsonResp)
		}

	}
}
