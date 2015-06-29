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

class RegisterController: UIViewController {
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var passwordVerify: UITextField!
    
    @IBOutlet var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loader.hidden = true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func register(sender: AnyObject) {
        if(username.text == nil ||
            password.text == nil ||
            passwordVerify.text == nil) {
                return;
        }
        
        if(count(username.text) < USERNAME_SIZE || count(password.text) < PASSWORD_SIZE) {
            return;
        }
        
        if((count(passwordVerify.text) != count(password.text))) {
            return;
        }
        
        let params = [
            "username": username.text,
            "password": password.text
        ];
        
        startLoader();
        
        Alamofire.request(.POST, URL_REGISTER, parameters: params)
            .validate()
            .responseJSON{
                (_, response, JSON, error) in
                
                self.stopLoader();
                
                if((error) != nil) {
                    if(response!.statusCode == 404) {
                        //Erreur est survenue...
                    }
                } else {
                    if(JSON!.valueForKey("user") != nil) {
                        let user = JSON!.valueForKey("user") as! NSDictionary;
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
