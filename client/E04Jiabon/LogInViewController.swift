//
//  LogInViewController.swift
//  E04Jiabon
//
//  Created by sandra on 2014/12/21.
//  Copyright (c) 2014年 htplay. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {

    let client : Client = Client.sharedInstance
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var inputName: UITextField! = nil
    @IBOutlet weak var inputPwd: UITextField! = nil
    
    @IBOutlet weak var regosterBtm: UIButton!
    
    var userDefault = NSUserDefaults.standardUserDefaults()    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        photo.image = UIImage(named: ("dinner.png"))
        photo.layer.borderColor = UIColor.blackColor().CGColor;
        photo.layer.borderWidth = 2.0;
        
        // Set image corner radius
        photo.layer.cornerRadius = 10.0;
    
        photo.layer.shadowColor = UIColor.blueColor().CGColor;
        photo.layer.shadowOffset = CGSize(width: 10.0, height:  20.0)
        photo.clipsToBounds = true
        
        var storedUserName: AnyObject? = userDefault.valueForKey("usrname")
        var storedPassword: AnyObject? = userDefault.valueForKey("password")
        
        if (storedUserName != nil && storedPassword != nil)
        {
            self.inputName.text = storedUserName as String
            self.inputPwd.text = storedPassword as String
        }
        inputName.delegate = self
        inputPwd.delegate = self
        
        
        client.initLocation()
        
        client.loginView = self
        client.connect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onLogin() {
        if client.connected {
            client.login(inputName.text, pwd: inputPwd.text)            
        }else {
            println("client is not connected")
        }

    }
    
    @IBAction func onClickRegister(sender: AnyObject) {
        client.register(inputName.text, pwd: inputPwd.text)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
       inputName.resignFirstResponder()
        self.view.endEditing(true)
        
    }
}
