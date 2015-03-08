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
	var objectId : String?
	
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
		self.objectId = object.objectId
		findEvents(force: false)
	}
	func findEvents(#force: Bool)
	{
		let eventsQuery = PFQuery(className: "Event")
		if let objId = objectId
		{
			eventsQuery.whereKey("club", equalTo: PFObject(withoutDataWithClassName: "Club", objectId: objId))
		}
		eventsQuery.whereKey("time", greaterThanOrEqualTo: NSDate(timeIntervalSinceNow: 0))
		eventsQuery.findObjectsInBackgroundWithBlock { (results, error) in
			if (results != nil && error == nil)
			{
				self.events = (results as! [PFObject]).map  { Event(object: $0, club: self) }
			}
			else
			{
				//TODO: Show error
			}
		}
	}
}