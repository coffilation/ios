//
//  CompilationOnMapDelegate.swift
//  coffilation
//
//  Created by Матвей Борисов on 14.06.2023.
//

import Foundation
import CoreLocation
import UIKit

protocol CompilationOnMapDelegate: AnyObject {

	var viewBox: [CLLocationCoordinate2D] { get }

	func moveToPoint(place: Place)

	func addPointsOnMap(places: [Place], color: UIColor)

	func configureNavigationBar(title: String, backAction: @escaping () -> Void, joinAction: (() -> Void)?)
}
