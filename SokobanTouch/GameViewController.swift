//
//  GameViewController.swift
//  Snake GB
//
//  Created by Александр Б. on 02.09.17.
//  Copyright © 2017 Александр Б. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var scene: GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // создаем экземпляр сцены
        let scene = GameScene(size: view.bounds.size)
        scene.delegateView = self
        // получаем главную область экрана
        guard let skView = view as? SKView else {
            return
        }
        // включаем отображение fps (Количество кадров в секунду)
        skView.showsFPS = true
        // показывать количество объектов на экране
        skView.showsNodeCount = true
        // включает включаем произвольный порядок рендеринга объектов в узле
        skView.ignoresSiblingOrder = true
        // режим отображения сцены, растягивается на все доступное пространство
        scene.scaleMode = .resizeFill
        // добавляем сцену на экран
        skView.presentScene(scene)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: GameSceneDelegate {
    func presentAlertView(title: String, text: String) {
        //Создаем контроллер
        let alter = UIAlertController(title: title, message: text, preferredStyle: .alert)
        //Создаем кнопку для UIAlertController
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        //Добавляем кнопку на UIAlertController
        alter.addAction(action)
        //показываем UIAlertController
        present(alter, animated: true)
        //present(alter, animated: true, completion: nil)
    }
}
