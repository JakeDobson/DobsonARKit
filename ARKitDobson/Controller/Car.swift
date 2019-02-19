//
//  Car.swift
//  ARKitDobson
//
//  Created by Josh Dobson on 1/29/18.
//  Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit
import SceneKit

class Car: SCNNode {
    
    var carNode :SCNNode
    
    init(node: SCNNode) {
        self.carNode = node
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.addChildNode(self.carNode)
        // add physics
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.physicsBody?.categoryBitMask = BodyType.car.rawValue
    }
    
    func turnRight() {
        print("right")
        self.physicsBody?.applyTorque(SCNVector4(0, 1.0, 0, -1.0), asImpulse: false)
    }
    
    func turnLeft() {
		print("left")
        self.physicsBody?.applyTorque(SCNVector4(0, 1.0, 0, 1.0), asImpulse: false)
    }
    
    func accelerate() {
		print("accelerate")
        let force = simd_make_float4(0, 0, -2, 0)
        let rotatedForce = simd_mul(self.presentation.simdTransform, force)
        let vectorForce = SCNVector3(rotatedForce.x, rotatedForce.y, rotatedForce.z)
        self.physicsBody?.applyForce(vectorForce, asImpulse: false)
    }
}

