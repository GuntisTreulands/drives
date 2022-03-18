//
//  FuelListHeaderView.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

protocol MainListHeaderViewDisplayLogic {
    func setSectionIndex(_ sectionIndex: Int)
}

class MainListHeaderView: FontChangeHeaderFooterView, MainListHeaderViewDisplayLogic {

	public var cellBgType: CellBackgroundType = .single

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet var iconRoad: UIImageView!
	@IBOutlet var iconTime: UIImageView!
	@IBOutlet var timeLabel: UILabel!
	@IBOutlet var distanceLabel: UILabel!

	var titleLabelTopConstraint: NSLayoutConstraint!
	var titleLabelBottomConstraint: NSLayoutConstraint!

	// MARK: View lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		iconRoad.translatesAutoresizingMaskIntoConstraints = false
		iconTime.translatesAutoresizingMaskIntoConstraints = false
		timeLabel.translatesAutoresizingMaskIntoConstraints = false
		distanceLabel.translatesAutoresizingMaskIntoConstraints = false


		self.contentView.backgroundColor = .white

		titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
//		titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
		titleLabelBottomConstraint = titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3)
		titleLabelBottomConstraint.priority = .defaultLow
		titleLabelBottomConstraint.isActive = true
		titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20) //24
		titleLabelTopConstraint.isActive = true

		titleLabel.textColor = UIColor(named: "TitleColor")


		timeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
		timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true

		iconTime.widthAnchor.constraint(equalToConstant: 18).isActive = true
		iconTime.heightAnchor.constraint(equalToConstant: 16).isActive = true
		iconTime.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: 1).isActive = true
		iconTime.rightAnchor.constraint(equalTo: timeLabel.leftAnchor, constant: -5).isActive = true


		distanceLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
		distanceLabel.rightAnchor.constraint(equalTo: iconTime.leftAnchor, constant: -10).isActive = true

		iconRoad.widthAnchor.constraint(equalToConstant: 18).isActive = true
		iconRoad.heightAnchor.constraint(equalToConstant: 16).isActive = true
		iconRoad.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: 1).isActive = true
		iconRoad.rightAnchor.constraint(equalTo: distanceLabel.leftAnchor, constant: -5).isActive = true
		iconRoad.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 5).isActive = true


		timeLabel.alpha = 0.6
		iconTime.alpha = 0.6
		distanceLabel.alpha = 0.6
		iconRoad.alpha = 0.6

		updateFonts()
    }

	// MARK: Functions
	
	private func updateFonts() {
		titleLabel.font = Font(.medium, size: .size1).font
		distanceLabel.font = Font(.medium, size: .size3).font
		timeLabel.font = Font(.medium, size: .size3).font
	}

    override func fontSizeWasChanged() {
		updateFonts()
	}

	// MARK: FuelListHeaderViewDisplayLogic
	
	func setSectionIndex(_ sectionIndex: Int) {
		if sectionIndex > 0 {
			titleLabelTopConstraint.constant = 20
		} else {
			titleLabelTopConstraint.constant = 6
		}
	}
}
