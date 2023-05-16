//
//  RegisterManager.swift
//  coffilation
//
//  Created by Матвей Борисов on 16.05.2023.
//

import Foundation

struct RegisterRequestModel: Encodable {
	let username: String
	let password: String
	let rePassword: String
}

struct RegisterResponseModel: Codable {
	let email: String
	let username: String
	let id: Int
}

struct RegisterPasswordErrorModel: Codable {
	let password: [String]
}

struct RegisterUsernameErrorModel: Codable {
	let username: [String]
}

enum RegisterError: Error {
	case responseError
	case passwordError(RegisterPasswordErrorModel)
	case usernameError(RegisterUsernameErrorModel)
}

protocol RegisterManagerProtocol: AnyObject {
	func performRegister(
		username: String,
		password: String,
		repeatPassword: String,
		completion: @escaping (Result<RegisterResponseModel, RegisterError>) -> Void
	)
}

class RegisterManager: RegisterManagerProtocol {
	private let networkManager: NetworkManagerProtocol

	init(networkManager: NetworkManagerProtocol) {
		self.networkManager = networkManager
	}

	func performRegister(
		username: String,
		password: String,
		repeatPassword: String,
		completion: @escaping (Result<RegisterResponseModel, RegisterError>) -> Void
	) {
		guard password == repeatPassword else {
			completion(.failure(.passwordError(RegisterPasswordErrorModel(password: ["Пароли должны совпадать"]))))
			return
		}

		let body = RegisterRequestModel(username: username, password: password, rePassword: repeatPassword)

		guard let request = try? RequestBuilder(path: "/users/")
			.httpMethod(.post)
			.httpHeader(name: "Content-Type", value: "application/json")
			.httpJSONBody(body)
			.makeRequestForCofApi() else {
			completion(.failure(.responseError))
			return
		}

		networkManager.request(with: request) { (result: Result<RegisterResponseModel, Error>) in
			switch result {
			case .success(let model):
				completion(.success(model))
			case .failure(let failure as NetworkError):
				switch failure {
				case .decodeFailure(let data):
					if let responseObject = try? JSONDecoder().decode(RegisterPasswordErrorModel.self, from: data) {
						completion(.failure(.passwordError(responseObject)))
					} else if let responseObject = try? JSONDecoder().decode(RegisterUsernameErrorModel.self, from: data) {
						completion(.failure(.usernameError(responseObject)))
					} else {
						completion(.failure(.responseError))
					}
				default:
					completion(.failure(.responseError))
				}
			case .failure:
				completion(.failure(.responseError))
			}
		}
	}
}
