//
//  Room.swift
//  Portal3
//
//  Created by Daniel Parra on 1/26/19.
//  Copyright © 2019 Davidson Family. All rights reserved.
//

import ARKit

class Room: SCNNode {
    
    var spaceShip = SpaceShip()
    var isShowingShip = false
    
    func addSpaceShip() {
        spaceShip.loadModal()
        addChildNode(spaceShip)
    }
    
    func showSpaceShip() {
        spaceShip.isHidden = false
    }
    
    func hideSpaceShip() {
        spaceShip.isHidden = true
    }
}
