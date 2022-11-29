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

	var sheetCoordinator: UBottomSheetCoordinator?
	var presenter: MapPresenterProtocol?

	private let mapDataSource = MapBottomSheetDataSource()
	private var locationManager: CLLocationManager?
	private var userLocation: CLLocation?

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

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		guard sheetCoordinator == nil else {return}
		sheetCoordinator = UBottomSheetCoordinator(parent: self,
												   delegate: self)
		sheetCoordinator?.dataSource = mapDataSource

		guard var menu = presenter?.createBottomSheetScreen() as? DraggableItem else {
			return
		}
		menu.sheetCoordinator = sheetCoordinator
		sheetCoordinator?.addSheet(menu, to: self, didContainerCreate: { container in
			let frame = self.view.frame
			let rect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
			container.roundCorners(corners: [.topLeft, .topRight], radius: 10, rect: rect)
		})
		sheetCoordinator?.setCornerRadius(10)
//		sheetCoordinator?.startTracking(item: self)
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
		locationButton.addTarget(self, action: #selector(locateToUserLocation), for: .touchUpInside)
	}

	@objc private func locateToUserLocation() {
		let status = locationManager?.authorizationStatus
		if status == .authorizedAlways || status == .authorizedWhenInUse {
			locationManager?.requestLocation()
		} else if status == .notDetermined {
			locationManager?.requestWhenInUseAuthorization()
		}
	}

	@objc private func zoomInAction() {
		var region = mapView.region
		region.span.latitudeDelta *= 0.25
		region.span.longitudeDelta *= 0.25
		mapView.setRegion(region, animated: true)
	}
}

extension MapViewController: UBottomSheetCoordinatorDelegate {}

//extension MapViewController: Draggable {}

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
		mapView.setRegion(region, animated: true)
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		return
	}
}
