//
//  GameScene.swift
//  FlappyBird
//
//  Created by Austin Dotto on 7/28/18.
//  Copyright © 2018 Austin Dotto. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    
    enum Collider: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    var timer = Timer()
    var score = 0
    var gameOver = false
   
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        setupGame()
        

    }
    
    func setupGame(){
        
       timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        let backgroundTexture = SKTexture(imageNamed: "bg.png")
        
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -backgroundTexture.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: backgroundTexture.size().width, dy: 0), duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        
        var i: CGFloat = 0
        
        while i < 3 {
            
            background = SKSpriteNode(texture: backgroundTexture)
            
            background.position = CGPoint(x: backgroundTexture.size().width * i, y: self.frame.midY)
            
            background.size.height = self.frame.height
            
            background.run(moveBGForever)
            
            background.zPosition = -2
            
            self.addChild(background)
            
            i += 1
            
        }
        
        
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let birdFlap = SKAction.repeatForever(animation)
        bird = SKSpriteNode(texture: birdTexture)
        
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.run(birdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        bird.physicsBody!.isDynamic = false
        bird.physicsBody!.contactTestBitMask = Collider.Object.rawValue
        bird.physicsBody!.categoryBitMask = Collider.Bird.rawValue
        bird.physicsBody!.collisionBitMask = Collider.Bird.rawValue
        self.addChild(bird)
        
        
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic = false
        ground.physicsBody!.contactTestBitMask = Collider.Object.rawValue
        ground.physicsBody!.categoryBitMask = Collider.Object.rawValue
        ground.physicsBody!.collisionBitMask = Collider.Object.rawValue
        self.addChild(ground)
        
        scoreLabel.fontName = "Baskerville"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        self.addChild(scoreLabel)
        
    }
    
    @objc func makePipes(){
        
        let gapHeight = bird.size.height * 4
        let movement = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffset = CGFloat(movement) - self.frame.height / 4
        let removePipes = SKAction.removeFromParent()
        let movePipe = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        
        let moveAndRemovePipes = SKAction.sequence([movePipe, removePipes])
        
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture.size().height / 2 + gapHeight / 2 + pipeOffset)
        pipe1.run(moveAndRemovePipes)
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipe1.physicsBody!.isDynamic = false
        pipe1.physicsBody!.contactTestBitMask = Collider.Object.rawValue
        pipe1.physicsBody!.categoryBitMask = Collider.Object.rawValue
        pipe1.physicsBody!.collisionBitMask = Collider.Object.rawValue
        pipe1.zPosition = -1
        self.addChild(pipe1)
        
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipeTexture.size().height / 2 - gapHeight / 2 + pipeOffset)
        pipe2.run(moveAndRemovePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture2.size())
        pipe2.physicsBody!.isDynamic = false
        pipe2.physicsBody!.contactTestBitMask = Collider.Object.rawValue
        pipe2.physicsBody!.categoryBitMask = Collider.Object.rawValue
        pipe2.physicsBody!.collisionBitMask = Collider.Object.rawValue
        pipe2.zPosition = -1
        self.addChild(pipe2)
        
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width, height: gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(moveAndRemovePipes)
        gap.physicsBody!.contactTestBitMask = Collider.Bird.rawValue
        gap.physicsBody!.categoryBitMask = Collider.Gap.rawValue
        gap.physicsBody!.collisionBitMask = Collider.Gap.rawValue
        self.addChild(gap)
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver == false {
            
            if contact.bodyA.categoryBitMask == Collider.Gap.rawValue || contact.bodyB.categoryBitMask == Collider.Gap.rawValue {
                
                score += 1
                
                scoreLabel.text = String(score)
            
                
                
            } else {
                
                self.speed = 0
                
                gameOver = true
                
                
                timer.invalidate()
                
                gameOverLabel.fontName = "Baskerville"
                
                gameOverLabel.fontSize = 30
                
                gameOverLabel.text = "Game Over!"
                
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                
                self.addChild(gameOverLabel)
                
            }
            
        }
    }
    
 
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false {
            
            bird.physicsBody!.isDynamic = true
            
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
           
            
            
        } else {
            
            gameOver = false
            
            score = 0
            
            self.speed = 1
            
            self.removeAllChildren()
            
            setupGame()
           
            
            
        }
        }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
