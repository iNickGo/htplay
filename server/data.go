package main

import (
	"gopkg.in/mgo.v2/bson"
)

type DBUser struct {
	Id       bson.ObjectId `bson:"_id"`
	Username string        `bson:"username"`
	Password string        `bson:"password"`
}

const (
	COL_USER = "user"
)

func (this *Server) GetUser(username string, user *DBUser) error {
	var err error
	if session, col, err := this.sessionCopy(COL_USER); err == nil {
		defer session.Close()

		return col.Find(bson.M{"username": username}).One(user)
	}
	return err
}

func (this *Server) UpdateUser(user *DBUser) error {
	var err error
	if session, col, err := this.sessionCopy(COL_USER); err == nil {
		defer session.Close()

		return col.UpdateId(user.Id, user)
	}
	return err
}

func (this *Server) AddUser(user *DBUser) error {
	var err error
	if session, col, err := this.sessionCopy(COL_USER); err == nil {
		defer session.Close()

		return col.Insert(user)
	}
	return err
}
