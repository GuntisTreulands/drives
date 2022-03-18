//
//  StatsLayoutView.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

protocol StatsLayoutViewLogic: AnyObject {

}

protocol StatsLayoutViewDataLogic: AnyObject {
	func adjustVisibilityOfShadowLines()
	func updateData(data: [[MainList.FetchDrives.ViewModel.DisplayedCellItem]])
	func resetUI()
	func scrollToTop()
	func dismissAnyActiveCell()
	func adjustNoDataLabelText()
}


class StatsLayoutView: UIView, UITableViewDataSource, UITableViewDelegate, StatsLayoutViewDataLogic {

	weak var controller: StatsLayoutViewLogic?
	weak var superParentView: UIView!

	var selectedCellIndexPath: IndexPath?

	@IBOutlet var baseView: UIView!
	@IBOutlet weak var tableViewNoDataView: TableViewNoDataView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var tableViewTopShadow: UIImageView!
	@IBOutlet weak var tableViewBottomShadow: UIImageView!

	var data = [[MainList.FetchDrives.ViewModel.DisplayedCellItem]]()

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
		tableViewNoDataView.translatesAutoresizingMaskIntoConstraints = false
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableViewTopShadow.translatesAutoresizingMaskIntoConstraints = false
		tableViewBottomShadow.translatesAutoresizingMaskIntoConstraints = false


		baseView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		baseView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true


		tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		tableView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
		tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true //, constant: -49

		tableViewNoDataView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		tableViewNoDataView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		tableViewNoDataView.topAnchor.constraint(equalTo: topAnchor, constant: 60).isActive = true

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
    	let nib = UINib(nibName: "MainListCell", bundle: nil)
    	tableView.register(nib, forCellReuseIdentifier: "cell")
    	let nibHeader = UINib(nibName: "MainListHeaderView", bundle: nil)
		self.tableView.register(nibHeader, forHeaderFooterViewReuseIdentifier: "header")
    	tableView.backgroundColor = .clear


		tableViewNoDataView.alpha = 0
		adjustNoDataLabelText()
  	}

  	// MARK: Table view

	func numberOfSections(in tableView: UITableView) -> Int {
		return data.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data[section].count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(
		   withIdentifier: "cell",
		   for: indexPath
		) as? MainListCell {

			if(self.data.count-1 >= indexPath.section && self.data[indexPath.section].count-1 >= indexPath.row) {
				let aData = self.data[indexPath.section][indexPath.row]

				cell.dateLabel.text = aData.dateString

				cell.importanceDotView.alpha = aData.isBusinessType ? 0 : 1

				cell.distanceLabel.text = HelperWorker.distanceFromMeters(aData.distance)
				cell.timeLabel.text = HelperWorker.timeFromSeconds(Int(aData.time))
				cell.startAddressLabel.text = aData.startAddress
				cell.endAddressLabel.text = aData.endAddress


				cell.selectionStyle = .none

				if self.data[indexPath.section].count == 1 {
					cell.setAsCellType(cellType: .single)
				} else {
					if aData.numberOfDrives == 1 {
						cell.setAsCellType(cellType: .single)
					} else {
						if aData.thisDriveIndex == 0 {
							cell.setAsCellType(cellType: .top)
						} else if aData.thisDriveIndex == aData.numberOfDrives-1 {
							cell.setAsCellType(cellType: .bottom)
						} else {
							cell.setAsCellType(cellType: .middle)
						}
					}
				}
			}

			return cell
		}
		else {
//			// Problem
			return UITableViewCell()
		}
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

		let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! MainListHeaderView

		let aData = self.data[section].first!

		var combinedTime: Double = 0
		var combinedDistance: Double = 0

		for drive in self.data[section] {
			combinedTime += drive.time
			combinedDistance += drive.distance
		}

		header.titleLabel.text = aData.monthName
		header.timeLabel.text = HelperWorker.timeFromSeconds(Int(combinedTime))
		header.distanceLabel.text = HelperWorker.distanceFromMeters(combinedDistance)

		header.setSectionIndex(section)

        return header
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

	// MARK: MainListLayoutViewDataLogic

	func adjustVisibilityOfShadowLines() {
		let alfa = min(25, max(0, tableView.contentOffset.y-15+12))/25
		tableViewTopShadow.alpha = alfa

//		print("alfa \(alfa)")
		let value = tableView.contentOffset.y+tableView.frame.size.height-tableView.contentInset.bottom-tableView.contentInset.top+15
		let alfa2 = min(25, max(0, tableView.contentSize.height-value))/25
		tableViewBottomShadow.alpha = alfa2
	}

	func updateData(data: [[MainList.FetchDrives.ViewModel.DisplayedCellItem]]) {

		self.data = data
		tableView.reloadData()

		self.adjustVisibilityOfShadowLines()

		if self.data.isEmpty {
			self.tableViewNoDataView.alpha = 1
			self.tableView.isScrollEnabled = false
		} else {
			self.tableViewNoDataView.alpha = 0
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

	func adjustNoDataLabelText() {
		self.tableViewNoDataView.set(title: "stats_no_data".localized(), loadingEnabled: false)
	}
}
