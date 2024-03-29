//
//  BigCompilationView.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.05.2023.
//

import Foundation
import UIKit

class BigCompilationView: UIView {

	private let collectionAvatarImage = UIView()

	private let collectionAvatarLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
		label.textColor = .white
		return label
	}()

	private var gradient: CAGradientLayer?

	private let nameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		label.textAlignment = .left
		label.numberOfLines = 1
		return label
	}()

	private let descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
		label.textAlignment = .left
		label.numberOfLines = 1
		label.textColor = .middleGray
		return label
	}()

	private var storedCompilation: Compilation?
	private var didTapCellCompletion: ((Compilation) -> Void)?

	init() {
		super.init(frame: .zero)
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		collectionAvatarImage.roundCorners(corners: .allCorners, radius: 8, rect: collectionAvatarImage.bounds)
		roundCorners(corners: .allCorners, radius: 10, rect: bounds)
		gradient?.frame = collectionAvatarImage.bounds
		backgroundColor = .white
	}

	private func setupLayout() {
		addSubview(collectionAvatarImage)
		collectionAvatarImage.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 0), excludingEdge: .right)
		collectionAvatarImage.autoSetDimensions(to: CGSize(width: 50, height: 50))

		collectionAvatarImage.addSubview(collectionAvatarLabel)
		collectionAvatarLabel.autoCenterInSuperview()

		addSubview(nameLabel)
		nameLabel.autoPinEdge(.left, to: .right, of: collectionAvatarImage, withOffset: 12)
		nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 22)
		nameLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)

		addSubview(descriptionLabel)
		descriptionLabel.autoPinEdge(.left, to: .right, of: collectionAvatarImage, withOffset: 12)
		descriptionLabel.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 4)
		descriptionLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
	}

	func configure(name: String, description: String?, gradient: [CGColor]) {
		nameLabel.text = name
		descriptionLabel.text = description ?? ""
		let collectionName = name
		collectionAvatarLabel.text = collectionName.prefix(1).capitalized
		self.gradient?.removeFromSuperlayer()
		self.gradient = nil
		self.gradient = collectionAvatarImage.addGradient(colors: gradient)
		collectionAvatarImage.bringSubviewToFront(collectionAvatarLabel)
	}

	func storeCompilation(_ compilation: Compilation, didTapCellCompletion: @escaping (Compilation) -> Void) {
		storedCompilation = compilation
		self.didTapCellCompletion = didTapCellCompletion
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCell)))
	}

	@objc private func didTapCell() {
		guard let completion = storedCompilation else {
			return
		}
		didTapCellCompletion?(completion)
	}
}
