//
//  MapScreenFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.11.2022.
//

import Foundation

struct MapScreenFactory {
	static func makeMapScreen(delegate: MapNavigationDelegateProtocol?) -> MapViewController {
		let mapView = MapViewController()
		let presenter = MapPresenter(view: mapView, navigationDelegate: delegate)
		mapView.presenter = presenter
		return mapView
	}
}
