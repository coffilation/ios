//
//  SplashScreenViewController.swift
//  coffilation
//
//  Created by Матвей Борисов on 29.03.2023.
//

import Foundation
import UIKit
import PureLayout

class SplashScreenViewController: UIViewController {

	var presenter: SplashScreenPresenterProtocol?

	private let loadIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .large)
		return indicator
	}()

	private let logoView: UIImageView = {
		let imageView = UIImageView(image: CoffilationImage.logo)
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupLayout()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadIndicator.startAnimating()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navigationController?.isNavigationBarHidden = true
		presenter?.validateUserAuth()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		navigationController?.isNavigationBarHidden = false
	}

	private func setupLayout() {
		view.backgroundColor = .white

		view.addSubview(logoView)
		logoView.autoCenterInSuperview()
		logoView.autoMatch(.width, to: .width, of: view, withMultiplier: 0.5)
		logoView.autoMatch(.height, to: .width, of: logoView, withMultiplier: 0.4)

		view.addSubview(loadIndicator)
		loadIndicator.autoAlignAxis(toSuperviewAxis: .vertical)
		loadIndicator.autoPinEdge(.top, to: .bottom, of: logoView, withOffset: 50)
	}
}
