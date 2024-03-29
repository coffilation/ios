//
//  TokenProvider.swift
//  coffilation
//
//  Created by Матвей Борисов on 25.10.2022.
//

import Foundation
import Security

protocol TokenProviderProtocol {
	func obtainAuthToken() -> String?
	func updateAuthToken(with token: String)
	func deleteAuthToken()

	func obtainRefreshToken() -> String?
	func updateRefreshToken(with token: String)
	func deleteRefreshToken()
}

class TokenProvider: TokenProviderProtocol {

	private struct Constants {
		static let account = "Coffilation"
		static let serviceAuth = "Auth"
		static let serviceRefresh = "Refresh"
	}

	func obtainAuthToken() -> String? {
		return obtainToken(service: Constants.serviceAuth, account: Constants.account)
	}

	func updateAuthToken(with token: String) {
		updateToken(service: Constants.serviceAuth, account: Constants.account, with: token)
	}

	func deleteAuthToken() {
		deleteToken(service: Constants.serviceAuth, account: Constants.account)
	}

	func obtainRefreshToken() -> String? {
		return obtainToken(service: Constants.serviceRefresh, account: Constants.account)
	}

	func updateRefreshToken(with token: String) {
		updateToken(service: Constants.serviceRefresh, account: Constants.account, with: token)
	}

	func deleteRefreshToken() {
		deleteToken(service: Constants.serviceRefresh, account: Constants.account)
	}

	private func saveToken(service: String, account: String, with token: String) {
		let data = token.data(using: .utf8)

		let query: [String: AnyObject] = [
			kSecAttrService as String: service as AnyObject,
			kSecAttrAccount as String: account as AnyObject,
			kSecClass as String: kSecClassGenericPassword,
			kSecValueData as String: data as AnyObject
		]

		let status = SecItemAdd(query as CFDictionary, nil)

		if status == errSecDuplicateItem {
			updateToken(service: service, account: account, with: token)
		}
	}

	private func obtainToken(service: String, account: String) -> String? {
		let query: [String: AnyObject] = [
			kSecAttrService as String: service as AnyObject,
			kSecAttrAccount as String: account as AnyObject,
			kSecClass as String: kSecClassGenericPassword,
			kSecMatchLimit as String: kSecMatchLimitOne,
			kSecReturnData as String: kCFBooleanTrue
		]

		var itemCopy: AnyObject?
		_ = SecItemCopyMatching(query as CFDictionary, &itemCopy)

		guard let rawData = itemCopy as? Data,
			  let token = String(data: rawData, encoding: .utf8) else {
			return nil
		}

		return token
	}

	private func updateToken(service: String, account: String, with token: String) {
		let query: [String: AnyObject] = [
			kSecAttrService as String: service as AnyObject,
			kSecAttrAccount as String: account as AnyObject,
			kSecClass as String: kSecClassGenericPassword
		]

		let data = token.data(using: .utf8)
		let attributes: [String: AnyObject] = [
			kSecValueData as String: data as AnyObject
		]

		let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

		if status == errSecItemNotFound {
			saveToken(service: service, account: account, with: token)
		}
	}

	private func deleteToken(service: String, account: String) {
		let query: [String: AnyObject] = [
			kSecAttrService as String: service as AnyObject,
			kSecAttrAccount as String: account as AnyObject,
			kSecClass as String: kSecClassGenericPassword
		]

		SecItemDelete(query as CFDictionary)
	}

}
