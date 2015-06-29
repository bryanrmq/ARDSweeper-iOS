//
//  LoginController.swift
//  ARDSweeper-iOS
//
//  Created by Bryan Reymonenq on 24/06/2015.
//  Copyright (c) 2015 Fliizweb.fr. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class LoginController: UIViewController {
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var loader: UIActivityIndicatorView!
    
    var token : String = ""
    var port : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loader.hidden = true;
        
        let preferences = NSUserDefaults.standardUserDefaults()
        if preferences.objectForKey(TOKEN_KEY) != nil {
            self.token = preferences.stringForKey(TOKEN_KEY)!
            let params = [
                "token": self.token
            ]
            self.requestLogin(params)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connection(sender: AnyObject) {
        if(username.text == nil || password.text == nil) {
            return;
        }
        
        if(count(username.text) < USERNAME_SIZE || count(password.text) < PASSWORD_SIZE) {
            return;
        }
        
        startLoader();
        
        let params = [
            "username": username.text,
            "password": password.text
        ];
        
        self.requestLogin(params);
    }
    
    func openView(view: String) {
        self.performSegueWithIdentifier("gameLoaderSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "gameLoaderSegue") {
            var svc = segue.destinationViewController as! GameLoader
            svc.port = self.port
        }
    }
    
    func requestLogin(params: NSDictionary) {
        var url = URL_LOGIN
        if params["token"] != nil { url = URL_LOGIN_TOKEN + (params["token"] as! String) }
        Alamofire.request(.POST, url, parameters: params as? [String : AnyObject])
            .validate()
            .responseJSON{
                (_, response, JSON, error) in
                
                self.stopLoader();
                
                if((error) != nil) {
                    println(response);
                    if(response?.statusCode != nil) {
                        if(response!.statusCode == 404) {
                            //L'utilisateur n'a pas été trouvé.
                        }
                    }
                } else {
                    if(JSON!.valueForKey("user") != nil) {
                        let user = JSON!.valueForKey("user") as! NSDictionary;
                        let server = JSON!.valueForKey("server") as! NSDictionary;
                        let u = User(id: user["id"] as! Int, username: user["username"] as! String, token: user["token"] as! String)
                        self.port = server["portString"] as! String
                        self.openView("GameLoader");
                    }
                }
        };
    }
    
    func startLoader() {
        self.loader.hidden = false;
        self.loader.startAnimating();
        
        username.enabled = false;
        password.enabled = false;
    }
    
    func stopLoader() {
        self.loader.stopAnimating();
        self.loader.hidden = true;
        
        username.enabled = true;
        password.enabled = true;
    }
}
