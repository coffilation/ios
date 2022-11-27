//
//  UIView+Extension.swift
//  coffilation
//
//  Created by Матвей Борисов on 26.11.2022.
//

import UIKit

extension UIView {
	func roundCorners(corners: UIRectCorner, radius: CGFloat, rect: CGRect) {
		let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		layer.mask = mask
	}

	enum ViewSide {
		case left, right, top, bottom
	}

	func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {

		let border = CALayer()
		border.backgroundColor = color

		switch side {
		case .left: border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: thickness, height: frame.height)
		case .right: border.frame = CGRect(x: bounds.maxX, y: bounds.minY, width: thickness, height: frame.height)
		case .top: border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: frame.width, height: thickness)
		case .bottom: border.frame = CGRect(x: bounds.minX, y: bounds.maxY - thickness, width: frame.width, height: thickness)
		}

		layer.addSublayer(border)
	}
}
