//
//  PlacesCollectionViewCell.swift
//  coffilation
//
//  Created by Матвей Борисов on 15.06.2023.
//

import Foundation
import UIKit

class PlacesCollectionViewCell: UICollectionViewCell {

	let titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		return label
	}()

	let adressTitle: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		label.textColor = .darkGray
		return label
	}()

	let adressLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
		label.numberOfLines = 0
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupLayout() {
		contentView.backgroundColor = .white
		contentView.layer.cornerRadius = 8

		contentView.addSubview(titleLabel)
		titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)

		contentView.addSubview(adressTitle)
		adressTitle.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 24)
		adressTitle.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
		adressTitle.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)

		contentView.addSubview(adressLabel)
		adressLabel.autoPinEdge(.top, to: .bottom, of: adressTitle)
		adressLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16), excludingEdge: .top)

		contentView.layer.shadowColor = UIColor.shadow.cgColor
		contentView.layer.shadowRadius = 5
		contentView.layer.shadowOpacity = 1
		contentView.layer.shadowOffset = CGSize(width: 0, height: 5)
	}

	func configure(with place: Place) {
		titleLabel.text = place.name
		adressLabel.text = "\(place.city), \(place.road) \(place.houseNumber)"
	}
}
