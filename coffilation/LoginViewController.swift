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

	private let emailField: UITextField = {
		let textField = UITextField()
		textField.backgroundColor = .white
		textField.borderStyle = .roundedRect
		return textField
	}()

	private let passwordField: UITextField = {
		let textField = UITextField()
		textField.backgroundColor = .white
		textField.borderStyle = .roundedRect
		textField.isSecureTextEntry = true
		return textField
	}()

	private let loginButton: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = 16
		button.backgroundColor = .blue
		button.setTitle("LOGIN", for: .normal)
		return button
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .lightGray

		setupLayout()

		loginButton.addTarget(self, action: #selector(requestLogin), for: .touchUpInside)
	}

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupLayout() {
		view.addSubview(emailField)
		view.addSubview(passwordField)
		view.addSubview(loginButton)

		loginButton.autoCenterInSuperview()
		loginButton.autoSetDimensions(to: CGSize(width: 160, height: 48))
		loginButton.autoPinEdge(.top, to: .bottom, of: passwordField, withOffset: 12)

		passwordField.autoPinEdge(toSuperviewEdge: .left, withInset: 24)
		passwordField.autoPinEdge(toSuperviewEdge: .right, withInset: 24)
		passwordField.autoPinEdge(.top, to: .bottom, of: emailField, withOffset: 12)

		emailField.autoPinEdge(toSuperviewEdge: .left, withInset: 24)
		emailField.autoPinEdge(toSuperviewEdge: .right, withInset: 24)
	}

	@objc private func requestLogin() {
		guard let email = emailField.text, let password = passwordField.text else {
			return
		}
		presenter?.performLogin(email: email, password: password)
	}
}

extension LoginViewController: LoginViewProtocol {
	func receivedError(with error: LoginPresenterErrors) {
		let alert = UIAlertController(title: "Failure", message: nil, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default)
		alert.addAction(okAction)
		present(alert, animated: true)
	}

	func receivedSuccess() {
		let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default)
		alert.addAction(okAction)
		present(alert, animated: true)
	}
}
