//
//  FriendGroup.swift
//  VIPP
//
//  Created by Manav Gabhawala on 4/4/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import Foundation

protocol FriendGroupDelegate
{
	func modelDidUpdate()
}

class FriendGroup
{
	var name: String
	var members : [(PFUser, UIImage?)]
	var delegate: FriendGroupDelegate?
	var databaseObject : PFObject!
	
	static let maximumGroupSize = 6

	private init(name: String, members: [PFUser?])
	{
		self.name = name
		self.members = members.filter{ $0 != nil }.map { ($0!, nil) }
	}
	
	convenience init(object: PFObject)
	{
		let members = (0..<FriendGroup.maximumGroupSize).map { object["member\($0)"] as? PFUser }
		self.init(name: object["name"] as! String, members: members)
		databaseObject = object
		downloadImages()
	}
	
	func downloadImages()
	{
		for (i, member) in enumerate(members)
		{
			if let fbId = member.0["fbId"] as? String
			{
				if member.1 == nil
				{
					facebookProfilePicture(facebookId: fbId, size: "small", block: {(response, data, error) in
						if (error == nil)
						{
							if let image = UIImage(data: data)
							{
								self.members[i].1 = image
								self.delegate?.modelDidUpdate()
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
	}
	
	class func createFriendGroupQuery() -> PFQuery
	{
		var memberQueries = [PFQuery]()
		for i in 0..<maximumGroupSize
		{
			let query = PFQuery(className: "FriendGroup")
			query.whereKey("member\(i)", equalTo: PFUser.currentUser())
			memberQueries.append(query)
		}
		let query = PFQuery.orQueryWithSubqueries(memberQueries)
		for i in 0..<maximumGroupSize
		{
			query.includeKey("member\(i)")
		}
		return query
	}
}