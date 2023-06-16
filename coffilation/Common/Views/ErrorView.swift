//
//  ErrorView.swift
//  coffilation
//
//  Created by Матвей Борисов on 13.06.2023.
//

import UIKit

class ErrorView: UIView {

	var retryAction: (() -> Void)?

	private let errorLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()

	private let retryButton: UIButton = {
		let button = UIButton(type: .system)
		var configuration = UIButton.Configuration.plain()
		configuration.imagePadding = 8
		button.configuration = configuration
		button.tintColor = .mainColor
		button.setTitleColor(.mainColor, for: .normal)
		button.setImage(CoffilationImage.refresh?.withRenderingMode(.alwaysTemplate), for: .normal)
		return button
	}()

	init(errorLabelText: String, errorButtonText: String) {
		super.init(frame: .zero)
		errorLabel.text = errorLabelText
		retryButton.setTitle(errorButtonText, for: .normal)
		retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupLayout() {
		addSubview(errorLabel)
		errorLabel.autoPinEdge(toSuperviewEdge: .top)
		errorLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 48)
		errorLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 48)

		addSubview(retryButton)
		retryButton.autoPinEdge(.top, to: .bottom, of: errorLabel, withOffset: 16)
		retryButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
		retryButton.autoSetDimension(.height, toSize: 40)
		retryButton.autoAlignAxis(toSuperviewAxis: .vertical)
	}

	@objc private func retryButtonTapped() {
		retryAction?()
	}
}
