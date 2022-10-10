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

protocol DependencyContainerProtocol: HasAuthManager {}

final class DependencyContainer: DependencyContainerProtocol {
	var authManager: AuthManagerProtocol = AuthManager()
}
