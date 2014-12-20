//
//  FirstViewController.swift
//  E04Jiabon
//
//  Created by sandra on 2014/12/20.
//  Copyright (c) 2014年 htplay. All rights reserved.
//

import UIKit

struct TOnlineUser
{
    var name: String
    var distance = 0
}

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    let APP_MESSAGE : String = "E04 甲奔拉！"
    
    @IBOutlet weak var myTabelView: UITableView!
    
    // this is fake data
    var ListArray = ["Sandra", "Steven", "Jerry", "Nick", "Diro", "Bin", "Jack", "Ives", "Emma", "Rick", "阿毛", "蕃薯", "兩百", "Trista", "Joyce", "John"]
   
    var userList: [TOnlineUser] = []
    
    var alert: UIAlertView = UIAlertView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchDataBase()
        
        // register tabel view
        self.myTabelView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myTabelView.delegate = self
        myTabelView.dataSource = self
        
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
    
        var cell: UITableViewCell = self.myTabelView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        println(toString(indexPath.row) + " : " + self.userList[indexPath.row].name);
        
        cell.textLabel?.text = self.userList[indexPath.row].name + "\t\t" + toString(self.userList[indexPath.row].distance) + " 公尺"
        return cell
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        println("accessoryButtonTappedForRowWithIndexPath : " + toString(indexPath.row) + " : " + self.userList[indexPath.row].name);
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        var name: String = self.userList[indexPath.row].name
        
        println("didHighlightRowAtIndexPath : " + toString(indexPath.row) + " : " + self.userList[indexPath.row].name);

        sendNameMsgTo(name)
        recvMsgFrom(name)
    }
    
    func showAlertMsg(name: String)
    {
        alert.title =  name
        alert.message = APP_MESSAGE
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func showLocalNotify(name: String)
    {
        var notification:UILocalNotification = UILocalNotification()
        notification.alertBody = name + " : " + APP_MESSAGE
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func searchDataBase()
    {
        // TO DO: server give ui a list of name and distance
        // please convert data to struct TOnlineUser
        // then append data to userList
        
        
        // this is a sample
        for index in 0...(ListArray.count - 1) {
            var data: TOnlineUser = TOnlineUser(name: ListArray[index], distance: index * 10)
            self.userList.append(data)
        }
    }
    
    func sendNameMsgTo(name: String)
    {
        // TO DO: Server send Message to name
        println("sendNameMsgTo : " + name);
        
        
        
    }
    
    func recvMsgFrom(name: String)
    {
        // TO DO: Server receive Message to name
        println("recvMsgFrom : " + name);
        
        
        
        
        // UI show Notify and alert window
        showLocalNotify(name)
        showAlertMsg(name)
    }
}

