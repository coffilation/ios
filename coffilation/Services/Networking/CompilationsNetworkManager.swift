//
//  CompilationsNetworkManager.swift
//  coffilation
//
//  Created by Матвей Борисов on 27.11.2022.
//

import Foundation

struct CompilationResponseModel: Codable {
	let id: Int
	let primaryColor: String?
	let secondaryColor: String?
	let isPrivate: Bool
	let name: String
	let description: String?
	let owner: User
}

struct CompilationsResponseModel: Codable {
	let count: Int
	let results: [CompilationResponseModel]
}

struct CompilationCreateRequestModel: Encodable {
	let name: String
	let primaryColor: String
	let secondaryColor: String
	let isPrivate: Bool
	let description: String?
}

protocol CompilationsNetworkManagerProtocol {
	func requestUserCollections(userId: Int, limit: Int, offset: Int, _ completion: @escaping (Result<CompilationsResponseModel, Error>) -> Void)

	func requestDiscoveryCompilations(userId: Int, limit: Int, offset: Int, _ completion: @escaping (Result<CompilationsResponseModel, Error>) -> Void)

	func createCompilation(
		data: CompilationCreateRequestModel,
		_ completion: @escaping (Result<CompilationResponseModel, Error>) -> Void
	)
}

class CompilationsNetworkManager: CompilationsNetworkManagerProtocol {
	private let authManager: AuthManagerProtocol
	private let networkManager: NetworkManagerProtocol

	init(authManager: AuthManagerProtocol, networkManager: NetworkManagerProtocol) {
		self.authManager = authManager
		self.networkManager = networkManager
	}

	func requestUserCollections(userId: Int, limit: Int, offset: Int, _ completion: @escaping (Result<CompilationsResponseModel, Error>) -> Void) {
		guard let request = RequestBuilder(path: "/compilations/")
			.httpMethod(.get)
			.queryItem(name: "compilationmembership__user", value: "\(userId)")
			.queryItem(name: "limit", value: "\(limit)")
			.queryItem(name: "offset", value: "\(offset)")
			.httpHeader(name: "accept", value: "application/json")
			.makeRequestForCofApi() else {
			completion(.failure(InternalError.encodeError))
			return
		}

		authManager.authorizedRequest(with: request) { (result: Result<CompilationsResponseModel, Error>) in
			DispatchQueue.main.async {
				switch result {
				case .success(let model):
					completion(.success(model))
				case .failure(_):
					completion(.failure(NetworkError.noResponse))
				}
			}
		}
	}

	func requestDiscoveryCompilations(userId: Int, limit: Int, offset: Int, _ completion: @escaping (Result<CompilationsResponseModel, Error>) -> Void) {
		guard let request = RequestBuilder(path: "/compilations/")
			.httpMethod(.get)
			.queryItem(name: "compilationmembership__user__not", value: "\(userId)")
			.queryItem(name: "limit", value: "\(limit)")
			.queryItem(name: "offset", value: "\(offset)")
			.httpHeader(name: "accept", value: "application/json")
			.makeRequestForCofApi() else {
			completion(.failure(InternalError.encodeError))
			return
		}

		networkManager.request(with: request) { (result: Result<CompilationsResponseModel, Error>) in
			DispatchQueue.main.async {
				switch result {
				case .success(let model):
					completion(.success(model))
				case .failure(_):
					completion(.failure(NetworkError.noResponse))
				}
			}
		}
	}

	func createCompilation(
		data: CompilationCreateRequestModel,
		_ completion: @escaping (Result<CompilationResponseModel, Error>) -> Void
	) {
		guard let request = try? RequestBuilder(path: "/compilations/")
			.httpMethod(.post)
			.httpHeader(name: "accept", value: "application/json")
			.httpHeader(name: "Content-Type", value: "application/json")
			.httpJSONBody(data)
			.makeRequestForCofApi()
		else {
			return
		}
		print(request.description)
		guard let data = request.httpBody else { return }
		print(String(decoding: data, as: UTF8.self))
		authManager.authorizedRequest(with: request) { (result: Result<CompilationResponseModel, Error>) in
			DispatchQueue.main.async {
				switch result {
				case .success(let model):
					completion(.success(model))
				case .failure(_):
					completion(.failure(NetworkError.noResponse))
				}
			}
		}
	}

}
