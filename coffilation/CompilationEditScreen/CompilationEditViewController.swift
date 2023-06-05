//
//  CompilationEditViewController.swift
//  coffilation
//
//  Created by Матвей Борисов on 20.05.2023.
//

import Foundation
import UIKit

protocol CompilationEditViewProtocol: AnyObject {
	func didSuccessCreate()
	func didReceivedError(text: String)
}

class CompilationEditViewController: UIViewController {

	private let presenter: CompilationEditPresenterProtocol

	private var form: CompilationEditFormProtocol?

	private var compilations: [Compilation]

	private let compilationEditFormCollection: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
		layout.scrollDirection = .vertical
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.register(
			CompilationEditFormCollectionCell.self,
			forCellWithReuseIdentifier: CompilationEditFormCollectionCell.reuseIdentifier
		)
		return collectionView
	}()

	let createButton = UIBarButtonItem(
		title: "Создать",
		style: .plain,
		target: nil,
		action: #selector(createCompilationAction)
	)

	init(presenter: CompilationEditPresenterProtocol,
		compilations: [Compilation] = []
	) {
		self.presenter = presenter
		self.compilations = compilations
		super.init(nibName: nil, bundle: nil)
		compilationEditFormCollection.delegate = self
		compilationEditFormCollection.dataSource = self
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupLayout()
	}

	private func setupLayout() {
		view.backgroundColor = .white
		view.addSubview(compilationEditFormCollection)
		compilationEditFormCollection.autoPinEdgesToSuperviewSafeArea()

		navigationItem.rightBarButtonItem = createButton
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc private func createCompilationAction() {
		navigationController?.navigationBar.isUserInteractionEnabled = false
		navigationController?.navigationBar.tintColor = UIColor.lightGray
		guard let formData = form?.collectFormData() else {
			form?.updateState(with: .error("Извините, попробуйте другое название"))
			return
		}
		presenter.createCompilation(with: formData)
	}
}

extension CompilationEditViewController: UICollectionViewDelegate {

}

extension CompilationEditViewController: UICollectionViewDataSource {
	func collectionView(
		_ collectionView: UICollectionView,
		numberOfItemsInSection section: Int
	) -> Int {
		compilations.count + 1
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		if indexPath.section == 0, indexPath.row == 0 {
			guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: CompilationEditFormCollectionCell.reuseIdentifier,
				for: indexPath
			) as? CompilationEditFormCollectionCell else {
				return UICollectionViewCell()
			}
			form = cell
			return cell
		} else {
			return UICollectionViewCell()
		}
	}
}

extension CompilationEditViewController: CompilationEditViewProtocol {
	func didSuccessCreate() {
		navigationController?.navigationBar.isUserInteractionEnabled = true
		navigationController?.navigationBar.tintColor = .mainColor
		navigationController?.popViewController(animated: true)
	}

	func didReceivedError(text: String) {
		navigationController?.navigationBar.isUserInteractionEnabled = true
		navigationController?.navigationBar.tintColor = .mainColor
		form?.updateState(with: .error(text))
	}
}
