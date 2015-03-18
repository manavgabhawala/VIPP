//
//  Event.swift
//  VIPP
//
//  Created by Manav Gabhawala on 2/26/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import Foundation

class Club
{
	var name : String
	var logo: UIImage?
	var location : PFGeoPoint
	var photoURLS : [NSURL?]
	var logoDelegate : ImageDownloaded?
	var photos = [UIImage]()
	var events = [Event]()
	var objectId : String?
	var photosDelegate : [ImageDownloaded?]?
	{
		didSet
		{
			for (i, photo) in enumerate(photos)
			{
				if i < photosDelegate?.count
				{
					photosDelegate?[i]?.setImage(photo)
				}
			}
		}
	}
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
					dispatch_async(dispatch_get_main_queue(), {
						self.logoDelegate?.setImage(image)
						self.getPhotos()
						self.logo = image
					})
					
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
	func getPhotos()
	{
		for (i, photoURL) in enumerate(photoURLS)
		{
			if let URL = photoURL
			{
				let downloadRequest = NSURLRequest(URL: URL, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 30.0)
				NSURLConnection.sendAsynchronousRequest(downloadRequest, queue: NSOperationQueue(), completionHandler: { (response, data, error) in
					if error == nil
					{
						if let image = UIImage(data: data)
						{
							if self.photos.count > i
							{
								self.photos[i] = image
							}
							else
							{
								while i != self.photos.count
								{
									self.photos.append(UIImage(named: "placeholder.png")!)
									//Add an empty image for all the other images.
								}
								self.photos.append(image)
							}
							if (self.photosDelegate?.count > i)
							{
								self.photosDelegate?[i]?.setImage(image)
							}
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
				println(error)
			}
		}
	}
}