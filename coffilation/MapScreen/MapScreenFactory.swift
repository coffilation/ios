//
//  MapScreenFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.11.2022.
//

import Foundation

struct MapScreenFactory {
	static func makeMapScreen() -> MapViewController {
		let mapView = MapViewController()
		let presenter = MapPresenter(view: mapView)
		mapView.presenter = presenter
		return mapView
	}
}
