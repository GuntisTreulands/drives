//
//  MainListCell.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

protocol StatsListPriceCellDisplayLogic {
    func setAsCellType(cellType: CellBackgroundType)
}

class StatsListPriceCell: FontChangeTableViewCell, StatsListPriceCellDisplayLogic {

	public var cellBgType: CellBackgroundType = .single

	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet var selectedBackgroundImageView: UIImageView!
	@IBOutlet weak var separatorView: UIView!
	@IBOutlet var iconTitle: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var titleRatioLabel: UILabel!
	@IBOutlet var iconPriceMonth: UIImageView!
	@IBOutlet var titlePriceMonth: UILabel!
	@IBOutlet var iconPriceHalfYear: UIImageView!
	@IBOutlet var titlePriceHalfYear: UILabel!
	@IBOutlet var iconPriceYear: UIImageView!
	@IBOutlet var titlePriceYear: UILabel!



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

        iconTitle.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleRatioLabel.translatesAutoresizingMaskIntoConstraints = false
        iconPriceMonth.translatesAutoresizingMaskIntoConstraints = false
        titlePriceMonth.translatesAutoresizingMaskIntoConstraints = false
        iconPriceHalfYear.translatesAutoresizingMaskIntoConstraints = false
        titlePriceHalfYear.translatesAutoresizingMaskIntoConstraints = false
        iconPriceYear.translatesAutoresizingMaskIntoConstraints = false
        titlePriceYear.translatesAutoresizingMaskIntoConstraints = false


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


		iconTitle.widthAnchor.constraint(equalToConstant: 18).isActive = true
		iconTitle.heightAnchor.constraint(equalToConstant: 16).isActive = true
		iconTitle.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 8).isActive = true
		iconTitle.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 8).isActive = true

		titleLabel.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 3).isActive = true
		titleLabel.leftAnchor.constraint(equalTo: iconTitle.rightAnchor, constant: 5).isActive = true

		titleRatioLabel.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 3).isActive = true
		titleRatioLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 20).isActive = true
		titleRatioLabel.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10).isActive = true

		iconPriceMonth.widthAnchor.constraint(equalToConstant: 18).isActive = true
		iconPriceMonth.heightAnchor.constraint(equalToConstant: 16).isActive = true
		iconPriceMonth.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 8).isActive = true
		iconPriceMonth.topAnchor.constraint(equalTo: iconTitle.bottomAnchor, constant: 8).isActive = true

		titlePriceMonth.topAnchor.constraint(equalTo: iconTitle.bottomAnchor, constant: 6).isActive = true
		titlePriceMonth.leftAnchor.constraint(equalTo: iconPriceMonth.rightAnchor, constant: 5).isActive = true
		titlePriceMonth.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10).isActive = true


		iconPriceHalfYear.widthAnchor.constraint(equalToConstant: 18).isActive = true
		iconPriceHalfYear.heightAnchor.constraint(equalToConstant: 16).isActive = true
		iconPriceHalfYear.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 8).isActive = true
		iconPriceHalfYear.topAnchor.constraint(equalTo: titlePriceMonth.bottomAnchor, constant: 8).isActive = true

		titlePriceHalfYear.topAnchor.constraint(equalTo: titlePriceMonth.bottomAnchor, constant: 6).isActive = true
		titlePriceHalfYear.leftAnchor.constraint(equalTo: iconPriceHalfYear.rightAnchor, constant: 5).isActive = true
		titlePriceHalfYear.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10).isActive = true

		iconPriceYear.widthAnchor.constraint(equalToConstant: 18).isActive = true
		iconPriceYear.heightAnchor.constraint(equalToConstant: 16).isActive = true
		iconPriceYear.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 8).isActive = true
		iconPriceYear.topAnchor.constraint(equalTo: titlePriceHalfYear.bottomAnchor, constant: 8).isActive = true

		titlePriceYear.topAnchor.constraint(equalTo: titlePriceHalfYear.bottomAnchor, constant: 6).isActive = true
		titlePriceYear.leftAnchor.constraint(equalTo: iconPriceYear.rightAnchor, constant: 5).isActive = true
		titlePriceYear.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10).isActive = true
		titlePriceYear.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -8).isActive = true;


		separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
		separatorView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -1).isActive = true
		separatorView.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor).isActive = true
		separatorView.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor).isActive = true


		selectedBackgroundImageView.alpha = 0
		titleRatioLabel.alpha = 0.7

		updateFonts()
    }

	// MARK: Functions

	private func updateFonts() {
		titleLabel.font = Font(.bold, size: .size21).font
		titleRatioLabel.font = Font(.bold, size: .size21).font
		titlePriceMonth.font = Font(.normal, size: .size17).font
		titlePriceHalfYear.font = Font(.normal, size: .size17).font
		titlePriceYear.font = Font(.normal, size: .size17).font
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
