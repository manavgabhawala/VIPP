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
	func imageLoaded(image: UIImage?)
}

class Club
{
	var name : String
	var logo: UIImage?
	var location : PFGeoPoint
	var photos : [NSURL?]
	var delegate : ClubDelegate?
	
	init(name: String, url: NSURL?, location: PFGeoPoint, photos: [String])
	{
		self.name = name
		self.location = location
		self.photos = photos.map { NSURL(string: $0) }
	}
}