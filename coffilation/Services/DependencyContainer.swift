//
//  DependencyContainer.swift
//  coffilation
//
//  Created by Матвей Борисов on 10.10.2022.
//

import Foundation

protocol HasAuthManager {
	var authManager: AuthManagerProtocol { get set }
}

protocol HasNetworkManager {
	var networkManager: NetworkManagerProtocol { get set }
}

protocol HasTokenProvider {
	var tokenProvider: TokenProviderProtocol { get set }
}

protocol HasTokenManager {
	var tokenManager: TokenManagerProtocol { get set }
}

protocol HasUserNetworkManager {
	var userNetworkManager: UserNetworkManagerProtocol { get set }
}

protocol HasCollectionNetworkManager {
	var collectionNetworkManager: CollectionsNetworkManagerProtocol { get set}
}

protocol DependencyContainerProtocol: HasAuthManager,
									  HasNetworkManager,
									  HasTokenProvider,
									  HasTokenManager,
									  HasUserNetworkManager,
									  HasCollectionNetworkManager {}

final class DependencyContainer: DependencyContainerProtocol {
	var authManager: AuthManagerProtocol
	var tokenManager: TokenManagerProtocol
	var userNetworkManager: UserNetworkManagerProtocol
	var collectionNetworkManager: CollectionsNetworkManagerProtocol

	var networkManager: NetworkManagerProtocol = NetworkManager()
	var tokenProvider: TokenProviderProtocol = TokenProvider()

	init() {
		let tokenManager = TokenManager(tokenProvider: tokenProvider, networkManager: networkManager)
		self.tokenManager = tokenManager
		let authManager = AuthManager(networkManager: networkManager, tokenManager: tokenManager)
		self.authManager = authManager
		tokenManager.delegate = authManager
		let userNetworkManager = UserNetworkManager(authManager: authManager)
		self.userNetworkManager = userNetworkManager
		let collectionNetworkManager = CollectionsNetworkManager(authManager: authManager, networkManager: networkManager)
		self.collectionNetworkManager = collectionNetworkManager
	}
}
