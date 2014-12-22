package main

import (
	"crypto/md5"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"strconv"
	"strings"

	"github.com/gorilla/websocket"
	"github.com/kellydunn/golang-geo"
	"gopkg.in/mgo.v2"
	"gopkg.in/mgo.v2/bson"
)

const (
	ID_REGISTER      = "register"
	ID_REGISTER_RESP = "register_resp"

	ID_LOGIN      = "login"
	ID_LOGIN_RESP = "login_resp"

	ID_UPDATE_LOC = "update_loc"

	ID_NEARBY_LIST      = "nearby_list"
	ID_NEARBY_LIST_RESP = "nearby_list_resp"

	ID_MESSAGE      = "message"
	ID_RECV_MESSAGE = "recv_message"

	ID_SET_INFO = "set_info"

	ID_UPDATE_CARDINFO = "upload_cardinfo"
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

	this.handlers[ID_REGISTER] = this.register
	this.handlers[ID_LOGIN] = this.login
	this.handlers[ID_NEARBY_LIST] = this.nearbyList
	this.handlers[ID_MESSAGE] = this.message

	this.handlers[ID_UPDATE_LOC] = this.updateLoc

	this.handlers[ID_UPDATE_CARDINFO] = this.updateCardInfo

	//
	this.initMongo(DB_IP, DB_PORT, DB_NAME, DB_USER, DB_PWD)
}

func (this *Server) updateCardInfo(req []byte, data interface{}) (interface{}, error) {
	cmd := &UploadCardInfo{}
	json.Unmarshal(req, cmd)

	username := data.(string)
	img, _ := base64.StdEncoding.DecodeString(cmd.Img)

	user := &DBUser{}
	err := this.GetUser(username, user)
	if err != nil {
		log.Printf("err %v\n", err)
	}
	user.Skill = cmd.Skill
	user.Img.Data = img
	this.UpdateUser(user)

	resp := &UploadCardInfoResp{Action: cmd.Action, Status: STATUS_OK}

	return resp, nil
}

func (this *Server) nearbyList(req []byte, data interface{}) (interface{}, error) {
	cmd := &NearbyList{}
	json.Unmarshal(req, cmd)

	username := data.(string)

	users := make([]DBUser, 0)

	err := this.FindNearPeople(cmd.Lng, cmd.Lat, cmd.Distance, &users)
	if err != nil {
		log.Printf("err %v\n", err)
		return EMPTY_RESP, err
	}

	//update user location
	go func() {
		user := &DBUser{}
		err := this.GetUser(username, user)
		if err != nil {
			log.Printf("err %v\n", err)
		}

		mLat, _ := strconv.ParseFloat((fmt.Sprintf("%.2f", cmd.Lat)), 64)
		mLng, _ := strconv.ParseFloat((fmt.Sprintf("%.2f", cmd.Lng)), 64)
		user.Loc.Lat = mLat
		user.Loc.Lng = mLng
		log.Printf("%v %v\n", mLat, mLng)
		err = this.UpdateUser(user)
		if err != nil {
			log.Printf("err %v\n", err)
		}
	}()

	resp := &NearbyListResp{Action: ID_NEARBY_LIST_RESP, Status: STATUS_OK}
	resp.List = make([]Stranger, 0)
	for _, v := range users {

		if v.Username == username {
			continue
		}
		user := Stranger{}
		user.Nickname = v.Username

		p := geo.NewPoint(cmd.Lat, cmd.Lng)
		p2 := geo.NewPoint(v.Loc.Lat, v.Loc.Lng)
		dist := p.GreatCircleDistance(p2)

		user.Distance = dist
		resp.List = append(resp.List, user)
	}

	//test data
	for i := 0; i < 7; i++ {
		user1 := Stranger{}
		user1.Nickname = fmt.Sprintf("%v_%v", "jack", i)
		user1.Distance = 1
		resp.List = append(resp.List, user1)
	}

	return resp, nil
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

	user.Loc.Lat = cmd.Lat
	user.Loc.Lng = cmd.Lng

	//todo err check
	err = this.UpdateUser(user)
	if err != nil {
		log.Printf("err %v\n", err)
	}

	return nil, nil
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

	//filter $ sign
	cmd.Username = strings.Replace(cmd.Username, "$", "", -1)

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
	client.Friends = make(map[string]*Stranger)
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
