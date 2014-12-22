package main

type Register struct {
	Action   string `json:"action"`
	Username string `json:"username"`
	Password string `json:"password"`
}

type RegisterResp struct {
	Action string `json:"action"`
	Status string `json:"status"`
}

type Login struct {
	Action   string `json:"action"`
	Username string `json:"username"`
	Password string `json:"password"`
	Token    string `json:"token"`
	UserType string `json:"user_type"`
}

type LoginResp struct {
	Action   string `json:"action"`
	Username string `json:"username"`
	Status   string `json:"status"`
}

type UpdateLoc struct {
	Action string  `json:"action"`
	Lat    float64 `json:"lat"`
	Lng    float64 `json:"lng"`
}

type NearbyList struct {
	Action   string  `json:"action"`
	Lng      float64 `json:"lng"`
	Lat      float64 `json:"lat"`
	Distance float64 `json:"distance"`
}

type NearbyListResp struct {
	Action string     `json:"action"`
	List   []Stranger `json:"list"`
	Status string     `json:"status"`
}

type StrangerList struct {
	Action string `json:"action"`
}

type Stranger struct {
	Nickname string  `json:"nickname"`
	Distance float64 `json:"distance"`
}

type Message struct {
	Action  string `json:"action"`
	From    string `json:"from"`
	To      string `json:"to"`
	Message string `json:"msg"`
}

type RecvMessage struct {
	Action  string `json:"action"`
	From    string `json:"from"`
	Message string `json:"msg"`
}

type UploadCardInfo struct {
	Action string `json:"action"`

	Img     string `json:"img"`
	Name    string `json:"name"`
	Engname string `json:"engname"`
	Skill   string `json:"skill"`
}
type UploadCardInfoResp struct {
	Action string `json:"action"`
	Status string `json:"status"`
}
