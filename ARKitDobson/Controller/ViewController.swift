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
	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		// Set the view's delegate
		sceneView.delegate = self
		// Show statistics such as fps and timing information
		sceneView.showsStatistics = true
		//enable lighting
		sceneView.autoenablesDefaultLighting = true
		//shows little dots on objects/planes while tracking AR world
//		sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
//		sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
		//add car model scene
		let modelScene = SCNScene(named: "transportation.dae")
		let carNode = modelScene?.rootNode.childNode(withName: "tesla", recursively: true)
		let jetNode = modelScene?.rootNode.childNode(withName: "jet", recursively: true)
		let firetruckNode = modelScene?.rootNode.childNode(withName: "firetruck", recursively: true)
		//empty scene
		let scene = SCNScene()
		//position nodes
		carNode?.position = SCNVector3(0, 0, -0.5)
		jetNode?.position = SCNVector3(0.5, 0, -0.5)
		firetruckNode?.position = SCNVector3(-0.5, 0, -0.5)
		//add nodes to scene
		scene.rootNode.addChildNode(carNode!)
		scene.rootNode.addChildNode(jetNode!)
		scene.rootNode.addChildNode(firetruckNode!)
		
		sceneView.scene = scene
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
