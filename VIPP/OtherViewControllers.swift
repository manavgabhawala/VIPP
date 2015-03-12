//
//  TermsAndConditionViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 2/9/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import Foundation
import UIKit

protocol ImageDownloaded
{
	func setImage(image: UIImage)
}

protocol TermsAndConditionsViewControllerDelegate
{
	func agreesToTerms()
}

class TermsAndConditionsViewController : UIViewController
{
	@IBOutlet var doneButton : UIBarButtonItem!
	@IBOutlet var cancelButton : UIBarButtonItem!
	@IBOutlet var textView : UITextView!
	var finalTerms = false
	var delegate : TermsAndConditionsViewControllerDelegate?
	override func viewDidLoad()
	{
		if delegate != nil
		{
			cancelButton.enabled = true
			doneButton.title = "I Agree"
		}
	}
	override func viewDidAppear(animated: Bool)
	{
		textView.setContentOffset(CGPoint(x: 0, y: -textView.contentInset.top), animated: true)
	}
	func dismissAction()
	{
		dismissViewControllerAnimated(true, completion: nil)
	}
	@IBAction func doneButtonPressed(_ : UIBarButtonItem)
	{
		delegate?.agreesToTerms()
		dismissAction()
	}
	@IBAction func cancelButtonPressed(_ : UIBarButtonItem)
	{
		dismissAction()
	}
}

class ImageViewController : UIViewController, ImageDownloaded
{
	@IBOutlet var imageView : UIImageView!
	var appeared = false
	var disableAnimations = false
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		if (!appeared && !disableAnimations)
		{
			let actualFrame = imageView.frame
			imageView.frame.origin.y = view.frame.height / 2
			UIView.animateWithDuration(0.4, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0,
				options: .CurveEaseInOut, animations:
				{
					self.imageView.frame = actualFrame
				}, completion:
				{ (completed) in self.appeared = true })
		}
	}
	override func viewDidDisappear(animated: Bool)
	{
		appeared = false
	}
	func setImage(image: UIImage)
	{
		imageView.image = image
		imageView.setNeedsDisplay()
	}
}