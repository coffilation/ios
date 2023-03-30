//
//  CollectionsNetworkManager.swift
//  coffilation
//
//  Created by Матвей Борисов on 27.11.2022.
//

import Foundation

struct CollectionResponseModel: Codable {

	struct Gradient: Codable {
		let startColor: Color
		let endColor: Color
	}

	struct Color: Codable {
		let blue: Int
		let green: Int
		let red: Int
	}

	struct Author: Codable {
		let id: Int
		let username: String
	}

	let id: Int
	let name: String
	let description: String?
	let type: String
	let gradient: Gradient?
	let author: Author
}

protocol CollectionsNetworkManagerProtocol {
	func requestUserCollections(for: Int, completion: @escaping ([CollectionResponseModel]) -> Void)

	func requestAllCollections(for: Int, completion: @escaping ([CollectionResponseModel]) -> Void)
}

class CollectionsNetworkManager: CollectionsNetworkManagerProtocol {
	private let authManager: AuthManagerProtocol
	private let networkManager: NetworkManagerProtocol

	init(authManager: AuthManagerProtocol, networkManager: NetworkManagerProtocol) {
		self.authManager = authManager
		self.networkManager = networkManager
	}

	func requestUserCollections(for userId: Int, completion: @escaping ([CollectionResponseModel]) -> Void) {
		guard let request = RequestBuilder(path: "/collections")
			.httpMethod(.get)
			.httpHeader(name: "accept", value: "application/json")
			.queryItem(name: "userId", value: "\(userId)")
			.makeRequestForCofApi() else {
			return
		}

		authManager.authorizedRequest(with: request) { (result: Result<[CollectionResponseModel], Error>) in
			DispatchQueue.main.async {
				switch result {
				case .success(let success):
					completion(success)
				case .failure(_):
					completion([])
				}
			}
		}
	}

	func requestAllCollections(for userId: Int, completion: @escaping ([CollectionResponseModel]) -> Void) {
		guard let request = RequestBuilder(path: "/collections")
			.httpMethod(.get)
			.httpHeader(name: "accept", value: "application/json")
			.makeRequestForCofApi() else {
			return
		}

		networkManager.request(with: request) { (result: Result<[CollectionResponseModel], Error>) in
			DispatchQueue.main.async {
				switch result {
				case .success(let success):
					completion(success.filter({ collection in
						collection.author.id != userId
					}))
				case .failure(_):
					completion([])
				}
			}
		}

	}
}
