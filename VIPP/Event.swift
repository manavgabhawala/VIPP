//
//  Event.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/3/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import Foundation

class Event
{
	var description = ""
	var image = UIImage(named: "Loading-Event")
	var date = NSDate()
	var objectId : String!
	var imageURL : NSURL!
	weak var club : Club?
	var delegate: ImageDownloaded?
	var friends = [Bool, String]()
	init(object: PFObject, club: Club?)
	{
		self.objectId = object.objectId
		self.date = object["time"] as! NSDate
		self.description = object["description"] as! String
		self.imageURL = NSURL(string: object["image"] as! String)
		self.club = club
		if club != nil
		{
			getFriendInfo(nil)
		}
	}
	func loadImage()
	{
		if let URL = imageURL
		{
			let downloadRequest = NSURLRequest(URL: URL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
			NSURLConnection.sendAsynchronousRequest(downloadRequest, queue: NSOperationQueue(), completionHandler:  { (response, data, error) in
				if (error == nil)
				{
					if let image = UIImage(data: data)
					{
						self.image = image
						self.delegate?.setImage(image)
					}
				}
				else
				{
					//TODO: Show error
					println(error)
				}
			})
		}
	}
	func getFriendInfo(completion: (() -> Void)?)
	{
		let query = PFQuery(className: "Invitation")
		query.whereKey("event", equalTo: PFObject(withoutDataWithClassName: "Event", objectId: objectId))
		query.whereKey("invitedBy", equalTo: PFUser.currentUser())
		query.whereKey("accepted", notEqualTo: false)
		query.includeKey("invitedVIPP")
		query.findObjectsInBackgroundWithBlock {(results, error) in
			if (error == nil)
			{
				self.friends = (results as! [PFObject]).map {
					let user = $0["invitedVIPP"] as! PFUser
					if let fbId = user["fbId"] as? String
					{
						return (true, fbId)
					}
					else
					{
						return (false, (user["firstName"] as? String ?? "") + " " + (user["lastName"] as? String ?? ""))
					}
				}
				completion?()
			}
			else
			{
				//TODO: Show error
				println(error)
			}
		}
	}
}