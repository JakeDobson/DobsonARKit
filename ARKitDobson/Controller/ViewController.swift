//  ViewController.swift
//  ARKitDobson
//  Created by Jacob Dobson on 1/7/18.
//  Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit
import SceneKit
import ARKit
import CoreML
import Vision
class ViewController: UIViewController, ARSCNViewDelegate {
	//outlets
    @IBOutlet var sceneView: ARSCNView!
	//globals
	let tapGestureRecognizer = UITapGestureRecognizer()
	let scene = SCNScene()
	private var visionRequests = [VNRequest]()
	private var resnetModel = Resnet50()
	private var hitTestResult: ARHitTestResult!
	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		// Set the view's delegate
		sceneView.delegate = self
		//register gesture recognizer
		tapGestureRecognizer.addTarget(self, action: #selector(tapped))
		sceneView.addGestureRecognizer(tapGestureRecognizer)
		// Set the scene to the view
		sceneView.scene = scene
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		//track devices movement with position(x, y, z) and rotation(roll, pitch, yaw)
		let configuration = ARWorldTrackingConfiguration()
		sceneView.session.run(configuration)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		//pause session
		sceneView.session.pause()
	}
//MARK: helper funcs
	@objc func tapped(recognizer: UITapGestureRecognizer) {
		let scnView = recognizer.view as! ARSCNView
		let touchLocation = self.sceneView.center
		
		guard let currentFrame = scnView.session.currentFrame else { return }
		
		let hitTestResults = scnView.hitTest(touchLocation, types: .featurePoint)
		
		
		if hitTestResults.isEmpty {
			return
		}
		
		guard let recentHitTestResult = hitTestResults.first else { return }
		
		self.hitTestResult = recentHitTestResult
		
		let pixelBuffer = currentFrame.capturedImage
		
		performVisionRequest(pixelBuffer: pixelBuffer)
	}
	
	private func displayPredictions(text: String) {
		let node = createText(text: text)
		
		node.position = SCNVector3(self.hitTestResult.worldTransform.columns.3.x,
								   self.hitTestResult.worldTransform.columns.3.y,
								   self.hitTestResult.worldTransform.columns.3.z)
		
		self.sceneView.scene.rootNode.addChildNode(node)
	}
	
	private func createText(text: String) -> SCNNode {
		let parentNode = SCNNode()
		let sphere = SCNSphere(radius: 0.01)
		let sphereMaterial = SCNMaterial()
		sphereMaterial.diffuse.contents = UIColor.orange
		sphere.firstMaterial = sphereMaterial
		let sphereNode = SCNNode(geometry: sphere)
		
		let textGeo = SCNText(string: text, extrusionDepth: 0)
		textGeo.alignmentMode = convertFromCATextLayerAlignmentMode(CATextLayerAlignmentMode.center)
		textGeo.firstMaterial?.diffuse.contents = UIColor.orange
		textGeo.firstMaterial?.specular.contents = UIColor.white
		textGeo.firstMaterial?.isDoubleSided = true
		textGeo.font = UIFont(name: "Futura", size: 0.15)
		
		let textNode = SCNNode(geometry: textGeo)
		textNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
		
		parentNode.addChildNode(sphereNode)
		parentNode.addChildNode(textNode)
		return parentNode
	}
	
	private func performVisionRequest(pixelBuffer: CVPixelBuffer) {
		let visionModel = try! VNCoreMLModel(for: self.resnetModel.model)
		let request = VNCoreMLRequest(model: visionModel) {request, error in
			
			if error != nil { return }

			guard let observations = request.results else { return }

			let observation = observations.first as! VNClassificationObservation
			print("Name \(observation.identifier) and confidence is \(observation.confidence)")
			DispatchQueue.main.async {
				self.displayPredictions(text: observation.identifier)
			}
		}
		request.imageCropAndScaleOption = .centerCrop
		self.visionRequests = [request]
		let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .upMirrored, options: [:])
		
		DispatchQueue.global().async {
			try! imageRequestHandler.perform(self.visionRequests)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATextLayerAlignmentMode(_ input: CATextLayerAlignmentMode) -> String {
	return input.rawValue
}
