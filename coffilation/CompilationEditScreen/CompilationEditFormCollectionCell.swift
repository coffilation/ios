//
//  CompilationEditFormCollectionCell.swift
//  coffilation
//
//  Created by Матвей Борисов on 20.05.2023.
//

import Foundation
import UIKit

struct CompilationEditFormData {
	let name: String?
	let description: String?
	let isPrivate: Bool
	let primaryColor: CGColor
	let secondaryColor: CGColor
}

protocol CompilationEditFormProtocol: AnyObject {
	func collectFormData() -> CompilationEditFormData

	func updateState(with state: CompilationEditFormCollectionCell.State)
}

class CompilationEditFormCollectionCell: UICollectionViewCell {

	enum State {
		case edit
		case error(String)
		case loading
	}

	let colorSelectView = ColorSelectView()

	let nameTextField: UITextField = {
		let textField = UITextField()
		textField.backgroundColor = .white
		textField.layer.cornerRadius = 10
		textField.attributedPlaceholder = NSAttributedString(
			string: "Название...",
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
		)
		textField.layer.shadowColor = UIColor.shadow.cgColor
		textField.layer.shadowRadius = 16
		textField.layer.shadowOpacity = 1
		textField.setLeftView(with: UIView(frame: .zero), insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0))
		return textField
	}()

	let descriptionTextView: UITextView = {
		let textView = UITextView()
		textView.backgroundColor = .white
		textView.layer.cornerRadius = 10
		textView.text = "Описание коллекции..."
		textView.textColor = UIColor.lightGray
		textView.layer.shadowColor = UIColor.shadow.cgColor
		textView.layer.shadowRadius = 16
		textView.layer.shadowOpacity = 1
		textView.clipsToBounds = false
		textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
		return textView
	}()

	private let privateSelectLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		label.text = "Приватная коллекция:"
		label.textAlignment = .left
		return label
	}()

	private let privateSwitch = UISwitch()

	private let errorLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .white
		label.textColor = .red
		label.textAlignment = .center
		return label
	}()

	private let loadIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .medium)
		indicator.hidesWhenStopped = true
		return indicator
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupLayout()

		descriptionTextView.delegate = self
		nameTextField.addTarget(self, action: #selector(hideErrorLabel), for: .allTouchEvents)
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditInForm)))
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupLayout() {
		addSubview(colorSelectView)
		colorSelectView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
		colorSelectView.autoSetDimension(.width, toSize: UIScreen.main.bounds.size.width)
		colorSelectView.isUserInteractionEnabled = true

		addSubview(nameTextField)
		nameTextField.autoPinEdge(.top, to: .bottom, of: colorSelectView, withOffset: 16)
		nameTextField.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
		nameTextField.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
		nameTextField.autoSetDimension(.height, toSize: 48)

		addSubview(descriptionTextView)
		descriptionTextView.autoPinEdge(.top, to: .bottom, of: nameTextField, withOffset: 24)
		descriptionTextView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
		descriptionTextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
		descriptionTextView.autoSetDimension(.height, toSize: 80)

		addSubview(privateSelectLabel)
		privateSelectLabel.autoPinEdge(.top, to: .bottom, of: descriptionTextView, withOffset: 24)
		privateSelectLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 19)
		privateSelectLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

		addSubview(privateSwitch)
		privateSwitch.autoPinEdge(.left, to: .right, of: privateSelectLabel, withOffset: 16)
		privateSwitch.autoAlignAxis(.horizontal, toSameAxisOf: privateSelectLabel)
		privateSwitch.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		privateSwitch.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

		addSubview(errorLabel)
		errorLabel.autoPinEdge(.top, to: .bottom, of: privateSwitch, withOffset: 8)
		errorLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
		errorLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
		errorLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
		errorLabel.autoSetDimension(.height, toSize: 20)

		addSubview(loadIndicator)
		loadIndicator.autoAlignAxis(.horizontal, toSameAxisOf: errorLabel)
		loadIndicator.autoAlignAxis(.vertical, toSameAxisOf: errorLabel)
	}

	@objc private func hideErrorLabel() {
		errorLabel.text = ""
	}

	@objc func endEditInForm() {
		nameTextField.endEditing(true)
		descriptionTextView.endEditing(true)
	}
}

extension CompilationEditFormCollectionCell: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == UIColor.lightGray {
			textView.text = nil
			textView.textColor = UIColor.black
		}
		updateState(with: .edit)
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = "Описание коллекции..."
			textView.textColor = UIColor.lightGray
		}
		updateState(with: .edit)
	}
}

extension CompilationEditFormCollectionCell: CompilationEditFormProtocol {
	func collectFormData() -> CompilationEditFormData {
		let compilationDescription = descriptionTextView.textColor == UIColor.lightGray ? nil : descriptionTextView.text
		return CompilationEditFormData(
			name: nameTextField.text,
			description: compilationDescription,
			isPrivate: privateSwitch.isOn,
			primaryColor: colorSelectView.selectedGradient.start,
			secondaryColor: colorSelectView.selectedGradient.end
		)
	}

	func updateState(with state: State) {
		switch state {
		case .error(let error):
			errorLabel.text = error
			loadIndicator.stopAnimating()
			nameTextField.isEnabled = true
			descriptionTextView.isUserInteractionEnabled = true
		case .edit:
			errorLabel.text = ""
			loadIndicator.stopAnimating()
			nameTextField.isEnabled = true
			descriptionTextView.isUserInteractionEnabled = true
		case .loading:
			errorLabel.text = ""
			loadIndicator.startAnimating()
			nameTextField.isEnabled = false
			descriptionTextView.isUserInteractionEnabled = false
		}
	}
}
