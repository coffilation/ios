//
//  MyCompilationTableViewCell.swift
//  coffilation
//
//  Created by Матвей Борисов on 29.11.2022.
//

import UIKit

class MyCompilationTableViewCell: UITableViewCell {

	private let collectionAvatarImage = SkeletonView()

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

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		collectionAvatarImage.roundCorners(corners: .allCorners, radius: 8, rect: collectionAvatarImage.bounds)
		gradient?.frame = collectionAvatarImage.bounds
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

	func configure(name: String?, description: String?, gradient: [CGColor]) {
		nameLabel.text = name
		descriptionLabel.text = description
		let collectionName = name ?? "?"
		collectionAvatarLabel.text = collectionName.prefix(1).capitalized
		self.gradient?.removeFromSuperlayer()
		self.gradient = nil
		if name == nil {
			collectionAvatarImage.start()
		} else {
			collectionAvatarImage.stop()
			if !gradient.isEmpty {
				self.gradient = collectionAvatarImage.addGradient(colors: gradient)
			} else {
				self.gradient = collectionAvatarImage.addGradient(colors: [UIColor.orangeGradient.start, UIColor.orangeGradient.end])
			}
		}
		collectionAvatarImage.bringSubviewToFront(collectionAvatarLabel)
	}
}

extension UITableViewCell {
	static var reuseIdentifier: String {
		return NSStringFromClass(self)
	}
}
