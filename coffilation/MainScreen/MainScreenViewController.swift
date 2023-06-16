//
//  MainScreenViewController.swift
//  coffilation
//
//  Created by Матвей Борисов on 08.04.2023.
//

import Foundation
import UIKit
import MapKit
import UBottomSheet
import PureLayout

class MainScreenViewController: UIViewController {

	var sheetCoordinator: UBottomSheetCoordinator?

	private let mainScreenDataSource = MainScreenBottomSheetDataSource()

	private let mapView: MapViewController
	private let coordinator: MainScreenCoordinator
	private var menuView: MainMenuViewController?

	init(
		presenter: MainScreenPresenter,
		mapView: MapViewController,
		coordinator: MainScreenCoordinator
	) {
		self.mapView = mapView
		self.coordinator = coordinator
		super.init(nibName: nil, bundle: nil)
		menuView = coordinator.makeMenuScreen(delegate: coordinator, openCompilationScreen: { [weak self] compilation in
			guard let self else {
				return
			}
			self.sheetCoordinator?.removeSheet()
			self.coordinator.saveNavigationStack()
			let compilationOnMapView = coordinator.makeCompilationOnMapScreen(with: compilation, delegate: self.mapView, didCloseCompletion: {
				self.coordinator.restoreNavigationStack()
				guard let menuView = self.menuView else {
					return
				}
				self.title = ""
				self.navigationController?.setNavigationBarHidden(true, animated: true)
				self.sheetCoordinator?.addSheet(
					menuView,
					to: self,
					didContainerCreate: { container in
						let frame = self.view.frame
						let rect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
						container.roundCorners(corners: [.topLeft, .topRight], radius: 10, rect: rect)
					}
				)

			})
			self.mapView.delegate = compilationOnMapView
			self.coordinator.showSheetScreen(with: compilationOnMapView)
		})

		addChild(mapView)
		view.addSubview(mapView.view)
		mapView.view.autoPinEdgesToSuperviewEdges()
		mapView.didMove(toParent: self)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		guard let menuView, sheetCoordinator == nil else {return}
		sheetCoordinator = UBottomSheetCoordinator(
			parent: self,
			delegate: self
		)
		sheetCoordinator?.dataSource = mainScreenDataSource
		self.title = ""
		navigationController?.setNavigationBarHidden(true, animated: true)
		menuView.sheetCoordinator = sheetCoordinator
		sheetCoordinator?.addSheet(
			menuView,
			to: self,
			didContainerCreate: { container in
				let frame = self.view.frame
				let rect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
				container.roundCorners(corners: [.topLeft, .topRight], radius: 10, rect: rect)
			}
		)
		sheetCoordinator?.setCornerRadius(10)
	}
}

extension MainScreenViewController: UBottomSheetCoordinatorDelegate {}
