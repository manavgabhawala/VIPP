//
//  RequestCarViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/27/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class RequestCarViewController : UIViewController
{
	@IBOutlet var tableView : UITableView!
	var event : Event!
	@IBOutlet var clubName: UILabel!
	@IBOutlet var eventDate: UILabel!
	
	var tableCells = [UITableViewCell]()
	var cars = [(image: UIImage(named: "UberBlack")!, productId: "d4abaae7-f4d6-4152-91cc-77523e8165a4", capacity: 4),
				(image: UIImage(named: "UberSUV")!, productId: "8920cb5e-51a4-4fa4-acdf-dd86c5e18ae0", capacity: 6)
		//(image: UIImage(named: "UberX")!, productId: "a1111c8c-c720-46c3-8534-2fcdd730040d", capacity: 4),
		//	(image: UIImage(named: "UberXL")!, productId: "821415d8-3bd5-4e27-9604-194e4359a449", capacity: 6)
	]
	//MARK: - ViewController Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		clubName.text = event.club?.name
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = .LongStyle
		eventDate.text = dateFormatter.stringFromDate(event.date)
		setupCells()
		// Do any additional setup after loading the view.
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	//MARK: - Actions
	@IBAction func requestCar(_: UIButton)
	{
		var date : NSDate?
		var productId = "d4abaae7-f4d6-4152-91cc-77523e8165a4"
		for cell in tableCells
		{
			if let scheduleCell = cell as? RequestScheduleCell
			{
				let dateFormatter = NSDateFormatter()
				dateFormatter.timeStyle = .ShortStyle
				date = dateFormatter.dateFromString(scheduleCell.timeLabel.text!)
			}
			if let pickerCell = cell as? CarPickerCell
			{
				productId = cars[pickerCell.pageIndex].productId
			}
		}
		if date == nil
		{
			date = NSDate(timeIntervalSinceNow: 0)
		}
		let comparison = date!.compare(NSDate(timeIntervalSinceNow: 60 * 30))
		if comparison == .OrderedSame || comparison == .OrderedAscending
		{
			
		}
		else
		{
			// TODO: Register a push notification
		}
	}
	@IBAction func goBack(_: UIButton)
	{
		dismissViewControllerAnimated(true, completion: nil)
	}
}
//MARK: - TableView Stuff
extension RequestCarViewController : UITableViewDelegate, UITableViewDataSource
{
	func setupCells()
	{
		let timeCell = tableView.dequeueReusableCellWithIdentifier("RequestScheduleCell") as! RequestScheduleCell
		timeCell.setup()
		tableCells.append(timeCell)
		let carPicker = tableView.dequeueReusableCellWithIdentifier("CarPicker") as! CarPickerCell
		carPicker.setup(cars, storyboard: storyboard)
		tableCells.append(carPicker)
		tableView.reloadData()
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 2
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return section == 0 ? 0 : tableCells.count
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		return tableCells[indexPath.row]
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		var dateText = ""
		if tableCells[indexPath.row] is RequestScheduleCell
		{
			for (i, cell) in enumerate(tableCells)
			{
				if cell is RequestSchedulePickerCell
				{
					tableCells.removeAtIndex(i)
					tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: 1)], withRowAnimation: .Right)
					return
				}
				if cell is RequestScheduleCell
				{
					dateText = (cell as! RequestScheduleCell).timeLabel.text!
				}
			}
			let pickerCell = tableView.dequeueReusableCellWithIdentifier("RequestSchedulePickerCell") as! RequestSchedulePickerCell
			pickerCell.setup(dateText)
			pickerCell.timePicker.addTarget(self, action: "dateSet:", forControlEvents: .ValueChanged)
			tableCells.insert(pickerCell, atIndex: indexPath.row + 1)
			tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: 1)], withRowAnimation: .Left)
		}
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		if tableCells[indexPath.row] is RequestSchedulePickerCell
		{
			return 178.0
		}
		if tableCells[indexPath.row] is CarPickerCell
		{
			return 300.0
		}
		return tableView.rowHeight
	}
	func dateSet(sender: UIDatePicker)
	{
		for cell in tableCells
		{
			if let scheduleCell = cell as? RequestScheduleCell
			{
				scheduleCell.timeLabel.text = scheduleCell.stringFromDate(sender.date)
			}
		}
	}
}