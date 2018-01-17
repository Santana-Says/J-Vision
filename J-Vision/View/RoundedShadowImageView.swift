//
//  RoundedShadowImageView.swift
//  J-Vision
//
//  Created by Jeffrey Santana on 1/17/18.
//  Copyright © 2018 Jefffrey Santana. All rights reserved.
//

import UIKit

class RoundedShadowImageView: UIImageView {

	override func awakeFromNib() {
		layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
		layer.shadowRadius = 15
		layer.shadowOpacity = 0.75
		layer.cornerRadius = 15
	}

}
