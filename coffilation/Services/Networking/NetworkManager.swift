//
//  NetworkManager.swift
//  coffilation
//
//  Created by Матвей Борисов on 16.10.2022.
//

import Foundation

enum NetworkError: Error {
	case noResponse
	case decodeFailure
	case notAuthorized
}

protocol NetworkManagerProtocol {
	typealias RequestCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

	@discardableResult func request<T: Decodable>(with url: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> RequestCompletion

	func retryRequest(for request: URLRequest, completion: @escaping RequestCompletion)
}

class NetworkManager: NetworkManagerProtocol {
	private let session = URLSession(configuration: .default)

	func request<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> RequestCompletion {
		let requestCompletion = { (data: Data?, response: URLResponse?, error: Error?) -> Void in
			if let error {
				completion(.failure(error))
				return
			}

			if let response = response as? HTTPURLResponse {
				if response.statusCode == 401 {
					completion(.failure(NetworkError.notAuthorized))
					return
				}
			}
			guard let data = data else {
				completion(.failure(NetworkError.noResponse))
				return
			}
			guard let responseObject = try? JSONDecoder().decode(T.self, from: data) else {
				completion(.failure(NetworkError.decodeFailure))
				return
			}
			completion(.success(responseObject))

		}
		let dataTask = session.dataTask(with: request, completionHandler: requestCompletion)
		dataTask.resume()
		return requestCompletion
	}

	func retryRequest(for request: URLRequest, completion: @escaping RequestCompletion) {
		let dataTask = session.dataTask(with: request, completionHandler: completion)
		dataTask.resume()
	}
}
