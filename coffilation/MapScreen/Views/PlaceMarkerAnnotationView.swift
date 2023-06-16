//
//  PlaceMarkerAnnotationView.swift
//  coffilation
//
//  Created by Матвей Борисов on 15.06.2023.
//

import Foundation
import MapKit

final class PlaceMarkerAnnotationView: MKMarkerAnnotationView {
	private var color = UIColor.mainColor

	static var clusteringIdentifier: String {
		NSStringFromClass(self)
	}

	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		clusteringIdentifier = Self.clusteringIdentifier
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForDisplay() {
		super.prepareForDisplay()
		markerTintColor = color
//		glyphImage = .init(named: AppImageNames.mapPin)
	}

	func configure(color: UIColor) {
		self.color = color
	}

	static var reuseIdentifier: String {
			return NSStringFromClass(self)
	}
}
