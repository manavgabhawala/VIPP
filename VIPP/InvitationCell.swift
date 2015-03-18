//
//  InvitationCell.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/15/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class InvitationCell: UITableViewCell, RoundedTableCells
{
	@IBOutlet var nameLabel : UILabel!
	@IBOutlet var shareButton : UIButton!
	@objc var bottom = false
	@objc var top = false
}

class AddressBookCell: UITableViewCell, RoundedTableCells
{
	@IBOutlet var nameLabel : UILabel!
	@IBOutlet var messageButton :  UIButton!
	@IBOutlet var phoneNumberLabel : UILabel!
	@objc var top = false, bottom = false
}