//
//  Extensions.swift
//  Portal3
//
//  Created by Davidson Family on 2/14/18.
//  Copyright © 2018 Davidson Family. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

var width : CGFloat = 0.01
var height : CGFloat = 2
var length : CGFloat = 2

var doorLength : CGFloat = 0.3

func createBox(isFloor : Bool) -> SCNNode {
    let node = SCNNode()
    
    //Add First Box
    let firstBox = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
    firstBox.firstMaterial?.diffuse.contents = isFloor ? UIImage.init(named: "grass") : UIImage.init(named: "bricks")
    let firstBoxNode = SCNNode(geometry: firstBox)
    firstBoxNode.renderingOrder = 200
    
    node.addChildNode(firstBoxNode)
    
    //Add Masked Box
    let maskedBox = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
    maskedBox.firstMaterial?.diffuse.contents = isFloor ? UIImage.init(named: "grass") : UIImage.init(named: "bricks")
    maskedBox.firstMaterial?.transparency = 0.000000001
    
    let maskedBoxNode = SCNNode(geometry: maskedBox)
    maskedBoxNode.renderingOrder = 100
    maskedBoxNode.position = SCNVector3.init(width, 0, 0)
    
    node.addChildNode(maskedBoxNode)
    
    return node
}

extension FloatingPoint {
    var degreesToRadians : Self {
        return self * .pi / 180
    }
    var radiansToDegrees : Self {
        return self * 180 / .pi
    }
}
