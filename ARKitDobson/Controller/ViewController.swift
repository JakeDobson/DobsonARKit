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
	let configuration = ARWorldTrackingConfiguration()
	let tapGestureRecognizer = UITapGestureRecognizer()
	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		// Set the view's delegate
		sceneView.delegate = self
		// Show statistics such as fps and timing information
		sceneView.showsStatistics = true
		//form box with /mterial/dimensions/position
		let scene = SCNScene()
		let box1 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
		let material = SCNMaterial()
		material.diffuse.contents = UIColor.red
		box1.materials = [material]
		let boxNode1 = SCNNode(geometry: box1)
		let boxNode2 = SCNNode(geometry: box1)
		let boxNode3 = SCNNode(geometry: box1)
		boxNode1.position = SCNVector3(0, 0, -0.4)
		boxNode2.position = SCNVector3(-0.2, 0, -0.4)
		boxNode3.position = SCNVector3(0.2, 0.2, -0.5)
		//add boxNode to scene
		scene.rootNode.addChildNode(boxNode1)
		scene.rootNode.addChildNode(boxNode2)
		scene.rootNode.addChildNode(boxNode3)
		//register gestures
		registerGestureRecognizers()
		// Set the scene to the view
		sceneView.scene = scene
	}
	//gesture func setup
	private func registerGestureRecognizers() {
		tapGestureRecognizer.addTarget(self, action: #selector(shoot))
		sceneView.addGestureRecognizer(tapGestureRecognizer)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		//track objects in ARWorld and start session
		sceneView.session.run(configuration)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		//pause session
		sceneView.session.pause()
	}
//MARK: helper funcs
	@objc func shoot(recognizer: UITapGestureRecognizer) {
		guard let currentFrame = self.sceneView.session.currentFrame else {
			return
		}
		var translation = matrix_identity_float4x4
		translation.columns.3.z = -0.3
		let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
		let material = SCNMaterial()
		material.diffuse.contents = UIColor.yellow
		box.firstMaterial = material
		let boxNode = SCNNode(geometry: box)
		boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		boxNode.physicsBody?.isAffectedByGravity = false
		boxNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
		let forceVector = SCNVector3(boxNode.worldFront.x * 2, boxNode.worldFront.y * 2, boxNode.worldFront.z * 2)
		boxNode.physicsBody?.applyForce(forceVector, asImpulse: true)
		self.sceneView.scene.rootNode.addChildNode(boxNode)
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
