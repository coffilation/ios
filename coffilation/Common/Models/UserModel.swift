//
//  UserModel.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.05.2023.
//

import Foundation

struct User: Codable, Hashable {
	let id: Int
	let username: String
}
