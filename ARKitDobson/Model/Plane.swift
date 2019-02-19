//  Plane.swift
//  ARKitDobson
//  Created by Jacob Dobson on 1/10/18.
//  Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit
import ARKit
import SceneKit
//subclass Plane
class Plane: SCNNode {
	//globals
    var anchor :ARPlaneAnchor!
    private var planeGeometry :SCNPlane!
    //init anchor and give plane node characteristics(material, geometry, etc)
    init(anchor :ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        setupPlaneNode()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Plane init failed")
    }
    //func for setting up the plane's geometry, first material, position, rotation, and adding as child node
    private func setupPlaneNode() {
        planeGeometry = SCNPlane(width: CGFloat(self.anchor.extent.x), height: CGFloat(self.anchor.extent.z))
        
        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "tronGrid.png")
		material.diffuse.contents = UIColor.clear
        planeGeometry.firstMaterial = material
        
        let planeNode = SCNNode(geometry: planeGeometry)
        
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        //rotate the plane 90 degrees to make a horizontal flat surface
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)
		
        self.addChildNode(planeNode)
    }
    //update anchor when new plane found on same surface(merges planes into one, larger, plane)
    func update(anchor :ARPlaneAnchor) {
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
    
}
