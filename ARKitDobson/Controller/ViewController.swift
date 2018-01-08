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
	let panGestureRecognizer = UIPanGestureRecognizer()
	let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
	let mat = SCNMaterial()
	let boxNode = SCNNode()
	let scene = SCNScene()
	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		// Set the view's delegate
		sceneView.delegate = self as ARSCNViewDelegate
		// Show statistics such as fps and timing information
		sceneView.showsStatistics = true
		//enable lighting
		sceneView.autoenablesDefaultLighting = true
		//form box with /mterial/dimensions/position
		boxNode.position = SCNVector3(0, 0, -0.5)
		boxNode.geometry = box
		mat.diffuse.contents = UIColor.purple
		box.firstMaterial = mat
		//add boxNode to scene
		scene.rootNode.addChildNode(boxNode)
		//give target to gesture recognizer and call tapped func to move box
		panGestureRecognizer.addTarget(self, action: #selector(panned))
		sceneView.addGestureRecognizer(panGestureRecognizer)
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
	@objc func panned(recognizer: UIPanGestureRecognizer) {
		//get location of touch from user
		let touchLocation: CGPoint = recognizer.location(in: recognizer.view)
		let arHitResults: [ARHitTestResult] = sceneView.hitTest(touchLocation, types: ARHitTestResult.ResultType.featurePoint)
		guard let result: ARHitTestResult = arHitResults.first else { return }
		let scnHitResults: [SCNHitTestResult] = sceneView.hitTest(touchLocation, options: nil)
		if let dragNode = scnHitResults.first?.node {
			let position = SCNVector3(result.worldTransform.columns.3.x,
									  result.worldTransform.columns.3.y,
									  result.worldTransform.columns.3.z)
			dragNode.position = position
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
