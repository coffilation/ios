//
//  AuthManager.swift
//  coffilation
//
//  Created by Матвей Борисов on 11.10.2022.
//

import Foundation

struct AuthLoginResponseModel: Codable {
	let access: String
	let refresh: String
}

struct AuthLoginRequestModel: Encodable {
	let username: String
	let password: String
}

struct AuthRefreshRequestModel: Encodable {
	let refresh: String
}

enum AuthError: Error {
	case responseError
}

protocol AuthManagerProtocol {
	func performLogin(email: String, password: String, completion: @escaping (AuthError?) -> Void)

	func authorizedRequest<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void)
}

class AuthManager: AuthManagerProtocol {
	private let networkManager: NetworkManagerProtocol
	private let tokenManager: TokenManagerProtocol
	private let lock = NSLock()
	private var needRefreshRequests = [URLRequest: NetworkManagerProtocol.RequestCompletion]()

	init(networkManager: NetworkManagerProtocol, tokenManager: TokenManagerProtocol) {
		self.networkManager = networkManager
		self.tokenManager = tokenManager
	}

	func performLogin(email: String, password: String, completion: @escaping (AuthError?) -> Void) {
		let body = AuthLoginRequestModel(username: email, password: password)

		guard let request = try? RequestBuilder(path: "/auth/login")
			.httpMethod(.post)
			.httpHeader(name: "Content-Type", value: "application/json")
			.httpJSONBody(body)
			.makeRequestForCofApi() else {
			return
		}

		networkManager.request(with: request) { [weak self] (result: Result<AuthLoginResponseModel, Error>) in
			switch result {
			case .success(let model):
				self?.tokenManager.saveTokens(with: model)
				completion(nil)
			case .failure(_):
				completion(AuthError.responseError)
			}
		}
	}

	func authorizedRequest<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
		guard let enrichedRequest = tokenManager.enrichAuthorizedRequest(request) else {
			return
		}

		let requestCompletion = networkManager.request(with: enrichedRequest) { [weak self] (result: Result<T, Error>) in
			switch result {
			case .success(let success):
				self?.lock.lock()
				self?.needRefreshRequests[request] = nil
				self?.lock.unlock()
				completion(.success(success))
			case .failure(let failure as NetworkError):
				if failure == .notAuthorized, self?.needRefreshRequests[request] == nil {
					self?.tokenManager.updateToken()
				} else {
					self?.needRefreshRequests[request] = nil
					completion(.failure(failure))
				}
			case .failure(let failure):
				self?.lock.lock()
				self?.needRefreshRequests[request] = nil
				self?.lock.unlock()
				completion(.failure(failure))
			}
		}
		lock.lock()
		needRefreshRequests[request] = requestCompletion
		lock.unlock()

	}

}

extension AuthManager: TokenManagerDelegate {
	func didUpdateToken() {
		lock.lock()
		for requestTuple in needRefreshRequests {
			guard let enrichedRequest = tokenManager.enrichAuthorizedRequest(requestTuple.key) else {
				return
			}
			networkManager.retryRequest(for: enrichedRequest,
										completion: requestTuple.value)
		}
		lock.unlock()
	}

	func didReceiveTokenUpdateError() {
		lock.lock()
		needRefreshRequests = [:]
		lock.unlock()
	}
}
