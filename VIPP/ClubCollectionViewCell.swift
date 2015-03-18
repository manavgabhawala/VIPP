//
//  ClubCollectionViewCell.swift
//  VIPP
//
//  Created by Manav Gabhawala on 2/26/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class ClubCollectionViewCell: UICollectionViewCell, ImageDownloaded
{
	@IBOutlet var imageView : UIImageView!
	
	weak var club : Club!
	
	func setImage(image: UIImage)
	{
		imageView.image = image
		imageView.setNeedsDisplay()
	}
}

class FriendCollectionViewCell : UICollectionViewCell
{
	@IBOutlet var imageView : UIImageView!
	
	func setImage(fbId: String)
	{
		imageView.layer.cornerRadius = imageView.frame.width / 2
		imageView.layer.masksToBounds = true
		facebookProfilePicture(facebookId: fbId, {(response, data, error) in
			if let image = UIImage(data: data)
			{
				self.imageView.image = image
				self.imageView.setNeedsDisplay()
			}
			else
			{
				//TODO: Show error
				println(error)
			}
		})
	}
}