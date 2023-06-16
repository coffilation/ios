//
//  LoadingReusableView.swift
//  coffilation
//
//  Created by Матвей Борисов on 13.06.2023.
//

import Foundation
import UIKit

class LoadingReusableView: UICollectionReusableView {

	private let activity = UIActivityIndicatorView(style: .large)

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	init() {
		super.init(frame: .zero)
		setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupView() {
		addSubview(activity)
		activity.autoCenterInSuperview()
		activity.tintColor = .darkGray
		autoSetDimension(.height, toSize: 50)
	}

	func startAnimating() {
		activity.startAnimating()
	}

	func stopAnimating() {
		activity.stopAnimating()
	}
}

extension UICollectionReusableView {
	static var reuseIdentifier: String {
		return NSStringFromClass(self)
	}
}
