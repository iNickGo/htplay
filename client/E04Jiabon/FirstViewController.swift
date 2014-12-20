//
//  FirstViewController.swift
//  E04Jiabon
//
//  Created by sandra on 2014/12/20.
//  Copyright (c) 2014年 htplay. All rights reserved.
//

import UIKit

import MobileCoreServices

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    
    var cameraUI: UIImagePickerController! = UIImagePickerController()
    
    let client : Client = Client.sharedInstance
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
        

        client.initLocation()
        client.setInfo("nick", pwd: "1234")
        client.connect()
        
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

       // self.presentCamera()
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

