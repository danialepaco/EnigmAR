//
//  SpaceShip.swift
//  Portal3
//
//  Created by Daniel Parra on 1/26/19.
//  Copyright © 2019 Davidson Family. All rights reserved.
//

import ARKit

class SpaceShip: SCNNode {
    
    func loadModal() {
        
//        let value = Int.random(in: 0...4)
//        var path = ""
//
//        switch value {
//        case 0:
//            path = "art.scnassets/ship.scn"
//            break
//        case 1:
//            path = "art.scnassets/candle/candle.scn"
//            break
//        case 2:
//            path = "art.scnassets/chair/chair.scn"
//            break
//        case 3:
//            path = "art.scnassets/lamp/lamp.scn"
//            break
//        case 4:
//            path = "art.scnassets/cup/cup.scn"
//            break
//        default:
//            break
//        }
        
        guard let virtualOjectScene = SCNScene(named: "art.scnassets/ship.scn") else {return}
        
        let wrapperNode = SCNNode()
        
        for child in virtualOjectScene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        
        self.addChildNode(wrapperNode)
        
    }
    
}
