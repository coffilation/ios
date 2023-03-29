//
//  SplashScreenCoordinator.swift
//  coffilation
//
//  Created by Матвей Борисов on 29.03.2023.
//

import Foundation
import UIKit

class SplashScreenCoordinator: Coordinator {

	private let navigationController: UINavigationController

	private let dependencies: DependencyContainerProtocol

	private lazy var authCoordinator = AuthCoordinator(navigationController: navigationController, dependencies: dependencies)

	private lazy var mapCoordinator = MapCoordinator(navigationController: navigationController, dependencies: dependencies)

	private var splashScreenViewController: SplashScreenViewController?

	init(navigationController: UINavigationController = UINavigationController(), dependencies: DependencyContainerProtocol) {
		self.navigationController = navigationController
		self.dependencies = dependencies
	}

	func start() {
		let screen = SplashScreenFactory.makeSplashScreen(with: dependencies, delegate: self)
		screen.loadViewIfNeeded()
		navigationController.pushViewController(screen, animated: false)
	}

}

extension SplashScreenCoordinator: SplashScreenNavigationDelegate {
	func showMainScreen() {
		mapCoordinator.start()
	}

	func showLogin() {
		authCoordinator.delegate = self
		authCoordinator.start()
	}
}

extension SplashScreenCoordinator: AuthCoordinatorDelegate {
	func didLogin() {
		mapCoordinator.start()
	}
}
