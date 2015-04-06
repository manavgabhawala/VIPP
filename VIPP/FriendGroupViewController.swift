//
//  FriendGroupViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 4/4/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class FriendGroupViewController : UIViewController
{
	@IBOutlet var tableView : UITableView!
	@IBOutlet var profileCell : ProfilePictureCell!
	
	var groups = [UITableViewCell]()
	var friendGroups = [FriendGroup]()
	weak var profileViewController: ProfileViewController!
	
	var selectedIndex : Int? = nil
	{
		didSet
		{
			if (selectedIndex != nil && selectedIndex! < friendGroups.count)
			{
				profileCell.setFriendGroup(friendGroups[selectedIndex!])
				profileCell.nameLabel.text = friendGroups[selectedIndex!].name
			}
		}
	}
	
	//MARK: - ViewController Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		//getFriendGroups()
		setupCells()
		profileCell.setup(self, action: "renameCurrentGroup")
		profileCell.nameLabel.text = "Group Name"
		if let _ = friendGroups.first
		{
			selectedIndex = 0
		}
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//MARK: - Actions
	@IBAction func goBack(_: UIButton)
	{
		profileViewController.friendGroups = friendGroups
		if let friendGroup = friendGroups.first
		{
			profileViewController.profileCell.setFriendGroup(friendGroup)
		}
		dismissViewControllerAnimated(true, completion: nil)
	}
	@IBAction func addNewGroup(_: UIButton)
	{
		
	}
	func renameCurrentGroup()
	{
		
	}
	
	//MARK: - Parse Interaction
	func getFriendGroups()
	{
		let query = FriendGroup.createFriendGroupQuery()
		
		query.findObjectsInBackgroundWithBlock({(results, error) in
			if (error == nil)
			{
				self.friendGroups = (results as! [PFObject]).map { FriendGroup(object: $0) }
				self.setupCells()
			}
			else
			{
				//TODO: Show error
				println(error)
			}
		})
	}
	
}
//MARK: - TableViewStuff
extension FriendGroupViewController : UITableViewDelegate, UITableViewDataSource
{
	func setupCells()
	{
		if friendGroups.count > 0
		{
			groups = friendGroups.map {
				let cell = self.tableView.dequeueReusableCellWithIdentifier("groupCell") as! FriendGroupCell
				cell.label.text = $0.name
				return cell
			}
			if selectedIndex == nil
			{
				selectedIndex = 0
				tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .Top)
			}
		}
		else
		{
			groups = [tableView.dequeueReusableCellWithIdentifier("noResults") as! UITableViewCell]
			selectedIndex = nil
			profileCell.nameLabel.text = "Group Name"
		}
		tableView.reloadData()
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return groups.count
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		return groups[indexPath.row]
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		if friendGroups.count > 0
		{
			selectedIndex = indexPath.row
		}
		else
		{
			selectedIndex = nil
		}
		
	}
	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
	{
		if groups[indexPath.row] is FriendGroupCell
		{
			let renameRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Rename", handler: { (action, indexPath) in
				let group = self.friendGroups[indexPath.row]
				
				let alert = UIAlertController(title: "Rename Friend Group \(group.name)", message: "Please enter a new friend group name.", preferredStyle: .Alert)
				alert.addTextFieldWithConfigurationHandler({(textField) in
					textField.placeholder = "New Friend Group Name"
					textField.keyboardAppearance = .Dark
					textField.keyboardType = .Default
					textField.autocapitalizationType = .Words
					textField.addTarget(self, action: "textChanged:", forControlEvents: .EditingChanged)
				})
				
				alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
				
				let renameAction = UIAlertAction(title: "Rename", style: .Default, handler: {(action) in
					//Update the UI
					let newName = (alert.textFields!.first! as! UITextField).text
					(self.groups[indexPath.row] as! FriendGroupCell).label.text = newName
					if indexPath.row == self.selectedIndex
					{
						self.profileCell.nameLabel.text = newName
					}
					//Update the model
					group.name = newName
					//Update the server
					group.databaseObject["name"] = newName
					group.databaseObject.saveInBackgroundWithBlock(nil)
				})
				renameAction.enabled = false
				alert.addAction(renameAction)
				self.presentViewController(alert, animated: true, completion: nil)
			})
			renameRowAction.backgroundColor = UIColor(red: 0, green: 0.5, blue: 1.0, alpha: 1.0)
			
			let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Leave", handler:{ (action, indexPath) in
				self.tableView(tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
			})
			
			return [deleteRowAction, renameRowAction]
		}
		return nil
	}
	
	/**
	A function callback for when the text is changed in the Alert that allows users to add or edit friend group names.
	
	:param: sender The text field where the name of the friend group can be entered.
	*/
	func textChanged(sender: AnyObject)
	{
		let textField = sender as! UITextField
		var responder : UIResponder = textField
		while !(responder is UIAlertController)
		{
			responder = responder.nextResponder()!
		}
		let alert = responder as! UIAlertController
		(alert.actions[1] as! UIAlertAction).enabled = !(textField.text.isEmpty)
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
	{
		if (editingStyle == .Delete && groups[indexPath.row] is FriendGroupCell)
		{
			let group = friendGroups[indexPath.row]
			if group.members.count <= 1
			{
				//There are no other members so get rid of the entire group. We don't want empty groups on the database its a waste of space.
				group.databaseObject.deleteInBackgroundWithBlock(nil)
			}
			else
			{
				let object = group.databaseObject
				if let index = find(group.members.map { $0.0 }, PFUser.currentUser())
				{
					assert(index >= 0 && index < 6, "Number of members must be in the range [0, 6). Recieved \(index)")
					object.removeObjectForKey("member\(index)")
					object.saveInBackgroundWithBlock(nil)
				}
			}
			friendGroups.removeAtIndex(indexPath.row)
			groups.removeAtIndex(indexPath.row)
			if groups.count > 0
			{
				tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
			}
			else
			{
				setupCells()
				tableView.reloadData()
			}
		}
	}
}