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
    var spheres = [SCNNode]()

	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		// Set the view's delegate
		sceneView.delegate = self
        
		// Show statistics such as fps and timing information
		sceneView.showsStatistics = true
        
        let scene = SCNScene()
        
        addCrossSign()
        registerGestureRecognizers()
		// Set the scene to the view
		sceneView.scene = scene
	}
    
    private func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        
        let scnView = recognizer.view as! ARSCNView
        let touchLocation = self.sceneView.center
        
        let hitTestResults = scnView.hitTest(touchLocation, types: .featurePoint)
        
        if (!hitTestResults.isEmpty) {
            guard let hitTestResult = hitTestResults.first else {
                return
            }
            
            let sphere = SCNSphere(radius: 0.005)
            
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor.red
            sphere.firstMaterial = mat
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = SCNVector3(hitTestResult.worldTransform.columns.3.x,
                                             hitTestResult.worldTransform.columns.3.y,
                                             hitTestResult.worldTransform.columns.3.z)
            self.sceneView.scene.rootNode.addChildNode(sphereNode)
            self.spheres.append(sphereNode)
            
            if self.spheres.count == 2 {
                // calculate distance
                let firstPoint = self.spheres.first!
                let secondPoint = self.spheres.last!
                
                let position = SCNVector3Make(secondPoint.position.x - firstPoint.position.x,
                                              secondPoint.position.y - firstPoint.position.y,
                                              secondPoint.position.z - firstPoint.position.z)
                let result = sqrt(position.x * position.x + position.y * position.y + position.z * position.z)
                
                print(result)
                // remove the speheres
            }
            
        }
    }
    
    private func addCrossSign() {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 33))
        label.text = "+"
        label.textAlignment = .center
        label.center = self.sceneView.center
        self.sceneView.addSubview(label)
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        // create a session configuration
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
