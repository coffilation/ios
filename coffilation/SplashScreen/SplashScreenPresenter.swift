//
//  SplashScreenPresenter.swift
//  coffilation
//
//  Created by Матвей Борисов on 29.03.2023.
//

import Foundation
import UIKit

protocol SplashScreenNavigationDelegate: AnyObject {
	func showMainScreen()
	func showLogin()
}

protocol SplashScreenPresenterProtocol {
	func validateUserAuth()
}

class SplashScreenPresenter: SplashScreenPresenterProtocol {
	typealias Dependencies = HasAuthManager

	weak var navigationDelegate: SplashScreenNavigationDelegate?

	private let dependencies: Dependencies

	init(navigationDelegate: SplashScreenNavigationDelegate? = nil, dependencies: Dependencies) {
		self.navigationDelegate = navigationDelegate
		self.dependencies = dependencies
	}

	func validateUserAuth() {
		dependencies.authManager.validateToken { [weak self] error in
			DispatchQueue.main.async {
				if error == nil {
					self?.navigationDelegate?.showMainScreen()
				} else {
					self?.navigationDelegate?.showLogin()
				}
			}
		}
	}
}
