//
//  ViewController.swift
//  J-Vision
//
//  Created by Jeffrey Santana on 1/15/18.
//  Copyright © 2018 Jefffrey Santana. All rights reserved.
//

import UIKit
import AVFoundation

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
		let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!	//returns a basic photo
		let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160]
		
		settings.previewPhotoFormat = previewFormat	//make thumbnail size image
		cameraOutput.capturePhoto(with: settings, delegate: self)
	}

}

extension CameraVC: AVCapturePhotoCaptureDelegate {
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		if let error = error {
			debugPrint(error)
		} else {
			photoData = photo.fileDataRepresentation()
			
			let image = UIImage(data: photoData!)
			captureImgView.image = image
		}
	}
	
}
