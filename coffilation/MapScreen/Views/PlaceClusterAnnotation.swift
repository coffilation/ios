//
//  PlaceClusterAnnotation.swift
//  coffilation
//
//  Created by Матвей Борисов on 15.06.2023.
//

import MapKit

class PlaceClusterAnnotation: MKClusterAnnotation {

	override init(memberAnnotations: [MKAnnotation]) {
		super.init(memberAnnotations: memberAnnotations)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	static var reuseIdentifier: String {
			return NSStringFromClass(self)
		}
}
