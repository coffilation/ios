//
//  DiscoveryCollectionViewCell.swift
//  coffilation
//
//  Created by Матвей Борисов on 29.11.2022.
//

import UIKit

class DiscoveryCollectionViewCell: UICollectionViewCell {
	private let label: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
		label.textAlignment = .left
		label.contentMode = .bottomLeft
		label.textColor = .white
		label.numberOfLines = 0
		return label
	}()

	private let skeleton = SkeletonView()
	private var gradient: CAGradientLayer?

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		roundCorners(corners: .allCorners, radius: 8, rect: bounds)
	}

	private func setupLayout() {
		addSubview(skeleton)
		skeleton.autoPinEdgesToSuperviewEdges()

		addSubview(label)
		label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 4, bottom: 8, right: 4), excludingEdge: .top)
		label.autoPinEdge(toSuperviewEdge: .top, withInset: 8, relation: .greaterThanOrEqual)

		autoSetDimensions(to: CGSize(width: 80, height: 100))
	}

	func configure(text: String?, gradient: [CGColor]) {
		label.text = text ?? ""
		self.gradient = nil
		if text == nil {
			skeleton.start()
		} else {
			skeleton.stop()
			if !gradient.isEmpty {
				self.gradient = addGradient(colors: gradient)
			} else {
				self.gradient = addGradient(colors: UIColor.orangeGradient)
			}
		}
	}
}

extension UICollectionViewCell {
	static var reuseIdentifier: String {
		return NSStringFromClass(self)
	}
}