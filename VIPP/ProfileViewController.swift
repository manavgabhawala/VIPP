//
//  ProfileViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/13/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit


class ProfileViewController: UIViewController
{
	@IBOutlet var tableView: UITableView!
	@IBOutlet var bottomBar : UIView!
	var tableCells = [UITableViewCell]()
	//MARK: - ViewController Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		UIApplication.sharedApplication().statusBarStyle = .LightContent
		// Do any additional setup after loading the view.
		setupCells()
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	override func viewDidAppear(animated: Bool)
	{
		view.bringSubviewToFront(tableView)
	}
	func setTableFrame(size: CGSize)
	{
		tableView.frame = CGRect(origin: CGPointZero, size: CGSize(width: size.width, height: size.height - bottomBar.frame.height))
		println(tableView.frame)
	}
	
	//MARK: - Actions
	func logout(_: UIButton)
	{
		safeLogout()
		let initialController = storyboard!.instantiateInitialViewController() as! UIViewController
		presentViewController(initialController, animated: true, completion: nil)
	}
}
extension ProfileViewController : UITableViewDelegate, UITableViewDataSource
{
	func setupCells()
	{
		let profilePictureCell = tableView.dequeueReusableCellWithIdentifier("profileImageCell") as! ProfilePictureCell
		profilePictureCell.setup(self, action: "logout:")
		tableCells.append(profilePictureCell)
		let buttons = [	(UIImage(named: "InvitesIcon")!, "INVITES"),
						(UIImage(named: "BookingsIcon")!, "BOOKINGS"),
						//(UIImage(named: "RewardsIcon")!, "REWARDS"),
						(UIImage(named: "SettingsIcon")!, "SETTINGS"),
						(UIImage(named: "AboutIcon")!, "ABOUT") ]
		for button in buttons
		{
			let buttonCell = tableView.dequeueReusableCellWithIdentifier("buttonCell") as! ProfileButtonCell
			buttonCell.setup(button)
			tableCells.append(buttonCell)
		}
		//tableView.reloadData()
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return tableCells.count
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		return tableCells[indexPath.row]
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		let rowSize = tableView.rowHeight
		if tableCells[indexPath.row] is ProfilePictureCell
		{
			let otherRows = CGFloat(tableCells.count - 1) * rowSize
			let bottomPadding : CGFloat = 30.0
			return tableView.frame.height - otherRows - bottomPadding
		}
		return rowSize
	}
	func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath)
	{
		if tableCells[indexPath.row] is ProfileButtonCell
		{
			let cell = tableCells[indexPath.row]
			((cell.subviews.first! as! UIView).subviews as! [UIView]).map{(view: UIView) -> Void in UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: { view.alpha = 0.25 }, completion: nil)  }
		}
	}
	func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath)
	{
		if tableCells[indexPath.row] is ProfileButtonCell
		{
			let cell = tableCells[indexPath.row]
			((cell.subviews.first! as! UIView).subviews as! [UIView]).map{(view: UIView) -> Void in UIView.animateWithDuration(1.0, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: { view.alpha = 1.0 }, completion: nil)  }
		}
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		
	}
}