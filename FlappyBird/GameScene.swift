//
//  GameScene.swift
//  FlappyBird
//
//  Created by takatoshi.ichige on 2021/03/31.
//

import SpriteKit

class GameScene: SKScene {
    
    // 初期表示
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        // 地面を表示
        // Textureの生成
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        // SpriteNodeを生成
        let groundNode = SKSpriteNode(texture: groundTexture)
        // ポジション設定
        groundNode.position = .init(x: groundTexture.size().width / 2, y: groundTexture.size().height / 2)
        
        // シーンに追加
        addChild(groundNode)
    }
}
