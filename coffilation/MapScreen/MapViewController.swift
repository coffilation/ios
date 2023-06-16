//
//  MapViewController.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.11.2022.
//

import UIKit
import MapKit
import CoreLocation
import UBottomSheet

protocol MapViewDelegate: AnyObject {
	func didSelectPlace(place: Place)
}

class MapViewController: UIViewController {

	var presenter: MapPresenterProtocol?

	private var locationManager: CLLocationManager?
	private var userLocation: CLLocation?
	private var userCurrentRegion: MKCoordinateRegion?

	private let mapView: MKMapView = {
		let map = MKMapView()
		map.mapType = .mutedStandard
		map.tintColor = .mainColor
		map.showsUserLocation = true
		map.register(PlaceMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: PlaceMarkerAnnotationView.reuseIdentifier)
		map.register(PlaceClusterAnnotation.self, forAnnotationViewWithReuseIdentifier: PlaceClusterAnnotation.reuseIdentifier)
		return map
	}()

	private let zoomInButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "plus"), for: .normal)
		button.tintColor = .darkGray
		button.backgroundColor = .coffiLightGray
		button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		button.layer.cornerRadius = 10
		return button
	}()

	private let zoomOutButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "minus"), for: .normal)
		button.tintColor = .darkGray
		button.backgroundColor = .coffiLightGray
		return button
	}()

	private let locationButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "location"), for: .normal)
		button.tintColor = .darkGray
		button.backgroundColor = .coffiLightGray
		button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		button.layer.cornerRadius = 10
		return button
	}()

	weak var delegate: MapViewDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()
		setupLayout()
		setupLocationManager()
		setupActions()

		mapView.delegate = self
	}

	override func viewDidAppear(_ animated: Bool) {
		zoomInButton.addBorder(toSide: .bottom, withColor: UIColor.grey2.cgColor, andThickness: 1)
		zoomOutButton.addBorder(toSide: .bottom, withColor: UIColor.grey2.cgColor, andThickness: 1)
	}

	private func setupLayout() {
		view.addSubview(mapView)
		mapView.autoPinEdgesToSuperviewEdges()

		let stack = UIStackView(arrangedSubviews: [zoomInButton, zoomOutButton, locationButton])
		stack.axis = .vertical
		view.addSubview(stack)

		stack.autoSetDimensions(to: CGSize(width: 44, height: 44*3))
		stack.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
		stack.autoAlignAxis(toSuperviewAxis: .horizontal)
		stack.distribution = .fillEqually
	}

	private func setupLocationManager() {
		locationManager = CLLocationManager()
		locationManager?.desiredAccuracy = kCLLocationAccuracyBest
		locationManager?.delegate = self
	}

	private func setupActions() {
		zoomInButton.addTarget(self, action: #selector(zoomInAction), for: .touchUpInside)
		zoomOutButton.addTarget(self, action: #selector(zoomOutAction), for: .touchUpInside)
		locationButton.addTarget(self, action: #selector(locateToUserLocation), for: .touchUpInside)
	}

	@objc private func locateToUserLocation() {
		guard let userCurrentRegion else { return }
		mapView.setRegion(userCurrentRegion, animated: true)
	}

	@objc private func zoomInAction() {
		var region = mapView.region
		region.span.latitudeDelta *= 0.25
		region.span.longitudeDelta *= 0.25
		mapView.setRegion(region, animated: true)
	}

	@objc private func zoomOutAction() {
		var region = mapView.region

		region.span.latitudeDelta = CLLocationDegrees(180) > (region.span.latitudeDelta / 0.25)
		? (region.span.latitudeDelta / 0.25)
		: CLLocationDegrees(180)
		region.span.longitudeDelta = CLLocationDegrees(180) > (region.span.longitudeDelta / 0.25)
		? (region.span.longitudeDelta / 0.25)
		: CLLocationDegrees(180)
		mapView.setRegion(region, animated: true)
	}
}

extension MapViewController: MapViewProtocol {}

extension MapViewController: CLLocationManagerDelegate {
	func activateLocationServices() {
		locationManager?.startUpdatingLocation()
	}

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		DispatchQueue.global().async {
			CLLocationManager.locationServicesEnabled()
		}

		let status = manager.authorizationStatus
		if status == .authorizedAlways || status == .authorizedWhenInUse {
			activateLocationServices()
		} else if status == .notDetermined {
			locationManager?.requestWhenInUseAuthorization()
		}
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let latest = locations.first else { return }

		let coordinate = latest.coordinate
		let region = MKCoordinateRegion(center: coordinate, span: .init(latitudeDelta: 0.025, longitudeDelta: 0.025))
		userCurrentRegion = region
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		return
	}

	private func addPin(for place: Place, color: UIColor) {
		let annotation = PlaceAnnotation()
		annotation.configure(with: place, color: .mainColor)
		annotation.coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon)
		annotation.title = place.name
		mapView.addAnnotation(annotation)
	}

	private func focusMap(on place: Place) {
		let mapCenter = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon)
		let newRegion = MKCoordinateRegion(center: mapCenter, span: .init(latitudeDelta: 0.006, longitudeDelta: 0.006))
		mapView.setRegion(newRegion, animated: true)
	}
}

extension MapViewController: CompilationOnMapDelegate {
	func configureNavigationBar(title: String, backAction: @escaping () -> Void) {
		let backItem = UIBarButtonItem(title: "", image: UIImage(systemName: "arrow.backward"), primaryAction: UIAction(handler: { _ in
			self.navigationController?.setNavigationBarHidden(true, animated: true)
			backAction()
			self.mapView.removeAnnotations(self.mapView.annotations)
		}), menu: nil)
		navigationController?.setNavigationBarHidden(false, animated: true)
		navigationController?.navigationBar.topItem?.title = title
		self.navigationController?.navigationBar.topItem?.leftBarButtonItem = backItem
	}

	var viewBox: [CLLocationCoordinate2D] {
		mapView.region.boundingBoxCoordinates
	}

	func moveToPoint(place: Place) {
		focusMap(on: place)
	}

	func addPointsOnMap(places: [Place], color: UIColor) {
		places.forEach { addPin(for: $0, color: color) }
	}
}

extension MapViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if let annotation = annotation as? PlaceAnnotation {
			let view = mapView.dequeueReusableAnnotationView(withIdentifier: PlaceMarkerAnnotationView.reuseIdentifier, for: annotation)
			view.clusteringIdentifier = PlaceClusterAnnotation.reuseIdentifier
			if let marker = view as? PlaceMarkerAnnotationView {
				marker.configure(color: annotation.color)
			}
			return view
		} else if let annotation = annotation as? PlaceClusterAnnotation {
			let view = mapView.dequeueReusableAnnotationView(withIdentifier: PlaceClusterAnnotation.reuseIdentifier, for: annotation)
			if let marker = view as? PlaceMarkerAnnotationView, let placeAnnotation = findAnnotation(in: annotation) {
				marker.configure(color: placeAnnotation.color)
			}
			return view
		}
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PlaceMarkerAnnotationView.reuseIdentifier)
		annotationView?.clusteringIdentifier = PlaceClusterAnnotation.reuseIdentifier
		if annotationView == nil {
			let markerView = PlaceMarkerAnnotationView(annotation: annotation, reuseIdentifier: PlaceMarkerAnnotationView.clusteringIdentifier)
			if let annotation = annotation as? PlaceAnnotation {
				markerView.configure(color: annotation.color)
			}
			annotationView = markerView
		} else {
			annotationView?.annotation = annotation
		}

		return annotationView
	}

	private func findAnnotation(in annotation: MKAnnotation) -> PlaceAnnotation? {
		if let searchAnnotation = annotation as? PlaceAnnotation {
			return searchAnnotation
		} else if let searchAnnotation = annotation as? PlaceClusterAnnotation, let firstAnnotation = searchAnnotation.memberAnnotations.first {
			return findAnnotation(in: firstAnnotation)
		} else {
			return nil
		}
	}

	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if let annotation = view.annotation as? PlaceAnnotation {
			if let place = annotation.place {
				delegate?.didSelectPlace(place: place)
			}

		} else if let annotation = view.annotation as? MKClusterAnnotation {
			annotation.title = "\(annotation.memberAnnotations.count)"
			let latCorrection = mapView.region.span.latitudeDelta / 8
			let span = MKCoordinateSpan(latitudeDelta: latCorrection, longitudeDelta: latCorrection)

			let region = MKCoordinateRegion(center: annotation.coordinate, span: span)

			mapView.setRegion(region, animated: true)
		}
	}
}

extension MKCoordinateRegion {

	var boundingBoxCoordinates: [CLLocationCoordinate2D] {
		let halfLatDelta = self.span.latitudeDelta / 2
		let halfLngDelta = self.span.longitudeDelta / 2

		let topLeft = CLLocationCoordinate2D(
			latitude: self.center.latitude + halfLatDelta,
			longitude: self.center.longitude - halfLngDelta
		)
		let bottomRight = CLLocationCoordinate2D(
			latitude: self.center.latitude - halfLatDelta,
			longitude: self.center.longitude + halfLngDelta
		)
		let bottomLeft = CLLocationCoordinate2D(
			latitude: self.center.latitude - halfLatDelta,
			longitude: self.center.longitude - halfLngDelta
		)
		let topRight = CLLocationCoordinate2D(
			latitude: self.center.latitude + halfLatDelta,
			longitude: self.center.longitude + halfLngDelta
		)

		return [topLeft, topRight, bottomRight, bottomLeft]
	}

}
