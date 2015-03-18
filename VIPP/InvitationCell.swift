//
//  InvitationCell.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/15/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit
import MessageUI

protocol InvitationCellDelegate
{
	func removeFacebookUser(id: String)
}
class InvitationCell: UITableViewCell, RoundedTableCells
{
	var fbId : String!
	weak var event : Event!
	@IBOutlet var nameLabel : UILabel!
	@objc var bottom = false
	@objc var top = false
	var delegate : InvitationCellDelegate?
	
	@IBAction func invite(_: UIButton!)
	{
		let query = PFUser.query()
		query.whereKey("fbId", equalTo: fbId)
		query.getFirstObjectInBackgroundWithBlock {(object, error) in
			if (error == nil)
			{
				let invitation = PFObject(className: "Invitation")
				invitation["event"] = PFObject(withoutDataWithClassName: "Event", objectId: self.event.objectId)
				invitation["invitedBy"] = PFUser.currentUser()
				invitation["invitedVIPP"] = object
				invitation.saveInBackgroundWithBlock{(result, error) in
					if (error == nil && result)
					{
						self.delegate?.removeFacebookUser(self.fbId)
					}
					else
					{
						//TODO: Show error
						println(error)
					}
				}
			}
			else
			{
				//TODO: Show error
				println(error)
			}
		}
	}
}

protocol AddressBookCellDelegate
{
	func sendMessage(number: String?)
}
class AddressBookCell: UITableViewCell, RoundedTableCells
{
	@IBOutlet var nameLabel : UILabel!
	@IBOutlet var phoneNumberLabel : UILabel!
	@objc var top = false, bottom = false
	var delegate : AddressBookCellDelegate?
	
	@IBAction func message(_: UIButton)
	{
		delegate?.sendMessage(phoneNumberLabel.text)
	}
}