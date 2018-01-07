//  ViewController.swift
//  ARKitDobson
//  Created by Jacob Dobson on 1/7/18.
//  Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit
import SceneKit
import ARKit
//MARK: VC
class ViewController: UIViewController, ARSCNViewDelegate {
	//outlets
    @IBOutlet var sceneView: ARSCNView!
	//globals
	let configuration = ARWorldTrackingConfiguration()
	let tapGestureRecognizer = UITapGestureRecognizer()
	let scene = SCNScene()
	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		// Set the view's delegate
		sceneView.delegate = self
		// Show statistics such as fps and timing information
		sceneView.showsStatistics = true
		sceneView.autoenablesDefaultLighting = true
		let box1 = addBox(position: SCNVector3(0, 0, -0.5), color: UIColor.purple, size: 0.2)
		//add boxNode to scene
		scene.rootNode.addChildNode(box1)
		print(box1)
		scene.rootNode.addChildNode(addBox(position: SCNVector3(0, 0, -0.2), color: UIColor.blue, size: 0.3))
		//give target to gesture recognizer and call tapped func to move box
		tapGestureRecognizer.addTarget(self, action: #selector(tapped))
		sceneView.addGestureRecognizer(tapGestureRecognizer)
		// Set the scene to the view
		sceneView.scene = scene
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		//track objects in ARWorld and start session
		sceneView.session.run(configuration)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		sceneView.session.pause()
	}
//MARK: helper funcs
	//add a new box to scene
	func addBox(position: SCNVector3, color: UIColor, size: CGFloat) -> SCNNode {
		let box = SCNBox(width: size, height: size, length: size, chamferRadius: size*0)
		let mat = SCNMaterial()
		let boxNode = SCNNode()
		//form box with /mterial/dimensions/position
		boxNode.position = position
		boxNode.geometry = box
		mat.diffuse.contents = color
		box.firstMaterial = mat
		//add box
		return boxNode
	}
	@objc func tapped(recognizer: UITapGestureRecognizer) {
		let touchLocation = recognizer.location(in: sceneView)
		//get SCNHitTestResults [ ]
		let hitResult = sceneView.hitTest(touchLocation, options: nil)
		//is box tapped?
		if hitResult.isEmpty { //box is not tapped
			print("pressed inside SELF.SCENEVIEW")
		} else { //box is tapped
			//usig "if let" to make cleaner and eliminate the need for adding a bang to each value of newPosition --> "node!.position.x/y/z"
			if let node = hitResult.first?.node {
				//tap to create new red box
				let newPosition = SCNVector3(node.position.x - 0.1, node.position.y - 0.2, node.position.z - 0.05)
				scene.rootNode.addChildNode(addBox(position: newPosition, color: UIColor.red, size: 0.1))
			}
			//boxNode.runAction(SCNAction.rotateBy(x: 1, y: 1, z: .pi * 2, duration: 4))
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
