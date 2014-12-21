//
//  client.swift
//  E04Jiabon
//
//  Copyright (c) 2014 htplay. All rights reserved.
//

import Foundation

import Starscream
import SwiftyJSON

import Foundation
import CoreLocation

private let _SingletonASharedInstance = Client()


class Client: NSObject, WebSocketDelegate, CLLocationManagerDelegate {
    class var sharedInstance : Client {
        return _SingletonASharedInstance
    }
    
    var socket = WebSocket(url: NSURL(scheme: "ws", host: "192.168.2.3:8080", path: "/service")!)
    var user: String = ""
    var pwd: String = ""
    var auth: Bool = false
    var img: String = ""
    var connected: Bool = false
    let manager = CLLocationManager()
    
    override init() {
        super.init()


        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    ////Location
    func initLocation() {
        self.manager.requestAlwaysAuthorization()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let location = locations.last as CLLocation
        println("lat = \(location.coordinate.latitude)")
        println("lng = \(location.coordinate.longitude)")
        
        if self.connected && self.auth {
            var json:JSON = ["action":"update_loc", "lat": location.coordinate.latitude, "lng": location.coordinate.longitude]
            socket.writeData(json.rawData()!)
        }
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
    
    func uploadImg(var data: String) {
        if auth {
            var json: JSON = ["action": "upload_img", "img":data]
            socket.writeData(json.rawData()!)
            
            img = data
        }
    }
    
    func sendMessage(to: String, msg: String) {
        if auth {
            var json:JSON = ["action":"message", "to": to,"from": user]
            socket.writeData(json.rawData()!)
        }
    }
    
    func nearbyList() {
        if auth {
            var json:JSON = ["action":"nearby_ilst"]
            socket.writeData(json.rawData()!)
        }
    }
    
    func nearbyListResp(json: JSON) {
        
    }
    
    func register(username: String, pwd: String) {
        var json:JSON = ["action":"register", "username":user,"password":pwd]
        socket.writeData(json.rawData()!)
    }
    
    //got message call back
    func gotMessage(from: String, msg: String) {
        
    }
    
    func setInfo(user: String, pwd: String) {
        self.user = user
        self.pwd = pwd
    }
    
    
    func websocketDidConnect() {
        println("websocket is connected")
        connected = true
        
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
        
        switch json["action"].stringValue {
            case "login_resp":
                if json["status"] == "OK" {
                    auth = true
                }
            case "register_resp":
                if json["status"] == "OK" {
                    //register ok
                }
            case "recv_message":
                var msg = json["msg"].stringValue
                var from = json["from"].stringValue
                gotMessage(from, msg: msg)
            
            case "nearby_list_resp":
                nearbyListResp(json)
            
            default:
                println("unhandled: " + json["action"].stringValue)
            
        }
    }
    
    func websocketDidReceiveData(data: NSData) {
        println("Received data: \(data.length)")
    }
}
