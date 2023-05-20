//
//  MainMenuPresenter.swift
//  coffilation
//
//  Created by Матвей Борисов on 26.11.2022.
//

import UIKit

protocol MainMenuViewProtocol: AnyObject {
	func didReceivedUserInfo(with user: User?)
}

protocol MainMenuNavigationDelegate: AnyObject {
	func showNewScreen(with viewController: UIViewController)
}

protocol MainMenuPresenterProtocol {
	func requestUserInfo()
	func logout()
}

class MainMenuPresenter: MainMenuPresenterProtocol {

	typealias Dependencies = HasUserNetworkManager & HasCollectionNetworkManager & HasAuthManager

	weak var view: MainMenuViewProtocol?
	weak var navigationDelegate: MainMenuNavigationDelegate?

	private let dependencies: Dependencies

	init(navigationDelegate: MainMenuNavigationDelegate? = nil, dependencies: Dependencies) {
		self.navigationDelegate = navigationDelegate
		self.dependencies = dependencies
	}

	func logout() {
		dependencies.authManager.logout()
	}

	func requestUserInfo() {
		dependencies.userNetworkManager.requestUserData { [weak self] userInfo in
			guard let userInfo = userInfo else {
				self?.view?.didReceivedUserInfo(with: nil)
				return
			}
			self?.view?.didReceivedUserInfo(with: User(id: userInfo.id, username: userInfo.username))
		}
	}
}
