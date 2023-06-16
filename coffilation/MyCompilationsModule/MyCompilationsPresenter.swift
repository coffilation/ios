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
	func createCompilationEditScreen() -> CompilationEditViewController
	func createCompilationsListScreen(openCompilationScreen: @escaping  (Compilation) -> Void) -> CompilationsListViewController
}

class MyCompilationsPresenter: MyCompilationsPresenterProtocol {

	typealias Dependencies = HasCollectionNetworkManager

	weak var view: MyCompilationsViewProtocol?
	weak var navigationDelegate: MyCompilationsNavigationDelegate?

	private let dependencies: Dependencies

	private var userId = 0

	init(
		navigationDelegate: MyCompilationsNavigationDelegate? = nil,
		dependencies: Dependencies
	) {
		self.navigationDelegate = navigationDelegate
		self.dependencies = dependencies
	}

	func requestMyCompilations(userId: Int) {
		self.userId = userId
		dependencies.collectionNetworkManager.requestUserCollections(
			userId: userId,
			limit: 5,
			offset: 0
		) { [weak self] (result: Result<CompilationsResponseModel, Error>) in
			switch result {
			case .success(let model):
				let compilations = model.results.compactMap { Compilation.convert(from: $0, isJoin: true) }
				self?.view?.didReceivedMyCompilations(compilations: compilations)
			case .failure:
				guard self != nil else {
					fatalError()
				}
				self?.view?.didReceivedError()
			}
		}
	}

	func createCompilationEditScreen() -> CompilationEditViewController {
		guard let dependencies = dependencies as? DependencyContainerProtocol else {
			fatalError()
		}
		return CompilationEditFactory.makeCompilationEditScreen(with: dependencies)
	}

	func createCompilationsListScreen(openCompilationScreen: @escaping  (Compilation) -> Void) -> CompilationsListViewController {
		guard let dependencies = dependencies as? DependencyContainerProtocol else {
			fatalError()
		}
		return CompilationsListFactory.makeCompilationsListScreen(
			userId: userId,
			with: dependencies,
			didSelectCompilations: { _ in },
			openCompilationScreen: openCompilationScreen
		)
	}
}
