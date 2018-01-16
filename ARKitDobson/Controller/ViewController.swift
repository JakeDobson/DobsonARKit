//  ViewController.swift
//  ARKitDobson
//  Created by Jacob Dobson on 1/7/18.
//  Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit
import SceneKit
import ARKit
//enum for category bit mask of physics bodies
enum BodyType: Int {
	case scooter = 1
	case plane = 2
}
class ViewController: UIViewController, ARSCNViewDelegate {
	//outlets
    @IBOutlet var sceneView: ARSCNView!
	//globals
	var planes = [Plane]()
	var scooters = [SCNNode]()
	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		//set sceneView's frame
		self.sceneView = ARSCNView(frame: self.view.frame)
		//add debugging option for sceneView (show x, y , z coords)
		self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
		//give lighting to the scene
		self.sceneView.autoenablesDefaultLighting = true
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
        addTaxi()
		//setup recognizer to add scooter to scene
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
		sceneView.addGestureRecognizer(tapGestureRecognizer)
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
		let yOffset = 0.3
		if let scooterNode = nodeForScene(sceneName: "scooter.dae", nodeName: "scooter") {
			//scooterNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
			//scooterNode.physicsBody?.categoryBitMask = BodyType.scooter.rawValue
			let size = scooterNode.boundingBox.max
			//create scooter geometry
			let scooterGeometry = SCNBox(width: CGFloat(size.x),
										 height: CGFloat(size.y/2),
										 length: CGFloat(size.z),
										 chamferRadius: 0)
			let scooterShape = SCNPhysicsShape(geometry: scooterGeometry, options: nil)
			//adding physics body
			scooterNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: scooterShape)
			scooterNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
											  hitResult.worldTransform.columns.3.y + Float(yOffset),
											  hitResult.worldTransform.columns.3.z)
			self.sceneView.scene.rootNode.addChildNode(scooterNode)
		}
	}
    
    private func addTaxi() {
        if let taxiNode = nodeForScene(sceneName: "taxi.dae", nodeName: "taxi")
        
        taxiNode.position = SCNVector3(0,0,-0.8)
        taxiNode.physicsBody(type: .static, shape: nil)
        self.sceneView.scene.rootNode.addChildNode(taxiNode);
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let configuration = ARWorldTrackingConfiguration()
		configuration.planeDetection = .horizontal
		//track objects in ARWorld and start session
		sceneView.session.run(configuration)
	}
// MARK: - ARSCNViewDelegate
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		//if no anchor found, don't render anything!
		if !(anchor is ARPlaneAnchor) {
			return
		}
		let plane = Plane(anchor: anchor as! ARPlaneAnchor)
		self.planes.append(plane)
		node.addChildNode(plane)
	}
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let plane = self.planes.filter {
            plane in return plane.anchor.identifier == anchor.identifier
        }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		//pause session
		sceneView.session.pause()
	}
}
