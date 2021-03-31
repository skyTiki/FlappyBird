//
//  GameScene.swift
//  FlappyBird
//
//  Created by takatoshi.ichige on 2021/03/31.
//

import SpriteKit

class GameScene: SKScene {
    
    // スクロール用のノードをまとめたノード
    var scrollNode: SKNode!
    
    // 初期表示
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        // スクロール用のノードをインスタンス化し、親Viewに設定
        scrollNode = SKNode()
        addChild(scrollNode)
        
        
        // 地面Textureの生成
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        
        // スクロール用にどのくらい画像を用意する必要があるか +2は右側で見切れないように追加している
        let needScroolImageCount = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        
        // スクロールのアクションを作成
        // ５秒かけて画像サイズ分左にずらす
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        // ０秒で元にもどすメソッド
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        // リピートさせる
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround,resetGround]))
        
        
        
        // SpriteNodeを生成
        //　必要な枚数分作成し、アクションを設定する
        for i in 0..<needScroolImageCount {
            let groundNode = SKSpriteNode(texture: groundTexture)
            // ポジション設定
            groundNode.position = .init(x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                                        y: groundTexture.size().height / 2)
            
            // アクションを設定
            groundNode.run(repeatScrollGround)
            
            // シーンに追加
            scrollNode.addChild(groundNode)
        }
    }
}
