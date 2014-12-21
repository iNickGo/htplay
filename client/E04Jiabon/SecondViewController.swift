//
//  SecondViewController.swift
//  E04Jiabon
//
//  Created by sandra on 2014/12/20.
//  Copyright (c) 2014年 htplay. All rights reserved.
//

import UIKit

import MobileCoreServices

import Foundation


class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let client : Client = Client.sharedInstance
    
    var cameraUI: UIImagePickerController! = UIImagePickerController()
    
    @IBOutlet var btn: UIButton!
    
    @IBOutlet var img: UIImageView!
    
    @IBOutlet var seg: UISegmentedControl!
    
    
    @IBAction func onPicture(sender: AnyObject) {
        self.presentCamera()
    }
    
    @IBAction func onClick(sender: AnyObject) {
        let image = UIImage(named: "open.png") as UIImage!

        btn.setImage(image, forState: .Normal)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            var skill: String
            
            switch seg.tag {
            case 0:
                skill = "APP"
            case 1:
                skill = "Web"
            case 2:
                skill = "Backend"
            case 3:
                skill = "Design"
            default:
                skill = "APP"
            }
            
            client.uploadImg(base64String, skill: skill)
            
            self.img.image = image
            
            
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
}

