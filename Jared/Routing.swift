import Foundation
import JaredFramework

public class EmoteModule: RoutingModule {
    public var routes: [Route] = []
    public var description = "fucLk"
    
    required public init() {
        let fuccboi = Route(comparisons: [.StartsWith: "/moduletest"], call: self.test, description: "TEST")
        routes = [fuccboi]
    }
    
    public func test(message:String, myRoom: Room) -> Void {
        SendText("Nigga this command was loaded from a modularized bundle", toRoom: myRoom)
    }
}




struct MessageRouting {
    var modules:[RoutingModule] = []
    var supportDir: NSURL?
    init () {
        let filemanager = NSFileManager.defaultManager()
        let appsupport = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)[0]
        let supportDir = appsupport.URLByAppendingPathComponent("Jared")
        let pluginDir = supportDir.URLByAppendingPathComponent("Plugins")
        
        try! filemanager.createDirectoryAtURL(supportDir, withIntermediateDirectories: true, attributes: nil)
        try! filemanager.createDirectoryAtURL(pluginDir, withIntermediateDirectories: true, attributes: nil)
        
        print(supportDir.absoluteString)
        
        
        //let path = "/Users/Zeke/Library/Developer/Xcode/DerivedData/EmoteModule-abvbbpvesnwseuaewkvascbwqpan/Build/Products/Debug/EmoteModule.bundle"
        //let myBundle = NSBundle(path: path)
        //let principleclass = myBundle?.principalClass as? RoutingModule.Type
        //let obj: RoutingModule = principleclass!.init()
        //print(obj.description)
        
        
        let files = filemanager.enumeratorAtURL(pluginDir, includingPropertiesForKeys: [], options: [.SkipsHiddenFiles, .SkipsPackageDescendants], errorHandler: nil)
        while let file = files?.nextObject() {
            if let currentURL = file as? NSURL {
                if currentURL.pathExtension == "bundle" {
                    if let myBundle = NSBundle(URL: currentURL) {
                        let principleClass = myBundle.principalClass as? RoutingModule.Type
                        if let module: RoutingModule = principleClass?.init() {
                            print(module.description)
                            modules.append(module)
                        }
                    }
                }
            }
        }
        
        let internalModules: [RoutingModule] = [CoreModule(), RESTModule(), TwitterModule(), EpicModule()]
        
        modules.appendContentsOf(internalModules)
    }
    func sendDocumentation(myMessage: String, forRoom: Room) {
        var documentation: String = ""
        for aModule in modules {
            documentation += aModule.description
            documentation += "\n"
            
            for aRoute in aModule.routes {
                if let aRouteDescription = aRoute.description {
                    documentation += aRouteDescription
                    documentation += "\n"
                }
                /*
                if let aRouteSyntax = aRoute.parameterSyntax?[safe:0] {
                    documentation += aRouteSyntax
                    documentation += "\n"
                }*/
            }
        }
        SendText(documentation, toRoom: forRoom)
    }
    
    func routeMessage(myMessage: String, fromBuddy: String, forRoom: Room) {
        
        let detector = try! NSDataDetector(types: NSTextCheckingType.Link.rawValue)
        let matches = detector.matchesInString(myMessage, options: [], range: NSMakeRange(0, myMessage.characters.count))
        let myLowercaseMessage = myMessage.lowercaseString
        
        
        if myLowercaseMessage == "/help" {
            sendDocumentation(myMessage, forRoom: forRoom)
        }
        
        RootLoop: for aModule in modules {
            for aRoute in aModule.routes {
                for aComparison in aRoute.comparisons {
                    
                    if aComparison.0 == .ContainsURL {
                        for match in matches {
                            let url = (myMessage as NSString).substringWithRange(match.range)
                            if url.containsString(aComparison.1) {
                                aRoute.call(url, forRoom)
                            }
                        }
                    }
                        
                        
                    else if aComparison.0 == .StartsWith {
                        if myLowercaseMessage.hasPrefix(aComparison.1.lowercaseString) {
                            aRoute.call(myMessage, forRoom)
                            break RootLoop
                        }
                    }
                        
                    else if aComparison.0 == .Contains {
                        if myLowercaseMessage.containsString(aComparison.1.lowercaseString) {
                            aRoute.call(myMessage, forRoom)
                            break RootLoop
                        }
                    }
                        
                    else if aComparison.0 == .Is {
                        if myLowercaseMessage == aComparison.1.lowercaseString {
                            aRoute.call(myMessage, forRoom)
                            break RootLoop
                        }
                    }
                }
            }
        }
    }
}


