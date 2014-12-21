//
//  FirstViewController.swift
//  E04Jiabon
//
//  Created by sandra on 2014/12/20.
//  Copyright (c) 2014年 htplay. All rights reserved.
//

import UIKit

import MobileCoreServices

import Foundation

import Starscream
import SwiftyJSON

struct TOnlineUser
{
    var name: String
    var distance: Float64
    
    init() {
        name = ""
        distance = 0.0
    }
}

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let client : Client = Client.sharedInstance
    let APP_MESSAGE : String = "E04 拉！"
    
    @IBOutlet weak var myTabelView: UITableView!
    
    var userList: [TOnlineUser] = []
    
    var alert: UIAlertView = UIAlertView()
    
    var userDefault = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // register tabel view
        self.myTabelView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myTabelView.delegate = self
        myTabelView.dataSource = self
                
        var storedNumber = userDefault.integerForKey("number")
        //userDefault.setInteger(number , forKey: "number")
        //userDefault.synchronize()
        println("read:" + toString(storedNumber))
        storedNumber+=1
        userDefault.setInteger(storedNumber , forKey: "number")
        userDefault.synchronize()
        
        client.view = self

        
    }

  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        println("ListCount = " + toString(self.userList.count));
        return self.userList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cellIdentifier = "cell"
        var cell: UITableViewCell = self.myTabelView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        println(toString(indexPath.row) + " : " + self.userList[indexPath.row].name);
        
        cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = self.userList[indexPath.row].name
        cell.detailTextLabel?.text = toString(self.userList[indexPath.row].distance) + " 公尺"
        
        return cell
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        println("accessoryButtonTappedForRowWithIndexPath : " + toString(indexPath.row) + " : " + self.userList[indexPath.row].name);
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        var name: String = self.userList[indexPath.row].name
        
        println("didHighlightRowAtIndexPath : " + toString(indexPath.row) + " : " + self.userList[indexPath.row].name);

        sendNameMsgTo(name)
        
        //self.presentCamera()
    }
    
    func showAlertMsg(name: String, msg: String)
    {
        alert.title =  name
        alert.message = msg
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func showLocalNotify(name: String, msg: String)
    {
        var notification:UILocalNotification = UILocalNotification()
        notification.alertBody = name + " : " + msg
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func updateTableView(var arr: [TOnlineUser]) {
        for user in arr {
            //println(user.name)
            //println(user.distance)
        }
        self.userList = arr
        
        self.myTabelView.reloadData()

    }
    
  
    
    func sendNameMsgTo(name: String)
    {
        client.sendMessage(name, msg: "E04")
    }
    
    func recvMsgFrom(name: String, msg: String)
    {
        // TO DO: Server receive Message to name
        println("recvMsgFrom : " + name);
        
        // UI show Notify and alert window
        showLocalNotify(name, msg: msg)
        showAlertMsg(name, msg: msg)
    }
}

