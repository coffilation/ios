//
//  UITextField+Extension.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.11.2022.
//

import UIKit

extension UITextField {
	func setLeftView(with view: UIView, insets: UIEdgeInsets) {
		leftViewMode = .always
		leftView = createContainerView(for: view, insets: insets)
	}

	func setRightView(with view: UIView, insets: UIEdgeInsets) {
		rightViewMode = .always
		rightView = createContainerView(for: view, insets: insets)
	}

	private func createContainerView(for view: UIView, insets: UIEdgeInsets) -> UIView {
		let movedView = view
		movedView.frame.origin = CGPoint(x: insets.left, y: insets.top)
		let containerView = UIView(
			frame: CGRect(
				x: 0,
				y: 0,
				width: movedView.frame.width + insets.left + insets.right,
				height: movedView.frame.height + insets.top + insets.bottom
			)
		)
		containerView.addSubview(movedView)
		return containerView
	}
}
