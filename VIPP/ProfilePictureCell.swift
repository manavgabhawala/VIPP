//
//  ProfilePictureCell.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/13/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit
import MobileCoreServices

class ProfilePictureCell: UITableViewCell
{
	@IBOutlet var backImage: UIImageView!
	@IBOutlet var profilePicture : UIImageView!
	@IBOutlet var nameLabel : UILabel!
	@IBOutlet var logoutButton : UIButton!
	
	func setup(target: AnyObject?, action: Selector)
	{
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
			let fileManager = NSFileManager()
			if let image = UIImage(contentsOfFile: profilePictureLocation) where fileManager.fileExistsAtPath(profilePictureLocation)
			{
				profilePicture.image = image
			}
			else
			{
				if let fbId = user["fbId"] as? String
				{
					facebookProfilePicture(facebookId: fbId, {(response, data, error) in
						if (error == nil)
						{
							if let image = UIImage(data: data)
							{
								self.profilePicture.image = image
								self.profilePicture.setNeedsDisplay()
								if let data = UIImagePNGRepresentation(image)
								{
									data.writeToFile(profilePictureLocation, atomically: true)
								}
							}
						}
					})
				}
			}
		}
	}
}
