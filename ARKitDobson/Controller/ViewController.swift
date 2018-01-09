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
	//let pinchGestureRecognizer = UIPinchGestureRecognizer()
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
		//shows little dots on objects track in AR world
		sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
		sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
		//form box with /mterial/dimensions/position
		boxNode.position = SCNVector3(0, 0, -0.5)
		boxNode.geometry = box
		mat.diffuse.contents = UIColor.purple
		box.firstMaterial = mat
		//add boxNode to scene
		scene.rootNode.addChildNode(boxNode)
		//give target 1-finger pan gesture to move box on x/y-axis
		panGestureRecognizer.addTarget(self, action: #selector(panned))
		sceneView.addGestureRecognizer(panGestureRecognizer)
//		//give target pinch gesture recognizer to move box on z-axis
//		pinchGestureRecognizer.addTarget(self, action: #selector(pinched))
//		sceneView.addGestureRecognizer(pinchGestureRecognizer)
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
		//limit to 1-finger pan for moving box
		recognizer.minimumNumberOfTouches = 1; recognizer.maximumNumberOfTouches = 1
		//get location of touch from user
		let touchLocation: CGPoint = recognizer.location(in: recognizer.view)
		let arHitResults: [ARHitTestResult] = sceneView.hitTest(touchLocation, types: ARHitTestResult.ResultType.featurePoint)
		guard let result: ARHitTestResult = arHitResults.first else { return }
		let scnHitResults: [SCNHitTestResult] = sceneView.hitTest(touchLocation, options: nil)
		if recognizer.state == .changed {
			if let dragNode = scnHitResults.first?.node {
				let position = SCNVector3(result.worldTransform.columns.3.x,
										  result.worldTransform.columns.3.y,
//										  result.worldTransform.columns.3.z)
										  dragNode.position.z)
				dragNode.position = position
			}
		}
	}
//	@objc func pinched(recognizer: UIPinchGestureRecognizer) {
//		print("\(recognizer.scale) -- SCALE")
//		print("\(recognizer.velocity) -- VELOCITY")
//		//get location of touch from user
//		let touchLocation: CGPoint = recognizer.location(in: sceneView)
//		let arHitResults: [ARHitTestResult] = sceneView.hitTest(touchLocation, types: ARHitTestResult.ResultType.featurePoint)
//		guard let result: ARHitTestResult = arHitResults.first else { return }
//		let scnHitResults: [SCNHitTestResult] = sceneView.hitTest(touchLocation, options: nil)
//		if recognizer.state == .changed {
//			if let dragNode = scnHitResults.first?.node {
//				dragNode.position.z = result.worldTransform.columns.3.z
//			}
//		}
//	}
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
