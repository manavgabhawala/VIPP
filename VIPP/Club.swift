//
//  Event.swift
//  VIPP
//
//  Created by Manav Gabhawala on 2/26/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import Foundation

protocol ClubDelegate
{
	func setImage(image: UIImage)
}

class Club
{
	var name : String
	var logo: UIImage?
	var location : PFGeoPoint
	var photoURLS : [NSURL?]
	var delegate : ClubDelegate?
	var photos = [UIImage]()
	var events = [Event]()
	
	init(name: String, url: NSURL?, location: PFGeoPoint, photos: [String])
	{
		self.name = name
		self.location = location
		self.photoURLS = photos.map { NSURL(string: $0) }
		if let logoURL = url
		{
			let downloadRequest = NSURLRequest(URL: logoURL, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 30.0)
			NSURLConnection.sendAsynchronousRequest(downloadRequest, queue: NSOperationQueue(), completionHandler:  { (response, data, error) in
				if let image = UIImage(data: data)
				{
					self.logo = image
					self.delegate?.setImage(image)
				}
			})
			
		}
	}
	convenience init(object: PFObject)
	{
		self.init(name: object["name"] as! String, url: NSURL(string: object["logo"] as! String), location: object["geoLocation"] as! PFGeoPoint, photos: object["photos"] as! [String])
		findEvents(object, force: false)
	}
	func findEvents(object: PFObject, force: Bool)
	{
		let eventsQuery = object.relationForKey("events").query()
		eventsQuery.findObjectsInBackgroundWithBlock { (results, error) in
			if (results != nil && error == nil)
			{
				self.events = (results as! [PFObject]).map  { Event(object: $0) }
			}
			else
			{
				if force
				{
					//TODO: Do something catastrophic here.
				}
			}
		}
	}
}