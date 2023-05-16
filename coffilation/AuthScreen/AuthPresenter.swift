//
//  AuthPresenter.swift
//  coffilation
//
//  Created by Матвей Борисов on 10.10.2022.
//

import Foundation

enum AuthPresenterErrors {
	case networkError
	case loginError
}

protocol AuthViewProtocol: AnyObject {
	func receivedAuthError(with error: AuthPresenterErrors)
	func receivedAuthSuccess()

	func receivedRegisterError(with errorText: String)
	func receivedRegisterSuccess(model: RegisterResponseModel)
}

protocol AuthNavigationDelegate: AnyObject {
	func didTapRegister()
	func didLogin()
}

protocol AuthPresenterProtocol {
	func performLogin(username: String, password: String)

	func performRegister(username: String, password: String, repeatPassword: String)
}

class AuthPresenter: AuthPresenterProtocol {
	typealias Dependencies = HasAuthManager & HasRegisterManager

	weak var view: AuthViewProtocol?
	weak var navigationDelegate: AuthNavigationDelegate?

	private let dependencies: Dependencies

	init(view: AuthViewProtocol?, navigationDelegate: AuthNavigationDelegate? = nil, dependencies: Dependencies) {
		self.view = view
		self.navigationDelegate = navigationDelegate
		self.dependencies = dependencies
	}

	func performLogin(username: String, password: String) {
		dependencies.authManager.performLogin(username: username, password: password) { [weak self] error in
			DispatchQueue.main.async {
				if error != nil {
					self?.view?.receivedAuthError(with: AuthPresenterErrors.loginError)
				} else {
					self?.view?.receivedAuthSuccess()
					self?.navigationDelegate?.didLogin()
				}
			}
		}
	}

	func performRegister(username: String, password: String, repeatPassword: String) {
		dependencies.registerManager.performRegister(username: username, password: password, repeatPassword: repeatPassword) { [weak self] result in
			DispatchQueue.main.async {
				switch result {
				case .success:
					self?.performLogin(username: username, password: password)
				case .failure(let error):
					var errorText = "Произошла ошибка, попробуйте позже"
					switch error {
					case .usernameError(let errorModel):
						if let usernameError = errorModel.username.first {
							errorText = usernameError
						}
					case .passwordError(let errorModel):
						if let passwordError = errorModel.password.first {
							errorText = passwordError
						}
					default:
						break
					}
					self?.view?.receivedRegisterError(with: errorText)
				}
			}
		}
	}
}
