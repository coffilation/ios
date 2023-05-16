//
//  AuthViewController.swift
//  coffilation
//
//  Created by Матвей Борисов on 10.10.2022.
//

import UIKit
import PureLayout

class AuthViewController: UIViewController {

	var presenter: AuthPresenterProtocol?

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
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
		)
		return textField
	}()

	private let passwordField: UITextField = makePasswordField(with: "Пароль")
	private let repeatPassField: UITextField = makePasswordField(with: "Повторите пароль")

	private let mainActionButton: UIButton = {
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
		label.numberOfLines = 0
		label.textAlignment = .center
		return label
	}()

	private let loadIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .medium)
		indicator.hidesWhenStopped = true
		return indicator
	}()

	private let secondActionButton: UIButton = {
		let button = UIButton(type: .system)
		let title = NSMutableAttributedString(
			string: "Нет аккаунта? ",
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray.cgColor]
		)
		let secondPartTitle = NSAttributedString(
			string: "Регистрация",
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainColor.cgColor]
		)
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

	private var repeatPassTopConstraint: NSLayoutConstraint?
	private var logoBottomConstraint: NSLayoutConstraint?

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .defaultBackground

		setupLayout()
		setupActions()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navigationItem.setHidesBackButton(true, animated: true)
		navigationController?.setNavigationBarHidden(true, animated: false)
	}

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupActions() {
		mainActionButton.addTarget(self, action: #selector(requestLogin), for: .touchUpInside)
		secondActionButton.addTarget(self, action: #selector(setupRegisterLayout), for: .touchUpInside)

		let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
		view.addGestureRecognizer(tap)

		loginField.addTarget(self, action: #selector(hideErrorLabel), for: .allEvents)
		passwordField.addTarget(self, action: #selector(hideErrorLabel), for: .allEvents)
		repeatPassField.addTarget(self, action: #selector(hideErrorLabel), for: .allEvents)
	}

	private func setupLayout() {
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
		containerView.addSubview(repeatPassField)
		containerView.addSubview(passwordField)
		containerView.addSubview(mainActionButton)
		containerView.addSubview(secondActionButton)
		containerView.addSubview(errorLabel)
		containerView.addSubview(loadIndicator)

		logoView.autoPinEdge(toSuperviewEdge: .top)
		logoView.autoAlignAxis(toSuperviewAxis: .vertical)

		logoBottomConstraint = loginField.autoPinEdge(.top, to: .bottom, of: logoView, withOffset: 56)
		loginField.autoPinEdge(toSuperviewEdge: .leading)
		loginField.autoPinEdge(toSuperviewEdge: .trailing)
		loginField.autoSetDimension(.height, toSize: 48)

		passwordField.autoPinEdge(.top, to: .bottom, of: loginField, withOffset: 24)
		passwordField.autoPinEdge(toSuperviewEdge: .leading)
		passwordField.autoPinEdge(toSuperviewEdge: .trailing)
		passwordField.autoSetDimension(.height, toSize: 48)

		repeatPassTopConstraint = repeatPassField.autoPinEdge(.top, to: .top, of: passwordField)
		repeatPassField.autoPinEdge(toSuperviewEdge: .leading)
		repeatPassField.autoPinEdge(toSuperviewEdge: .trailing)
		repeatPassField.autoSetDimension(.height, toSize: 48)

		errorLabel.autoPinEdge(toSuperviewEdge: .leading)
		errorLabel.autoPinEdge(toSuperviewEdge: .trailing)
		errorLabel.autoPinEdge(.top, to: .bottom, of: repeatPassField, withOffset: 20)

		mainActionButton.autoPinEdge(.top, to: .bottom, of: errorLabel, withOffset: 20)
		mainActionButton.autoPinEdge(toSuperviewEdge: .leading)
		mainActionButton.autoPinEdge(toSuperviewEdge: .trailing)
		mainActionButton.autoSetDimension(.height, toSize: 48)

		secondActionButton.autoPinEdge(.top, to: .bottom, of: mainActionButton, withOffset: 16)
		secondActionButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
		secondActionButton.autoAlignAxis(toSuperviewAxis: .vertical)

		loadIndicator.autoAlignAxis(toSuperviewAxis: .vertical)
		loadIndicator.autoPinEdge(.top, to: .bottom, of: repeatPassField, withOffset: 12)
	}

	@objc private func requestLogin() {
		guard let username = loginField.text, username != "", let password = passwordField.text, password != "" else {
			showErrorLabel(with: "Заполните поля")
			return
		}
		hideErrorLabel()
		disableButtons()
		presenter?.performLogin(username: username, password: password)
	}

	@objc private func requestRegister() {
		guard let username = loginField.text,
			  username != "",
			  let password = passwordField.text,
			  password != "",
			  let repeatPassword = repeatPassField.text,
			  repeatPassword != ""
		else {
			showErrorLabel(with: "Заполните поля")
			return
		}
		presenter?.performRegister(username: username, password: password, repeatPassword: repeatPassword)
		hideErrorLabel()
		disableButtons()
	}

	private static func makePasswordField(with text: String) -> UITextField {
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
		hidePassButton.addAction(
			UIAction(handler: { [weak textField] _ in
				textField?.isSecureTextEntry.toggle()
			}),
			for: .touchUpInside
		)
		textField.setRightView(with: hidePassButton, insets: .zero)
		hidePassButton.autoPinEdgesToSuperviewEdges()

		textField.attributedPlaceholder = NSAttributedString(
			string: text,
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
		)
		return textField
	}

	@objc private func hideErrorLabel() {
		errorLabel.text = ""
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
			self.errorLabel.alpha = 0
			self.view.layoutIfNeeded()
		}
	}

	private func showErrorLabel(with text: String) {
		errorLabel.text = text
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
			self.errorLabel.alpha = 1
			self.view.layoutIfNeeded()
		}
	}

	private func enableButtons() {
		loadIndicator.stopAnimating()
		UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
			self.mainActionButton.backgroundColor = .mainColor
			self.mainActionButton.isEnabled = true
			self.secondActionButton.isEnabled = true
		}
	}

	private func disableButtons() {
		loadIndicator.startAnimating()
		UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
			self.mainActionButton.backgroundColor = .middleGray
			self.mainActionButton.isEnabled = false
			self.secondActionButton.isEnabled = false
		}
	}

	@objc private func setupRegisterLayout() {
		let title = NSMutableAttributedString(
			string: "Есть аккаунт? ",
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray.cgColor]
		)
		let secondPartTitle = NSAttributedString(
			string: "Вход",
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainColor.cgColor]
		)
		title.append(secondPartTitle)
		self.secondActionButton.setAttributedTitle(title, for: .normal)
		self.mainActionButton.setTitle("Регистрация", for: .normal)
		UIView.animate(withDuration: 0) {
			self.view.layoutIfNeeded()
		}
		mainActionButton.removeTarget(self, action: #selector(requestLogin), for: .touchUpInside)
		mainActionButton.addTarget(self, action: #selector(requestRegister), for: .touchUpInside)
		secondActionButton.removeTarget(self, action: #selector(setupRegisterLayout), for: .touchUpInside)
		secondActionButton.addTarget(self, action: #selector(setupLoginLayout), for: .touchUpInside)

		logoBottomConstraint?.constant = 20
		repeatPassTopConstraint?.constant = 48 + 24
		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
		}
	}

	@objc private func setupLoginLayout() {
		let title = NSMutableAttributedString(
			string: "Нет аккаунта? ",
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray.cgColor]
		)
		let secondPartTitle = NSAttributedString(
			string: "Регистрация",
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainColor.cgColor]
		)
		title.append(secondPartTitle)
		self.secondActionButton.setAttributedTitle(title, for: .normal)
		self.mainActionButton.setTitle("Вход", for: .normal)
		UIView.animate(withDuration: 0) {
			self.view.layoutIfNeeded()
		}
		mainActionButton.removeTarget(self, action: #selector(requestRegister), for: .touchUpInside)
		mainActionButton.addTarget(self, action: #selector(requestLogin), for: .touchUpInside)
		secondActionButton.removeTarget(self, action: #selector(setupLoginLayout), for: .touchUpInside)
		secondActionButton.addTarget(self, action: #selector(setupRegisterLayout), for: .touchUpInside)

		logoBottomConstraint?.constant = 56
		repeatPassTopConstraint?.constant = 0
		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
		}
	}
}

extension AuthViewController: AuthViewProtocol {
	func receivedRegisterError(with errorText: String) {
		enableButtons()
		showErrorLabel(with: errorText)
	}

	func receivedRegisterSuccess(model: RegisterResponseModel) {
		enableButtons()
		loginField.text = model.username
		setupLoginLayout()
		showErrorLabel(with: "Войдите в аккаунт")
	}

	func receivedAuthError(with error: AuthPresenterErrors) {
		enableButtons()
		switch error {
		case .loginError:
			showErrorLabel(with: "Проверьте введенные данные")
		case .networkError:
			showErrorLabel(with: "Повторите попытку позже")
		}
	}

	func receivedAuthSuccess() {
		enableButtons()
		navigationController?.popViewController(animated: true)
		navigationController?.setNavigationBarHidden(false, animated: false)
	}
}
