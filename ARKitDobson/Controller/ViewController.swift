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
		let boxNode = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
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
		//track objects in ARWorld and start session
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
