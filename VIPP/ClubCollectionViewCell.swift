//
//  ClubCollectionViewCell.swift
//  VIPP
//
//  Created by Manav Gabhawala on 2/26/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class ClubCollectionViewCell: UICollectionViewCell, ClubDelegate
{
	@IBOutlet var label : UILabel!
	@IBOutlet var imageView : UIImageView!
	
	func imageLoaded(image: UIImage?)
	{
		if let actualImage = image
		{
			label.hidden = true
			imageView.image = actualImage
		}
		else
		{
			label.hidden = false
		}
	}
}
