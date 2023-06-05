//
//  BigCompilationLoadingView.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.05.2023.
//

import Foundation
import UIKit

class BigCompilationLoadingView: UIView {

	private let collectionAvatarImage = SkeletonView()
	private let nameLabel = SkeletonView()
	private let descriptionLabel = SkeletonView()

	init() {
		super.init(frame: .zero)
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		roundCorners(corners: .allCorners, radius: 10, rect: bounds)
		collectionAvatarImage.roundCorners(corners: .allCorners, radius: 8, rect: collectionAvatarImage.bounds)
		nameLabel.roundCorners(corners: .allCorners, radius: 4, rect: nameLabel.bounds)
		descriptionLabel.roundCorners(corners: .allCorners, radius: 4, rect: descriptionLabel.bounds)
	}

	private func setupLayout() {
		addSubview(collectionAvatarImage)
		collectionAvatarImage.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 0), excludingEdge: .right)
		collectionAvatarImage.autoSetDimensions(to: CGSize(width: 50, height: 50))

		addSubview(nameLabel)
		nameLabel.autoPinEdge(.left, to: .right, of: collectionAvatarImage, withOffset: 12)
		nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 22)
		nameLabel.autoSetDimensions(to: CGSize(width: 100, height: 20))

		addSubview(descriptionLabel)
		descriptionLabel.autoPinEdge(.left, to: .right, of: collectionAvatarImage, withOffset: 12)
		descriptionLabel.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 4)
		descriptionLabel.autoSetDimensions(to: CGSize(width: 60, height: 14))

		collectionAvatarImage.start()
		nameLabel.start()
		descriptionLabel.start()

		backgroundColor = .white
	}
}
