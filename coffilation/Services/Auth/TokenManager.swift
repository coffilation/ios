//
//  TokenManager.swift
//  coffilation
//
//  Created by Матвей Борисов on 29.10.2022.
//

import Foundation

protocol TokenManagerProtocol {
	var delegate: TokenManagerDelegate? { get set }

	func updateToken()
	func validateToken(completion: @escaping (AuthError?) -> Void)
	func saveTokens(with: AuthLoginResponseModel)
	func enrichAuthorizedRequest(_ request: URLRequest) -> URLRequest?
	func clearTokens()
}

protocol TokenManagerDelegate: AnyObject {
	func didUpdateToken()
	func didReceiveTokenUpdateError()
}

struct TokenValidateRequestModel: Encodable {
	let token: String
}

class TokenManager: TokenManagerProtocol {
	private let tokenProvider: TokenProviderProtocol
	private let networkManager: NetworkManagerProtocol

	weak var delegate: TokenManagerDelegate?

	init(tokenProvider: TokenProviderProtocol, networkManager: NetworkManagerProtocol) {
		self.tokenProvider = tokenProvider
		self.networkManager = networkManager
	}

	func clearTokens() {
		tokenProvider.deleteAuthToken()
		tokenProvider.deleteRefreshToken()
	}

	func saveTokens(with model: AuthLoginResponseModel) {
		tokenProvider.updateAuthToken(with: model.access)
		tokenProvider.updateRefreshToken(with: model.refresh)
	}

	func enrichAuthorizedRequest(_ request: URLRequest) -> URLRequest? {
		guard let token = tokenProvider.obtainAuthToken() else {
			return nil
		}
		var enrichAbleRequest = request
		enrichAbleRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		return enrichAbleRequest
	}

	func updateToken() {
		guard let refresh = tokenProvider.obtainRefreshToken() else {
			return
		}

		let body = AuthRefreshRequestModel(refresh: refresh)
		guard let request = try? RequestBuilder(path: "auth/jwt/refresh/")
			.httpMethod(.post)
			.httpHeader(name: "Content-Type", value: "application/json")
			.httpJSONBody(body)
			.makeRequestForCofApi()
		else {
			return
		}

		networkManager.request(with: request) { [weak self] (result: Result<AuthLoginResponseModel, Error>) in
			switch result {
			case .success(let success):
				self?.tokenProvider.updateAuthToken(with: success.access)
				self?.tokenProvider.updateRefreshToken(with: success.refresh)
				self?.delegate?.didUpdateToken()
			case .failure(_):
				self?.delegate?.didReceiveTokenUpdateError()
			}
		}
	}

	func validateToken(completion: @escaping (AuthError?) -> Void) {
		guard let refresh = tokenProvider.obtainRefreshToken() else {
			completion(.responseError)
			return
		}

		let body = TokenValidateRequestModel(token: refresh)
		guard let request = try? RequestBuilder(path: "auth/jwt/verify/")
			.httpMethod(.post)
			.httpHeader(name: "Content-Type", value: "application/json")
			.httpJSONBody(body)
			.makeRequestForCofApi()
		else {
			return
		}

		networkManager.request(with: request) {(result: Result<EmptyModel, Error>) in
			switch result {
			case .success:
				completion(nil)
			case .failure(_):
				completion(.responseError)
			}
		}
	}

}
