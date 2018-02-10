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
	//globals
	let tapGestureRecognizer = UITapGestureRecognizer()
	let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
	let mat = SCNMaterial()
	let boxNode = SCNNode()
	let scene = SCNScene()
	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		// Set the view's delegate
		sceneView.delegate = self
		// Show statistics such as fps and timing information
		sceneView.showsStatistics = true
		//form box with /mterial/dimensions/position
		boxNode.position = SCNVector3(0, 0, -0.5)
		boxNode.geometry = box
		mat.diffuse.contents = UIColor.purple
		box.firstMaterial = mat
		//add boxNode to scene
		scene.rootNode.addChildNode(boxNode)
		//give target to gesture recognizer and call tapped func to move box
		tapGestureRecognizer.addTarget(self, action: #selector(tapped))
		sceneView.addGestureRecognizer(tapGestureRecognizer)
		// Set the scene to the view
		sceneView.scene = scene
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		//track devices movement with position(x, y, z) and rotation(roll, pitch, yaw)
		let configuration = ARWorldTrackingConfiguration()
		sceneView.session.run(configuration)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		//pause session
		sceneView.session.pause()
	}
//MARK: helper funcs
	@objc func tapped(recognizer: UITapGestureRecognizer) {
		//get location of touch from user
		let touchLocation = recognizer.location(in: sceneView)
		//get hitTestResults
		let hitResult = sceneView.hitTest(touchLocation, options: nil)
		//if box touched, move box
		if hitResult.isEmpty { //alert user to touch box?
			print("pressed inside SELF.SCENEVIEW")
		} else { //move box
			boxNode.runAction(SCNAction.rotateBy(x: 1, y: 1, z: .pi * 2, duration: 4))
		// below is an alternate spin method that runs forever \\
//			boxNode.pivot = SCNMatrix4MakeRotation(.pi / 2, 1, 0, 0)
//			let spin = CABasicAnimation(keyPath: "rotation")
//			spin.fromValue = NSValue(scnVector4: SCNVector4(0, 0, 1, 0))
//			spin.toValue = NSValue(scnVector4: SCNVector4(0, 0, 1, 6.28))
//			spin.duration = 3
//			spin.repeatCount = .infinity
//			boxNode.addAnimation(spin, forKey: "spin around")
		}
	}
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
