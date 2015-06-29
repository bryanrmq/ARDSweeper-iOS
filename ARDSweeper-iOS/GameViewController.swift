//
//  GameViewController.swift
//  ARDSweeper-iOS

//
//  Created by Bryan Reymonenq on 25/06/2015.
//  Copyright (c) 2015 Fliizweb.fr. All rights reserved.
//


import Foundation
import UIKit
import SpriteKit

enum State: Int {
    case EMPTY_BOMB = -3
    case EMPTY      = -2
    case DEFAULT    = -1
    case NONE       = 0
    case ONE        = 1
    case TWO        = 2
    case THREE      = 3
    case FOUR       = 4
    case FIVE       = 5
    case SIX        = 6
    case SEVEN      = 7
    case EIGHT      = 8
}

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! SKScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    
    var map : NSMutableArray!
    var socket : SocketIOClient!
    var scene : SKScene
    var world : SKSpriteNode!
    var sprites : NSMutableArray!
    var port : String!
    
    var previousPosition : CGPoint!
    var pan = false

    required init(coder aDecoder: NSCoder) {
        scene = (SKScene.unarchiveFromFile("GameScene") as? SKScene)!
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //socket = SocketIOClient(socketURL: URL_GAME_SOCKET + self.port);
        
        self.socketHandlers()
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
        self.generate();
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func generate() {
        self.world = SKSpriteNode(
            color: UIColor.whiteColor(),
            size: CGSize(width: BOX_SIZE * self.map.count, height: BOX_SIZE * self.map.count)
        );
        scene.addChild(self.world)
        var z = 0;
        for(var i = 0; i < self.map.count; i++) {
            for(var j = 0; j < self.map[i].count; j++) {
                for(var k = 0; k < self.map[i][j].count; k++) {
                    z++;
                    let x = k * BOX_SIZE
                    let y = j * BOX_SIZE
                    
                    let sprite = SKSpriteNode(
                            color: UIColor(red: 1, green: 0, blue: 0, alpha: 1),
                            size: CGSize(width: BOX_SIZE, height: BOX_SIZE)
                    )
                    self.updateGrid(sprite, state: self.map[i][j][k][1] as! Int)
                    sprite.position = CGPoint(x: x, y: y)
                    sprite.name = String(j) + " " + String(k)
                    self.world.addChild(sprite)
                }
            }
        }
    }
    
    func socketHandlers() {
        self.socket.on("position") { data, ack in
            var position = data!.copy() as! NSArray;
            self.updateGrid(position[0] as! Int, y: position[1] as! Int, state: position[2] as! Int)
        }
        
        self.socket.on("bomb") { data, ack in
            var alert = UIAlertController(title: "BOMBE", message: "Attention le joueur... est tombé sur une bombe ! Aidez le !", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: { () -> Void in
                self.socket.emit("bomb desengaged");
            });
        }
        
        self.socket.on("bomb explode") { data, ack in
            var alert = UIAlertController(title: "BOMBE EXPLOSE", message: "La bombe a explosée...", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        self.socket.on("disconnect") { data, ack in
            var alert = UIAlertController(title: "Déconnexion", message: "La connexion avec le serveur a été perdue", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if(touches.count == 1) {
            var touch = touches.first as! UITouch
            let location = touch.locationInNode(self.world)
            if let node = self.world.nodeAtPoint(location) as? SKSpriteNode {
                var positionArr = node.name!.componentsSeparatedByString(" ")
                let x:Int? = positionArr[1].toInt()
                let y:Int? = positionArr[0].toInt()
                self.socket.emit("position", x!, y!)
            }
            
        } else if (touches.count == 2) {
            for touch in (touches as! Set<UITouch>) {
                self.pan = true
                self.previousPosition = touch.locationInNode(world)
            }
        }
    }
    
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if(pan) {
            for touch in (touches as! Set<UITouch>) {
                var position = touch.locationInNode(self.world);
                self.previousPosition = touch.previousLocationInNode(self.world);
                var translation = CGPointMake(position.x - previousPosition.x, position.y - previousPosition.y)
                self.world.position = translation
            }
        } else {
            
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in (touches as! Set<UITouch>) {
            println("End");
        }
    }

    
    func updateGrid(node: SKSpriteNode, state: Int) {
        self.updateNode(node, state: state)
    }
    
    func updateGrid(x: Int, y: Int, state: Int) {
        if let node = scene.nodeAtPoint(CGPoint(x: x * BOX_SIZE, y: y * BOX_SIZE)) as? SKSpriteNode {
            self.updateNode(node, state: state)
        }
    }
    
    func updateNode(node: SKSpriteNode, state: Int) {
        switch (state) {
        case State.EMPTY_BOMB.rawValue:
            node.color = UIColor.blackColor()
            break;
        case State.EMPTY.rawValue:
            node.color = UIColor.darkGrayColor()
            break;
        case State.DEFAULT.rawValue:
            node.color = UIColor.grayColor()
            break;
        default:
            node.color = UIColor.greenColor()
            break;
        }
    }
    


}
