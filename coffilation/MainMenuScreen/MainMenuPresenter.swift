//
//  MainMenuPresenter.swift
//  coffilation
//
//  Created by Матвей Борисов on 26.11.2022.
//

import Foundation

protocol MainMenuViewProtocol: AnyObject {}

protocol MainMenuNavigationDelegate: AnyObject {}

protocol MainMenuPresenterProtocol {}

class MainMenuPresenter: MainMenuPresenterProtocol {
	typealias Dependencies = HasNetworkManager

	weak var view: MainMenuViewProtocol?
	weak var navigationDelegate: MainMenuNavigationDelegate?

	private let dependencies: Dependencies

	init(view: MainMenuViewProtocol?, navigationDelegate: MainMenuNavigationDelegate? = nil, dependencies: Dependencies) {
		self.view = view
		self.navigationDelegate = navigationDelegate
		self.dependencies = dependencies
	}
}

