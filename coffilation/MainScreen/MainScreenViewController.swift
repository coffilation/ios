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
	private let menuView: MainMenuViewController

	init(
		mapView: MapViewController,
		menuView: MainMenuViewController
	) {
		self.mapView = mapView
		self.menuView = menuView
		super.init(nibName: nil, bundle: nil)

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

		guard sheetCoordinator == nil else {return}
		sheetCoordinator = UBottomSheetCoordinator(
			parent: self,
			delegate: self
		)
		sheetCoordinator?.dataSource = mainScreenDataSource

		menuView.sheetCoordinator = sheetCoordinator
		sheetCoordinator?.addSheet(
			menuView, to: self,
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
