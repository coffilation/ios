//
//  MainMenuScreenFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 26.11.2022.
//

import UIKit

struct MainMenuScreenFactory {
	static func makeMainMenuScreen(with dependencies: DependencyContainerProtocol, delegate: MainMenuNavigationDelegate?) -> MainMenuViewController {
		let presenter = MainMenuPresenter(navigationDelegate: delegate, dependencies: dependencies)
		let discoveryView = DiscoveryFactory.makeDiscoveryModule(with: dependencies)
		let myCompilationsView = MyCompilationsFactory.makeMyCompilationsModule(with: dependencies)
		let menuView = MainMenuViewController(
			presenter: presenter,
			discoveryView: discoveryView,
			myCompilationView: myCompilationsView
		)
		presenter.view = menuView
		return menuView
	}
}
