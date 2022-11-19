//
//  UITextField+Extension.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.11.2022.
//

import UIKit

extension UITextField {
	func setLeftView(with view: UIView, insets: UIEdgeInsets) {
		let movedView = view
		movedView.frame.origin = CGPoint(x: insets.left, y: insets.top)
		let movedLeftView = UIView(frame: CGRect(x: 0,
												 y: 0,
												 width: movedView.frame.width + insets.left + insets.right,
												 height: movedView.frame.height + insets.top + insets.bottom))
		movedLeftView.addSubview(movedView)
		leftViewMode = .always
		leftView = movedLeftView
	}
}
