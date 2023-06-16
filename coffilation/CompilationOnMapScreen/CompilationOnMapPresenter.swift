//
//  CompilationOnMapPresenter.swift
//  coffilation
//
//  Created by Матвей Борисов on 14.06.2023.
//

import Foundation
import CoreLocation

protocol CompilationOnMapPresenterProtocol: AnyObject {
	func requestPlaces(compilationId: Int, viewBox: [CLLocationCoordinate2D])

	func joinInCollection(compilationId: Int)
}

class CompilationOnMapPresenter: CompilationOnMapPresenterProtocol {
	typealias Dependencies = HasPlacesNetworkManager & HasCollectionNetworkManager

	weak var view: CompilationOnMapViewProtocol?

	private let dependencies: Dependencies

	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}

	func requestPlaces(compilationId: Int, viewBox: [CLLocationCoordinate2D]) {
		let viewBoxString = "29.608218,60.049997,30.694038,59.760964"

		dependencies.placesNetworkManager.requestPlaces(
			compilationId: compilationId,
			viewBox: viewBoxString) { [weak self] (result: Result<[Place], Error>) in
				switch result {
				case .success(let places):
					self?.view?.didReceivedPlaces(places: places)
				case .failure:
					self?.view?.didReceivedError()
				}
			}
	}

	func joinInCollection(compilationId: Int) {
		dependencies.collectionNetworkManager.joinInCollection(data: CompilationJoinRequestModel(compilation: compilationId)) { _ in }
	}
}
