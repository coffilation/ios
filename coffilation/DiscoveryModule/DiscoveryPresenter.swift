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

	func refreshAll()

	func loadMore()
}

class DiscoveryPresenter: DiscoveryPresenterProtocol {

	typealias Dependencies = HasCollectionNetworkManager

	weak var view: DiscoveryViewProtocol?
	weak var navigationDelegate: DiscoveryNavigationDelegate?

	private let dependencies: Dependencies

	private var userId = 0
	private var collectionsCount = 0
	private var offset = 0
	private var limit = 5

	init(
		navigationDelegate: DiscoveryNavigationDelegate? = nil,
		dependencies: Dependencies
	) {
		self.navigationDelegate = navigationDelegate
		self.dependencies = dependencies
	}

	func requestDiscovery(userId: Int) {
		self.userId = userId
		dependencies.collectionNetworkManager.requestDiscoveryCompilations(
			userId: userId,
			limit: limit,
			offset: offset
		) { [weak self] (result: Result<CompilationsResponseModel, Error>) in
			switch result {
			case .success(let model):
				self?.collectionsCount = model.count
				self?.offset += (self?.limit ?? 0)
				let compilations = model.results.compactMap { Compilation.convert(from: $0) }
				let isEnd = (self?.offset ?? 0) >= (self?.collectionsCount ?? 0)
				self?.view?.didReceivedDiscovery(isEnd: isEnd, compilations: compilations)
			case .failure:
				guard self != nil else {
					fatalError()
				}
				self?.view?.didReceivedError()
			}
		}
	}

	func refreshAll() {
		collectionsCount = 0
		offset = 0
		limit = 5
		requestDiscovery(userId: userId)
	}

	func loadMore() {
		dependencies.collectionNetworkManager.requestDiscoveryCompilations(
			userId: userId,
			limit: limit,
			offset: offset
		) { [weak self] (result: Result<CompilationsResponseModel, Error>) in
			switch result {
			case .success(let model):
				self?.collectionsCount = model.count

				self?.offset += (self?.limit ?? 0)
				let compilations = model.results.compactMap { Compilation.convert(from: $0) }
				let isEnd = (self?.offset ?? 0) >= (self?.collectionsCount ?? 0)
				self?.view?.appendDiscovery(isEnd: isEnd, with: compilations)
			case .failure:
				guard self != nil else {
					fatalError()
				}
				self?.view?.didReceivedError()
			}
		}
	}
}
