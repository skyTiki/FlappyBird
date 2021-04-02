//
//  GameScene.swift
//  FlappyBird
//
//  Created by takatoshi.ichige on 2021/03/31.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // スクロール用のノードをまとめたノード
    var scrollNode: SKNode!
    var wallNode: SKNode!
    
    var bird: SKSpriteNode!
    
    
    // 衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0 // 0...0001 → 1
    let groundCategory: UInt32 = 1 << 1 // 0....0010 → 2
    let wallCategory: UInt32 = 1 << 2 // 0...0100 → 4
    let scoreCategory: UInt32 = 1 << 3 // 0...1000 → 8
    
    // スコア用
    var score = 0
    let userDefaults: UserDefaults = UserDefaults.standard
    let bestKeyName = "BEST"
    
    var scoreLabelNode: SKLabelNode!
    var bestScoreLabelNode: SKLabelNode!
    
    // ゲームオーバー時のRotateエフェクト中はリスタートさせないためのフラグ
    var isRotatingEffect = false
    
    
    // 初期表示
    override func didMove(to view: SKView) {
        
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        // 衝突時のデリゲートメソッド使用
        physicsWorld.contactDelegate = self
        
        
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        // スクロール用のノードをインスタンス化し、親Viewに設定
        scrollNode = SKNode()
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        addChild(scrollNode)
        
        // ノードの設定
        setGround()
        setClound()
        setWall()
        setBird()
        
        setScoreLabel()
    }
    
    
    private func setGround() {
        
        // Textureの生成
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        
        // スクロール用にどのくらい画像を用意する必要があるか +2は右側で見切れないように追加している
        let needImageCount = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        
        // スクロールのアクションを作成
        // ５秒かけて画像サイズ分左にずらす
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        // ０秒で元にもどすメソッド
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        // リピートさせる
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround,resetGround]))
        
        
        
        // SpriteNodeを生成
        //　必要な枚数分作成し、アクションを設定する
        for i in 0..<needImageCount {
            let groundNode = SKSpriteNode(texture: groundTexture)
            // ポジション設定
            groundNode.position = .init(x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                                        y: groundTexture.size().height / 2)
            
            // アクションを設定
            groundNode.run(repeatScrollGround)
            
            
            // 物理演算
            groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            // 動かないように設定
            groundNode.physicsBody?.isDynamic = false
            
            groundNode.physicsBody?.categoryBitMask = self.groundCategory
            
            // シーンに追加
            scrollNode.addChild(groundNode)
        }
    }
    
    private func setClound() {
        
        // Textureを生成
        let cloudTexeture = SKTexture(imageNamed: "cloud")
        cloudTexeture.filteringMode = .nearest
        
        
        // 必要な枚数の数を用意
        let needImageCount = Int(self.frame.width / cloudTexeture.size().width) + 2
        
        // action生成
        let moveCloudAction = SKAction.moveBy(x: -cloudTexeture.size().width, y: 0, duration: 5)
        let resetCloudAction = SKAction.moveBy(x: cloudTexeture.size().width, y: 0, duration: 0)
        
        let repeatCloudScrollAction = SKAction.repeatForever(SKAction.sequence([moveCloudAction, resetCloudAction]))
        
        // ループで必要な数Node作成
        for i in 0..<needImageCount {
            
            // nodeの作成
            let cloudSpriteNode = SKSpriteNode(texture: cloudTexeture)
            // 再背面に設定
            cloudSpriteNode.zPosition = -100
            cloudSpriteNode.position = .init(x: cloudTexeture.size().width / 2 + cloudTexeture.size().width * CGFloat(i), y: self.frame.height - cloudTexeture.size().height / 2)
            
            // アクション設定
            cloudSpriteNode.run(repeatCloudScrollAction)
            
            scrollNode.addChild(cloudSpriteNode)
            
        }
        
    }
    
    private func setWall() {
        // Texture生成
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        // アクション生成
        // どのくらい画像を移動させるか
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        // 画面外までスクロールさせるアクション生成
        let wallMoveAction = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        // 親ノードから自身のノードを削除する
        let removeWallAction = SKAction.removeFromParent()
        
        // アニメーションを一つにまとめる
        let wallAnimation = SKAction.sequence([wallMoveAction, removeWallAction])
        
        
        // 設置ポジション
        // 鳥の画像のサイズ取得
        let birdSize = SKTexture.init(imageNamed: "bird_a").size()
        
        // 上と下の壁の隙間を鳥の高さの３倍にする
        let slitLength = birdSize.height * 3
        
        // 隙間の位置の振れ幅を鳥の高さの2.5倍とする
        let randomYRange = birdSize.height * 2.5
        
        // 壁の下限位置を取得（地面の高さ）
        let groundSize = SKTexture.init(imageNamed: "ground").size()
        let centerY = groundSize.height + (self.frame.height - groundSize.height) / 2
        let underWallLowestY = centerY - slitLength / 2 - wallTexture.size().height / 2 - randomYRange / 2
        
        // 壁を生成(アクションで生成する)
        let createWallAnimation = SKAction.run {
            
            // 壁関連のノードを乗せるノードを生成
            let wall = SKNode()
            wall.position = .init(x: self.frame.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50
            
            // 壁の隙間の範囲をランダムに生成
            let randomY = CGFloat.random(in: 0..<randomYRange)
            let underWallY = underWallLowestY + randomY
            
            // 下側の壁生成
            let underWall = SKSpriteNode(texture: wallTexture)
            underWall.position = .init(x: 0, y: underWallY)
            
            
            // 物理演算
            underWall.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            underWall.physicsBody?.isDynamic = false
            underWall.physicsBody?.categoryBitMask = self.wallCategory
            
            wall.addChild(underWall)
            
            // 上側の壁生成
            let upperWall = SKSpriteNode(texture: wallTexture)
            upperWall.position = .init(x: 0, y: underWallY + wallTexture.size().height + slitLength)
            
            // 物理演算
            upperWall.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upperWall.physicsBody?.isDynamic = false
            upperWall.physicsBody?.categoryBitMask = self.wallCategory
            
            
            wall.addChild(upperWall)
            
            
            // スコア用のノードを追加
            let scoreNode = SKNode()
            // position
            scoreNode.position = .init(x: upperWall.size.width + birdSize.width / 2, y: self.frame.height / 2)
            
            // 物理演算
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upperWall.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            // ビットマスク
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            //            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            
            wall.run(wallAnimation)
            self.wallNode.addChild(wall)
        }
        
        
        // 次の壁生成までの待ち時間のアクション生成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        // 無限にループさせ、wallNodeに登録
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
        
        
    }
    
    private func setBird() {
        // 2つのTextureを読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        // Actionを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        // Nodeを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = .init(x: self.frame.width * 0.2, y: self.frame.height * 0.6)
        
        
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        // 回転させない
        bird.physicsBody?.allowsRotation = false
        
        // 衝突のカテゴリー
        bird.physicsBody?.categoryBitMask = self.birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | scoreCategory
        
        
        // Actionを登録
        bird.run(flap)
        
        // nodeに追加
        addChild(bird)
    }
    
    
    // タップ時の処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 鳥が回転している間は処理させない
        if isRotatingEffect { return }
        
        if scrollNode.speed > 0 {
            
            // 速度を一旦０にする
            bird.physicsBody?.velocity = CGVector.zero
            // 上方向に力を加える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else {
            restart()
        }
    }
    
    private func restart() {
        // スコアもどす
        score = 0
        scoreLabelNode.text = "Score: \(score)"
        
        // 鳥のポジションを初期位置に戻す
        bird.position = .init(x: self.frame.width * 0.2, y: self.frame.height * 0.7)
        
        // 鳥の物理演算,衝突検知,回転角度を設定
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        wallNode.removeAllChildren()
        
        // 鳥、スクロールノードのスピード設定
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 早期リターン（すでにゲームオーバーだったら）
        if scrollNode.speed <= 0 { return }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            print("スコアアップ",score)
            score += 1
            
            scoreLabelNode.text = "Score: \(score)"
            // ベストスコア更新
            var bestScore = userDefaults.integer(forKey: bestKeyName)
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score: \(bestScore)"
                userDefaults.set(bestScore, forKey: bestKeyName)
                userDefaults.synchronize()
            }
            
            
        } else {
            print("ゲームオーバー", score)
            
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            
            let roll = SKAction.rotate(byAngle: CGFloat.pi * bird.position.y * 0.01, duration: 1)
            bird.run(roll) {
                self.bird.speed = 0
            }
            isRotatingEffect = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isRotatingEffect = false
            }
            
        }
        
    }
    
    
    private func setScoreLabel() {
        score = 0
        // スコアノード
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = .black
        scoreLabelNode.position = .init(x: 10, y: self.frame.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = .left
        scoreLabelNode.text = "Score: \(score)"
        self.addChild(scoreLabelNode)
        
        
        // ベストスコアノード
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = .black
        bestScoreLabelNode.position = .init(x: 10, y: self.frame.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = .left
        
        let bestScore = userDefaults.integer(forKey: bestKeyName)
        bestScoreLabelNode.text = "Best Score: \(bestScore)"
        self.addChild(bestScoreLabelNode)
        
    }
}
