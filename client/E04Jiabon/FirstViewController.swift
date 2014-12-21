//
//  FirstViewController.swift
//  E04Jiabon
//
//  Created by sandra on 2014/12/20.
//  Copyright (c) 2014年 htplay. All rights reserved.
//

import UIKit

import MobileCoreServices

struct TOnlineUser
{
    var name: String
    var distance = 0
}

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    
    var cameraUI: UIImagePickerController! = UIImagePickerController()
    
    let client : Client = Client.sharedInstance
    let APP_MESSAGE : String = "E04 甲奔拉！"
    
    @IBOutlet weak var myTabelView: UITableView!
    
    // this is fake data
    var ListArray = ["Sandra", "Steven", "Jerry", "Nick", "Diro", "Bin", "Jack", "Ives", "Emma", "Rick", "阿毛", "蕃薯", "兩百", "Trista", "Joyce", "John"]
   
    var userList: [TOnlineUser] = []
    
    var alert: UIAlertView = UIAlertView()
    
    var userDefault = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        client.view = self
        
        searchDataBase()
        
        // register tabel view
        self.myTabelView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myTabelView.delegate = self
        myTabelView.dataSource = self
        

        client.initLocation()
        client.setInfo("nick", pwd: "1234")
        client.connect()
        
        var storedNumber = userDefault.integerForKey("number")
        //userDefault.setInteger(number , forKey: "number")
        //userDefault.synchronize()
        println("read:" + toString(storedNumber))
        storedNumber+=1
        userDefault.setInteger(storedNumber , forKey: "number")
        userDefault.synchronize()
        
    }
    
    func presentCamera()
    {

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            cameraUI = UIImagePickerController()
            cameraUI.delegate = self
            cameraUI.sourceType = UIImagePickerControllerSourceType.Camera;
            cameraUI.mediaTypes = [kUTTypeImage]
            cameraUI.allowsEditing = false
            cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.Front
            
            self.presentViewController(cameraUI, animated: true, completion: nil)
        }
        else
        {
            // error msg
        }
    }

    func imagePickerControllerDidCancel(picker:UIImagePickerController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    func imagePickerController(picker:UIImagePickerController!, didFinishPickingMediaWithInfo info:NSDictionary)
    {
        if(picker.sourceType == UIImagePickerControllerSourceType.Camera)
        {
            var image: UIImage = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
            var newImg = RBResizeImage(image, targetSize: CGSizeMake(200, 100))
            var data  = UIImageJPEGRepresentation(newImg, 50)
            
            let base64String = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
            
            client.uploadImg(base64String)

            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
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
        cell.textLabel.text = self.userList[indexPath.row].name
        cell.detailTextLabel?.text = toString(self.userList[indexPath.row].distance) + " 公尺"
        
        return cell
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        println("accessoryButtonTappedForRowWithIndexPath : " + toString(indexPath.row) + " : " + self.userList[indexPath.row].name);
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        var name: String = self.userList[indexPath.row].name
        
        println("didHighlightRowAtIndexPath : " + toString(indexPath.row) + " : " + self.userList[indexPath.row].name);

        //sendNameMsgTo(name)
        //recvMsgFrom(name)

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
    
    func recvMsgFrom(name: String, msg: String)
    {
        // TO DO: Server receive Message to name
        println("recvMsgFrom : " + name);
        
        // UI show Notify and alert window
        showLocalNotify(name, msg: msg)
        showAlertMsg(name, msg: msg)
    }
}

