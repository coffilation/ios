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
	func saveTokens(with: AuthLoginResponseModel)
	func enrichAuthorizedRequest(_ request: URLRequest) -> URLRequest?
}

protocol TokenManagerDelegate: AnyObject {
	func didUpdateToken()
	func didReceiveTokenUpdateError()
}

class TokenManager: TokenManagerProtocol {
	private let tokenProvider: TokenProviderProtocol
	private let networkManager: NetworkManagerProtocol

	weak var delegate: TokenManagerDelegate?

	init(tokenProvider: TokenProviderProtocol, networkManager: NetworkManagerProtocol) {
		self.tokenProvider = tokenProvider
		self.networkManager = networkManager
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
		guard let request = try? RequestBuilder(path: "/auth/refresh")
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

}
