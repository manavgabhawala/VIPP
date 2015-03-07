//
//  EventViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/3/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class EventViewController : UIViewController
{
	@IBOutlet var pagingViewContainer : UIView!
	@IBOutlet var clubName: UILabel!
	@IBOutlet var eventDate: UILabel!
	
	var currentImages = [ImageViewController]()
	var club : Club!
	let pagingController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
	//MARK: - View Controller Lifecycle
	override func viewDidLoad()
	{
		clubName.text = club.name
		club.events.sort { $0.date < $1.date }
		let firstDate = club.events.first?.date
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = .LongStyle
		eventDate.text = dateFormatter.stringFromDate(firstDate ?? NSDate(timeIntervalSinceNow: 0))
		getImagesFromServer()
		pagingController.delegate = self
		pagingController.dataSource = self
		pagingController.setViewControllers([viewControllerForIndex(0)], direction: .Forward, animated: true, completion: nil)
		pagingViewContainer.addSubview(pagingController.view)
	}
	override func viewDidLayoutSubviews()
	{
		let percentage : CGFloat = 0.9
		let frame = pagingViewContainer.frame
		pagingController.view.frame = CGRect(origin: CGPoint(x: frame.width * (1 - percentage) / 2, y: 0), size: CGSize(width: frame.width * percentage, height: frame.height))
	}
	
	//MARK: - Server Interaction
	func getImagesFromServer()
	{
		currentImages = club.events.map {
			let imageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
			imageViewController.imageView.image = $0.image
			$0.controller = imageViewController
			$0.loadImage()
			return imageViewController
		}
		
	}
	func getFriends()
	{
		
	}
	
	//MARK: - Actions
	@IBAction func requestBlackCar(_ : UIButton)
	{
	
	}
	@IBAction func generalShareButtonPressed(_ : UIButton)
	{
		
	}
	@IBAction func friendIconPressed(user: PFUser)
	{
		
	}
}
extension EventViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
	func viewControllerForIndex(index: Int) -> ImageViewController
	{
		if (index < 0)
		{
			return viewControllerForIndex(currentImages.count - 1)
		}
		if (index >= currentImages.count)
		{
			return viewControllerForIndex(0)
		}
		return currentImages[index]
	}
	func viewControllerWithImage(image: UIImage?, tag: Int) -> ImageViewController
	{
		let viewController = storyboard!.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
		viewController.view.tag = tag
		viewController.imageView.image = image
		viewController.view.frame.size = pagingViewContainer.frame.size
		return viewController
	}
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
	{
		let index = viewController.view.tag - 1
		return viewControllerForIndex(index)
	}
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
	{
		let index = viewController.view.tag + 1
		return viewControllerForIndex(index)
	}
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool)
	{
		if (completed)
		{
			let currentIndex = (pageViewController.viewControllers.first! as! UIViewController).view.tag
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateStyle = .LongStyle
			eventDate.text = dateFormatter.stringFromDate(club.events[currentIndex].date)
		}
	}
}