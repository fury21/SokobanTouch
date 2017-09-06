//
//  GameScene.swift
//  Sokoban
//
//  Created by Александр Б. on 02.09.17.
//  Copyright © 2017 Александр Б. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene {
    
    var heroX = 0
    var heroY = 0
    static let heroIcon = "🏃"
    
    var recycleX = 3
    var recycleY = 3
    static let recycleIcon = "🗑"
    
    var smokeX = 2
    var smokeY = 3
    static var smokeIcon = "🚬"
    
    let roomX = 5
    let roomY = 5
    static let roomIcon = "◽️"
    
    let fontSize: CGFloat = 60
    
    var board = [[SKLabelNode]()]
    
    enum Direction {
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
    
    func restartGame() {
        func randomNum(maxNum: Int, minNum: Int) -> Int {
            return Int(arc4random_uniform(UInt32(maxNum-minNum)) + 1) + minNum
        }
        
        heroX = randomNum(maxNum: 4, minNum: 0)
        heroY = randomNum(maxNum: 4, minNum: 0)
        
        smokeX = randomNum(maxNum: roomX - 2, minNum: 1)
        smokeY = randomNum(maxNum: roomY - 2, minNum: 1)
        
        recycleX = randomNum(maxNum: 4, minNum: 0)
        recycleY = randomNum(maxNum: 4, minNum: 0)
        
        while smokeX == heroX && smokeY == heroY || smokeX == recycleX && smokeY == recycleY {
            smokeX = randomNum(maxNum: roomX - 2, minNum: 1)
            smokeY = randomNum(maxNum: roomY - 2, minNum: 1)
        }
        
        while recycleX == heroX && recycleY == heroY {
            recycleX = randomNum(maxNum: 4, minNum: 0)
            recycleY = randomNum(maxNum: 4, minNum: 0)
        }
        
        removePrint()
        GameScene.smokeIcon = "🚬"
        printBoard()
        
    }
    
    
    func printBoard() {
        func partOfFunc(_ ix: Int, _ iy: Int, _ text: String) {
            board[ix][iy].text = text
            board[ix][iy].fontName = "Chalkboard SE Bold"  // задаем имя шрифта.
            board[ix][iy].fontColor = SKColor.white // задаем цвет шрифта.
            board[ix][iy].position = CGPoint(x: frame.minX + 70 + CGFloat(ix * 60), y: frame.midY + 150 - CGFloat(iy * 60))
            board[ix][iy].fontSize = fontSize // задаем размер шрифта.
            board[ix][iy].name = "board[0]" // задаем имя спрайта
            self.addChild(board[ix][iy]) // добавляем на сцену
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
    
    func checkBoarders(pos: (x: Int, y: Int), dir: Direction) -> Bool {
        // Если герой вышел за пределы поля.
        if pos.x < 0 || pos.x > (roomX - 1) || pos.y < 0 || pos.y > (roomY - 1) {
            print("Нельзя выходить за пределы поля")
            printBoard()
            return false
        }
        
        if pos.x == smokeX && pos.y == smokeY { // если кор-ды героя совпали с сигаретой
            
            switch dir {
            case .up, .down: if smokeY - 1 < 0 || smokeY + 2 > roomY {
                print("Нельзя двигать сигарету за пределы поля")
                printBoard()
                return false
                }
            case .right, .left: if smokeX - 1 < 0 || smokeX + 2 > roomX {
                print("Нельзя двигать сигарету за пределы поля")
                printBoard()
                return false
                }
            }
        }
        
        if pos.x == recycleX && pos.y == recycleY {
            print("Вы не можете двигать корзину!")
            printBoard()
            return false
        }
        return true
    }
    
    
    func moveHero(_ dir: Direction) {
        switch dir {
        case .up:
            if checkBoarders(pos: (x: heroX, y: heroY - 1), dir: .up) {
                if heroY - 1 == smokeY && heroX == smokeX { heroY -= 1; smokeY -= 1 } else { heroY -= 1 }
                printBoard()
                win()
            }
        case .down:
            if checkBoarders(pos: (x: heroX, y: heroY + 1), dir: .down) {
                if heroY + 1 == smokeY && heroX == smokeX { heroY += 1; smokeY += 1 } else { heroY += 1 }
                printBoard()
                win()
            }
        case .left:
            if checkBoarders(pos: (x: heroX - 1, y: heroY), dir: .left) {
                if heroX - 1 == smokeX && heroY == smokeY  { heroX -= 1; smokeX -= 1 } else { heroX -= 1 }
                printBoard()
                win()
            }
        case .right:
            if checkBoarders(pos: (x: heroX + 1, y: heroY), dir: .right) {
                if heroX + 1 == smokeX && heroY == smokeY { heroX += 1; smokeX += 1 } else { heroX += 1 }
                printBoard()
                win()
            }
        }
    }
    
    
    
    func win() {
        if smokeX == recycleX && smokeY == recycleY {
            GameScene.smokeIcon = "🗑"
            removePrint()
            printBoard()
            print("Вы выкинули сигарету в мусорку и выиграли в игре! Поздравляем!")
            
        }
    }
    
    
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
        
        // создаем кнопки управления
        
        // кнопка налево
        let leftButton = SKShapeNode()
        leftButton.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 45, height: 45)).cgPath
        leftButton.position = CGPoint(x: view.scene!.frame.minX+30, y: view.scene!.frame.minY+30)
        leftButton.fillColor = UIColor.gray
        leftButton.strokeColor = UIColor.gray
        leftButton.lineWidth = 10
        leftButton.name = "leftButton"
        self.addChild(leftButton)
        
        
        // кнопка направо
        let rightButton = SKShapeNode()
        rightButton.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 45, height: 45)).cgPath
        rightButton.position = CGPoint(x: view.scene!.frame.maxX-80, y: view.scene!.frame.minY+30)
        rightButton.fillColor = UIColor.gray
        rightButton.strokeColor = UIColor.gray
        rightButton.lineWidth = 10
        rightButton.name = "rightButton"
        self.addChild(rightButton)
        
        
        // кнопка вверх
        let upButton = SKShapeNode()
        upButton.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 45, height: 45)).cgPath
        upButton.position = CGPoint(x: view.scene!.frame.midX-30, y: view.scene!.frame.minY+100)
        upButton.fillColor = UIColor.gray
        upButton.strokeColor = UIColor.gray
        upButton.lineWidth = 10
        upButton.name = "upButton"
        self.addChild(upButton)
        
        
        // кнопка вниз
        let downButton = SKShapeNode()
        downButton.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 45, height: 45)).cgPath
        downButton.position = CGPoint(x: view.scene!.frame.midX-30, y: view.scene!.frame.minY+30)
        downButton.fillColor = UIColor.gray
        downButton.strokeColor = UIColor.gray
        downButton.lineWidth = 10
        downButton.name = "downButton"
        self.addChild(downButton)
        
        // кнопка рестарта игры
        let restartGame = SKLabelNode()
        restartGame.text = "Начать заново"
        restartGame.fontName = "Chalkboard SE Bold"  // задаем имя шрифта.
        restartGame.fontColor = SKColor.white // задаем цвет шрифта.
        restartGame.position = CGPoint(x: frame.midX, y: frame.midY + 270)
        restartGame.fontSize = 40 // задаем размер шрифта.
        restartGame.name = "restartGame" // задаем имя спрайта
        self.addChild(restartGame) // добавляем на сцену
    }
    
    
    // вызывается при нажатии на экран
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = (touch as! UITouch).location(in: self)
            
            if let name = self.atPoint(location).name {
                if name == "restartGame" {
                    
                    //board.isHidden = true // прячем надпись
                    restartGame()
                }
            }
        }
        
        // перебираем все точки, куда прикоснулся палец
        for touch in touches {
            // определяем координаты касания для точки
            let touchLocation = touch.location(in: self)
            // проверяем, есть ли объект по этим координатам, и если есть, то не наша ли это кнопка
            guard let touchedNode = self.atPoint(touchLocation) as? SKShapeNode,
                touchedNode.name == "leftButton" || touchedNode.name == "rightButton" || touchedNode.name == "upButton" || touchedNode.name == "downButton"
                else {
                    return
            }
            
            // если это наша кнопка, заливаем ее зеленой
            touchedNode.fillColor = .green
            
            // определяем, какая кнопка нажата и поворачиваем в нужную сторону
            if touchedNode.name == "leftButton" {
                removePrint()
                moveHero(.left)
            } else if touchedNode.name == "rightButton" {
                removePrint()
                moveHero(.right)
            } else if touchedNode.name == "upButton" {
                removePrint()
                moveHero(.up)
            } else if touchedNode.name == "downButton" {
                removePrint()
                moveHero(.down)
            }
        }
    }
    
    
    
    
    // вызывается при прекращении нажатия на экран
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // повторяем все то же самое для действия, когда палец отрывается от экрана
        for touch in touches {
            let touchLocation = touch.location(in: self)
            guard let touchedNode = self.atPoint(touchLocation) as? SKShapeNode,
                touchedNode.name == "leftButton" || touchedNode.name == "rightButton" || touchedNode.name == "upButton" || touchedNode.name == "downButton"
                else {
                    return
            }
            // но делаем цвет снова серый
            touchedNode.fillColor = UIColor.gray
        }
    }
    // вызывается при обрыве нажатия на экран, например ,если телефон примет звонок и свернет приложение
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    // вызывается при обработке кадров сцены
    override func update(_ currentTime: TimeInterval) {
        
    }
}

