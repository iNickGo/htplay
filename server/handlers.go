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
