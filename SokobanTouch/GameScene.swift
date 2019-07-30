//
//  GameScene.swift
//  Sokoban
//
//  Created by Александр Б. on 02.09.17.
//  Copyright © 2017 Александр Б. All rights reserved.
//

import SpriteKit
import GameplayKit
import AudioToolbox

class GameScene: SKScene {
    
    var heroX = 0
    var heroY = 0
    
    var recycleX = 1
    var recycleY = 1
    
    var smokeX = 2
    var smokeY = 2
    
    let roomX = 5
    let roomY = 5
    
    let fontSize: CGFloat = 60
    var board = [[SKLabelNode]()]
    
    var delegateView: GameSceneDelegate?
    
    static let roomIcon = "◽️"
    static var smokeIcon = "🚬"
    static let heroIcon = "🏃"
    static let recycleIcon = "🗑"
    static var totalSteps = 0
    
    private enum Direction {
        case left
        case right
        case up
        case down
    }
    
    func removePrint() {
        for x in 0...(roomX - 1) {
            for y in 0...(roomY - 1) {
                board[x][y].removeFromParent()
            }
        }
    }
    
    private func restartGame() {
        heroX = Int.random(in: 0..<roomX) //randomNum(maxNum: 4, minNum: 0)
        heroY = Int.random(in: 0..<roomY) //randomNum(maxNum: 4, minNum: 0)
        
        smokeX = Int.random(in: 1..<roomX - 1) //randomNum(maxNum: roomX - 2, minNum: 1)
        smokeY = Int.random(in: 1..<roomY - 1) //randomNum(maxNum: roomY - 2, minNum: 1)
        
        recycleX = Int.random(in: 0..<roomX) //randomNum(maxNum: 4, minNum: 0)
        recycleY = Int.random(in: 0..<roomY) //randomNum(maxNum: 4, minNum: 0)
        
        while smokeX == heroX && smokeY == heroY || smokeX == recycleX && smokeY == recycleY {
            smokeX = Int.random(in: 1..<roomX - 1) //randomNum(maxNum: roomX - 2, minNum: 1)
            smokeY = Int.random(in: 1..<roomY - 1) //randomNum(maxNum: roomY - 2, minNum: 1)
        }
        
        while recycleX == heroX && recycleY == heroY {
            recycleX = Int.random(in: 0..<roomX) //randomNum(maxNum: 4, minNum: 0)
            recycleY = Int.random(in: 0..<roomY) //randomNum(maxNum: 4, minNum: 0)
        }
        
        removePrint()
        GameScene.smokeIcon = "🚬"
        printBoard()
        GameScene.totalSteps = 0
        
    }
    
    
    private func printBoard() {
        func partOfFunc(_ ix: Int, _ iy: Int, _ text: String) {
            board[ix][iy].text = text
            board[ix][iy].fontName = "Chalkboard SE Bold"  // задаем имя шрифта.
            board[ix][iy].fontColor = SKColor.white // задаем цвет шрифта.
            board[ix][iy].position = CGPoint(x: frame.minX + 70 + CGFloat(ix * 60), y: frame.midY + 150 - CGFloat(iy * 60))
            board[ix][iy].fontSize = fontSize // задаем размер шрифта.
            board[ix][iy].name = "board[0]" // задаем имя спрайта
            addChild(board[ix][iy]) // добавляем на сцену
        }
        for ix in 0...(roomX - 1) {
            if ix > 0 { board.append([SKLabelNode]()) }
            
            for iy in 0...(roomY - 1) {
                
                board[ix].append(SKLabelNode())
                
                switch (ix, iy) {
                case let (x, y) where x == heroX && y == heroY:
                    partOfFunc(ix, iy, GameScene.heroIcon)
                case let (x, y) where x == Int(recycleX) && y == Int(recycleY):
                    partOfFunc(ix, iy, GameScene.recycleIcon)
                case let (x, y) where x == Int(smokeX) && y == Int(smokeY):
                    partOfFunc(ix, iy, GameScene.smokeIcon)
                default:
                    partOfFunc(ix, iy, GameScene.roomIcon)
                }
            }
        }
    }
    
    private func checkBoarders(pos: (x: Int, y: Int), dir: Direction) -> Bool {
        // Если герой вышел за пределы поля.
        if pos.x < 0 || pos.x > (roomX - 1) || pos.y < 0 || pos.y > (roomY - 1) {
            delegateView?.presentAlertView(title: "Внимание!", text: "Нельзя выходить за пределы поля")
            printBoard()
            return false
        }
        
        if pos.x == smokeX && pos.y == smokeY { // если кор-ды героя совпали с сигаретой
            
            switch dir {
            case .up, .down: if smokeY - 1 < 0 || smokeY + 2 > roomY {
                delegateView?.presentAlertView(title: "Внимание!", text: "Нельзя двигать сигарету за пределы поля")
                printBoard()
                return false
                }
            case .right, .left: if smokeX - 1 < 0 || smokeX + 2 > roomX {
                delegateView?.presentAlertView(title: "Внимание!", text: "Нельзя двигать сигарету за пределы поля")
                printBoard()
                return false
                }
            }
        }
        
        if pos.x == recycleX && pos.y == recycleY {
            delegateView?.presentAlertView(title: "Внимание!", text: "Вы не можете двигать корзину!")
            
            printBoard()
            return false
        }
        
        return true
    }
    
    
    private func moveHero(_ dir: Direction) {
        switch dir {
        case .up:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            if checkBoarders(pos: (x: heroX, y: heroY - 1), dir: .up) {
                if heroY - 1 == smokeY && heroX == smokeX { heroY -= 1; smokeY -= 1 } else { heroY -= 1 }
                sumSteps()
                printBoard()
                win()
            }
        case .down:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            if checkBoarders(pos: (x: heroX, y: heroY + 1), dir: .down) {
                if heroY + 1 == smokeY && heroX == smokeX { heroY += 1; smokeY += 1 } else { heroY += 1 }
                sumSteps()
                printBoard()
                win()
            }
        case .left:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            if checkBoarders(pos: (x: heroX - 1, y: heroY), dir: .left) {
                if heroX - 1 == smokeX && heroY == smokeY  { heroX -= 1; smokeX -= 1 } else { heroX -= 1 }
                sumSteps()
                printBoard()
                win()
            }
        case .right:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            if checkBoarders(pos: (x: heroX + 1, y: heroY), dir: .right) {
                if heroX + 1 == smokeX && heroY == smokeY { heroX += 1; smokeX += 1 } else { heroX += 1 }
                sumSteps()
                printBoard()
                win()
            }
        }
    }
    
    private func sumSteps() {
        GameScene.totalSteps += 1
    }
    
    private func win() {
        if smokeX == recycleX && smokeY == recycleY {
            GameScene.smokeIcon = "🗑"
            removePrint()
            printBoard()
            
            delegateView?.presentAlertView(title: "Поздравляем!", text: "Вы выкинули сигарету в мусорку и выиграли в игре за \(String(describing: GameScene.totalSteps)) шагов!")
            restartGame()
        }
    }
    
//    // генератор надписей
//    func textNodeGenerator(text: String, name: String, x: CGFloat, y: CGFloat) -> SKLabelNode {
//        let restartGame = SKLabelNode()
//        restartGame.text = text
//        restartGame.fontName = "Chalkboard SE Bold"  // задаем имя шрифта.
//        restartGame.fontColor = SKColor.white // задаем цвет шрифта.
//        restartGame.position = CGPoint(x: x, y: y)
//        restartGame.fontSize = 40 // задаем размер шрифта.
//        restartGame.name = name // задаем имя спрайта
//        self.addChild(restartGame) // добавляем на сцену
//        return restartGame
//    }
    
    
    // вызывается при первом запуске сцены
    override func didMove(to view: SKView) {
        
        // цвет фона сцены
        backgroundColor = SKColor.black
        // вектор и сила гравитации
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        // добавляем поддержку физики
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        // выключаем внешние воздействия на нашу игру
        self.physicsBody?.allowsRotation = false
        // включаем отображение отладочной информации
        view.showsPhysics = true
        
        
        printBoard() // печатаем доску
        restartGame() // расставляем эл-ты рандомно
       
        
        // создаем кнопки управления
      
        func buttonControl(name: String, link: SKSpriteNode) {
            link.name = name
            link.size.width = CGFloat(100)
            link.size.height = CGFloat(100)
            addChild(link)
        }
        
        // кнопка налево
        let leftButton = SKSpriteNode(imageNamed: "left.png")
        leftButton.position = CGPoint(x: view.scene!.frame.minX + 70, y: view.scene!.frame.minY + 70)
        buttonControl(name: "leftButton", link: leftButton)
        
        // кнопка направо
        let rightButton = SKSpriteNode(imageNamed: "right.png")
        buttonControl(name: "rightButton", link: rightButton)
        rightButton.position = CGPoint(x: view.scene!.frame.maxX - 70, y: view.scene!.frame.minY + 70)
        
        // кнопка вверх
        let upButton = SKSpriteNode(imageNamed: "up.png")
        upButton.position = CGPoint(x: view.scene!.frame.midX, y: view.scene!.frame.minY + 180)
        buttonControl(name: "upButton", link: upButton)
        
        
        // кнопка вниз
        let downButton = SKSpriteNode(imageNamed: "down.png")
        downButton.position = CGPoint(x: view.scene!.frame.midX, y: view.scene!.frame.minY + 70)
        buttonControl(name: "downButton", link: downButton)
        
        // кнопка restart
        let restart = SKSpriteNode(imageNamed: "restart.png")
        restart.position = CGPoint(x: view.scene!.frame.maxX - 30, y: view.scene!.frame.maxY - 30)
        restart.name = "restartGame"
        restart.size.width = CGFloat(40)
        restart.size.height = CGFloat(40)
        self.addChild(restart)
    }
    
    
    // вызывается при нажатии на экран
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = (touch as! UITouch).location(in: self)
            
            if let name = self.atPoint(location).name {
                if name == "restartGame" {
                    //board.isHidden = true // прячем надпись
                    restartGame()
                } else if name == "leftButton" {
                    removePrint()
                    moveHero(.left)
                } else if name == "rightButton" {
                    removePrint()
                    moveHero(.right)
                } else if name == "upButton" {
                    removePrint()
                    moveHero(.up)
                } else if name == "downButton" {
                    removePrint()
                    moveHero(.down)
                }
            }
        }
    }
    
    
    
    
    // вызывается при прекращении нажатия на экран
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    // вызывается при обрыве нажатия на экран, например ,если телефон примет звонок и свернет приложение
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    // вызывается при обработке кадров сцены
    override func update(_ currentTime: TimeInterval) {
        
    }
}

