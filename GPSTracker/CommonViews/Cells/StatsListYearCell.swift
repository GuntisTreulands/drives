//
//  StatsListYearCell.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

protocol StatsListYearCellDisplayLogic {
    func setAsCellType(cellType: CellBackgroundType)
}

class StatsListYearCell: FontChangeTableViewCell, StatsListYearCellDisplayLogic {

	public var cellBgType: CellBackgroundType = .single

	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet var selectedBackgroundImageView: UIImageView!
	@IBOutlet weak var separatorView: UIView!
	@IBOutlet var forwardArrow: UIImageView!
	@IBOutlet var iconRoad: UIImageView!
	@IBOutlet var iconTime: UIImageView!
	@IBOutlet var distanceLabel: UILabel!
	@IBOutlet var timeLabel: UILabel!

	@IBOutlet var iconCalendar1: UIImageView!
	@IBOutlet var iconCalendar2: UIImageView!
	@IBOutlet var iconCalendar3: UIImageView!
	@IBOutlet var cal1Text: UILabel!
	@IBOutlet var cal2Text: UILabel!
	@IBOutlet var cal3Text: UILabel!


	var bgViewBottomAnchorConstraint: NSLayoutConstraint!
	var bgViewTopAnchorConstraint: NSLayoutConstraint!

	var selectedBgViewBottomAnchorConstraint: NSLayoutConstraint!
	var selectedBgViewTopAnchorConstraint: NSLayoutConstraint!



	// MARK: View lifecycle
	
	override func awakeFromNib() {
        super.awakeFromNib()

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        selectedBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        iconRoad.translatesAutoresizingMaskIntoConstraints = false
        iconTime.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
		timeLabel.translatesAutoresizingMaskIntoConstraints = false
		iconCalendar1.translatesAutoresizingMaskIntoConstraints = false
		iconCalendar2.translatesAutoresizingMaskIntoConstraints = false
		iconCalendar3.translatesAutoresizingMaskIntoConstraints = false
		cal1Text.translatesAutoresizingMaskIntoConstraints = false
		cal2Text.translatesAutoresizingMaskIntoConstraints = false
		cal3Text.translatesAutoresizingMaskIntoConstraints = false

		backgroundImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
		backgroundImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
		bgViewBottomAnchorConstraint = backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		bgViewBottomAnchorConstraint.isActive = true
		bgViewTopAnchorConstraint = backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor)
		bgViewTopAnchorConstraint.isActive = true

		selectedBackgroundImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
		selectedBackgroundImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
		selectedBgViewBottomAnchorConstraint = selectedBackgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		selectedBgViewBottomAnchorConstraint.isActive = true
		selectedBgViewTopAnchorConstraint = selectedBackgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor)
		selectedBgViewTopAnchorConstraint.isActive = true


		iconRoad.widthAnchor.constraint(equalToConstant: 18).isActive = true
		iconRoad.heightAnchor.constraint(equalToConstant: 16).isActive = true
		iconRoad.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 8).isActive = true
		iconRoad.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 8).isActive = true

		distanceLabel.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 3).isActive = true
		distanceLabel.leftAnchor.constraint(equalTo: iconRoad.rightAnchor, constant: 5).isActive = true

		iconTime.widthAnchor.constraint(equalToConstant: 18).isActive = true
		iconTime.heightAnchor.constraint(equalToConstant: 16).isActive = true
		iconTime.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 8).isActive = true
		iconTime.leftAnchor.constraint(equalTo: distanceLabel.rightAnchor, constant: 10).isActive = true

		timeLabel.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 3).isActive = true
		timeLabel.leftAnchor.constraint(equalTo: iconTime.rightAnchor, constant: 5).isActive = true


		iconCalendar1.widthAnchor.constraint(equalToConstant: 18).isActive = true
		iconCalendar1.heightAnchor.constraint(equalToConstant: 16).isActive = true
		iconCalendar1.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 8).isActive = true
		iconCalendar1.topAnchor.constraint(equalTo: iconRoad.bottomAnchor, constant: 8).isActive = true

		iconCalendar2.widthAnchor.constraint(equalToConstant: 18).isActive = true
		iconCalendar2.heightAnchor.constraint(equalToConstant: 16).isActive = true
		iconCalendar2.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 8).isActive = true
		iconCalendar2.topAnchor.constraint(equalTo: cal1Text.bottomAnchor, constant: 8).isActive = true

		iconCalendar3.widthAnchor.constraint(equalToConstant: 18).isActive = true
		iconCalendar3.heightAnchor.constraint(equalToConstant: 16).isActive = true
		iconCalendar3.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 8).isActive = true
		iconCalendar3.topAnchor.constraint(equalTo: cal2Text.bottomAnchor, constant: 8).isActive = true


		cal1Text.topAnchor.constraint(equalTo: iconRoad.bottomAnchor, constant: 6).isActive = true
		cal1Text.leftAnchor.constraint(equalTo: iconCalendar1.rightAnchor, constant: 5).isActive = true
		cal1Text.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10).isActive = true

		cal2Text.topAnchor.constraint(equalTo: cal1Text.bottomAnchor, constant: 6).isActive = true
		cal2Text.leftAnchor.constraint(equalTo: iconCalendar2.rightAnchor, constant: 5).isActive = true
		cal2Text.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10).isActive = true

		cal3Text.topAnchor.constraint(equalTo: cal2Text.bottomAnchor, constant: 6).isActive = true
		cal3Text.leftAnchor.constraint(equalTo: iconCalendar3.rightAnchor, constant: 5).isActive = true
		cal3Text.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10).isActive = true
		cal3Text.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -8).isActive = true;


		separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
		separatorView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -1).isActive = true
		separatorView.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor).isActive = true
		separatorView.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor).isActive = true


		selectedBackgroundImageView.alpha = 0

		updateFonts()
    }

	// MARK: Functions

	private func updateFonts() {
		distanceLabel.font = Font(.bold, size: .size21).font
		timeLabel.font = Font(.bold, size: .size21).font
		cal1Text.font = Font(.normal, size: .size17).font
		cal2Text.font = Font(.normal, size: .size17).font
		cal3Text.font = Font(.normal, size: .size17).font
	}

	override func fontSizeWasChanged() {
		updateFonts()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        UIView.animate(withDuration: animated ? 0.15 : 0, delay: 0, options: [], animations: { [weak self] in
			if selected {
				self?.selectedBackgroundImageView.alpha = 1
			} else {
				self?.selectedBackgroundImageView.alpha = 0
			}
		}, completion: { (finished: Bool) in })
    }

	// MARK: FuelListCellDisplayLogic

	func setAsCellType(cellType: CellBackgroundType) {
		switch cellType {
			case .top:
				self.bgViewTopAnchorConstraint?.constant = 5
				self.bgViewBottomAnchorConstraint?.constant = 0
				self.selectedBgViewTopAnchorConstraint?.constant = 5
				self.selectedBgViewBottomAnchorConstraint?.constant = 0
				self.separatorView.isHidden = false
				backgroundImageView.image = UIImage(named: "cell_bg_top")
				selectedBackgroundImageView.image = UIImage(named: "cell_bg_selected_top")
			case .bottom:
				self.bgViewTopAnchorConstraint?.constant = 0
				self.bgViewBottomAnchorConstraint?.constant = -5
				self.selectedBgViewTopAnchorConstraint?.constant = 0
				self.selectedBgViewBottomAnchorConstraint?.constant = -5
				self.separatorView.isHidden = true
				backgroundImageView.image = UIImage(named: "cell_bg_bottom")
				selectedBackgroundImageView.image = UIImage(named: "cell_bg_selected_bottom")
			case .middle:
				self.bgViewTopAnchorConstraint?.constant = 0
				self.bgViewBottomAnchorConstraint?.constant = 0
				self.selectedBgViewTopAnchorConstraint?.constant = 0
				self.selectedBgViewBottomAnchorConstraint?.constant = 0
				self.separatorView.isHidden = false
				backgroundImageView.image = UIImage(named: "cell_bg_middle")
				selectedBackgroundImageView.image = UIImage(named: "cell_bg_selected_middle")
			case .single:
				self.bgViewTopAnchorConstraint?.constant = 5
				self.bgViewBottomAnchorConstraint?.constant = -5
				self.selectedBgViewTopAnchorConstraint?.constant = 5
				self.selectedBgViewBottomAnchorConstraint?.constant = -5
				self.separatorView.isHidden = true
				backgroundImageView.image = UIImage(named: "cell_bg_single")
				selectedBackgroundImageView.image = UIImage(named: "cell_bg_selected_single")
			default:
				break
		}
	}
}
