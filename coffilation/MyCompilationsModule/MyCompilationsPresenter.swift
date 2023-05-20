//
//  MyCompilationsPresenter.swift
//  coffilation
//
//  Created by Матвей Борисов on 20.05.2023.
//

import Foundation

protocol MyCompilationsNavigationDelegate: AnyObject {}

protocol MyCompilationsPresenterProtocol: AnyObject {
	func requestMyCompilations(userId: Int)
}

class MyCompilationsPresenter: MyCompilationsPresenterProtocol {

	typealias Dependencies = HasCollectionNetworkManager

	weak var view: MyCompilationsViewProtocol?
	weak var navigationDelegate: MyCompilationsNavigationDelegate?

	private let dependencies: Dependencies

	init(
		navigationDelegate: MyCompilationsNavigationDelegate? = nil,
		dependencies: Dependencies
	) {
		self.navigationDelegate = navigationDelegate
		self.dependencies = dependencies
	}

	func requestMyCompilations(userId: Int) {
		dependencies.collectionNetworkManager.requestUserCollections(
			for: userId,
			completion: { [weak self] (result: Result<[CompilationResponseModel], Error>) in
				switch result {
				case .success(let rawCompilations):
					let compilations = rawCompilations.compactMap { Compilation.convert(from: $0) }
					self?.view?.didReceivedMyCompilations(compilations: compilations)
				case .failure:
					guard self != nil else {
						fatalError()
					}
					self?.view?.didReceivedError()
				}
			}
		)
	}
}
