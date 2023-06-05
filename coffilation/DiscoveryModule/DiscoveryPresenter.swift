//
//  DiscoveryPresenter.swift
//  coffilation
//
//  Created by Матвей Борисов on 18.05.2023.
//

import Foundation
import UIKit

protocol DiscoveryNavigationDelegate: AnyObject {}

protocol DiscoveryPresenterProtocol {
	func requestDiscovery(userId: Int)
}

class DiscoveryPresenter: DiscoveryPresenterProtocol {

	typealias Dependencies = HasCollectionNetworkManager

	weak var view: DiscoveryViewProtocol?
	weak var navigationDelegate: DiscoveryNavigationDelegate?

	private let dependencies: Dependencies

	init(
		navigationDelegate: DiscoveryNavigationDelegate? = nil,
		dependencies: Dependencies
	) {
		self.navigationDelegate = navigationDelegate
		self.dependencies = dependencies
	}

	func requestDiscovery(userId: Int) {
		dependencies.collectionNetworkManager.requestDiscoveryCompilations(
			userId: userId
		) { [weak self] (result: Result<[CompilationResponseModel], Error>) in
			switch result {
			case .success(let rawCompilations):
				let compilations = rawCompilations.compactMap { Compilation.convert(from: $0) }
				self?.view?.didReceivedDiscovery(compilations: compilations)
			case .failure:
				guard self != nil else {
					fatalError()
				}
				self?.view?.didReceivedError()
			}
		}
	}
}
