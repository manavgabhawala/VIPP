//
//  ProfilePictureCell.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/13/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit
import MobileCoreServices

class ProfilePictureCell: UIView
{
	@IBOutlet var backImage: UIImageView!
	@IBOutlet var profilePicture : UIImageView!
	@IBOutlet var nameLabel : UILabel!
	@IBOutlet var logoutButton : UIButton! //This can also be the rename button
	
	@IBOutlet var friend1 : FriendImage!
	@IBOutlet var friend2 : FriendImage!
	@IBOutlet var friend3 : FriendImage!
	@IBOutlet var friend4 : FriendImage!
	@IBOutlet var friend5 : FriendImage!
	
	weak var friendGroup : FriendGroup?
	
	func setup(target: AnyObject?, action: Selector)
	{
		let tapGesture = UITapGestureRecognizer(target: self, action: "tapGesture:")
		addGestureRecognizer(tapGesture)
		let friends = [friend1, friend2, friend3, friend4, friend5]
		for friend in friends
		{
			friend.layer.cornerRadius = friend.frame.width / 2
			friend.layer.borderWidth = 1.0
			friend.layer.borderColor = UIColor.whiteColor().CGColor
			friend.layer.masksToBounds = true
			//TODO: Set to + button.
		}
		
		//Shape into a circle and add nice border
		profilePicture.layer.cornerRadius = profilePicture.frame.width / 2
		profilePicture.layer.borderWidth = 1.0
		profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
		profilePicture.layer.masksToBounds = true
		//TODO: Ensure that profile picture image is initialized to some default image.
		if let user = PFUser.currentUser()
		{
			let name = (user["firstName"] as? String ?? "") + " " + (user["lastName"] as? String ?? "")
			nameLabel.text = name
			logoutButton.addTarget(target, action: action, forControlEvents: .TouchUpInside)
			if let image = UIImage(contentsOfFile: profilePictureLocation)
			{
				profilePicture.image = image
			}
			else
			{
				if let fbId = user["fbId"] as? String
				{
					facebookProfilePicture(facebookId: fbId, size: "normal", block: {(response, data, error) in
						if (error == nil)
						{
							if let image = UIImage(data: data)
							{
								self.profilePicture.image = image
								self.profilePicture.setNeedsDisplay()
								if let imageData = UIImagePNGRepresentation(image)
								{
									let fileManager = NSFileManager()
									fileManager.removeItemAtPath(profilePictureLocation, error: nil)
									imageData.writeToFile(profilePictureLocation, atomically: true)
								}
							}
						}
					})
				}
			}
		}
	}
	
	func tapGesture(sender: UITapGestureRecognizer)
	{
		let friends = [friend1, friend2, friend3, friend4, friend5]
		let location = sender.locationInView(self)
		for friend in friends
		{
			if friend.frame.contains(location) && !friend.friendExists
			{
				println(friend)
			}
		}
	}
	
	func setFriendGroup(friendGroup: FriendGroup)
	{
		self.friendGroup = friendGroup
		self.friendGroup?.delegate = self
		updateFriendGroupImages()
	}
	
	func updateFriendGroupImages()
	{
		let friends = [friend1, friend2, friend3, friend4, friend5]
		var currentIndex = 0
		if let group = friendGroup
		{
			for member in group.members
			{
				if member.0.objectId != PFUser.currentUser().objectId
				{
					if member.1 != nil
					{
						friends[currentIndex].image = member.1
						friends[currentIndex].setNeedsDisplay()
						friends[currentIndex].friendExists = true
						++currentIndex
					}
				}
			}
		}
	}
}
extension ProfilePictureCell : FriendGroupDelegate
{
	func modelDidUpdate()
	{
		updateFriendGroupImages()
	}
}
