//
//  ViewController.swift
//  FlappyBird
//
//  Created by takatoshi.ichige on 2021/03/31.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ViewをSKviewに変換
        let skView = self.view as! SKView
        
        // FPS,node数の表示
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        let scene = SKScene(size: skView.frame.size)
        
        skView.presentScene(scene)
    }


}

