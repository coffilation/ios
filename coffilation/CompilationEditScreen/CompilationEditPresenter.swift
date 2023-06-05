//
//  CompilationEditPresenter.swift
//  coffilation
//
//  Created by Матвей Борисов on 20.05.2023.
//

import Foundation
import UIKit

protocol CompilationEditPresenterProtocol {
	func createCompilation(with data: CompilationEditFormData)
}

class CompilationEditPresenter: CompilationEditPresenterProtocol {

	typealias Dependencies = HasCollectionNetworkManager

	weak var view: CompilationEditViewProtocol?

	private let dependencies: Dependencies

	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}

	func createCompilation(with data: CompilationEditFormData) {
		guard let name = data.name, name != "" else {
			view?.didReceivedError(text: "Необходимо ввести название")
			return
		}

		let primaryColor = UIColor(cgColor: data.primaryColor).toHex() ?? "#DF4685"
		let secondaryColor = UIColor(cgColor: data.secondaryColor).toHex() ?? "#FF8345"

		dependencies.collectionNetworkManager.createCompilation(
			data: CompilationCreateRequestModel(
				name: name,
				primaryColor: primaryColor,
				secondaryColor: secondaryColor,
				isPrivate: data.isPrivate,
				description: data.description == "" ? nil : data.description
			)
		) { [weak self] (result: Result<CompilationResponseModel, Error>) in
			switch result {
			case .success:
				self?.view?.didSuccessCreate()
			case .failure:
				self?.view?.didReceivedError(text: "Произошла ошибка, попробуйте позже")
			}
		}
	}
}
