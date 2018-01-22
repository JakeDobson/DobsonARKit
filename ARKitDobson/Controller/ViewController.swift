//  ViewController.swift
//  ARKitDobson
//  Created by Jacob Dobson on 1/7/18.
//  Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit
import SceneKit
import ARKit
//body type enum
enum BoxBodyType: Int {
	case bullet = 1
	case barrier = 2
}
class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
	//outlets
    @IBOutlet var sceneView: ARSCNView!
	//globals
	let configuration = ARWorldTrackingConfiguration()
	let tapGestureRecognizer = UITapGestureRecognizer()
	var lastContactNode: SCNNode!
	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		// Set the view's delegate
		sceneView.delegate = self
		// Show statistics such as fps and timing information
		sceneView.showsStatistics = true
		//form box with w/ material & dimensions
		let scene = SCNScene()
		//box geometries
		let box1 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
		let box2 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
		let box3 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
		//box materials
			//1
		let mat1 = SCNMaterial()
		mat1.diffuse.contents = UIColor.red
		box1.materials = [mat1]
			//2
		let mat2 = SCNMaterial()
		mat2.diffuse.contents = UIColor.red
		box2.materials = [mat2]
			//3
		let mat3 = SCNMaterial()
		mat3.diffuse.contents = UIColor.red
		box3.materials = [mat3]
		//init box nodes
		let boxNode1 = SCNNode(geometry: box1)
		let boxNode2 = SCNNode(geometry: box2)
		let boxNode3 = SCNNode(geometry: box3)
		//name box nodes
		boxNode1.name = "barrier1"
		boxNode2.name = "barier2"
		boxNode3.name = "barrier3"
		//box node positions
		boxNode1.position = SCNVector3(0, 0, -0.8)
		boxNode2.position = SCNVector3(-0.2, 0, -0.8)
		boxNode3.position = SCNVector3(0.2, 0.2, -0.8)
		//box node physic bodies
		boxNode1.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
		boxNode2.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
		boxNode3.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
		//box node bit masks
		boxNode1.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
		boxNode2.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
		boxNode3.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
		//add boxNode to scene
		scene.rootNode.addChildNode(boxNode1)
		scene.rootNode.addChildNode(boxNode2)
		scene.rootNode.addChildNode(boxNode3)
		// Set the scene to the view
		sceneView.scene = scene
		//subscribe to physics contact delegate
		sceneView.scene.physicsWorld.contactDelegate = self
		//register gestures
		registerGestureRecognizers()
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
		//box setup
		let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
		let mat = SCNMaterial()
		mat.diffuse.contents = UIColor.yellow
		box.firstMaterial = mat
		//create node, give physics properties, add to scene
		let boxNode = SCNNode(geometry: box)
		boxNode.name = "bullet"
		boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		boxNode.physicsBody?.categoryBitMask = BoxBodyType.bullet.rawValue
		boxNode.physicsBody?.contactTestBitMask = BoxBodyType.barrier.rawValue
		boxNode.physicsBody?.isAffectedByGravity = false
		boxNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
		let forceVector = SCNVector3(boxNode.worldFront.x * 2, boxNode.worldFront.y * 2, boxNode.worldFront.z * 2)
		boxNode.physicsBody?.applyForce(forceVector, asImpulse: true)
		self.sceneView.scene.rootNode.addChildNode(boxNode)
	}
// MARK: - ARSCNViewDelegate
	func session(_ session: ARSession, didFailWithError error: Error) {
		// Present an error message to the user
	}
	func sessionWasInterrupted(_ session: ARSession) {
		// Inform the user that the session has been interrupted, for example, by presenting an overlay
	}
	func sessionInterruptionEnded(_ session: ARSession) {
		// Reset tracking and/or remove existing anchors if consistent tracking is required
	}
//MARK: SCNPhysicsContactDelegate
	func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
		var contactNode: SCNNode!
		//if bullet shot and contact is made, bullet node becomes secondary on contact list, else keep primary on list
		if contact.nodeA.name == "bullet" {
			contactNode = contact.nodeB
		} else {
			contactNode = contact.nodeA
		}
		if self.lastContactNode != nil && self.lastContactNode == contactNode {
			//box geo
			let mat = SCNMaterial()
			mat.diffuse.contents = UIColor.green
			self.lastContactNode.geometry?.materials = [mat]
		}
		self.lastContactNode = contactNode
	}
}
