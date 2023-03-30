//
//  MapCoordinator.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.11.2022.
//

import Foundation
import UIKit

class MapCoordinator: Coordinator {
	private let navigationController: UINavigationController

	private let dependencies: DependencyContainerProtocol

	private lazy var authCoordinator = AuthCoordinator(navigationController: navigationController, dependencies: dependencies)

	private var mainMenuViewController: MainMenuViewController?

	init(navigationController: UINavigationController = UINavigationController(), dependencies: DependencyContainerProtocol) {
		self.navigationController = navigationController
		self.dependencies = dependencies
	}

	func start() {
		let screen = MapScreenFactory.makeMapScreen(delegate: self)
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

extension MapCoordinator: MapNavigationDelegateProtocol {
	func createBottomSheetScreen() -> MainMenuViewController? {
		mainMenuViewController = MainMenuScreenFactory().makeMainMenuScreen(with: dependencies, delegate: self)
		return mainMenuViewController
	}
}

extension MapCoordinator: MainMenuNavigationDelegate {
	func showNewScreen(with viewController: UIViewController) {
		navigationController.pushViewController(viewController, animated: true)
	}
}
