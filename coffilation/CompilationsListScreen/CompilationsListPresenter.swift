//
//  CompilationsListPresenter.swift
//  coffilation
//
//  Created by Матвей Борисов on 12.06.2023.
//

import Foundation

protocol CompilationsListPresenterProtocol {
	func loadCompilations()

	func loadMore()
}

class CompilationsListPresenter: CompilationsListPresenterProtocol {
	typealias Dependencies = HasCollectionNetworkManager

	weak var view: CompilationsListViewProtocol?

	private let dependencies: Dependencies
	private let didSelectCompilations: (Set<Compilation>) -> Void

	private var userId: Int
	private var collectionsCount = 0
	private var offset = 0
	private var limit = 10

	init(
		userId: Int,
		dependencies: Dependencies,
		didSelectCompilations: @escaping (Set<Compilation>) -> Void
	) {
		self.userId = userId
		self.dependencies = dependencies
		self.didSelectCompilations = didSelectCompilations
	}

	func loadCompilations() {
		collectionsCount = 0
		offset = 0
		limit = 10
		dependencies.collectionNetworkManager.requestUserCollections(
			userId: userId,
			limit: limit,
			offset: offset
		) { [weak self] (result: Result<CompilationsResponseModel, Error>) in
			switch result {
			case .success(let model):
				self?.collectionsCount = model.count
				self?.offset += (self?.limit ?? 0)
				let compilations = model.results.compactMap { Compilation.convert(from: $0) }
				let isLoadAll = (self?.offset ?? 0) >= (self?.collectionsCount ?? 0)
				self?.view?.didReceivedCompilations(isLoadAll: isLoadAll, compilations: compilations)
			case .failure:
				guard self != nil else {
					fatalError()
				}
				self?.view?.didReceivedError()
			}
		}
	}

	func loadMore() {
		dependencies.collectionNetworkManager.requestUserCollections(
			userId: userId,
			limit: limit,
			offset: offset
		) { [weak self] (result: Result<CompilationsResponseModel, Error>) in
			switch result {
			case .success(let model):
				self?.collectionsCount = model.count

				self?.offset += (self?.limit ?? 0)
				let compilations = model.results.compactMap { Compilation.convert(from: $0) }
				let isLoadAll = (self?.offset ?? 0) >= (self?.collectionsCount ?? 0)
				self?.view?.appendCompilations(isLoadAll: isLoadAll, with: compilations)
			case .failure:
				guard self != nil else {
					fatalError()
				}
				self?.view?.didReceivedError()
			}
		}
	}
}
