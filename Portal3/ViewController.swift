//
//  ViewController.swift
//  Portal3
//
//  Created by Davidson Family on 2/14/18.
//  Copyright © 2018 Davidson Family. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AudioToolbox
import Cosmos
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var node: Room!
    let heartStack = CosmosView()
    var starStack = CosmosView()
    var starCounter = 0 {
        didSet {
            starStack.settings.totalStars = starCounter
            starStack.rating = Double(starCounter)
            gameOver()
        }
    }
    
    var heartCounter = 3 {
        didSet {
            heartStack.rating = Double(heartCounter)
            gameOver()
        }
    }

    var player: AVAudioPlayer?
    var maxTimer: Timer?
    var currentTime = ""
    var maxTime = 30  {
        didSet {
            if maxTime % 60 < 10 {
                currentTime = "0\(maxTime / 60):0\(maxTime % 60)"
            } else {
                currentTime = "0\(maxTime / 60):\(maxTime % 60)"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.showsStatistics = true
        navigationController?.navigationBar.transparentNavigationBar()
        
        addRightButton()
        addleftButton()
        setUpTimer()
        setUpNodes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func gameOver() {
        
        if heartCounter <= 0 {
            self.playSound(isBad: true)
            let alert = UIAlertController(title: "Alerta", message: "Haz perdido todas tus vidas 💔", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.navigationController?.dismiss(animated: true, completion: {
                    self.stopPlayer()
                })
            }))
            self.present(alert, animated: true)
        } else if starCounter >= 3 {
            self.playSound(isBad: false)
            
            let alert = UIAlertController(title: "Alerta", message: "Haz encontrado los tres cuartos secretos. Ganaste 🏆", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.navigationController?.dismiss(animated: true, completion: {
                    self.stopPlayer()
                })
            }))
            self.present(alert, animated: true)
        }
    }
    
    func playSound(isBad: Bool) {
        
        var path = ""
        
        if isBad {
            path = "pain"
        } else {
            path = "win"
        }
        
        guard let url = Bundle.main.url(forResource: path, withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: sceneView)
            
            let hitList = sceneView.hitTest(location, options: nil)
            
            if let hitObject = hitList.first {
                let node = hitObject.node
                
                if node.name == "ARShip" {
                    starCounter += 1
                    setUpNodes()
                }
            }
            
        }
    }
    
    private func setUpTimer() {
        maxTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    @objc func fireTimer() {
        maxTime -= 1
        navigationItem.title = currentTime
        guard maxTime == 0 else {
            return
        }
        heartCounter -= 1
        playSound(isBad: true)
        setUpNodes()
    }
    
    func addleftButton(){
        
        starStack.rating = Double(starCounter)
        starStack.settings.totalStars = starCounter
        starStack.settings.starSize = 15
        starStack.settings.filledImage = UIImage.init(named: "star")
        starStack.settings.updateOnTouch = false
        starStack.settings.fillMode = .full
        
        let leftBarButton = UIBarButtonItem(customView: starStack)
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func addRightButton(){
        
        heartStack.rating = 3
        heartStack.settings.totalStars = 3
        heartStack.settings.starSize = 15
        heartStack.settings.filledImage = UIImage.init(named: "redHeart")
        heartStack.settings.emptyImage = UIImage.init(named: "whiteHeart")
        heartStack.settings.updateOnTouch = false
        heartStack.settings.fillMode = .full
        
        let rightBarButton = UIBarButtonItem(customView: heartStack)
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func stopPlayer() {
        maxTimer?.invalidate()
        if let play = player {
            print("stopped")
            play.pause()
            player = nil
            print("player deallocated")
        } else {
            print("player was already deallocated")
        }
    }
    
    private func setUpNodes() {
        maxTime = 30
        setupScene()
    }
    
    private func createNode(x: Int, y: Int, z: Int) -> Room {
        let node = Room()
        node.position = SCNVector3.init(x, y, z)
        
        let leftWall = createBox(isFloor: false)
        leftWall.position = SCNVector3.init((-length / 2) + width, 0, 0)
        leftWall.eulerAngles = SCNVector3.init(0, 180.0.degreesToRadians, 0)
        
        let rightWall = createBox(isFloor: false)
        rightWall.position = SCNVector3.init((length / 2) - width, 0, 0)
        
        let topWall = createBox(isFloor: false)
        topWall.position = SCNVector3.init(0, (height / 2) - width, 0)
        topWall.eulerAngles = SCNVector3.init(0, 0, 90.0.degreesToRadians)
        
        let bottomWall = createBox(isFloor: true)
        bottomWall.position = SCNVector3.init(0, (-height / 2) + width, 0)
        bottomWall.eulerAngles = SCNVector3.init(0, 0, -90.0.degreesToRadians)
        
        let backWall = createBox(isFloor: false)
        backWall.position = SCNVector3.init(0, 0, (-length / 2) + width)
        backWall.eulerAngles = SCNVector3.init(0, 90.0.degreesToRadians, 0)
        
        let frontWall = createBox(isFloor: false)
        frontWall.position = SCNVector3.init(0, 0, (length / 2) + width)
        frontWall.eulerAngles = SCNVector3.init(0, -90.0.degreesToRadians, 0)
        
        //Create Light
        
        let light = SCNLight()
        light.type = .spot
        light.spotInnerAngle = 70
        light.spotOuterAngle = 120
        light.zNear = 0.00001
        light.zFar = 5
        light.castsShadow = true
        light.shadowRadius = 200
        light.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        light.shadowMode = .deferred
        let constraint = SCNLookAtConstraint(target: bottomWall)
        constraint.isGimbalLockEnabled = true
        
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3.init(0, 0.4, 0)
        lightNode.constraints = [constraint]
        node.addChildNode(lightNode)
        
        //Adding Nodes to Main Node
        node.addChildNode(leftWall)
        node.addChildNode(rightWall)
        node.addChildNode(topWall)
        node.addChildNode(bottomWall)
        node.addChildNode(backWall)
        node.addChildNode(frontWall)
        
        node.addSpaceShip()
        
        return node
    }
    
    func setupScene() {
        
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        
        node = createNode(x: Int.random(in: -2...2), y: 0, z: Int.random(in: -2...2))
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    func getUserVector(frame: simd_float4x4?) -> (SCNVector3) { // (direction, position)
        if let frame = frame {
            let mat = SCNMatrix4(frame) // 4x4 transform matrix describing camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (pos)
        }
        return SCNVector3(0, 0, 0)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do something with the new transform
        let currentTransform = frame.camera.transform
        let value = getUserVector(frame: currentTransform)
        
        if  value.x >= (node.position.x + Float((-length / 2) + width)) &&
            value.x <= (node.position.x + Float((length / 2) - width)) &&
            value.y >= (node.position.y + Float((-height / 2) + width)) &&
            value.y <= (node.position.y + Float((height / 2) - width)) &&
            value.z >= (node.position.z + Float((-length / 2) + width)) &&
            value.z <= (node.position.z + Float((length / 2) + width)) {

            if !node.isShowingShip {
                node.isShowingShip = true
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                node.showSpaceShip()
            }
        } else {
            node.isShowingShip = false
            node.hideSpaceShip()
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension UINavigationBar {
    func transparentNavigationBar() {
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
    }
}
