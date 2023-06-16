//
//  PlacesCollectionViewFlowLayout.swift
//  coffilation
//
//  Created by Матвей Борисов on 15.06.2023.
//

import Foundation
import UIKit

class PlacesCollectionViewFlowLayout: UICollectionViewFlowLayout {
	override func prepare() {
		super.prepare()

		scrollDirection = .horizontal
		minimumInteritemSpacing = 8
	}

	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
		guard let collectionView else { return .zero }

		var offsetAdjustment = CGFloat.greatestFiniteMagnitude
		let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left
		let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
		let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
		layoutAttributesArray?.forEach({ (layoutAttributes) in
			let itemOffset = layoutAttributes.frame.origin.x
			if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
				offsetAdjustment = itemOffset - horizontalOffset
			}
		})
		return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
	}
}
