//
//  MainTabBarView.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright © 2022 . All rights reserved.
//

import UIKit

protocol MainTabBarViewButtonLogic: AnyObject {
	func userSelectedMainTab()
	func userSelectedStatsTab()
}

protocol MainTabBarViewDisplayLogic {
    func updateTitles()
}

class MainTabBarView: FontChangeView, MainTabBarViewDisplayLogic {

	weak var controller: MainTabBarViewButtonLogic?

	@IBOutlet weak var baseView: UIView!
	@IBOutlet var leftIcon: UIImageView!
	@IBOutlet var leftLabel: UILabel!
	@IBOutlet var rightButton: UIButton!
	@IBOutlet var rightIcon: UIImageView!
	@IBOutlet var rightLabel: UILabel!

	@IBOutlet var leftButton: UIButton!
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
		Bundle.main.loadNibNamed("MainTabBarView", owner: self, options: nil)
		addSubview(baseView)
		baseView.frame = self.bounds
//		self.clipsToBounds = true
		self.backgroundColor = .clear
		baseView.backgroundColor = .clear

		self.translatesAutoresizingMaskIntoConstraints = false
		self.baseView.translatesAutoresizingMaskIntoConstraints = false
		self.leftButton.translatesAutoresizingMaskIntoConstraints = false
		self.leftIcon.translatesAutoresizingMaskIntoConstraints = false
		self.leftLabel.translatesAutoresizingMaskIntoConstraints = false
		self.rightButton.translatesAutoresizingMaskIntoConstraints = false
		self.rightIcon.translatesAutoresizingMaskIntoConstraints = false
		self.rightLabel.translatesAutoresizingMaskIntoConstraints = false

		baseView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		baseView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true


		self.leftButton.addTarget(self, action: NSSelectorFromString("leftButtonPressed"), for: .touchUpInside)
		self.leftButton.backgroundColor = .clear
		self.leftButton.setTitle("", for: .normal)


		self.rightButton.addTarget(self, action: NSSelectorFromString("rightButtonPressed"), for: .touchUpInside)
		self.rightButton.backgroundColor = .clear
		self.rightButton.setTitle("", for: .normal)

		self.leftIcon.image = UIImage.init(named: "tab_main_off")
		self.leftIcon.highlightedImage = UIImage.init(named: "tab_main_on")

		self.rightIcon.image = UIImage.init(named: "tab_stats_off")
		self.rightIcon.highlightedImage = UIImage.init(named: "tab_stats_on")


		self.leftLabel.textAlignment = .center
		self.rightLabel.textAlignment = .center


		self.leftLabel.textColor = UIColor(named: "TitleColor")
		self.rightLabel.textColor = UIColor(named: "TitleColor")


		self.leftButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		self.leftButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
		self.leftButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		self.leftButton.widthAnchor.constraint(equalTo: baseView.widthAnchor, multiplier: 0.5).isActive = true

		self.rightButton.leftAnchor.constraint(equalTo: leftButton.rightAnchor).isActive = true
		self.rightButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
		self.rightButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		self.rightButton.widthAnchor.constraint(equalTo: baseView.widthAnchor, multiplier: 0.5).isActive = true

		self.leftIcon.widthAnchor.constraint(equalToConstant: 29).isActive = true
		self.leftIcon.heightAnchor.constraint(equalToConstant: 24.5).isActive = true
		self.leftIcon.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
		self.leftIcon.centerXAnchor.constraint(equalTo: self.leftButton.centerXAnchor).isActive = true

		self.rightIcon.widthAnchor.constraint(equalToConstant: 29).isActive = true
		self.rightIcon.heightAnchor.constraint(equalToConstant: 24.5).isActive = true
		self.rightIcon.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
		self.rightIcon.centerXAnchor.constraint(equalTo: self.rightButton.centerXAnchor).isActive = true


		self.leftLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		self.leftLabel.topAnchor.constraint(equalTo: self.leftIcon.bottomAnchor, constant: 0).isActive = true
		self.leftLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		self.leftLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true


		self.rightLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		self.rightLabel.topAnchor.constraint(equalTo: self.rightIcon.bottomAnchor, constant: 0).isActive = true
		self.rightLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		self.rightLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true


		updateFonts()


		updateTitles()

		leftButtonPressed()
	}

	// MARK: MainTabBarViewDisplayLogic

	func updateTitles() {
		self.leftLabel.text = "main_drives".localized()
		self.rightLabel.text = "main_stats".localized()
	}

	// MARK: Functions

	@objc private func leftButtonPressed() {
		controller?.userSelectedMainTab()

		self.leftIcon.isHighlighted = true
		self.rightIcon.isHighlighted = false

		self.leftLabel.textColor = UIColor(named: "TitleColor")
		self.rightLabel.textColor = UIColor(named: "DateColor")
	}

	@objc private func rightButtonPressed() {
		controller?.userSelectedStatsTab()

		self.leftIcon.isHighlighted = false
		self.rightIcon.isHighlighted = true

		self.leftLabel.textColor = UIColor(named: "DateColor")
		self.rightLabel.textColor = UIColor(named: "TitleColor")
	}

	private func updateFonts() {
		self.leftLabel.font = Font(.normal, size: .size6).font
		self.rightLabel.font = Font(.normal, size: .size6).font
	}

	override func fontSizeWasChanged() {
		updateFonts()
	}
	
}
