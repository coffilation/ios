//
//  MainMenuScreenFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 26.11.2022.
//

import UIKit

struct MainMenuScreenFactory {
	static func makeMainMenuScreen(with dependencies: DependencyContainerProtocol, delegate: MainMenuNavigationDelegate?) -> MainMenuViewController {
		let menuView = MainMenuViewController()
		let presenter = MainMenuPresenter(view: menuView, navigationDelegate: delegate, dependencies: dependencies)
		menuView.presenter = presenter
		return menuView
	}
}
