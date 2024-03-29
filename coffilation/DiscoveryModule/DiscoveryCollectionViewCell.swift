//
//  DiscoveryCollectionViewCell.swift
//  coffilation
//
//  Created by Матвей Борисов on 29.11.2022.
//

import UIKit

class DiscoveryCollectionViewCell: UICollectionViewCell {
	private let labelText: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		label.textAlignment = .left
		label.contentMode = .bottomLeft
		label.textColor = .white
		label.numberOfLines = 0
		return label
	}()

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
		gradient?.frame = bounds
	}

	private func setupLayout() {
		addSubview(labelText)
		labelText.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 4, bottom: 8, right: 4), excludingEdge: .top)
		labelText.autoPinEdge(toSuperviewEdge: .top, withInset: 8, relation: .greaterThanOrEqual)
	}

	func configure(text: String?, gradient: [CGColor]) {
		labelText.text = text ?? ""
		self.gradient = nil
		self.gradient = addGradient(colors: gradient)
		bringSubviewToFront(labelText)
	}
}
