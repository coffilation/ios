//
//  UserNetworkManager.swift
//  coffilation
//
//  Created by Матвей Борисов on 27.11.2022.
//

import Foundation

struct UserResponseModel: Codable {
	let id: Int
	let username: String
}

protocol UserNetworkManagerProtocol {
	func requestUserData(completion: @escaping (UserResponseModel?) -> Void)
}

class UserNetworkManager: UserNetworkManagerProtocol {
	private let authManager: AuthManagerProtocol

	init(authManager: AuthManagerProtocol) {
		self.authManager = authManager
	}

	func requestUserData(completion: @escaping (UserResponseModel?) -> Void) {
		guard let request = RequestBuilder(path: "/users/me/")
			.httpMethod(.get)
			.httpHeader(name: "accept", value: "application/json")
			.makeRequestForCofApi() else {
			return
		}

		authManager.authorizedRequest(with: request) { (result: Result<UserResponseModel, Error>) in
			DispatchQueue.main.async {
				switch result {
				case .success(let success):
					completion(success)
				case .failure(_):
					completion(nil)
				}
			}
		}
	}
}
