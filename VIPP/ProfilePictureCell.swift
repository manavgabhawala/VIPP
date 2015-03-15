//
//  ProfilePictureCell.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/13/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class ProfilePictureCell: UITableViewCell
{
	@IBOutlet var backImage: UIImageView!
	@IBOutlet var profilePicture : UIImageView!
	@IBOutlet var nameLabel : UILabel!
	@IBOutlet var viewProfileButton : UIButton!
	
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
			viewProfileButton.addTarget(target, action: action, forControlEvents: .TouchUpInside)
			if let fbId = user["fbId"] as? String
			{
				let profilePictureURL = NSURL(string: "https://graph.facebook.com/\(fbId)/picture?type=large&return_ssl_resources=1")!
				let request = NSURLRequest(URL: profilePictureURL)
				NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {(response, data, error) in
					if (error == nil)
					{
						if let image = UIImage(data: data)
						{
							//TODO: Add a cache for the profile picture.
							self.profilePicture.image = image
							self.profilePicture.setNeedsDisplay()
						}
					}
				})
			}
		}
	}
}
