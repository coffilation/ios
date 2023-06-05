//
//  ColorSelectView.swift
//  coffilation
//
//  Created by Матвей Борисов on 20.05.2023.
//

import Foundation
import UIKit

class ColorSelectView: UIView {

	var selectedGradient = UIColor.redGradient

	private let defaultGradients = [
		UIColor.redGradient,
		UIColor.orangeGradient,
		UIColor.greenGradient,
		UIColor.blueGradient,
		UIColor.purpleGradient
	]

	private lazy var firstButton: UIButton = {
		let button = UIButton(type: .system)
		button.autoSetDimensions(to: CGSize(width: 50, height: 50))
		button.addTarget(self, action: #selector(selectColorAction(_:)), for: .touchUpInside)
		return button
	}()

	private lazy var secondButton: UIButton = {
		let button = UIButton(type: .system)
		button.autoSetDimensions(to: CGSize(width: 50, height: 50))
		button.addTarget(self, action: #selector(selectColorAction(_:)), for: .touchUpInside)
		return button
	}()

	private lazy var thirdButton: UIButton = {
		let button = UIButton(type: .system)
		button.autoSetDimensions(to: CGSize(width: 50, height: 50))
		button.addTarget(self, action: #selector(selectColorAction(_:)), for: .touchUpInside)
		return button
	}()

	private lazy var fourthButton: UIButton = {
		let button = UIButton(type: .system)
		button.autoSetDimensions(to: CGSize(width: 50, height: 50))
		button.addTarget(self, action: #selector(selectColorAction(_:)), for: .touchUpInside)
		return button
	}()

	private lazy var fifthButton: UIButton = {
		let button = UIButton(type: .system)
		button.autoSetDimensions(to: CGSize(width: 50, height: 50))
		button.addTarget(self, action: #selector(selectColorAction(_:)), for: .touchUpInside)
		return button
	}()

	private lazy var gradientsButtons = [
		firstButton: firstButton.addGradient(colors: [defaultGradients[0].start, defaultGradients[0].end]),
		secondButton: secondButton.addGradient(colors: [defaultGradients[1].start, defaultGradients[1].end]),
		thirdButton: thirdButton.addGradient(colors: [defaultGradients[2].start, defaultGradients[2].end]),
		fourthButton: fourthButton.addGradient(colors: [defaultGradients[3].start, defaultGradients[3].end]),
		fifthButton: fifthButton.addGradient(colors: [defaultGradients[4].start, defaultGradients[4].end])
	]

	private var selectedButton: UIButton?

	private let label: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		label.text = "Выберите фон"
		label.textAlignment = .left
		return label
	}()

	private let selectView: UIView = {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
		view.backgroundColor = .white
		view.layer.cornerRadius = 10
		return view
	}()

	private let buttonsContainer: UIView = {
		let view = UIView()
		view.layer.shadowColor = UIColor.shadow.cgColor
		view.layer.shadowOpacity = 1
		view.layer.shadowRadius = 16
		return view
	}()

	init() {
		super.init(frame: .zero)
		setupLayout()
		selectedButton = firstButton
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		if let button = selectedButton {
			self.selectView.center = self.buttonsContainer.convert(button.center, to: self)
		}
		gradientsButtons.forEach { (button, gradient) in
			button.layer.cornerRadius = 8
			gradient.cornerRadius = 8
			gradient.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupLayout() {
		addSubview(label)
		label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 19, bottom: 0, right: 19), excludingEdge: .bottom)

		addSubview(buttonsContainer)
		buttonsContainer.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 19, bottom: 16, right: 19), excludingEdge: .top)
		buttonsContainer.autoPinEdge(.top, to: .bottom, of: label, withOffset: 16)

		buttonsContainer.addSubview(firstButton)
		firstButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)

		buttonsContainer.addSubview(fifthButton)
		fifthButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .leading)

		buttonsContainer.addSubview(thirdButton)
		thirdButton.autoCenterInSuperview()

		let secondButtonContainer = UIView()
		buttonsContainer.addSubview(secondButtonContainer)
		secondButtonContainer.autoPinEdge(.leading, to: .trailing, of: firstButton)
		secondButtonContainer.autoPinEdge(.trailing, to: .leading, of: thirdButton)
		buttonsContainer.addSubview(secondButton)
		secondButton.autoPinEdge(toSuperviewEdge: .top)
		secondButton.autoAlignAxis(.vertical, toSameAxisOf: secondButtonContainer)

		let fourthButtonContainer = UIView()
		buttonsContainer.addSubview(fourthButtonContainer)
		fourthButtonContainer.autoPinEdge(.leading, to: .trailing, of: thirdButton)
		fourthButtonContainer.autoPinEdge(.trailing, to: .leading, of: fifthButton)
		buttonsContainer.addSubview(fourthButton)
		fourthButton.autoPinEdge(toSuperviewEdge: .top)
		fourthButton.autoAlignAxis(.vertical, toSameAxisOf: fourthButtonContainer)

		addSubview(selectView)
	}

	@objc private func selectColorAction(_ sender: UIButton) {
		selectedButton = sender
		UIView.animate(withDuration: 0.5) {
			self.selectView.center = self.buttonsContainer.convert(sender.center, to: self)
		}
		if let index = gradientsButtons.firstIndex(where: { (button, _) in
			button === sender
		}) {
			let distance = gradientsButtons.distance(from: gradientsButtons.startIndex, to: index)
			selectedGradient = defaultGradients[distance]
		}
	}
}
