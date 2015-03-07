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
	@IBOutlet var imageView : UIImageView!
	
	weak var club : Club!
	
	func setImage(image: UIImage)
	{
		imageView.image = image
		imageView.setNeedsDisplay()
	}
}
