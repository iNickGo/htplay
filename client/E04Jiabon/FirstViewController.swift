//
//  FirstViewController.swift
//  E04Jiabon
//
//  Created by sandra on 2014/12/20.
//  Copyright (c) 2014年 htplay. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    let APP_MESSAGE : String = "E04 甲奔拉！"
    
    @IBOutlet weak var myTabelView: UITableView!
    
    var ListArray = ["Sandra", "Steven", "Jerry", "Nick", "Diro", "Bin", "Jack", "Ives", "Emma", "Rick", "阿毛", "蕃薯", "兩百", "Trista", "Joyce", "John"]
    
    var alert: UIAlertView = UIAlertView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        println("ListCount = " + toString(self.ListArray.count));
        return self.ListArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        var cell: UITableViewCell = self.myTabelView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        println(toString(indexPath.row) + " : " + self.ListArray[indexPath.row]);
        cell.textLabel.text = self.ListArray[indexPath.row] + "\t" + toString(indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        println("accessoryButtonTappedForRowWithIndexPath : " + toString(indexPath.row) + " : " + self.ListArray[indexPath.row]);
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        var name: String = self.ListArray[indexPath.row]
        
        println("didHighlightRowAtIndexPath : " + toString(indexPath.row) + " : " + self.ListArray[indexPath.row]);

        showLocalNotify(name)
        showAlertMsg(name)
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
    
    func sendNameMsg()
    {
        //
    }
}

