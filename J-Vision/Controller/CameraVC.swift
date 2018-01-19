//
//  ViewController.swift
//  J-Vision
//
//  Created by Jeffrey Santana on 1/15/18.
//  Copyright © 2018 Jefffrey Santana. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

enum FlashState {
	case off
	case on
}

class CameraVC: UIViewController {

	//Outlets
	@IBOutlet weak var captureImgView: UIImageView!
	@IBOutlet weak var identificationLbl: UILabel!
	@IBOutlet weak var confidenceLbl: UILabel!
	@IBOutlet weak var cameraView: UIView!
	@IBOutlet weak var flashBtn: UIButton!
	@IBOutlet weak var roundedLblView: RoundedShadowView!
	
	//Variables
	var captureSession: AVCaptureSession!			//work with camera
	var cameraOutput: AVCapturePhotoOutput!			//take a still image
	var previewLayer: AVCaptureVideoPreviewLayer!	//see through camera
	var photoData: Data?
	var flashControlState: FlashState = .off
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
		tap.numberOfTapsRequired = 1

		captureSession = AVCaptureSession()
		captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080	//capture full size of screen
		
		let backCamera = AVCaptureDevice.default(for: AVMediaType.video)	//video is bigger than photo
		
		do {
			let input = try AVCaptureDeviceInput(device: backCamera!)
			if captureSession.canAddInput(input) {
				captureSession.addInput(input)
			}
			
			cameraOutput = AVCapturePhotoOutput()
			if captureSession.canAddOutput(cameraOutput) {
				captureSession.addOutput(cameraOutput!)
				
				previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
				previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
				previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
				
				cameraView.layer.addSublayer(previewLayer!)
				cameraView.addGestureRecognizer(tap)
				captureSession.startRunning()
			}
		} catch {
			debugPrint(error)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		previewLayer.frame = cameraView.bounds		//same size as cameraView
	}
	
	@objc func didTapCameraView() {
		let settings = AVCapturePhotoSettings()
		settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
		
		if flashControlState == .off {
			settings.flashMode = .off
		} else {
			settings.flashMode = .on
		}
		
		cameraOutput.capturePhoto(with: settings, delegate: self)
	}
	
	func resultsMethod(request: VNRequest, error: Error?) {
		guard let results = request.results as? [VNClassificationObservation] else { return }
		
		for classification in results {
			print(classification.identifier )
			if classification.confidence < 0.5 {
				identificationLbl.text = "I'm not sure what this is, try again"
				confidenceLbl.text = ""
			} else {
				identificationLbl.text = classification.identifier
				confidenceLbl.text = "CONFIDENCE: \(Int(classification.confidence * 100))%"
			}
			break
		}
	}
	
	@IBAction func flashBtnPressed(_ sender: Any) {
		switch flashControlState {
		case .off:
			flashBtn.setTitle("FLASH ON", for: .normal)
			flashControlState = .on
		case .on:
			flashBtn.setTitle("FLASH OFF", for: .normal)
			flashControlState = .off
		}
	}
	
}

extension CameraVC: AVCapturePhotoCaptureDelegate {
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		if let error = error {
			debugPrint(error)
		} else {
			photoData = photo.fileDataRepresentation()
			
			do {
				let model = try VNCoreMLModel(for: SqueezeNet().model)							//see's image
				let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)	//think about image
				let handler = VNImageRequestHandler(data: photoData!)							//make comparisons
				try handler.perform([request])													//produce data
			} catch {
				debugPrint(error)
			}
			
			let image = UIImage(data: photoData!)
			captureImgView.image = image
		}
	}
	
}
