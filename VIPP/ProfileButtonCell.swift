//
//  ProfileButtonCell.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/13/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class ProfileButtonCell: UITableViewCell
{
	@IBOutlet var button : UILabel!
	@IBOutlet var icon : UIImageView!
	weak var tapTarget : AnyObject?
	var tapAction : Selector?
	
	func setup(information: (UIImage, String, Selector), target: AnyObject!)
	{
		icon.image = information.0
		button.text = information.1
		tapAction = information.2
		tapTarget = target
	}
	func didTap()
	{
		if tapTarget != nil && tapAction != nil
		{
			NSTimer.scheduledTimerWithTimeInterval(0.0, target: tapTarget!, selector: tapAction!, userInfo: nil, repeats: false)
		}
	}
}
protocol InvitedCellDelegate
{
	func deleteCell(sender: UITableViewCell)
}
class InvitedCell : UITableViewCell
{
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var picture: UIImageView!
	@IBOutlet var accepted : UIButton!
	@IBOutlet var declined : UIButton!
	var objectId : String!
	var delegate : InvitedCellDelegate?
	func setup(invitedBy: PFUser, event: Event, accepted: Bool?, objectId: String, delegate: InvitedCellDelegate)
	{
		self.objectId = objectId
		self.delegate = delegate
		let name = (invitedBy["firstName"] as? String ?? "") + " " + (invitedBy["lastName"] as? String ?? "")
		nameLabel.text = name + " invited you to " + event.description
		picture.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
		picture.layer.cornerRadius = picture.frame.width / 2
		picture.layer.masksToBounds = true
		picture.clipsToBounds = true
		if let fbId = invitedBy["fbId"] as? String
		{
			facebookProfilePicture(facebookId: fbId, size: "square", block: {(response, data, error) in
				if (error == nil)
				{
					if let image = UIImage(data: data)
					{
						self.picture.image = image
						self.picture.setNeedsDisplay()
					}
				}
			})
		}
		if let accept = accepted
		{
			if accept
			{
				self.accepted.setImage(UIImage(named: "Attending")!, forState: .Normal)
			}
		}
	}
	@IBAction func accept(_: UIButton)
	{
		let object = PFQuery.getObjectOfClass("Invitation", objectId: objectId)
		object["accepted"] = true
		object.saveEventually({(result, error) in
			if (error == nil && result)
			{
				self.accepted.setImage(UIImage(named: "Attending")!, forState: .Normal)
			}
			else
			{
				//TODO: Show error
				println(error)
			}
		})
	}
	@IBAction func decline(_: UIButton)
	{
		let object = PFQuery.getObjectOfClass("Invitation", objectId: objectId)
		object["accepted"] = false
		object.saveEventually({(result, error) in
			if (error == nil && result)
			{
				self.delegate?.deleteCell(self)
			}
			else
			{
				//TODO: Show error
				println(error)
			}
		})
	}
}

class BookingsCell : UITableViewCell
{
	@IBOutlet var backImage : UIImageView!
	
}
