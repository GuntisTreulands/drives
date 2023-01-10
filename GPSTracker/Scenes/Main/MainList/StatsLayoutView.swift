//
//  StatsLayoutView.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

protocol StatsLayoutViewLogic: AnyObject {
	func segmentButtonIndexChanged(_ index: Int)
}

protocol StatsLayoutViewDataLogic: AnyObject {
	func adjustVisibilityOfShadowLines()
	func updateData(data: [[MainList.FetchStats.ViewModel.StatsCellItem]], statsShowType: MainList.StatsShowType)
	func resetUI()
	func scrollToTop()
	func dismissAnyActiveCell()
}


class StatsLayoutView: UIView, UITableViewDataSource, UITableViewDelegate, StatsLayoutViewDataLogic, StatsSegmentHeaderViewButtonLogic {

	weak var controller: StatsLayoutViewLogic?
	weak var superParentView: UIView!

	var selectedCellIndexPath: IndexPath?
	var statsShowType: MainList.StatsShowType!

	@IBOutlet var baseView: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var tableViewTopShadow: UIImageView!
	@IBOutlet weak var tableViewBottomShadow: UIImageView!

	var heightConstraint: NSLayoutConstraint!

	var data = [[MainList.FetchStats.ViewModel.StatsCellItem]]()

	// MARK: View lifecycle

	override init(frame: CGRect) {
   	super.init(frame: frame)
		setup()
  	}

  	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
    	setup()
	}

	deinit {

	}

	override func layoutSubviews() {
		adjustVisibilityOfShadowLines()
		super.layoutSubviews()
	}

	private func setup() {
		Bundle.main.loadNibNamed("StatsLayoutView", owner: self, options: nil)
		addSubview(baseView)
		baseView.frame = self.bounds

		self.translatesAutoresizingMaskIntoConstraints = false
		baseView.translatesAutoresizingMaskIntoConstraints = false
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableViewTopShadow.translatesAutoresizingMaskIntoConstraints = false
		tableViewBottomShadow.translatesAutoresizingMaskIntoConstraints = false


		baseView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		baseView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true


		tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		tableView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
		tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true



		tableViewTopShadow.heightAnchor.constraint(equalToConstant: 3).isActive = true
		tableViewTopShadow.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		tableViewTopShadow.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		tableViewTopShadow.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true

		tableViewBottomShadow.heightAnchor.constraint(equalToConstant: 3).isActive = true
		tableViewBottomShadow.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		tableViewBottomShadow.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		tableViewBottomShadow.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true


		tableView.delegate = self
    	tableView.dataSource = self
    	tableView.contentInset = UIEdgeInsets(top: 17, left: 0, bottom: -17, right: 0)

    	let nib1 = UINib(nibName: "StatsListPriceCell", bundle: nil)
    	tableView.register(nib1, forCellReuseIdentifier: "cell1")

    	let nib2 = UINib(nibName: "StatsListYearCell", bundle: nil)
    	tableView.register(nib2, forCellReuseIdentifier: "cell2")

    	let nibHeader = UINib(nibName: "MainListHeaderView", bundle: nil)
		self.tableView.register(nibHeader, forHeaderFooterViewReuseIdentifier: "header")

		let nibSegmentHeader = UINib(nibName: "StatsSegmentHeaderView", bundle: nil)
		self.tableView.register(nibSegmentHeader, forHeaderFooterViewReuseIdentifier: "segmentHeader")

    	tableView.backgroundColor = .clear
  	}

  	// MARK: Table view

	func numberOfSections(in tableView: UITableView) -> Int {
		return data.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data[section].count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let aData = self.data[indexPath.section][indexPath.row]

		if aData.statsCellType == .year {

			if let cell = tableView.dequeueReusableCell(
			   withIdentifier: "cell2",
			   for: indexPath
			) as? StatsListYearCell {

				var yearString = "stats_drives_days_in_year".localized()
				yearString = yearString.replacingOccurrences(of: "xxx", with: "\(aData.driveDaysInAYear)")
				yearString = yearString.replacingOccurrences(of: "yyy", with: "\(aData.drivesInAYear)")

				var monthString = "stats_drives_days_in_month".localized()
				monthString = monthString.replacingOccurrences(of: "xxx", with: String(format: "%.01f", aData.avgMonthDays))
				monthString = monthString.replacingOccurrences(of: "yyy", with: String(format: "%.01f", aData.avgMonthDrives))

				var weekString = "stats_drives_days_in_week".localized()
				weekString = weekString.replacingOccurrences(of: "xxx", with: String(format: "%.01f", aData.avgWeekDays))
				weekString = weekString.replacingOccurrences(of: "yyy", with: String(format: "%.01f", aData.avgWeekDrives))

				cell.distanceLabel.text = HelperWorker.distanceFromMeters(aData.yearDistance)
				cell.timeLabel.text = HelperWorker.timeFromSeconds(Int(aData.yearTime))
				cell.cal1Text.text = yearString
				cell.cal2Text.text = monthString
				cell.cal3Text.text = weekString

				cell.selectionStyle = .none
				cell.setAsCellType(cellType: .single)

				return cell
			}
		} else {

			if let cell = tableView.dequeueReusableCell(
			   withIdentifier: "cell1",
			   for: indexPath
			) as? StatsListPriceCell {

				cell.titleLabel.text = aData.title

				if Int(aData.avgMonthCost) == 0 {
					cell.titlePriceMonth.text = "-"
					cell.titlePriceHalfYear.text = "-"
					cell.titlePriceYear.text = "-"
					cell.titleRatioLabel.text = ""
				} else {
					var monthString = "stats_avg_month_eur".localized()
					monthString = monthString.replacingOccurrences(of: "xxx", with: "\(String(format: "%.01f", aData.avgMonthCost))")

					var halfYearString = "stats_avg_half_year_eur".localized()
					halfYearString = halfYearString.replacingOccurrences(of: "xxx", with: "\(String(format: "%.01f", aData.avgHalfYearCost))")

					var yearString = "stats_avg_year_eur".localized()
					yearString = yearString.replacingOccurrences(of: "xxx", with: "\(String(format: "%.01f", aData.avgYearCost))")

					cell.titlePriceMonth.text = monthString
					cell.titlePriceHalfYear.text = halfYearString
					cell.titlePriceYear.text = yearString
					cell.titleRatioLabel.text = aData.ratioText
				}

				cell.selectionStyle = .none

				if indexPath.row == 0 {
					cell.setAsCellType(cellType: .top)
				} else if indexPath.row == self.data[indexPath.section].count-1 {
					cell.setAsCellType(cellType: .bottom)
				} else {
					cell.setAsCellType(cellType: .middle)
				}

				return cell
			}
		}

		// Problem
		return UITableViewCell()
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

		if section == 0 {
			let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! MainListHeaderView

			header.titleLabel.text = "stats_year_interval".localized()
			header.timeLabel.text = " "
			header.distanceLabel.text = ""
			header.iconTime.isHidden = true
			header.iconRoad.isHidden = true

			header.setSectionIndex(section)

			return header
		} else {
			let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "segmentHeader") as! StatsSegmentHeaderView
			header.controller = self
			header.setSelectedIndex(self.statsShowType.rawValue)
			return header
		}
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		selectedCellIndexPath = indexPath
	}

  	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		adjustVisibilityOfShadowLines()
	}

	// MARK: Functions

	@objc private func nextButtonPressed() {

  	}

	// MARK: StatsListLayoutViewDataLogic

	func adjustVisibilityOfShadowLines() {

		let alfa = min(25, max(0, tableView.contentOffset.y-15+12))/25
		tableViewTopShadow.alpha = alfa

		let value = tableView.contentOffset.y+tableView.frame.size.height-tableView.contentInset.bottom-tableView.contentInset.top+15
		let alfa2 = min(25, max(0, tableView.contentSize.height-value))/25
		tableViewBottomShadow.alpha = alfa2
	}

	func updateData(data: [[MainList.FetchStats.ViewModel.StatsCellItem]], statsShowType: MainList.StatsShowType) {

		self.statsShowType = statsShowType
		self.data = data
		tableView.reloadData()

		self.adjustVisibilityOfShadowLines()

		if self.data.isEmpty {
			self.tableView.isScrollEnabled = false
		} else {
			self.tableView.isScrollEnabled = true
		}

		DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
			self.adjustVisibilityOfShadowLines()
		}
	}


	func resetUI() {
		tableView.reloadData()
	}


	func scrollToTop() {
		tableView.setContentOffset(CGPoint.init(x: 0, y: tableView.contentInset.top * -1), animated: false)
	}

	func dismissAnyActiveCell() {
		if let indexPath = selectedCellIndexPath {
			let cell = tableView.cellForRow(at: indexPath)
			cell?.setSelected(false, animated: true)
		}
	}

	// MARK: StatsSegmentHeaderViewButtonLogic

	func segmentButtonIndexChanged(_ index: Int) {
		self.controller?.segmentButtonIndexChanged(index)
	}
}
