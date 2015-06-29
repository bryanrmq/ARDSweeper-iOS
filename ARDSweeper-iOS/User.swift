//
//  User.swift
//  ARDSweeper-iOS
//
//  Created by Bryan Reymonenq on 24/06/2015.
//  Copyright (c) 2015 Fliizweb.fr. All rights reserved.
//

import Foundation

class User: NSObject {
    
    var id : Int = 0;
    var username : String = ""
    var token : String = ""
    
    init(id: Int, username: String, token: String) {
        super.init()
        
        self.id = id
        self.username = username
        self.set_token(token)
    }
    
    init(user: NSDictionary) {
        super.init()
        
        self.id = user["id"] as! Int;
        self.set_username(user["username"] as! String);
        self.set_token(user["token"] as! String);
    }
    
    func get_token() -> String {
        let preferences = NSUserDefaults.standardUserDefaults()
        let currentToken = self.token
        if (preferences.stringForKey(TOKEN_KEY) == nil) {
            return "";
        }
        self.token = preferences.stringForKey(TOKEN_KEY)!;
        return self.token;
    }
    
    func set_token(T: String) {
        let preferences = NSUserDefaults.standardUserDefaults()
        let currentToken = self.token
        if (preferences.stringForKey(TOKEN_KEY) == nil) {
            preferences.setObject(T, forKey: TOKEN_KEY)
            let didSave = preferences.synchronize()
            if (didSave) {
                self.token = T
            }
        } else {
            self.token = preferences.stringForKey(TOKEN_KEY)!
        }
    }
    
    func set_username(U: String) {
        let preferences = NSUserDefaults.standardUserDefaults()
        let current = self.username
        if (preferences.stringForKey(USERNAME_KEY) == nil) {
            preferences.setObject(U, forKey: USERNAME_KEY)
            let didSave = preferences.synchronize()
            if (didSave) {
                self.username = U
            }
        } else {
            self.username = preferences.stringForKey(USERNAME_KEY)!
        }
    }
    
}
