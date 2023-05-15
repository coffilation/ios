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

	override func viewDidLoad() {
		super.viewDidLoad()
		setupLayout()
		setupLocationManager()
		setupActions()
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
		region.span.latitudeDelta /= 0.25
		region.span.longitudeDelta /= 0.25
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
}
