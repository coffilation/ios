//
//  AuthScreenFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 10.10.2022.
//

import Foundation

struct AuthScreenFactory {
	static func makeLoginScreen(with dependencies: DependencyContainerProtocol, delegate: LoginNavigationDelegate?) -> LoginViewController {
		let loginView = LoginViewController()
		let presenter = LoginPresenter(view: loginView, navigationDelegate: delegate, dependencies: dependencies)
		loginView.presenter = presenter

		return loginView
	}

	static func makeRegisterScreen() {

	}
}
