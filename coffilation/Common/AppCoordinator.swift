//
//  AppCoordinator.swift
//  coffilation
//
//  Created by Матвей Борисов on 11.10.2022.
//

import Foundation
import UIKit

class AppCoordinator {
	private let window: UIWindow
	private let navigationController: UINavigationController
	private var starterCoordinator: Coordinator?

	private let dependencies: DependencyContainerProtocol

	init(window: UIWindow, navigationController: UINavigationController = UINavigationController(), dependencies: DependencyContainerProtocol) {
		self.window = window
		self.navigationController = navigationController
		self.dependencies = dependencies
		setupWindow()
		setupStarterCoordinator()
	}

	private func setupWindow() {
		window.rootViewController = navigationController
		window.makeKeyAndVisible()
	}

	private func setupStarterCoordinator() {
		starterCoordinator = SplashScreenCoordinator(navigationController: navigationController, dependencies: dependencies)
	}

	func start() {
		starterCoordinator?.start()
	}
}
