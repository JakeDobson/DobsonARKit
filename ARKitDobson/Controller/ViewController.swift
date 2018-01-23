//  ViewController.swift
//  ARKitDobson
//  Created by Jacob Dobson on 1/7/18.
//  Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit
import SceneKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {
	//outlets
	@IBOutlet var sceneView: ARSCNView!
	var spheres = [SCNNode]()
	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		// Set the view's delegate
		sceneView.delegate = self
		// Show statistics such as fps and timing information
		sceneView.showsStatistics = true
		// Set the scene to the view
		let scene = SCNScene()
		sceneView.scene = scene
		//helper funcs
		addCrossSign()
		registerGestureRecognizers()
	}
	
	private func registerGestureRecognizers() {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
		self.sceneView.addGestureRecognizer(tapGestureRecognizer)
	}
	
	@objc func tapped(recognizer: UITapGestureRecognizer) {
		
		let scnView = recognizer.view as! ARSCNView
		let touchLocation = self.sceneView.center
		
		let hitTestResults = scnView.hitTest(touchLocation, types: .featurePoint)
		
		if (!hitTestResults.isEmpty) {
			guard let hitTestResult = hitTestResults.first else {
				return
			}
			
			let sphere = SCNSphere(radius: 0.005)
			
			let mat = SCNMaterial()
			mat.diffuse.contents = UIColor.red
			sphere.firstMaterial = mat
			let sphereNode = SCNNode(geometry: sphere)
			sphereNode.position = SCNVector3(hitTestResult.worldTransform.columns.3.x,
											 hitTestResult.worldTransform.columns.3.y,
											 hitTestResult.worldTransform.columns.3.z)
			self.sceneView.scene.rootNode.addChildNode(sphereNode)
			self.spheres.append(sphereNode)
			
			if self.spheres.count == 2 {
				// calculate distance
				let firstPoint = self.spheres.first!
				let secondPoint = self.spheres.last!
				
				let position = SCNVector3Make(secondPoint.position.x - firstPoint.position.x,
											  secondPoint.position.y - firstPoint.position.y,
											  secondPoint.position.z - firstPoint.position.z)
				let result = sqrt(position.x * position.x + position.y * position.y + position.z * position.z)
				
				// Middle = (x1+x2)/2, (y1+y2)/2, (z1+z2)/2
				let centerPoint = SCNVector3((firstPoint.position.x + secondPoint.position.x)/2,
											 (firstPoint.position.y + secondPoint.position.y)/2,
											 (firstPoint.position.z + secondPoint.position.z)/2)
				display(distance: result, position: centerPoint)
				spheres.removeAll()
			}
		}
	}
	
	private func display(distance: Float, position: SCNVector3) {
		let textGeo = SCNText(string: "\(distance) m", extrusionDepth: 1.0)
		textGeo.firstMaterial?.diffuse.contents = UIColor.white
		let textNode = SCNNode(geometry: textGeo)
		// Update object's pivot to its center
		// https://stackoverflow.com/questions/44828764/arkit-placing-an-scntext-at-a-particular-point-in-front-of-the-camera
		let (min, max) = textGeo.boundingBox
		let dx = min.x + 0.5 * (max.x - min.x)
		let dy = min.y + 0.5 * (max.y - min.y)
		let dz = min.z + 0.5 * (max.z - min.z)
		textNode.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
		//must set scale after pivot translation...as it resets the node's position and scale
		textNode.scale = SCNVector3(0.002, 0.002, 0.002)
		//create plane for textNode placement, textNode was acting weird so we'll do rotation on the plane instead
		let planeGeo = SCNPlane(width: 1, height: 1)
		planeGeo.firstMaterial?.diffuse.contents = UIColor.clear
		let planeNode = SCNNode(geometry: planeGeo) // this node will hold our text node
		//apply constraint to make planeNode always face camera
		planeNode.constraints = [SCNBillboardConstraint()]
		planeNode.position = position
		planeNode.addChildNode(textNode)
		self.sceneView.scene.rootNode.addChildNode(planeNode)
	}
	
	private func addCrossSign() {
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 33))
		label.text = "+"
		label.textAlignment = .center
		label.center = sceneView.center
		self.sceneView.addSubview(label)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// create a session configuration
		let configuration = ARWorldTrackingConfiguration()
		configuration.planeDetection = .horizontal
		//track objects in ARWorld and start session
		sceneView.session.run(configuration)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		//pause session
		sceneView.session.pause()
	}
	//MARK: helper funcs
	
	// MARK: - ARSCNViewDelegate
	/*
	// Override to create and configure nodes for anchors added to the view's session.
	func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
	let node = SCNNode()
	return node
	}
	*/
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


/*
just gonna save this code here as it may be handy at some point

//		let (minVec, maxVec) = textNode.boundingBox
//		textNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
//		textNode.pivot = SCNMatrix4MakeRotation(Float.pi/2, 0, 0, 0)
//		textNode.rotation = SCNVector4(0, 0, 0, Float.pi/2)
//		textNode.transform = SCNMatrix4MakeRotation(0, position.x, position.y, position.z)

*/

