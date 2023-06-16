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

		let presenter = MainScreenPresenter()

		let mapView = MapScreenFactory.makeMapScreen()

		let viewController = MainScreenViewController(
			presenter: presenter,
			mapView: mapView,
			coordinator: coordinator
		)

		return viewController
	}
}
