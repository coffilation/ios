//
//  MainMenuPresenter.swift
//  coffilation
//
//  Created by Матвей Борисов on 26.11.2022.
//

import UIKit

struct User {
	let id: Int
	let name: String
}

struct Collection {

	struct Gradient {
		let startColor: CGColor
		let endColor: CGColor
	}

	let id: Int
	let name: String
	let description: String?
	let type: String
	var gradient: Gradient?
}

protocol MainMenuViewProtocol: AnyObject {
	func didReceivedUserInfo(with user: User?)

	func didReceivedDiscovery(collections: [Collection])

	func didReceivedCollections(collections: [Collection])
}

protocol MainMenuNavigationDelegate: AnyObject {
	func showNewScreen(with viewController: UIViewController)
}

protocol MainMenuPresenterProtocol {
	func requestUserInfo()
	func requestCollections(for: Int)
	func requestDiscovery(for: Int)
	func logout()
}

class MainMenuPresenter: MainMenuPresenterProtocol {
	typealias Dependencies = HasUserNetworkManager & HasCollectionNetworkManager & HasAuthManager

	weak var view: MainMenuViewProtocol?
	weak var navigationDelegate: MainMenuNavigationDelegate?

	private let dependencies: Dependencies

	init(view: MainMenuViewProtocol?, navigationDelegate: MainMenuNavigationDelegate? = nil, dependencies: Dependencies) {
		self.view = view
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
			self?.view?.didReceivedUserInfo(with: User(id: userInfo.id, name: userInfo.username))
		}
	}

	func requestCollections(for userId: Int) {
		dependencies.collectionNetworkManager.requestUserCollections(for: userId) { [weak self] collectionsResult in
			let collections = collectionsResult.compactMap { self?.convert(from: $0) }
			self?.view?.didReceivedCollections(collections: collections)
		}
	}

	func requestDiscovery(for userId: Int) {
		dependencies.collectionNetworkManager.requestAllCollections(for: userId) { [weak self] collectionsResult in
			let collections = collectionsResult.compactMap { self?.convert(from: $0) }
			self?.view?.didReceivedDiscovery(collections: collections)
		}
	}

	private func convert(from rawCollection: CollectionResponseModel) -> Collection {
		var collection = Collection(id: rawCollection.id,
									name: rawCollection.name,
									description: rawCollection.description,
									type: rawCollection.type,
									gradient: nil)

		if let rawGradient = rawCollection.gradient {
			let gradient = Collection.Gradient(startColor: UIColor(red: CGFloat(rawGradient.startColor.red) / 255,
																   green: CGFloat(rawGradient.startColor.green) / 255,
																   blue: CGFloat(rawGradient.startColor.blue) / 255,
																   alpha: 1).cgColor,
											   endColor: UIColor(red: CGFloat(rawGradient.endColor.red) / 255,
																 green: CGFloat(rawGradient.endColor.red) / 255,
																 blue: CGFloat(rawGradient.endColor.red) / 255,
																 alpha: CGFloat(rawGradient.endColor.red) / 255).cgColor)
			collection.gradient = gradient
		} else {
			let defaultGradient = Collection.Gradient(startColor: UIColor.orangeGradient[0], endColor: UIColor.orangeGradient[1])
			collection.gradient = defaultGradient
		}

		return collection
	}
}
