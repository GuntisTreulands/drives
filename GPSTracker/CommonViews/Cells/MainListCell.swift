//
//  MainListCell.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

protocol MainListCellDisplayLogic {
    func setAsCellType(cellType: CellBackgroundType)
}

class MainListCell: FontChangeTableViewCell, MainListCellDisplayLogic {

	public var cellBgType: CellBackgroundType = .single

	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet var selectedBackgroundImageView: UIImageView!
	@IBOutlet weak var separatorView: UIView!
	@IBOutlet var forwardArrow: UIImageView!
	@IBOutlet var iconRoad: UIImageView!
	@IBOutlet var iconGreenPin: UIImageView!
	@IBOutlet var iconRedPin: UIImageView!
	@IBOutlet var iconTime: UIImageView!
	@IBOutlet var distanceLabel: UILabel!
	@IBOutlet var timeLabel: UILabel!
	@IBOutlet var startAddressLabel: UILabel!
	@IBOutlet var endAddressLabel: UILabel!
	@IBOutlet var dateLabel: UILabel!
	@IBOutlet var importanceDotView: UIView!


	var bgViewBottomAnchorConstraint: NSLayoutConstraint!
	var bgViewTopAnchorConstraint: NSLayoutConstraint!

	var selectedBgViewBottomAnchorConstraint: NSLayoutConstraint!
	var selectedBgViewTopAnchorConstraint: NSLayoutConstraint!

	var iconBottomConstraint: NSLayoutConstraint!
	var forwardArrowTopConstraint: NSLayoutConstraint!

	var importanceRightOffsetFromDateConstraint: NSLayoutConstraint!
	var importanceRightOffsetFromBorderConstraint: NSLayoutConstraint!



	// MARK: View lifecycle
	
	override func awakeFromNib() {
        super.awakeFromNib()

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        selectedBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        forwardArrow.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        iconRoad.translatesAutoresizingMaskIntoConstraints = false
        iconGreenPin.translatesAutoresizingMaskIntoConstraints = false
        iconRedPin.translatesAutoresizingMaskIntoConstraints = false
        iconTime.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        startAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        endAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
		importanceDotView.translatesAutoresizingMaskIntoConstraints = false

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


		importanceDotView.backgroundColor = UIColor.init(named: "OtherStuffColor")
		importanceDotView.layer.cornerRadius = 3
		importanceDotView.clipsToBounds = true

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

		iconGreenPin.widthAnchor.constraint(equalToConstant: 18).isActive = true
		iconGreenPin.heightAnchor.constraint(equalToConstant: 16).isActive = true
		iconGreenPin.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 8).isActive = true
		iconGreenPin.topAnchor.constraint(equalTo: iconRoad.bottomAnchor, constant: 8).isActive = true

		startAddressLabel.topAnchor.constraint(equalTo: iconRoad.bottomAnchor, constant: 6).isActive = true
		startAddressLabel.leftAnchor.constraint(equalTo: iconGreenPin.rightAnchor, constant: 5).isActive = true
		startAddressLabel.rightAnchor.constraint(equalTo: forwardArrow.leftAnchor, constant: -10).isActive = true


		iconRedPin.widthAnchor.constraint(equalToConstant: 18).isActive = true
		iconRedPin.heightAnchor.constraint(equalToConstant: 16).isActive = true
		iconRedPin.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 8).isActive = true
		iconRedPin.topAnchor.constraint(equalTo: startAddressLabel.bottomAnchor, constant: 8).isActive = true

		endAddressLabel.topAnchor.constraint(equalTo: startAddressLabel.bottomAnchor, constant: 6).isActive = true
		endAddressLabel.leftAnchor.constraint(equalTo: iconRedPin.rightAnchor, constant: 5).isActive = true
		endAddressLabel.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10).isActive = true
		endAddressLabel.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -8).isActive = true;


		dateLabel.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 6).isActive = true
		dateLabel.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10).isActive = true

		importanceDotView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true
		importanceDotView.widthAnchor.constraint(equalToConstant: 6).isActive = true
		importanceDotView.heightAnchor.constraint(equalToConstant: 6).isActive = true
		importanceRightOffsetFromDateConstraint = importanceDotView.rightAnchor.constraint(equalTo: dateLabel.leftAnchor, constant: -10)
		importanceRightOffsetFromBorderConstraint = importanceDotView.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10)


		forwardArrow.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10).isActive = true
		forwardArrowTopConstraint = forwardArrow.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: -4)
		forwardArrowTopConstraint.isActive = true
		forwardArrow.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		forwardArrow.widthAnchor.constraint(equalToConstant: 21.0/2).isActive = true


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
		dateLabel.font = Font(.normal, size: .size17).font
		startAddressLabel.font = Font(.normal, size: .size17).font
		endAddressLabel.font = Font(.normal, size: .size17).font
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
				forwardArrowTopConstraint.constant = -4
				importanceRightOffsetFromBorderConstraint.isActive = false
				importanceRightOffsetFromDateConstraint.isActive = true
			case .bottom:
				self.bgViewTopAnchorConstraint?.constant = 0
				self.bgViewBottomAnchorConstraint?.constant = -5
				self.selectedBgViewTopAnchorConstraint?.constant = 0
				self.selectedBgViewBottomAnchorConstraint?.constant = -5
				self.separatorView.isHidden = true
				backgroundImageView.image = UIImage(named: "cell_bg_bottom")
				selectedBackgroundImageView.image = UIImage(named: "cell_bg_selected_bottom")
				self.dateLabel.text = ""
				forwardArrowTopConstraint.constant = -30
				importanceRightOffsetFromDateConstraint.isActive = false
				importanceRightOffsetFromBorderConstraint.isActive = true
			case .middle:
				self.bgViewTopAnchorConstraint?.constant = 0
				self.bgViewBottomAnchorConstraint?.constant = 0
				self.selectedBgViewTopAnchorConstraint?.constant = 0
				self.selectedBgViewBottomAnchorConstraint?.constant = 0
				self.separatorView.isHidden = false
				backgroundImageView.image = UIImage(named: "cell_bg_middle")
				selectedBackgroundImageView.image = UIImage(named: "cell_bg_selected_middle")
				self.dateLabel.text = ""
				forwardArrowTopConstraint.constant = -30
				importanceRightOffsetFromDateConstraint.isActive = false
				importanceRightOffsetFromBorderConstraint.isActive = true
			case .single:
				self.bgViewTopAnchorConstraint?.constant = 5
				self.bgViewBottomAnchorConstraint?.constant = -5
				self.selectedBgViewTopAnchorConstraint?.constant = 5
				self.selectedBgViewBottomAnchorConstraint?.constant = -5
				self.separatorView.isHidden = true
				backgroundImageView.image = UIImage(named: "cell_bg_single")
				selectedBackgroundImageView.image = UIImage(named: "cell_bg_selected_single")
				forwardArrowTopConstraint.constant = -4
				importanceRightOffsetFromBorderConstraint.isActive = false
				importanceRightOffsetFromDateConstraint.isActive = true
			default:
				break
		}
	}
}
