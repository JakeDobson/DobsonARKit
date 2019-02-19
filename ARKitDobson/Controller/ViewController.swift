//  ViewController.swift
//  ARKitDobson
//  Created by Jacob Dobson on 1/7/18.
//  Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit
import SceneKit
import ARKit
import MapboxSceneKit
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
		self.sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showWorldOrigin]
		//add subview to scene
		self.view.addSubview(self.sceneView)
		//set the view's delegate
		sceneView.delegate = self
		//show statistics such as fps and timing information
//		sceneView.showsStatistics = true
		//create new scene
		let scene = SCNScene()
		//set scene to view
		sceneView.scene = scene
		//setup recognizer to add car to scene
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
	//setup and add terrain to the scene
    private func addTerrain(from ht: ARHitTestResult) {
		//setup terrain node w/ coords, position, scalability, transform, position
        let terrainNode = TerrainNode(minLat: 46.747183,
									  maxLat: 46.990353,
									  minLon: -121.904431,
									  maxLon: -121.548861)
        terrainNode.position = SCNVector3(ht.worldTransform.columns.3.x,
										  ht.worldTransform.columns.3.y,
										  ht.worldTransform.columns.3.z)
		let scale = Float(0.333 * ht.distance) / terrainNode.boundingSphere.radius
		terrainNode.transform = SCNMatrix4MakeScale(scale, scale, scale)
		terrainNode.position = SCNVector3(ht.worldTransform.columns.3.x,
										  ht.worldTransform.columns.3.y,
										  ht.worldTransform.columns.3.z)
		//set materials
		terrainNode.geometry?.materials = defaultMaterials()
		//add node to scene
        self.sceneView.scene.rootNode.addChildNode(terrainNode)
		//grab terrain from mapbox
		terrainNode.fetchTerrainAndTexture(minWallHeight: 5000.0,
										      multiplier: 1.0,
									enableDynamicShadows: true,
										    textureStyle: "mapbox/satellite-v9",
										  heightProgress: { _, _ in },
										heightCompletion: {_ in NSLog("Terrain load complete") },
										 textureProgress: { _, _ in },
										 textureCompletion: { image, arg in
											NSLog("Texture load complete")
											terrainNode.geometry?.materials[4].diffuse.contents = image
										})
    }
	//default materials for nodes
	private func defaultMaterials() -> [SCNMaterial] {
		//vars
		let groundImg = SCNMaterial()
		let sideMaterial = SCNMaterial()
		let bottomMaterial = SCNMaterial()
		//setup groundImg
		groundImg.diffuse.contents = UIColor.darkGray
		groundImg.name = "Ground Texture"
		//setup sideMaterial
		sideMaterial.isDoubleSided = true
		sideMaterial.name = "side"
		//setup bottomMaterial
		bottomMaterial.diffuse.contents = UIColor.black
		bottomMaterial.name = "Bottom"
		//return our array of materials
		return [sideMaterial, sideMaterial, sideMaterial, sideMaterial, groundImg, bottomMaterial]
	}
	//location of hit test result
	@objc func tapped(recognizer: UIGestureRecognizer) {
		let scnView = recognizer.view as! ARSCNView
		let touchLocation = recognizer.location(in: scnView)
		let hitTestResult = scnView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
		//if touched on a plane, add object at location of touch
		if !hitTestResult.isEmpty {
			guard let ht = hitTestResult.first else { return }
			addTerrain(from: ht)
		}
	}
// MARK: - ARSCNViewDelegate
	
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		//if no anchor found, don't render anything!
		if !(anchor is ARPlaneAnchor) {
			return
		}
		//every time plane is detected, increase numOfPlanes counter by 1
		numOfPlanes += 1
		DispatchQueue.main.async {
			//present label as alert for total number  of planes detected off the main thread
			self.label.text = "\(self.numOfPlanes) plane(s) detected"
			print("\(self.numOfPlanes) plane(s) detected")
			UIView.animate(withDuration: 3.0, animations: {
				self.label.alpha = 1.0
			}) { (completion: Bool) in
				self.label.alpha = 0.0
			}
			//add plane to scene
			let plane = Plane(anchor: anchor as! ARPlaneAnchor)
			self.planes.append(plane)
			node.addChildNode(plane)
		}
	}
	
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		//if plane found with anchor, upaate(which will merge each plane, increasing plane's surface)
        let plane = self.planes.filter {
            plane in return plane.anchor.identifier == anchor.identifier
        }.first
        if plane == nil {
            return
        }
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
}
