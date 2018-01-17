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
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
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

}

extension CameraVC {
	
}
