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

	init(navigationController: UINavigationController = UINavigationController(), dependencies: DependencyContainerProtocol) {
		self.navigationController = navigationController
		self.dependencies = dependencies
	}

	private func showMapScreen() {
		let screen = MapScreenFactory.makeMapScreen(delegate: self)
		screen.loadViewIfNeeded()
		navigationController.pushViewController(screen, animated: false)
	}

	func start() {
		showMapScreen()
	}
}

extension MapCoordinator: MapNavigationDelegateProtocol {
	func createBottomSheetScreen() -> MainMenuViewController? {
		MainMenuScreenFactory().makeMainMenuScreen(with: dependencies, delegate: self)
	}
}

extension MapCoordinator: MainMenuNavigationDelegate {
	func showNewScreen(with viewController: UIViewController) {
		navigationController.pushViewController(viewController, animated: true)
	}
}
