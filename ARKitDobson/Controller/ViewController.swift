//ViewController.swift
//ARKitDobson
//Created by Jacob Dobson on 1/7/18.
//Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit
import SceneKit
import ARKit
//enum for bit mask
enum BodyType: Int {
	case box = 1
	case pyramid = 2
	case plane = 3
}
class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
	//outlets
    @IBOutlet var sceneView: ARSCNView!
	//globals
	var planes = [Plane]()
	var boxes = [SCNNode]()
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
		//subscribe to physics contact delegate
		self.sceneView.scene.physicsWorld.contactDelegate = self
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
	//MARK: helper funcs
	@objc func tapped(recognizer: UIGestureRecognizer) {
		let scnView = recognizer.view as! ARSCNView
		let touchLocation = recognizer.location(in: scnView)
		let touch = scnView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
		//take action if user touches box
		if !touch.isEmpty {
			guard let hitResult = touch.first else { return }
			addBox(hitResult: hitResult)
		}
	}
	private func addBox(hitResult: ARHitTestResult) {
		let boxGeometry = SCNBox(width:  0.1,
								 height: 0.1,
								 length: 0.1,
								 chamferRadius: 0)
		let material = SCNMaterial()
		material.diffuse.contents = UIColor(red: 	.random(),
											green: 	.random(),
											blue: 	.random(),
											alpha: 	1.0)
		boxGeometry.materials = [material]
		let boxNode = SCNNode(geometry: boxGeometry)
		//adding physics body, a box already has a shape, so nil is fine
		boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		//set bitMask on boxNode, enabling objects with diff categoryBitMasks to collide w/ each other
		boxNode.physicsBody?.categoryBitMask = BodyType.plane.rawValue | BodyType.box.rawValue
		boxNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
									  hitResult.worldTransform.columns.3.y + 0.3,
									  hitResult.worldTransform.columns.3.z)
		self.sceneView.scene.rootNode.addChildNode(boxNode)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let configuration = ARWorldTrackingConfiguration()
		configuration.planeDetection = .horizontal
		//track objects in ARWorld and start session
		sceneView.session.run(configuration)
	}
	//MARK: - ARSCNViewDelegate
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		//if no anchor found, don't render anything!
		if !(anchor is ARPlaneAnchor) {
			return
		}
		DispatchQueue.main.async {
			//add plane to scene
			let plane = Plane(anchor: anchor as! ARPlaneAnchor)
			self.planes.append(plane)
			node.addChildNode(plane)
			//add initial scene object
			let pyramidGeometry = SCNPyramid(width: CGFloat(plane.planeGeometry.width / 8), height: plane.planeGeometry.height / 8, length: plane.planeGeometry.height / 8)
			pyramidGeometry.firstMaterial?.diffuse.contents = UIColor.white
			let pyramidNode = SCNNode(geometry: pyramidGeometry)
			pyramidNode.name = "pyramid"
			pyramidNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
			pyramidNode.physicsBody?.categoryBitMask = BodyType.pyramid.rawValue | BodyType.plane.rawValue
			pyramidNode.physicsBody?.contactTestBitMask = BodyType.box.rawValue
			pyramidNode.position = SCNVector3(-(plane.planeGeometry.width) / 3, 0, plane.planeGeometry.height / 3)
			node.addChildNode(pyramidNode)
		}
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
	//MARK: SCNPhysicsContactDelegate
	func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
		print("WE MADE CONTACT!!!!")
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		//pause session
		sceneView.session.pause()
	}
}


/*

Tapped() code for applying force when objects not alike collide

switch(self.boxStatus) {
case .notAdded:
let hitResults = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
if !hitResults.isEmpty {
guard let hitResult = hitResults.first else { return }
addBox(hitResult: hitResult)
}

self.boxStatus = .added

case .added:
let hitResults = sceneView.hitTest(touchLocation, options: nil)

if !hitResults.isEmpty {
guard let hitResult = hitResults.first else { return }

let boxNode = hitResult.node

// apply force to scooter node
let force = SCNVector3(0,0,0.5)
boxNode.physicsBody?.applyForce(force, asImpulse: true)
}
}

*/
