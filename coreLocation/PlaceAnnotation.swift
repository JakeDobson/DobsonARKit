//
//  PlaceAnnotation.swift
//  NeAR Me
//
//  Created by Josh Dobson on 2/5/18.
//  Copyright © 2018 Josh Dobson. All rights reserved.
//

import UIKit
import ARCL
import CoreLocation
import SceneKit

class PlaceAnnotation: LocationNode {
	var title: String!
	var annotationNode: SCNNode
	
	init(location: CLLocation?, title: String) {
		self.annotationNode = SCNNode()
		super.init(location: location)
		
		self.title = title
		
		initializeUI()
	}
	
	private func center(node: SCNNode) {
		let (min,max) = node.boundingBox
		let dx = min.x + 0.5 * (max.x - min.x)
		let dy = min.y + 0.5 * (max.y - min.y)
		let dz = min.z + 0.5 * (max.z - min.z)
		node.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
	}
	
	private func initializeUI() {
		let plane = SCNPlane(width: 5, height: 3)
		plane.cornerRadius = 0.2
		plane.firstMaterial?.diffuse.contents = UIColor.blue
		
		let text  = SCNText(string: self.title, extrusionDepth: 0)
		text.containerFrame = CGRect(x: 0, y: 0, width: 5, height: 3)
		text.isWrapped = true
		text.font = UIFont(name: "Futura", size: 1.0)
		text.alignmentMode = kCAAlignmentCenter
		text.truncationMode = kCATruncationMiddle
		text.firstMaterial?.diffuse.contents = UIColor.white
		
		let textNode = SCNNode(geometry: text)
		textNode.position = SCNVector3(0,0,0.2)
		center(node: textNode)
		
		
		let planeNode = SCNNode(geometry: plane)
		planeNode.addChildNode(textNode)
		self.annotationNode.scale = SCNVector3(3,3,3)
		self.annotationNode.addChildNode(planeNode)
		
		let billboardConstraint = SCNBillboardConstraint()
		billboardConstraint.freeAxes = SCNBillboardAxis.Y
		constraints = [billboardConstraint]
		
		self.addChildNode(self.annotationNode)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}



