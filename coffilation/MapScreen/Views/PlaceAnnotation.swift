//
//  PlaceAnnotation.swift
//  coffilation
//
//  Created by Матвей Борисов on 15.06.2023.
//

import Foundation
import MapKit

final class PlaceAnnotation: MKPointAnnotation {
	static var pointIdentifier: String {
		NSStringFromClass(self)
	}

	var place: Place?
	var color = UIColor.mainColor

	func configure(with place: Place, color: UIColor) {
		self.place = place
		self.color = color
	}
}
