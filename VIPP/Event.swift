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
	var image = UIImage(named: "placeholder.png")
	var date = NSDate()
	var objectId : String!
	var imageURL : NSURL!
	weak var controller : ImageViewController!
	weak var club : Club?
	
	init(object: PFObject, club: Club)
	{
		self.objectId = object.objectId
		self.date = object["time"] as! NSDate
		self.description = object["description"] as! String
		self.imageURL = NSURL(string: object["image"] as! String)
		self.club = club
	}
	func loadImage()
	{
		if let URL = imageURL
		{
			let downloadRequest = NSURLRequest(URL: URL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
			NSURLConnection.sendAsynchronousRequest(downloadRequest, queue: NSOperationQueue(), completionHandler:  { (response, data, error) in
				if let image = UIImage(data: data)
				{
					self.image = image
					self.controller.imageView.image = self.image
				}
			})
		}
	}
}