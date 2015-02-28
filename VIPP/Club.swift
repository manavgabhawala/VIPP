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
}