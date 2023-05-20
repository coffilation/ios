//
//  DiscoveryLoadingView.swift
//  coffilation
//
//  Created by Матвей Борисов on 18.05.2023.
//

import UIKit
import PureLayout

class DiscoveryLoadingView: UIView {

	init() {
		super.init(frame: .zero)
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupLayout() {
		var arrangedSubviews = [UIView]()
		for _ in 0...2 {
			let skeletonView = SkeletonView()
			arrangedSubviews.append(skeletonView)
			skeletonView.autoSetDimensions(to: CGSize(width: 80, height: 100))
			skeletonView.layer.cornerRadius = 8
			skeletonView.start()
		}
		let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
		addSubview(stackView)
		stackView.distribution = .equalSpacing
		stackView.spacing = 8
		stackView.alignment = .leading
		stackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
		stackView.autoPinEdge(toSuperviewEdge: .top)
		stackView.autoPinEdge(toSuperviewEdge: .bottom)
	}
}
