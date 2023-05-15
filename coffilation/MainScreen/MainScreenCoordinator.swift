//
//  MainScreenCoordinator.swift
//  coffilation
//
//  Created by Матвей Борисов on 08.04.2023.
//

import Foundation
import UIKit

class MainScreenCoordinator: Coordinator {

	private let navigationController: UINavigationController
	private let dependencies: DependencyContainerProtocol

	init(
		navigationController: UINavigationController = UINavigationController(),
		dependencies: DependencyContainerProtocol
	) {
		self.navigationController = navigationController
		self.dependencies = dependencies
	}

	func start() {
		let screen = MainScreenFactory.createMainScreen(
			dependencies: dependencies,
			coordinator: self
		)
		screen.loadViewIfNeeded()
		if navigationController.viewControllers.count <= 1 {
			navigationController.viewControllers.append(screen)
		} else {
			navigationController.viewControllers.insert(screen, at: 1)
		}
		navigationController.popToViewController(screen, animated: true)
		navigationController.viewControllers = [screen]
	}
}

extension MainScreenCoordinator: MapNavigationDelegateProtocol {}

extension MainScreenCoordinator: MainMenuNavigationDelegate {
	func showNewScreen(with viewController: UIViewController) {
		navigationController.pushViewController(viewController, animated: true)
	}
}
