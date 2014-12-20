//
//  client.swift
//  E04Jiabon
//
//  Created by nick on 12/20/14.
//  Copyright (c) 2014 htplay. All rights reserved.
//

import Foundation

import Starscream
import SwiftyJSON

import Foundation
import CoreLocation


class Client: NSObject, WebSocketDelegate, CLLocationManagerDelegate {
    var socket = WebSocket(url: NSURL(scheme: "ws", host: "192.168.2.3:8080", path: "/service")!)
    var user: String = ""
    var pwd: String = ""
    var auth: Bool = false
    let manager = CLLocationManager()
    
    override init() {
        super.init()


        self.manager.delegate = self
        self.manager.requestAlwaysAuthorization()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let location = locations.last as CLLocation
        
        println("didUpdateLocations:  (location.coordinate.latitude), (location.coordinate.longitude)")
        
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("didChangeAuthorizationStatus")
        
        switch status {
        case .NotDetermined:
            println(".NotDetermined")
            break
            
        case .Authorized:
            println(".Authorized")
            self.manager.startUpdatingLocation()
            break
            
        case .Denied:
            println(".Denied")
            break
            
        default:
            println("Unhandled authorization status")
            break
            
        }
    }
    
    func connect() {
        socket.delegate = self
        socket.connect()
    }
    
    
    
    func setInfo(user: String, pwd: String) {
        self.user = user
        self.pwd = pwd
    }
    
    
    func websocketDidConnect() {
        println("websocket is connected")
        
        if !auth {
            var json:JSON = ["action":"login", "username":user,"password":pwd]
            socket.writeData(json.rawData()!)
        }
    }
    
    func websocketDidDisconnect(error: NSError?) {
        if let e = error {
            println("websocket is disconnected: \(e.localizedDescription)")
        }
    }
    
    func websocketDidWriteError(error: NSError?) {
        if let e = error {
            println("wez got an error from the websocket: \(e.localizedDescription)")
        }
    }
    
    func websocketDidReceiveMessage(text: String) {
        println("Received text: \(text)")
        var json:JSON = JSON(data: text.dataUsingEncoding(NSUTF8StringEncoding)!)
        println("json:" + json["action"].stringValue)
        
        switch json["action"].stringValue {
            case "login_resp":
                if json["status"] == "OK" {
                    
                }
            default:
                println("unhandled: " + json["action"].stringValue)
            
        }
    }
    
    func websocketDidReceiveData(data: NSData) {
        println("Received data: \(data.length)")
    }
}
