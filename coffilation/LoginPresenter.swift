//
//  LoginPresenter.swift
//  coffilation
//
//  Created by Матвей Борисов on 10.10.2022.
//

import Foundation

enum LoginPresenterErrors {
	case networkError
	case loginError
}

protocol LoginViewProtocol: AnyObject {
	func receivedError(with error: LoginPresenterErrors)
	func receivedSuccess()
}

protocol LoginNavigationDelegate: AnyObject {
	func didTapRegister()
}

protocol LoginPresenterProtocol {
	func performLogin(email: String, password: String)
}

class LoginPresenter: LoginPresenterProtocol {
	typealias Dependencies = HasAuthManager

	weak var view: LoginViewProtocol?
	weak var navigationDelegate: LoginNavigationDelegate?

	private let dependencies: Dependencies

	init(view: LoginViewProtocol?, navigationDelegate: LoginNavigationDelegate? = nil, dependencies: Dependencies) {
		self.view = view
		self.navigationDelegate = navigationDelegate
		self.dependencies = dependencies
	}

	func performLogin(email: String, password: String) {

	}
}
