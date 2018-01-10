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
	private let label: UILabel = UILabel()
	var numOfPlanes: Int = 0
	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		//set sceneView's frame
		self.sceneView = ARSCNView(frame: self.view.frame)
		//label properties
		setupAlertLabel()
		//add debugging option for sceneView (show x, y , z coords)
		self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
		//add subview to scene
		self.view.addSubview(self.sceneView)
		// Set the view's delegate
		sceneView.delegate = self
		//show statistics such as fps and timing information
		sceneView.showsStatistics = true
		//create new scene
		let scene = SCNScene()
		//set scene to view
		sceneView.scene = scene
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
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
	func setupAlertLabel() {
		//setup label properties
		self.label.frame = CGRect(x: 0,
								  y: 0,
								  width: sceneView.frame.size.width,
								  height: 44)
		self.label.center = CGPoint(x: label.frame.width/2 + 16, y: label.frame.height/2 + 16)
		self.label.textAlignment = .left
		self.label.textColor = UIColor.white
		self.label.font = UIFont.boldSystemFont(ofSize: 36)
		self.label.alpha = 0
		//add label to sceneView as subview
		self.sceneView.addSubview(self.label)
	}
// MARK: - ARSCNViewDelegate
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		//if no anchor found, don't render anything!
		if !(anchor is ARPlaneAnchor) {
			return
		}
		//every time plane is detected, increase numOfPlanes counter by 1
		numOfPlanes += 1
		//present label as alert for total number  of planes detected off the main thread
		DispatchQueue.main.async {
			self.label.text = "\(self.numOfPlanes) plane(s) detected"
			print("\(self.numOfPlanes) plane(s) detected")
			UIView.animate(withDuration: 3.0, animations: {
				self.label.alpha = 1.0
			}) { (completion: Bool) in
				self.label.alpha = 0.0
			}
		}
	}
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
