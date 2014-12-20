package main

import (
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"errors"
	"log"

	"github.com/gorilla/websocket"
	"gopkg.in/mgo.v2"
	"gopkg.in/mgo.v2/bson"
)

const (
	ID_REGISTER      = "register"
	ID_REGISTER_RESP = "register_resp"

	ID_LOGIN      = "login"
	ID_LOGIN_RESP = "login_resp"

	ID_UPDATE_LOC = "update_loc"

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

func (this *Server) InitServer() {
	this.clients = make(map[string]*Client)
	this.handlers = make(map[string]HANDLER)

	this.handlers[ID_LOGIN] = this.login
	this.handlers[ID_FRIEND_LIST] = this.friend_list
	this.handlers[ID_MESSAGE] = this.message
	this.handlers[ID_REGISTER] = this.register

	this.handlers[ID_UPDATE_LOC] = this.updateLoc

	this.initMongo(DB_IP, DB_PORT, DB_NAME, DB_USER, DB_PWD)
}

func (this *Server) updateLoc(req []byte, data interface{}) (interface{}, error) {
	cmd := &UpdateLoc{}
	json.Unmarshal(req, cmd)

	username := data.(string)
	user := &DBUser{}
	err := this.GetUser(username, user)
	if err == mgo.ErrNotFound {
		return EMPTY_RESP, errors.New("user not found")
	}

	user.Lat = cmd.Lat
	user.Lng = cmd.Lng

	//todo err check
	this.UpdateUser(user)

	return EMPTY_RESP, nil
}

func (this *Server) register(req []byte, data interface{}) (interface{}, error) {
	cmd := &Register{}
	json.Unmarshal(req, cmd)

	//check existed user
	existedUser := &DBUser{}
	err := this.GetUser(cmd.Username, existedUser)
	if err != mgo.ErrNotFound {
		log.Printf("err%v\n", err)
		return nil, errors.New("existed username")
	}

	//new
	hasher := md5.New()
	hasher.Write([]byte(cmd.Password))
	hashPwd := hex.EncodeToString(hasher.Sum(nil))
	user := &DBUser{Id: bson.NewObjectId(), Username: cmd.Username, Password: hashPwd}

	this.AddUser(user)

	resp := &LoginResp{Action: ID_REGISTER_RESP, Username: cmd.Username, Status: STATUS_OK}

	return resp, nil
}

func (this *Server) login(req []byte, data interface{}) (interface{}, error) {
	cmd := &Login{}
	json.Unmarshal(req, cmd)

	if len(cmd.Username) == 0 {
		return EMPTY_RESP, errors.New("parameter error")

	}

	//todo: check login
	user := &DBUser{}
	err := this.GetUser(cmd.Username, user)
	if err == mgo.ErrNotFound {
		return EMPTY_RESP, errors.New("not found")
	}

	hasher := md5.New()
	hasher.Write([]byte(cmd.Password))
	hashPwd := hex.EncodeToString(hasher.Sum(nil))

	if hashPwd != user.Password {
		return EMPTY_RESP, errors.New("password not matched")
	}

	client := &Client{Name: cmd.Username}
	client.Friends = make(map[string]*Friend)
	client.Conn = data.(*websocket.Conn)

	this.AddClient(client)

	resp := &LoginResp{Action: ID_LOGIN_RESP, Status: STATUS_OK, Username: cmd.Username}

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
