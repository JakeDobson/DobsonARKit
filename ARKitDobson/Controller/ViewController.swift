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
	var numOfPlanes: Int = 0
	var planes = [Plane]()
	//constants
	private let label: UILabel = UILabel()
	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		//set sceneView's frame
		self.sceneView = ARSCNView(frame: self.view.frame)
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
		//setup recognizer to add scooter to scene
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
		sceneView.addGestureRecognizer(tapGestureRecognizer)
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
	@objc func tapped(recognizer: UIGestureRecognizer) {
		let scnView = recognizer.view as! ARSCNView
		let touchLocation = recognizer.location(in: scnView)
		let hitTestResult = scnView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
		//if touched on a plane, add object at location of touch
		if !hitTestResult.isEmpty {
			guard let hitResult = hitTestResult.first else { return }
			addScooter(hitResult: hitResult)
		}
	}
	private func nodeForScene(sceneName: String, nodeName: String) -> SCNNode? {
		let scn = SCNScene(named: sceneName)!
		return scn.rootNode.childNode(withName: nodeName, recursively: true)
	}
	private func addScooter(hitResult: ARHitTestResult) {
		if let scooterNode = nodeForScene(sceneName: "scooter.dae", nodeName: "scooter") {
			scooterNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
			scooterNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
											  hitResult.worldTransform.columns.3.y,
											  hitResult.worldTransform.columns.3.z)
			sceneView.scene.rootNode.addChildNode(scooterNode)
		}
	}
// MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let plane = self.planes.filter {
            plane in return plane.anchor.identifier == anchor.identifier
        }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
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
