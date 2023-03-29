//
//  AuthCoordinator.swift
//  coffilation
//
//  Created by Матвей Борисов on 11.10.2022.
//

import Foundation
import UIKit

protocol AuthCoordinatorDelegate: AnyObject {
	func didLogin()
}

class AuthCoordinator: Coordinator {
	private let navigationController: UINavigationController

	private let dependencies: DependencyContainerProtocol

	weak var delegate: AuthCoordinatorDelegate?

	init(navigationController: UINavigationController = UINavigationController(), dependencies: DependencyContainerProtocol) {
		self.navigationController = navigationController
		self.dependencies = dependencies
	}

	private func showLoginScreen() {
		let screen = AuthScreenFactory.makeLoginScreen(with: dependencies, delegate: self)
		screen.loadViewIfNeeded()
		navigationController.pushViewController(screen, animated: false)
	}

	func start() {
		showLoginScreen()
	}
}

extension AuthCoordinator: LoginNavigationDelegate {
	func didTapRegister() {

	}

	func didLogin() {
		delegate?.didLogin()
	}
}
