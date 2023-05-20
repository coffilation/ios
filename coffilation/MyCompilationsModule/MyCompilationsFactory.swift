//
//  MyCompilationsFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 20.05.2023.
//

import Foundation

struct MyCompilationsFactory {
	static func makeMyCompilationsModule(
		with dependencies: DependencyContainerProtocol,
		delegate: MyCompilationsNavigationDelegate? = nil
	) -> MyCompilationsView {
		let presenter = MyCompilationsPresenter(dependencies: dependencies)
		let myCompilationsView = MyCompilationsView(presenter: presenter)
		presenter.view = myCompilationsView
		return myCompilationsView
	}
}
