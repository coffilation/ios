//
//  SplashScreenFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 29.03.2023.
//

import Foundation

struct SplashScreenFactory {
	static func makeSplashScreen(with dependencies: DependencyContainerProtocol, delegate: SplashScreenNavigationDelegate) -> SplashScreenViewController {
		let splashScreenView = SplashScreenViewController()
		let presenter = SplashScreenPresenter(navigationDelegate: delegate, dependencies: dependencies)
		splashScreenView.presenter = presenter
		return splashScreenView
	}
}
