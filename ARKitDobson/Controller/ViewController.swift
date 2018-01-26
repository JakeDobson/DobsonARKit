//  ViewController.swift
//  ARKitDobson
//  Created by Jacob Dobson on 1/7/18.
//  Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit
import SceneKit
import ARKit
import UIKit
import SceneKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {
	
	@IBOutlet var sceneView: ARSCNView!
	var planes = [OverlayPlane]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.sceneView = ARSCNView(frame: self.view.frame)
		self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
		self.view.addSubview(sceneView)
		// Set the view's delegate
		sceneView.delegate = self
		// Show statistics such as fps and timing information
		sceneView.showsStatistics = true
        
        let carScene = SCNScene(named: "dodge.dae")
        let carNode = carScene?.rootNode.childNode(withName: "car", recursively: true)
        
		// Set the scene to the view
		let scene = SCNScene()
        carNode?.position = SCNVector3(0,0,-0.5)
        scene.rootNode.addChildNode(carNode!)
		sceneView.scene = scene
		registerGestureRecognizers()
		setupPlaneToggleSwitch()
        self.sceneView.autoenablesDefaultLighting = true;

	}
	
	private func setupPlaneToggleSwitch() {
		
		let planeToggleSwitch = UISwitch(frame: CGRect(x: 10, y: self.sceneView.frame.height - 44, width: 100, height: 33))
		planeToggleSwitch.addTarget(self, action: #selector(planeSwitchToggled), for: .valueChanged)
		self.sceneView.addSubview(planeToggleSwitch)
	}
	
	// turn off the plane detection and remove the grid from the plane
	@objc func planeSwitchToggled(planeSwitch :UISwitch) {
		
		let configuration = self.sceneView.session.configuration as! ARWorldTrackingConfiguration
		
		configuration.planeDetection = []
		self.sceneView.session.run(configuration, options: [])
		
		// turn off the grid
		for plane in self.planes {
			plane.planeGeometry.materials.forEach { material in
				material.diffuse.contents = UIColor.clear
			}
		}
	}
	
	private func registerGestureRecognizers() {
		
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
		
		self.sceneView.addGestureRecognizer(tapGestureRecognizer)
	}
	
	
	@objc func tapped(recognizer :UIGestureRecognizer) {
		
		let sceneView = recognizer.view as! ARSCNView
		let touchLocation = recognizer.location(in: sceneView)
		
		let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
		
		if !hitTestResult.isEmpty {
			
			guard let hitResult = hitTestResult.first else {
				return
			}
             // function to run
            
        }
	}

	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Create a session configuration
		let configuration = ARWorldTrackingConfiguration()
		
		configuration.planeDetection = .horizontal
		
		// Run the view's session
		sceneView.session.run(configuration)
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		
		if !(anchor is ARPlaneAnchor) {
			return
		}
		
		let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
		self.planes.append(plane)
		node.addChildNode(plane)
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		
		let plane = self.planes.filter { plane in
			return plane.anchor.identifier == anchor.identifier
			}.first
		
		if plane == nil {
			return
		}
		
		plane?.update(anchor: anchor as! ARPlaneAnchor)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Pause the view's session
		sceneView.session.pause()
	}
}

