//
//  MainScreenFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 08.04.2023.
//

import Foundation

class MainScreenFactory {

	static func createMainScreen(
		dependencies: DependencyContainerProtocol,
		coordinator: MainScreenCoordinator
	) -> MainScreenViewController {

		let menu = MainMenuScreenFactory.makeMainMenuScreen(
			with: dependencies,
			delegate: coordinator
		)
		
		let mapView = MapScreenFactory.makeMapScreen()

		let viewController = MainScreenViewController(
			mapView: mapView,
			menuView: menu
		)

		return viewController
	}
}
