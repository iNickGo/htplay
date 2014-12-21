//
//  LogInViewController.swift
//  E04Jiabon
//
//  Created by sandra on 2014/12/21.
//  Copyright (c) 2014年 htplay. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    let client : Client = Client.sharedInstance
    
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputPwd: UITextField!
    
    @IBOutlet weak var regosterBtm: UIButton!
    var userDefault = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var storedUserName = userDefault.valueForKey("usrname")
        var storedPassword = userDefault.valueForKey("password")
        
        if (storedUserName != nil && storedPassword != nil)
        {
            self.regosterBtm.setTitle("Login", forState: UIControlState.Normal)
            self.inputName.text = storedUserName as String
            self.inputPwd.text = storedPassword as String
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickRegister(sender: AnyObject) {
        println(inputName.text + " " + inputPwd.text)
        client.register(inputName.text, pwd: inputPwd.text)
        client.login(inputName.text, pwd: inputPwd.text)
        
        
        userDefault.setValue(inputName.text, forKey: "usrname")
        userDefault.setValue(inputPwd.text, forKey: "password")
        userDefault.synchronize()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
