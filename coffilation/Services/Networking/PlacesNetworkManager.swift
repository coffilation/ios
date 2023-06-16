//
//  PlacesNetworkManager.swift
//  coffilation
//
//  Created by Матвей Борисов on 15.06.2023.
//

import Foundation

struct PlacesResponseModel: Codable {
	let id: Int
	let address: Address
	let lon, lat: Double

	struct Address: Codable {
		let amenity, city, road, state, region: String
		let houseNumber: String?
	}
}

protocol PlacesNetworkManagerProtocol: AnyObject {
	func requestPlaces(compilationId: Int, viewBox: String, _ completion: @escaping (Result<[Place], Error>) -> Void)
}

class PlacesNetworkManager: PlacesNetworkManagerProtocol {
	private let authManager: AuthManagerProtocol

	init(authManager: AuthManagerProtocol) {
		self.authManager = authManager
	}

	func requestPlaces(compilationId: Int, viewBox: String, _ completion: @escaping (Result<[Place], Error>) -> Void) {
		guard let request = RequestBuilder(path: "/map/places/")
			.httpMethod(.get)
			.queryItem(name: "compilation", value: "\(compilationId)")
			.queryItem(name: "viewbox", value: viewBox)
			.httpHeader(name: "accept", value: "application/json")
			.makeRequestForCofApi() else {
			completion(.failure(InternalError.encodeError))
			return
		}

		authManager.authorizedRequest(with: request) { (result: Result<[PlacesResponseModel], Error>) in
			DispatchQueue.main.async {
				switch result {
				case .success(let model):
					completion(.success(model.map({ placeResponce in
						Place.convert(from: placeResponce)
					})))
				case .failure(_):
					completion(.failure(NetworkError.noResponse))
				}
			}
		}
	}
}
