//
//  UIColor+Extension.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.05.2023.
//

import Foundation
import UIKit

extension UIColor {
	public convenience init?(hex: String) {
		let red, green, blue: CGFloat

		if hex.hasPrefix("#") {
			let start = hex.index(hex.startIndex, offsetBy: 1)
			let hexColor = String(hex[start...])

			if hexColor.count == 6 {
				let scanner = Scanner(string: hexColor)
				var hexNumber: UInt64 = 0

				if scanner.scanHexInt64(&hexNumber) {
					red = CGFloat((hexNumber & 0xff0000) >> 16) / 255
					green = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
					blue = CGFloat((hexNumber & 0x0000ff)) / 255
					self.init(red: red, green: green, blue: blue, alpha: 1)
					return
				}
			}
		}
		return nil
	}

	func toHex(withAlpha: Bool = false) -> String? {
		guard let components = cgColor.components, components.count >= 3 else {
			return nil
		}

		let red = Float(components[0])
		let green = Float(components[1])
		let blue = Float(components[2])
		var alpha = Float(1.0)

		if components.count >= 4 {
			alpha = Float(components[3])
		}

		if withAlpha {
			return String(format: "#%02lX%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255), lroundf(alpha * 255)).lowercased()
		} else {
			return String(format: "#%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255)).lowercased()
		}
	}
}
