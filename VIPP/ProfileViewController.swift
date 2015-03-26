//
//  ProfileViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/13/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit


private enum ProfileState
{
	case Home, Invites, Bookings
}
class ProfileViewController: UIViewController
{
	@IBOutlet var tableView: UITableView!
	@IBOutlet var bottomBar : UIView!
	@IBOutlet var backButton : UIButton!
	@IBOutlet var profileCell : ProfilePictureCell!
	
	var clubs = [Club]()
	var tableCells = [UITableViewCell]()
	var mainViewCells = [ProfileButtonCell]()
	var invitesCells = [InvitedCell]()
	var bookingsCells = [BookingsCell]()
	private var currentState = ProfileState.Home
	
	//MARK: - ViewController Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		UIApplication.sharedApplication().statusBarStyle = .LightContent
		// Do any additional setup after loading the view.
		setupCells()
		profileCell.setup(self, action: "logout:")
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
	
	//MARK: - Database Interaction
	func getInvites()
	{
		let query = PFQuery(className: "Invitation")
		query.whereKey("invitedVIPP", equalTo: PFUser.currentUser())
		query.includeKey("invitedBy")
		query.includeKey("event")
		query.findObjectsInBackgroundWithBlock({(results, error) in
			if (error == nil)
			{
				for obj in results as! [PFObject]
				{
					let event = Event(object: obj["event"] as! PFObject, club: nil)
					if event.date >= NSDate(timeIntervalSinceNow: 0)
					{
						if (obj["accepted"] == nil) || (obj["accepted"] as! Bool)
						{
							let cell = self.tableView.dequeueReusableCellWithIdentifier("invitedCell") as! InvitedCell
							cell.setup(obj["invitedBy"] as! PFUser, event: Event(object: obj["event"] as! PFObject, club: nil), accepted: obj["accepted"] as? Bool, objectId: obj.objectId, delegate: self)
							self.invitesCells.append(cell)
						}
					}
				}
				if self.currentState == .Invites
				{
					self.tableCells = self.invitesCells
					self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Left)
				}
			}
			else
			{
				//TODO: Show error
				println(error)
			}
		})
	}
	func getBookings()
	{
		let query = PFQuery(className: "Bookings")
		query.whereKey("user", equalTo: PFUser.currentUser())
		query.findObjectsInBackgroundWithBlock {(results, error) in
			if (error == nil)
			{
				for obj in results as! [PFObject]
				{
					for club in self.clubs
					{
						if let event = (club.events.filter{$0.objectId == (obj["event"] as! PFObject).objectId } as [Event]).first
						{
							if event.date >= NSDate(timeIntervalSinceNow: 0)
							{
								let cell = self.tableView.dequeueReusableCellWithIdentifier("bookingCell") as! BookingsCell
								if let image = club.photos.first
								{
									cell.setup(forEvent: event, image: image)
								}
								else
								{
									cell.setup(forEvent: event, imageURL: club.photoURLS.first!)
								}
								self.bookingsCells.append(cell)
							}
						}
					}
					
				}
				if self.currentState == .Bookings
				{
					self.tableCells = self.bookingsCells
					self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Left)
				}
			}
			else
			{
				//TODO: Show error
				println(error)
			}
		}
	}
	
	//MARK: - Actions
	func showInvites()
	{
		backButton.hidden = false
		currentState = .Invites
		tableCells = invitesCells
		tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Left)
	}
	func showBookings()
	{
		backButton.hidden = false
		currentState = .Bookings
		tableCells = bookingsCells
		tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Left)
	}
	func showSettings()
	{
		let alertController = UIAlertController(title: "No Settings Available", message: "Currently, we do not have any customizable settings. We are working very hard to include these in future releases.", preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}
	func showAbout()
	{
		let termsAndConditions = storyboard!.instantiateViewControllerWithIdentifier("TermsAndConditions") as! UINavigationController
		presentViewController(termsAndConditions, animated: true, completion: nil)
	}
	func logout(_: UIButton)
	{
		let alertController = UIAlertController(title: "Log Out?", message: "Do you really wish to log out?", preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Log Out", style: .Destructive, handler: {(action) in
			safeLogout()
			let initialController = self.storyboard!.instantiateInitialViewController() as! UIViewController
			self.presentViewController(initialController, animated: true, completion: nil)
		}))
		presentViewController(alertController, animated: true, completion: nil)
	}
	@IBAction func goBack(sender: UIButton)
	{
		if currentState != .Home
		{
			sender.hidden = true
			currentState = .Home
			tableCells = mainViewCells
			tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Right)
		}
	}
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		backButton.hidden = true
	}
}
extension ProfileViewController : InvitedCellDelegate
{
	func deleteCell(sender: UITableViewCell)
	{
		if let indexPath = tableView.indexPathForCell(sender)
		{
			tableCells.removeAtIndex(indexPath.row)
			invitesCells.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
		}
	}
}
extension ProfileViewController : UITableViewDelegate, UITableViewDataSource
{
	func setupCells()
	{
		let buttons =  [	(UIImage(named: "InvitesIcon")!, "INVITES", Selector("showInvites")),
						(UIImage(named: "BookingsIcon")!, "BOOKINGS", Selector("showBookings")),
						//(UIImage(named: "RewardsIcon")!, "REWARDS"),
						(UIImage(named: "SettingsIcon")!, "SETTINGS", Selector("showSettings")),
						(UIImage(named: "AboutIcon")!, "ABOUT", Selector("showAbout")) ]
		for button in buttons
		{
			let buttonCell = tableView.dequeueReusableCellWithIdentifier("buttonCell") as! ProfileButtonCell
			buttonCell.setup(button, target: self)
			mainViewCells.append(buttonCell)
		}
		tableCells = mainViewCells
		tableView.reloadData()
		getInvites()
		getBookings()
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 2
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return section == 0 ? 0 : tableCells.count == 0 ? 1 : tableCells.count
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		return indexPath.row < tableCells.count ? tableCells[indexPath.row] : tableView.dequeueReusableCellWithIdentifier("noResults") as! UITableViewCell
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		if (tableCells.count > indexPath.row && tableCells[indexPath.row] is BookingsCell)
		{
			return 140.0
		}
		return tableView.rowHeight
	}
	func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath)
	{
		if (currentState == .Home && tableCells[indexPath.row] is ProfileButtonCell)
		{
			let cell = tableCells[indexPath.row]
			((cell.subviews.first! as! UIView).subviews as! [UIView]).map{(view: UIView) -> Void in UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: { view.alpha = 0.25 }, completion: nil)  }
		}
		
	}
	func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath)
	{
		if currentState == .Home && tableCells[indexPath.row] is ProfileButtonCell
		{
			let cell = tableCells[indexPath.row]
			((cell.subviews.first! as! UIView).subviews as! [UIView]).map{(view: UIView) -> Void in UIView.animateWithDuration(1.0, delay: 0.25, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: { view.alpha = 1.0 }, completion: nil)  }
		}
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		if currentState == .Home, let cell = tableCells[indexPath.row] as? ProfileButtonCell
		{
			cell.didTap()
		}
		if currentState == .Bookings && tableCells.count > indexPath.row, let event = (tableCells[indexPath.row] as? BookingsCell)?.event
		{
			println(event.description)
		}
	}
}