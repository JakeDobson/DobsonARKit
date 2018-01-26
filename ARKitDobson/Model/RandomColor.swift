//RandomColor.swift
//ARKitDobson
//Created by Jacob Dobson on 1/17/18.
//Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit
//extension to create random number
extension CGFloat {
	static func random() -> CGFloat {
		return CGFloat(arc4random()) / CGFloat(UInt32.max)
	}
}
//extension to execute a random color
extension UIColor {
	static func random() -> UIColor {
		return UIColor(red: .random(),
					   green: .random(),
					   blue: .random(),
					   alpha: 1.0)
	}
}
