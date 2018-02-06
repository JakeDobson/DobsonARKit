//  ViewController.swift
//  ARKitDobson
//  Created by Jacob Dobson on 1/7/18.
//  Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit
import SceneKit
import ARKit
import CoreML
import Vision
class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	//outlets
	@IBOutlet weak var imgView: UIImageView!
	@IBOutlet weak var txtView: UITextView!
	//globals
	private var imgPicker = UIImagePickerController()
	private var model = GoogLeNetPlaces()
	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.imgPicker.sourceType = .photoLibrary
		self.imgPicker.delegate = self
		
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		//fired when img slected
		dismiss(animated: true, completion: nil)
		guard let pickedImg = info[UIImagePickerControllerOriginalImage] as? UIImage else {
			return
		}
		self.imgView.image = pickedImg
		
		processImg(img: pickedImg)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		//track objects in ARWorld and start session
		//sceneView.session.run(configuration)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		//pause session
		//sceneView.session.pause()
	}
//MARK: helper funcs
	private func processImg(img: UIImage) {
		guard let ciImg = CIImage(image: img) else {
			fatalError("Unable to create ciImg object")
		}
		//create vision model
		guard let visionModel = try? VNCoreMLModel(for: self.model.model) else {
			fatalError("Unable to create vision model")
		}
		let visionRequest = VNCoreMLRequest(model: visionModel, completionHandler: { request, error in
			if error != nil {
				return
			}
			
			guard let requestResults = request.results as? [VNClassificationObservation] else {
				return
			}
			
			let classifications = requestResults.map { observation in
				"\(observation.identifier) \(observation.confidence * 100)"
			}
			
			DispatchQueue.main.async {
				self.txtView.text = classifications.joined(separator: "\n")
			}
			
		})
		let visionRequestHandler = VNImageRequestHandler(ciImage: ciImg, orientation: .up, options: [:])
		
		DispatchQueue.global(qos: .userInteractive).async {
			try! visionRequestHandler.perform([visionRequest])
		}
	}
//MARK: actions
	@IBAction func openPhotoLibraryButtonPressed(_ sender: Any) {
		self.present(self.imgPicker, animated: true, completion: nil)
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
