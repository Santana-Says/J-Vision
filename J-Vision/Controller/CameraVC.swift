//
//  ViewController.swift
//  J-Vision
//
//  Created by Jeffrey Santana on 1/15/18.
//  Copyright © 2018 Jefffrey Santana. All rights reserved.
//

import UIKit

class CameraVC: UIViewController {

	@IBOutlet weak var captureImgView: UIImageView!
	@IBOutlet weak var identificationLbl: UILabel!
	@IBOutlet weak var confidenceLbl: UILabel!
	@IBOutlet weak var cameraView: UIView!
	@IBOutlet weak var flashBtn: UIButton!
	@IBOutlet weak var roundedLblView: RoundedShadowView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

}

