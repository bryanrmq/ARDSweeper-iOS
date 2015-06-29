//
//  GameLoader.swift
//  ARDSweeper-iOS
//
//  Created by Bryan Reymonenq on 24/06/2015.
//  Copyright (c) 2015 Fliizweb.fr. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class GameLoader: UIViewController {
    
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var indications: UILabel!
    @IBOutlet var gameView: SKView!
    
    @IBOutlet var btn: UIButton!
    var socket : SocketIOClient!
    var map : NSMutableArray!
    var port = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader.startAnimating()
        println(URL_GAME_SOCKET + self.port);
        self.socket = SocketIOClient(socketURL: URL_GAME_SOCKET + self.port)
        
        self.addHandlers()
        
        //Ouverture Socket
        self.socket.connect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func addHandlers() {
        //self.socket.onAny {println("Got event: \($0.event), with items: \($0.items)")}
        
        self.socket.on( "connect" ) { data, ack in
            println("Connexion started")
            self.socket.emit("new player");
            self.socket.emit("get full map", "1234567890")
        }
        
        self.socket.on( "full map" ) { data, ack in
            self.indications.text = "Chargement de la carte...";
            self.map = data!.mutableCopy() as! NSMutableArray
            self.socket.emit( "full map client" );
        }
        
        self.socket.on( "server full" ) { data, ack in
            var alert = UIAlertController(title: "Serveur plein", message: "Vous allez être déconnecté car le serveur est plein", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        };
        
        self.socket.on( "disconnect" ) { data, ack in
            self.socket.close(fast: false);
        }
        
        self.socket.on("start game") {[weak self] data, ack in
            self!.indications.text = "Lancement du jeu"
            self!.performSegueWithIdentifier("gameSegue", sender: self!)
            return
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "gameSegue") {
            var svc = segue.destinationViewController as! GameViewController;
            
            svc.socket = self.socket
            svc.map = self.map
            svc.port = self.port
        }
    }
    
}