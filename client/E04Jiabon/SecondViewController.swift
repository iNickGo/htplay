//
//  SecondViewController.swift
//  E04Jiabon
//
//  Created by sandra on 2014/12/20.
//  Copyright (c) 2014年 htplay. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet var btn: UIButton!

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


}

