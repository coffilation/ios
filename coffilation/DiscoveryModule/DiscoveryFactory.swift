//
//  DiscoveryFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 18.05.2023.
//

import Foundation

struct DiscoveryFactory {
	static func makeDiscoveryModule(
		with dependencies: DependencyContainerProtocol,
		delegate: DiscoveryNavigationDelegate? = nil,
		openCompilationScreen: @escaping (Compilation) -> Void
	) -> DiscoveryView {
		let presenter = DiscoveryPresenter(dependencies: dependencies)
		let discoveryView = DiscoveryView(presenter: presenter, openCompilationScreen: openCompilationScreen)
		presenter.view = discoveryView
		return discoveryView
	}
}
