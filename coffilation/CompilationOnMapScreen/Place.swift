//
//  Place.swift
//  coffilation
//
//  Created by Матвей Борисов on 15.06.2023.
//

import Foundation

struct Place: Equatable {
	let id: Int
	let name: String
	let lon: Double
	let lat: Double
	let city: String
	let road: String
	let houseNumber: String

	static func convert(from model: PlacesResponseModel) -> Place {
		return Place(
			id: model.id,
			name: model.address.amenity,
			lon: model.lon,
			lat: model.lat,
			city: model.address.city,
			road: model.address.road,
			houseNumber: model.address.houseNumber ?? ""
		)
	}
}
