//
//  ProfileButtonCell.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/13/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class ProfileButtonCell: UITableViewCell
{
	@IBOutlet var button : UILabel!
	@IBOutlet var icon : UIImageView!
	func setup(information: (UIImage, String))
	{
		icon.image = information.0
		button.text = information.1
	}
}
