//
//  SkeletonImageView.swift
//  coffilation
//
//  Created by Матвей Борисов on 27.11.2022.
//

import Foundation
import UIKit

final class SkeletonView: UIView {

	private let gradientLayer: CAGradientLayer = {
		let gradientLayer = CAGradientLayer()
		gradientLayer.startPoint = CGPoint(x: 0, y: 1)
		gradientLayer.endPoint = CGPoint(x: 1, y: 1)
		gradientLayer.colors = [UIColor.lightGray.cgColor,
								UIColor.white.cgColor,
								UIColor.lightGray.cgColor]

		return gradientLayer
	}()

	private var isAnimationRunning = false

	init() {
		super.init(frame: .zero)
		layer.addSublayer(gradientLayer)
		gradientLayer.isHidden = true
		setupImageView()
		start()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		gradientLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
		start()
	}

	private func setupImageView() {
		clipsToBounds = true
		contentMode = .scaleAspectFill
	}

	func start() {
		guard !isAnimationRunning else {
			return
		}
		isAnimationRunning = true
		gradientLayer.isHidden = false

		let startLocations: [NSNumber] = [-1, -0.5, 0]
		let endLocations: [NSNumber] = [1, 1.5, 2]
		gradientLayer.locations = startLocations

		let animation = CABasicAnimation(keyPath: "locations")
		animation.fromValue = startLocations
		animation.toValue = endLocations
		animation.duration = 1
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

		let animationGroup = CAAnimationGroup()
		animationGroup.duration = 2
		animationGroup.animations = [animation]
		animationGroup.repeatCount = .infinity
		gradientLayer.add(animationGroup, forKey: animation.keyPath)
	}

	func stop() {
		isAnimationRunning = false
		gradientLayer.isHidden = true
		gradientLayer.removeAllAnimations()
	}
}
