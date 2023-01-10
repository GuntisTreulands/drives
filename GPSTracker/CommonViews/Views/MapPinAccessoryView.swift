//
//  MapPinAccessoryView.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright © 2022 . All rights reserved.
//

import UIKit

protocol MapPinAccessoryViewDisplayLogic {
	func setAsSelected(_ selected: Bool, isCheapestPrice: Bool)
    func setDistanceVisible(_ visible: Bool)
}

class MapPinAccessoryView: UIView, MapPinAccessoryViewDisplayLogic {

	@IBOutlet weak var baseView: UIView!
	@IBOutlet var backgroundImageView: UIImageView!
	@IBOutlet var backgroundBubbleArrowImageView: UIImageView!
	@IBOutlet var iconGray: UIImageView!
	@IBOutlet var iconNormal: UIImageView!
	@IBOutlet var priceLabel: UILabel!
	@IBOutlet var distanceLabel: UILabel!

	var priceLabelBottomConstraint: NSLayoutConstraint!
	var distanceLabelBottomConstraint: NSLayoutConstraint!
	var iconGrayBottomConstraint: NSLayoutConstraint!
	var iconNormalBottomConstraint: NSLayoutConstraint!


	var iconNormalWidthConstraint: NSLayoutConstraint!
	var iconNormalHeightConstraint: NSLayoutConstraint!

	var iconGrayWidthConstraint: NSLayoutConstraint!
	var iconGrayHeightConstraint: NSLayoutConstraint!


	var iconGrayRightConstraint: NSLayoutConstraint!
	var iconNormalRightConstraint: NSLayoutConstraint!


	var priceLabelRightConstraint: NSLayoutConstraint!
	var distanceLabelRightConstraint: NSLayoutConstraint!

	var address: String!
	var title: String!
	
	// MARK: View lifecycle

	override init(frame: CGRect) {
   	super.init(frame: frame)
		setup()
  	}

  	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
    	setup()
	}

	private func setup() {
		Bundle.main.loadNibNamed("MapPinAccessoryView", owner: self, options: nil)
		addSubview(baseView)
		baseView.frame = self.bounds

		// For icons. We need to compensate, so that it would nice, when showing price + distance.
		let increaseIconSize: CGFloat = CGFloat(max(0, Font.increaseFontSize)) * 2

		self.translatesAutoresizingMaskIntoConstraints = false
		baseView.translatesAutoresizingMaskIntoConstraints = false
		backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
		backgroundBubbleArrowImageView.translatesAutoresizingMaskIntoConstraints = false
		iconGray.translatesAutoresizingMaskIntoConstraints = false
		iconNormal.translatesAutoresizingMaskIntoConstraints = false
		priceLabel.translatesAutoresizingMaskIntoConstraints = false
		distanceLabel.translatesAutoresizingMaskIntoConstraints = false


		baseView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		baseView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		baseView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		baseView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

		backgroundImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		backgroundImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		backgroundImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3.5).isActive = true

		backgroundBubbleArrowImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		backgroundBubbleArrowImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

		backgroundBubbleArrowImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

		iconGray.leftAnchor.constraint(equalTo: leftAnchor, constant: 7).isActive = true
		iconGray.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
		iconGrayRightConstraint = iconGray.rightAnchor.constraint(equalTo: rightAnchor, constant: -7)

		iconGrayWidthConstraint = iconGray.widthAnchor.constraint(equalToConstant: 28+increaseIconSize)
		iconGrayHeightConstraint = iconGray.heightAnchor.constraint(equalToConstant: 28+increaseIconSize)

		iconGrayBottomConstraint = iconGray.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
		iconGrayBottomConstraint.priority = .defaultHigh
		iconGrayBottomConstraint.isActive = true

		iconNormal.leftAnchor.constraint(equalTo: leftAnchor, constant: 7).isActive = true
		iconNormal.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
		iconNormalRightConstraint = iconGray.rightAnchor.constraint(equalTo: rightAnchor, constant: -7)


		iconNormalWidthConstraint = iconNormal.widthAnchor.constraint(equalToConstant: 28+increaseIconSize)
		iconNormalHeightConstraint = iconNormal.heightAnchor.constraint(equalToConstant: 28+increaseIconSize)

		iconNormalBottomConstraint = iconNormal.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
		iconNormalBottomConstraint.priority = .defaultHigh
		iconNormalBottomConstraint.isActive = true

		iconGrayWidthConstraint.isActive = true
		iconGrayHeightConstraint.isActive = true
		iconNormalWidthConstraint.isActive = true
		iconNormalHeightConstraint.isActive = true

		priceLabel.leftAnchor.constraint(equalTo: iconGray.rightAnchor, constant: 5).isActive = true
		priceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
		priceLabelRightConstraint = priceLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -7)
		priceLabelBottomConstraint = priceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7)


		distanceLabel.leftAnchor.constraint(equalTo: iconGray.rightAnchor, constant: 5).isActive = true
		distanceLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: -1).isActive = true
		distanceLabelRightConstraint = distanceLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -7)
		distanceLabelBottomConstraint = distanceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
		distanceLabelBottomConstraint.isActive = true

		priceLabel.font = Font(.medium, size: .size19).font
		distanceLabel.font = Font(.normal, size: .size15).font

		iconGray.contentMode = .center
		iconNormal.contentMode = .center
	}

	// MARK: MapPinAccessoryViewDisplayLogic

	func setAsTiny(_ tiny: Bool) {
		let increaseIconSize: CGFloat = CGFloat(max(0, Font.increaseFontSize)) * 2

		if tiny {
			iconGray.contentMode = .scaleAspectFit
			iconNormal.contentMode = .scaleAspectFit
			self.priceLabel.isHidden = true
			self.distanceLabel.isHidden = true
			
			priceLabelBottomConstraint.isActive = false
			distanceLabelBottomConstraint.isActive = false

			iconGrayRightConstraint.isActive = true
			iconNormalRightConstraint.isActive = true

			priceLabelRightConstraint.isActive = false
			distanceLabelRightConstraint.isActive = false
		} else {

			iconGray.contentMode = .center
			iconNormal.contentMode = .center

			self.priceLabel.isHidden = false
			self.distanceLabel.isHidden = false
			self.backgroundImageView.image = UIImage.init(named: "map_bubble")
			self.backgroundBubbleArrowImageView.isHidden = false

			iconGrayWidthConstraint.constant = 28+increaseIconSize
			iconGrayHeightConstraint.constant = 28+increaseIconSize

			iconNormalWidthConstraint.constant = 28+increaseIconSize
			iconNormalHeightConstraint.constant = 28+increaseIconSize

			iconGrayRightConstraint.isActive = false
			iconNormalRightConstraint.isActive = false

			priceLabelRightConstraint.isActive = true
			distanceLabelRightConstraint.isActive = true
		}
	}

	func setAsSelected(_ selected: Bool, isCheapestPrice: Bool) {
		if selected == true {
			priceLabel.textColor = UIColor(named: isCheapestPrice ? "CheapPriceColor" : "TitleColor")
			distanceLabel.textColor = UIColor(named: "SubTitleColor")
			iconGray.isHidden = true
			iconNormal.isHidden = false
		} else {
			priceLabel.textColor = UIColor(named: "InactiveTextColor")
			distanceLabel.textColor = UIColor(named: "InactiveTextColor")
			iconGray.isHidden = false
			iconNormal.isHidden = true
		}
	}

	func setDistanceVisible(_ visible: Bool) {
		baseView.fadeTransition(0.2)
		backgroundImageView.fadeTransition(0.2)
		backgroundBubbleArrowImageView.fadeTransition(0.2)
		priceLabel.fadeTransition(0.2)
		distanceLabel.fadeTransition(0.2)
		iconGray.fadeTransition(0.2)
		iconNormal.fadeTransition(0.2)
		
		if visible == true {
			distanceLabel.isHidden = false
			priceLabelBottomConstraint.isActive = false
			distanceLabelBottomConstraint.isActive = true
		} else {
			distanceLabel.isHidden = true
			distanceLabelBottomConstraint.isActive = false
			priceLabelBottomConstraint.isActive = true
		}
	}
}
