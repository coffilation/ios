//
//  MainMenuScreenFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 26.11.2022.
//

import UIKit

struct MainMenuScreenFactory {
	static func makeMainMenuScreen(
		with dependencies: DependencyContainerProtocol,
		delegate: MainMenuNavigationDelegate?,
		openCompilationScreen: @escaping  (Compilation) -> Void
	) -> MainMenuViewController {
		let presenter = MainMenuPresenter(navigationDelegate: delegate, dependencies: dependencies)
		let discoveryView = DiscoveryFactory.makeDiscoveryModule(with: dependencies, openCompilationScreen: openCompilationScreen)
		let myCompilationsView = MyCompilationsFactory.makeMyCompilationsModule(with: dependencies, openCompilationScreen: openCompilationScreen)
		let menuView = MainMenuViewController(
			presenter: presenter,
			discoveryView: discoveryView,
			myCompilationView: myCompilationsView
		)
		presenter.view = menuView
		return menuView
	}
}
