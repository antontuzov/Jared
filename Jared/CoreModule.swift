//
//  CoreModule.swift
//  Jared 3.0 - Swiftified
//
//  Created by Zeke Snider on 4/3/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import Cocoa
import JaredFramework

struct CoreModule: RoutingModule {
    var description = "Core functionality for Jared with universal uses"
    var routes: [Route] = []
    
    init() {
        let ping = Route(comparisons: [.StartsWith: "/ping"], call: self.pingCall, description: "Check if the chat bot is available")
        let thankYou = Route(comparisons: [.StartsWith: "Thank you Jared"], call: self.thanksJared, description: "Thank Jared")
        let version = Route(comparisons: [.StartsWith: "/version"], call: self.getVersion, description: "Get what version Jared is running")
        let send = Route(comparisons: [.StartsWith: "/send"], call: self.sendRepeat, description: "Send a message repeatedly")
        let test = Route(comparisons: [.StartsWith: "/test"], call: self.hello, description: "A test command")
        

        routes = [ping, thankYou, version, send, test]
    }
    
    func hello(message:String, myRoom: Room) -> Void{
        SendImage("/Users/Jared/Desktop/Video Message.mov", toRoom: myRoom)
    }
    
    func pingCall(message:String, myRoom: Room) -> Void {
        let responseLocalized = NSLocalizedString("Pong!", comment: "Response for ping! command")
        SendText(responseLocalized, toRoom: myRoom)
    }
    
    func thanksJared(message:String, myRoom: Room) -> Void {
        SendText("You're welcome.", toRoom: myRoom)
    }
    
    func getVersion(message:String, myRoom: Room) -> Void {
        SendText("I am version 3.0 beta of Jared, compiled on Swift 2.2!", toRoom: myRoom)
    }
    
    func sendRepeat(message:String, myRoom: Room) -> Void {
        let parameters = message.componentsSeparatedByString(",")
        if let repeatNum: Int = Int(parameters[1]), let delay = Int(parameters[2]) {
            print(parameters.count)
            var textToSend: String
            
            if (parameters.count > 4) {
                textToSend = "lol"
            }
            else {
                textToSend = parameters[3]
            }
            
            for _ in 1...repeatNum {
                SendText(textToSend, toRoom: myRoom)
                NSThread.sleepForTimeInterval(Double(delay))
            }
        }
        
        
        
        
        
    }
}