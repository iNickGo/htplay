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
}

type StrangerList struct {
	Action string `json:"action"`
}

type Stranger struct {
	Nickname string  `json:"nickname"`
	Distance float64 `json:"distance"`
}

type FriendListResp struct {
	Action string     `json:"action"`
	List   []Stranger `json:"list"`
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

type CreateGroup struct {
	Action string `json:"action"`
	Name   string `json:"name"`
}

type CreateGroupResp struct {
	Action string `json:"action"`
	ID     string `json:"group_id"`
}

type JoinGroup struct {
	Action string `json:"action"`
	ID     string `json:"group_id"`
}

type ListGroup struct {
	Action string `json:"action"`
}

type Group struct {
	ID   string `json:"gropu_id"`
	Name string `json:"name"`
}
type ListGroupResp struct {
	Action string  `json:"action"`
	Groups []Group `json:"groups"`
}
type GroupChat struct {
	Action  string `json:"action"`
	ID      string `json:"group_id"`
	Message string `json:"msg"`
}

type RecvGroupChat struct {
	Action  string `json:"action"`
	ID      string `json:"group_id"`
	Message string `json:"msg"`
}
