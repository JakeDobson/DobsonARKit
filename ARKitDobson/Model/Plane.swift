//  Plane.swift
//  ARKitDobson
//  Created by Jacob Dobson on 1/10/18.
//  Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit
import ARKit
import SceneKit
//subclass Plane
class Plane: SCNNode {
    var anchor :ARPlaneAnchor!
    private var planeGeometry :SCNPlane!
    
    init(anchor :ARPlaneAnchor) {
        
        self.anchor = anchor
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Plane init failed")
    }
    
    private func setup() {
        self.planeGeometry = SCNPlane(width: CGFloat(self.anchor.extent.x), height: CGFloat(self.anchor.extent.z))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "tronGrid.png")
        
        self.planeGeometry.firstMaterial = material
        
        let planeNode = SCNNode(geometry: self.planeGeometry)
        
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)
        
        self.addChildNode(planeNode)
    }
    
    func update(anchor :ARPlaneAnchor) {
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
    
}
