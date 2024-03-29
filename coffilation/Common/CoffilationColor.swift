//
//  CoffilationColor.swift
//  coffilation
//
//  Created by Матвей Борисов on 15.11.2022.
//

import UIKit

extension UIColor {
//	static let mainColor = UIColor(displayP3Red: 255/255, green: 103/255, blue: 72/255, alpha: 1)

	static let mainColor = UIColor(red: 255/255, green: 103/255, blue: 72/255, alpha: 1)

	static let darkGray = UIColor(red: 108/255, green: 108/255, blue: 108/255, alpha: 1)

	static let middleGray = UIColor(red: 190/255, green: 191/255, blue: 192/255, alpha: 1)

	static let grey2 = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)

	static let defaultBackground = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)

	static let defaultButtonText = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)

	static let coffiLightGray = UIColor(red: 247/255, green: 248/255, blue: 248/255, alpha: 1)

	static let shadow = UIColor(red: 0, green: 0, blue: 0, alpha: 0.13)

	static let redGradient = (
		start: UIColor(red: 223/255, green: 70/255, blue: 133/255, alpha: 1).cgColor,
		end: UIColor(red: 255/255, green: 131/255, blue: 69/255, alpha: 1).cgColor
	)

	static let orangeGradient = (
		start: UIColor(red: 255/255, green: 118/255, blue: 40/255, alpha: 1).cgColor,
		end: UIColor(red: 255/255, green: 199/255, blue: 0/255, alpha: 1).cgColor
	)

	static let purpleGradient = (
		start: UIColor(red: 255/255, green: 74/255, blue: 130/255, alpha: 1).cgColor,
		end: UIColor(red: 112/255, green: 0/255, blue: 155/255, alpha: 1).cgColor
	)

	static let blueGradient = (
		start: UIColor(red: 72/255, green: 224/255, blue: 151/255, alpha: 1).cgColor,
		end: UIColor(red: 112/255, green: 0/255, blue: 255/255, alpha: 1).cgColor
	)

	static let greenGradient = (
		start: UIColor(red: 0/255, green: 160/255, blue: 6/255, alpha: 1).cgColor,
		end: UIColor(red: 255/255, green: 235/255, blue: 55/255, alpha: 1).cgColor
	)
}
