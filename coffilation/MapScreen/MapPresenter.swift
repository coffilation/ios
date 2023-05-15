//
//  MapPresenter.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.11.2022.
//

import Foundation

protocol MapViewProtocol: AnyObject {}

protocol MapNavigationDelegateProtocol: AnyObject {}

protocol MapPresenterProtocol {}

class MapPresenter: MapPresenterProtocol {

	weak var view: MapViewProtocol?
	weak var navigationDelegate: MapNavigationDelegateProtocol?

	init(view: MapViewProtocol?, navigationDelegate: MapNavigationDelegateProtocol? = nil) {
		self.view = view
		self.navigationDelegate = navigationDelegate
	}
}
