//
//  LoginViewController.swift
//  coffilation
//
//  Created by Матвей Борисов on 10.10.2022.
//

import UIKit
import PureLayout

class LoginViewController: UIViewController {

	var presenter: LoginPresenterProtocol?

	private let logoView: UIImageView = {
		let imageView = UIImageView(image: CoffilationImage.logo)
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	private let loginField: UITextField = {
		let textField = UITextField()
		textField.backgroundColor = .white
		textField.borderStyle = .roundedRect
		textField.layer.cornerRadius = 5
		textField.layer.borderWidth = 1
		textField.layer.borderColor = UIColor.grey2.cgColor
		let profileImageView = UIImageView(image: CoffilationImage.profile)
		profileImageView.tintColor = .darkGray
		profileImageView.contentMode = .scaleAspectFit
		textField.setLeftView(with: profileImageView, insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
		textField.attributedPlaceholder = NSAttributedString(
			string: "Никнейм",
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
		return textField
	}()

	private let passwordField: UITextField = {
		let textField = UITextField()
		textField.isSecureTextEntry = true
		textField.backgroundColor = .white
		textField.borderStyle = .roundedRect
		textField.layer.cornerRadius = 5
		textField.layer.borderWidth = 1
		textField.layer.borderColor = UIColor.grey2.cgColor

		let lockImageView = UIImageView(image: CoffilationImage.lock)
		lockImageView.tintColor = .darkGray
		lockImageView.contentMode = .scaleAspectFit
		textField.setLeftView(with: lockImageView, insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))

		let hidePassButton = UIButton(type: .custom)
		var buttonConfig = UIButton.Configuration.plain()
		buttonConfig.contentInsets = .init(top: 2, leading: 0, bottom: 0, trailing: 12)
		hidePassButton.configuration = buttonConfig
		hidePassButton.setImage(CoffilationImage.hidePassword, for: .normal)
		hidePassButton.tintColor = .darkGray
		hidePassButton.imageView?.contentMode = .scaleAspectFit
		hidePassButton.addAction(UIAction(handler: { [weak textField] _ in
			textField?.isSecureTextEntry.toggle()
		}), for: .touchUpInside)
		textField.setRightView(with: hidePassButton, insets: .zero)
		hidePassButton.autoPinEdgesToSuperviewEdges()

		textField.attributedPlaceholder = NSAttributedString(
			string: "Пароль",
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
		return textField
	}()

	private let loginButton: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = 5
		button.backgroundColor = .mainColor
		button.tintColor = .defaultButtonText
		button.setTitle("Вход", for: .normal)
		button.setTitleColor(.defaultButtonText, for: .normal)
		button.setImage(CoffilationImage.login, for: .normal)
		return button
	}()

	private let errorLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .white
		label.textColor = .red
		return label
	}()

	private let loadIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .medium)
		indicator.hidesWhenStopped = true
		return indicator
	}()

	private let registerButton: UIButton = {
		let button = UIButton(type: .system)
		let title = NSMutableAttributedString(string: "Нет аккаунта? ",
											  attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray.cgColor])
		let secondPartTitle = NSAttributedString(string: "Регистрация",
												 attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainColor.cgColor])
		title.append(secondPartTitle)
		button.setAttributedTitle(title, for: .normal)
		return button
	}()

	private let scrollView: UIScrollView = {
		let scroll = UIScrollView()
		scroll.delaysContentTouches = false
		return scroll
	}()

	private let containerView = UIView()

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .defaultBackground

		setupLayout()
		setupActions()

		loginField.delegate = self
		passwordField.delegate = self
	}

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupActions() {
		loginButton.addTarget(self, action: #selector(requestLogin), for: .touchUpInside)

		let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
		view.addGestureRecognizer(tap)
	}

	private func setupLayout() {
		navigationItem.setHidesBackButton(true, animated: true)
		view.addSubview(scrollView)
		scrollView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
		scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true

		scrollView.addSubview(containerView)
		containerView.autoMatch(.width, to: .width, of: scrollView, withOffset: -32, relation: .equal)
		containerView.autoCenterInSuperview()
		containerView.setContentHuggingPriority(.defaultLow, for: .vertical)
		containerView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

		containerView.addSubview(logoView)
		containerView.addSubview(loginField)
		containerView.addSubview(passwordField)
		containerView.addSubview(loginButton)
		containerView.addSubview(registerButton)
		containerView.addSubview(errorLabel)
		containerView.addSubview(loadIndicator)

		logoView.autoPinEdge(toSuperviewEdge: .top)
		logoView.autoAlignAxis(toSuperviewAxis: .vertical)

		loginField.autoPinEdge(.top, to: .bottom, of: logoView, withOffset: 56)
		loginField.autoPinEdge(toSuperviewEdge: .leading)
		loginField.autoPinEdge(toSuperviewEdge: .trailing)
		loginField.autoSetDimension(.height, toSize: 48)

		passwordField.autoPinEdge(.top, to: .bottom, of: loginField, withOffset: 24)
		passwordField.autoPinEdge(toSuperviewEdge: .leading)
		passwordField.autoPinEdge(toSuperviewEdge: .trailing)
		passwordField.autoSetDimension(.height, toSize: 48)

		loginButton.autoPinEdge(.top, to: .bottom, of: passwordField, withOffset: 56)
		loginButton.autoPinEdge(toSuperviewEdge: .leading)
		loginButton.autoPinEdge(toSuperviewEdge: .trailing)
		loginButton.autoSetDimension(.height, toSize: 48)

		registerButton.autoPinEdge(.top, to: .bottom, of: loginButton, withOffset: 16)
		registerButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0), excludingEdge: .top)

		errorLabel.autoAlignAxis(toSuperviewAxis: .vertical)
		errorLabel.autoPinEdge(.top, to: .bottom, of: passwordField, withOffset: 16)

		loadIndicator.autoAlignAxis(toSuperviewAxis: .vertical)
		loadIndicator.autoPinEdge(.top, to: .bottom, of: passwordField, withOffset: 18)
	}

	@objc private func requestLogin() {
		guard let email = loginField.text, email != "", let password = passwordField.text, password != "" else {
			errorLabel.text = "Заполните поля"
			showErrorLabel()
			return
		}
		hideErrorLabel()
		disableLoginButton()
		presenter?.performLogin(email: email, password: password)
	}

	private func hideErrorLabel() {
		UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
			self.errorLabel.alpha = 0
		}
	}

	private func showErrorLabel() {
		UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
			self.errorLabel.alpha = 1
		}
	}

	private func enableLoginButton() {
		loadIndicator.stopAnimating()
		UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
			self.loginButton.backgroundColor = .mainColor
			self.loginButton.isEnabled = true
		}
	}

	private func disableLoginButton() {
		loadIndicator.startAnimating()
		UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
			self.loginButton.backgroundColor = .middleGray
			self.loginButton.isEnabled = false
		}
	}
}

extension LoginViewController: LoginViewProtocol {
	func receivedError(with error: LoginPresenterErrors) {
		enableLoginButton()
		switch error {
		case .loginError:
			errorLabel.text = "Проверьте введенные данные"
		case .networkError:
			errorLabel.text = "Повторите попытку позже"
		}
		showErrorLabel()
	}

	func receivedSuccess() {
		enableLoginButton()
		navigationController?.popViewController(animated: true)
	}
}

extension LoginViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		hideErrorLabel()
	}
}
