package main

type Login struct {
	Action   string
	Username string
	Token    string
	UserType string `json:"user_type"`
}

type LoginResp struct {
	Action   string
	Username string
	Status   string
}

type FriendList struct {
	Action string
}

type Friend struct {
	ID       string `json:"friend_id"`
	Nickname string
}

type FriendListResp struct {
	Action string
	List   []Friend
}
type Message struct {
	Action  string
	To      string
	Message string `json:"msg"`
}

type RecvMessage struct {
	Action  string
	From    string
	Message string `json:"msg"`
}

type CreateGroup struct {
	Action string
	Name   string
}

type CreateGroupResp struct {
	Action string
	ID     string `json:"group_id"`
}

type JoinGroup struct {
	Action string
	ID     string `json:"group_id"`
}

type ListGroup struct {
	Action string
}

type Group struct {
	ID   string `json:"gropu_id"`
	Name string
}
type ListGroupResp struct {
	Action string
	Groups []Group
}
type GroupChat struct {
	Action  string
	ID      string `json:"group_id"`
	Message string `json:"msg"`
}

type RecvGroupChat struct {
	Action  string
	ID      string `json:"group_id"`
	Message string `json:"msg"`
}
