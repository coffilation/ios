//
//  RequestBuilder.swift
//  coffilation
//
//  Created by Матвей Борисов on 16.10.2022.
//

import Foundation

struct RequestBuilder {
	enum HTTPRequestMethod: String {
		case get = "GET"
		case post = "POST"
		case put = "PUT"
		case delete = "DELETE"
		case patch = "PATCH"
	}

	var urlComponents: URLComponents

	private var buildURLRequest: (inout URLRequest) -> Void
	static let jsonEncoder = JSONEncoder()

	private init(urlComponents: URLComponents) {
		self.urlComponents = urlComponents
		self.buildURLRequest = { _ in }
	}

	init(path: String) {
		var components = URLComponents()
		components.path = path
		self.init(urlComponents: components)
	}

	func makeRequest(apiBaseString: String) -> URLRequest? {
		guard let baseUrl = URL(string: apiBaseString),
			  let finalUrl = urlComponents.url(relativeTo: baseUrl)
		else {
			return nil
		}
		var urlRequest = URLRequest(url: finalUrl)
		buildURLRequest(&urlRequest)

		return urlRequest
	}

	func modifyURLComponents(_ modifyURLComponents: @escaping (inout URLComponents) -> Void) -> RequestBuilder {
		var copy = self
		modifyURLComponents(&copy.urlComponents)
		return copy
	}

	func queryItems(_ queryItems: [URLQueryItem]) -> RequestBuilder {
		modifyURLComponents { urlComponents in
			var items = urlComponents.queryItems ?? []
			items.append(contentsOf: queryItems)
			urlComponents.queryItems = items
		}
	}

	func queryItems(_ queryItems: [(name: String, value: String)]) -> RequestBuilder {
		self.queryItems(queryItems.map { URLQueryItem(name: $0.name, value: $0.value) })
	}

	func queryItem(name: String, value: String) -> RequestBuilder {
		queryItems([(name: name, value: value)])
	}

	func modifyURLRequest(_ modifyURLRequest: @escaping (inout URLRequest) -> Void) -> RequestBuilder {
		var copy = self
		let existing = buildURLRequest
		copy.buildURLRequest = { request in
			existing(&request)
			modifyURLRequest(&request)
		}
		return copy
	}

	func httpMethod(_ method: HTTPRequestMethod) -> RequestBuilder {
		modifyURLRequest { $0.httpMethod = method.rawValue }
	}

	func httpHeader(name: String, value: String) -> RequestBuilder {
		modifyURLRequest { $0.addValue(value, forHTTPHeaderField: name) }
	}

	func httpBody(_ body: Data) -> RequestBuilder {
		modifyURLRequest { $0.httpBody = body }
	}

	func httpJSONBody<T: Encodable>(_ body: T, encoder: JSONEncoder = RequestBuilder.jsonEncoder) throws -> RequestBuilder {
		let body = try encoder.encode(body)
		return httpBody(body)
	}

	func timeout(seconds timeout: TimeInterval) -> RequestBuilder {
		modifyURLRequest { $0.timeoutInterval = timeout }
	}
}

extension RequestBuilder {
	func makeRequestForCofApi() -> URLRequest? {
		guard let baseUrl = URL(string: "https://test.api.coffilation.ru"),
			  let finalUrl = urlComponents.url(relativeTo: baseUrl)
		else {
			return nil
		}
		var urlRequest = URLRequest(url: finalUrl)
		buildURLRequest(&urlRequest)

		return urlRequest
	}
}
