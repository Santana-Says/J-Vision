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
	var speechSynthesizer = AVSpeechSynthesizer()
	
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
		speechSynthesizer.delegate = self
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
				let unknownObjectMessage = "I'm not sure what this is, try again"
				identificationLbl.text = unknownObjectMessage
				synthesizeSpeech(fromString: unknownObjectMessage)
				confidenceLbl.text = ""
			} else {
				let identification = classification.identifier
				let confidence = "\(Int(classification.confidence * 100))"
				
				identificationLbl.text = identification
				confidenceLbl.text = "CONFIDENCE: \(confidence)%"
				synthesizeSpeech(fromString: randomPhrase(object: identification, confidence: confidence))
			}
			break
		}
	}
	
	func randomPhrase(object: String, confidence: String) -> String {
		let randomizer = Int(arc4random_uniform(3))
		let phrase: String!
		
		switch randomizer {
		case 0:
			phrase = "Bruh, it's a \(object), and I'm about \(confidence) percent sure about it!"
		case 1:
			phrase = "I am \(confidence)% sure you are wasting my time with this cheap \(object)"
		case 2:
			phrase = "I am \(confidence)% sure about two things in life. One, that this is a \(object), and two, that you are a virgin. Ha, burn."
		default:
			phrase = ""
		}
		return phrase
	}
	
	// MARK: - SpeechSynthesizer
	func synthesizeSpeech(fromString string: String) {
		let speechUtterance = AVSpeechUtterance(string: string)
		speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
		speechSynthesizer.speak(speechUtterance)
	}
	
	// MARK: - IBActions
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

extension CameraVC: AVSpeechSynthesizerDelegate {
	func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
		//code to finish utterance
	}
}
