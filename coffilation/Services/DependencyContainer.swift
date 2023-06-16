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

protocol HasRegisterManager {
	var registerManager: RegisterManagerProtocol { get set }
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
	var collectionNetworkManager: CompilationsNetworkManagerProtocol { get set }
}

protocol HasPlacesNetworkManager {
	var placesNetworkManager: PlacesNetworkManagerProtocol { get set }
}

protocol DependencyContainerProtocol: HasAuthManager,
									  HasRegisterManager,
									  HasNetworkManager,
									  HasTokenProvider,
									  HasTokenManager,
									  HasUserNetworkManager,
									  HasCollectionNetworkManager,
									  HasPlacesNetworkManager {}

final class DependencyContainer: DependencyContainerProtocol {
	var authManager: AuthManagerProtocol
	var registerManager: RegisterManagerProtocol
	var tokenManager: TokenManagerProtocol
	var userNetworkManager: UserNetworkManagerProtocol
	var collectionNetworkManager: CompilationsNetworkManagerProtocol
	var placesNetworkManager: PlacesNetworkManagerProtocol

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
		let collectionNetworkManager = CompilationsNetworkManager(authManager: authManager, networkManager: networkManager)
		self.collectionNetworkManager = collectionNetworkManager
		registerManager = RegisterManager(networkManager: networkManager)
		self.placesNetworkManager = PlacesNetworkManager(authManager: authManager)
	}
}
