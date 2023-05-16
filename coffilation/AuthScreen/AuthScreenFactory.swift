//
//  AuthScreenFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 10.10.2022.
//

import Foundation

struct AuthScreenFactory {
	static func makeAuthScreen(with dependencies: DependencyContainerProtocol, delegate: AuthNavigationDelegate?) -> AuthViewController {
		let loginView = AuthViewController()
		let presenter = AuthPresenter(view: loginView, navigationDelegate: delegate, dependencies: dependencies)
		loginView.presenter = presenter

		return loginView
	}
}
