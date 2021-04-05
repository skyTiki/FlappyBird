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
    var coinNode: SKNode!
    var starNode: SKNode!
    
    var bird: SKSpriteNode!
    
    
    // 衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0 // 0...0001 → 1
    let groundCategory: UInt32 = 1 << 1 // 0....0010 → 2
    let wallCategory: UInt32 = 1 << 2 // 0...0100 → 4
    let scoreCategory: UInt32 = 1 << 3 // 0...1000 → 8
    let coinCategory: UInt32 = 1 << 4 // 0...10000 →16
    let starCategory: UInt32 = 1 << 5 // 0...100000 →32
    
    // スコア用
    var score = 0
    let userDefaults: UserDefaults = UserDefaults.standard
    let bestKeyName = "BEST"
    
    var scoreLabelNode: SKLabelNode!
    var bestScoreLabelNode: SKLabelNode!
    
    // アイテム
    var coinCount = 0
    var coinCountLabel: SKLabelNode!
    var isStarApperedStatus = false
    var gettingStar = false
    
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
        coinNode = SKNode()
        starNode = SKNode()
        scrollNode.addChild(wallNode)
        scrollNode.addChild(coinNode)
        scrollNode.addChild(starNode)
        addChild(scrollNode)
        
        // ノードの設定
        setGround()
        setClound()
        setWall()
        setBird()
        setCoin()
        setStar()
        
        setScoreLabel()
        setCoinCountLabel()
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
    
    private func setCoin() {
        
        // texture
        let coinTexture = SKTexture(imageNamed: "coin")
        coinTexture.filteringMode = .linear
        
        // 横幅とコインの大きさ設定
        let scrollDistance = self.frame.width + coinTexture.size().width / 2
        let coinSize: CGFloat = 50
        
        // 子ノード（coin）に設定するaction
        let scrollCoin = SKAction.moveBy(x: -scrollDistance, y: 0, duration: 4)
        let removeParent = SKAction.removeFromParent()
        let coinScrollAnimation = SKAction.sequence([scrollCoin,removeParent])
        
        // 親ノード（coinNode)に設定するアクション
        let createCoin = SKAction.run {
            // コインの高さの位置を設定
            let randomHeight = CGFloat.random(in: -(coinSize)...(coinSize*3))
            let coinPositionY = self.frame.height / 2 + randomHeight
            
            // ノード作成
            let coin = SKSpriteNode(texture: coinTexture)
            coin.size = .init(width: coinSize, height: coinSize)
            coin.position = .init(x: scrollDistance, y: coinPositionY)
            coin.zPosition = -30 // 壁よりも前に表示
            
            // 物理演算
            coin.physicsBody = SKPhysicsBody(circleOfRadius: coinSize / 2)
            coin.physicsBody?.isDynamic = false
            coin.physicsBody?.categoryBitMask = self.coinCategory
            coin.physicsBody?.contactTestBitMask = self.birdCategory
            
            // アクション登録
            coin.run(coinScrollAnimation)
            
            self.coinNode.addChild(coin)
        }
        
        let wait = SKAction.wait(forDuration: 1.5)
        let createAnimation = SKAction.repeatForever(SKAction.sequence([createCoin,wait]))
        
        coinNode.run(createAnimation)
        
    }
    
    private func setStar() {
        let starTexture = SKTexture(imageNamed: "star")
        starTexture.filteringMode = .linear
        
        let starSize: CGFloat = 50
        let scrollDistance = self.frame.width + starSize / 2
        
        
        // starにつけるアクション
        // 左スクロール
        let scrollLeft = SKAction.moveBy(x: -(scrollDistance + starSize), y: 0, duration: 3)
        // 上下のスクロール
        let scrollUp = SKAction.moveTo(y: self.frame.height, duration: 2.0)
        let groundSize = SKTexture(imageNamed: "ground").size()
        let scrollDown = SKAction.moveTo(y: groundSize.height, duration: 2.0)
        // 同時実行
        let scrollActionGroup = SKAction.group([scrollLeft, SKAction.sequence([scrollDown, scrollUp])])
        
        let removeFromParent = SKAction.removeFromParent()
        let starAction = SKAction.repeat(.sequence([scrollActionGroup, removeFromParent]), count: 5)
        
        let createStar = SKAction.run {
            
            if !self.isStarApperedStatus { return }
            
            // Starが入ってくる位置（地面からスター３つ分上〜画面上部まで）
            let startPosition = CGFloat.random(in: (groundSize.height + starSize * 3)...(self.frame.height - starSize * 3))
            
            let star = SKSpriteNode(texture: starTexture)
            star.size = .init(width: starSize, height: starSize)
            star.position = .init(x: scrollDistance, y: startPosition)
            star.zPosition = -30
            
            // 物理演算
            star.physicsBody = SKPhysicsBody(circleOfRadius: starSize / 2)
            star.physicsBody?.isDynamic = false
            star.physicsBody?.categoryBitMask = self.starCategory
            star.physicsBody?.contactTestBitMask = self.birdCategory
            
            star.run(starAction)
            self.starNode.addChild(star)
        }
        
        let wait = SKAction.wait(forDuration: 10.0)
        let starAnimation = SKAction.repeatForever(SKAction.sequence([createStar, wait]))
        starNode.run(starAnimation)
        
    }
    
    
    private func setCoinCountLabel() {
        coinCount = 0
        
        coinCountLabel = SKLabelNode()
        coinCountLabel.fontColor = .black
        coinCountLabel.position = .init(x: 10, y: self.frame.height - 120)
        coinCountLabel.zPosition = 100
        coinCountLabel.horizontalAlignmentMode = .left
        coinCountLabel.text = "Coin: \(coinCount)"
        
        addChild(coinCountLabel)
        
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
        
        // アイテム
        coinCount = 0
        coinCountLabel.text = "Coin: \(coinCount)"
        isStarApperedStatus = false
        
        // 鳥のポジションを初期位置に戻す
        bird.position = .init(x: self.frame.width * 0.2, y: self.frame.height * 0.7)
        
        // 鳥の物理演算,衝突検知,回転角度を設定
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        wallNode.removeAllChildren()
        coinNode.removeAllChildren()
        starNode.removeAllChildren()
        
        // 鳥、スクロールノードのスピード設定
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 早期リターン（すでにゲームオーバーだったら）
        if scrollNode.speed <= 0 { return }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            score += 1
            print("スコアアップ",score)
            
            scoreLabelNode.text = "Score: \(score)"
            // ベストスコア更新
            var bestScore = userDefaults.integer(forKey: bestKeyName)
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score: \(bestScore)"
                userDefaults.set(bestScore, forKey: bestKeyName)
                userDefaults.synchronize()
            }
            
            
        } else if (contact.bodyA.categoryBitMask & coinCategory) == coinCategory || (contact.bodyB.categoryBitMask & coinCategory) == coinCategory {
            // 取得したコインのノードを削除する。（基本的に一番最初のノードを取得することになるため、firstを指定）
            coinNode.children.first?.removeFromParent()
            coinCount += 1
            coinCountLabel.text = "Coin: \(coinCount)"
            
            if coinCount >= 5 {
                isStarApperedStatus = true
            }
            print("Coin取得", coinCount)
            
        } else if (contact.bodyA.categoryBitMask & starCategory) == starCategory || (contact.bodyB.categoryBitMask & starCategory) == starCategory  {
            
            // 早期リターン（スターを取得していたら）
            if gettingStar { return }
            
            // スターアイコン取得
            print("Star取得")
            
            self.gettingStar = true
            bird.physicsBody?.collisionBitMask = groundCategory
            scrollNode.speed = 3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.gettingStar = false
                self.bird.physicsBody?.collisionBitMask = self.groundCategory | self.wallCategory
                self.scrollNode.speed = 1
            }
            
        } else {
            
            // 早期リターン（スターを取得していたら）
            if gettingStar { return }
            
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
