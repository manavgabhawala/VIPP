//
//  RequestCarCells.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/27/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class RequestScheduleCell : UITableViewCell
{
	@IBOutlet var timeLabel : UILabel!
	func setup()
	{
		backgroundColor = UIColor.clearColor()
		let date = NSDate(timeIntervalSinceNow: 0)
		timeLabel.text = stringFromDate(date)
	}
	func stringFromDate(date: NSDate) -> String
	{
		let dateFormatter = NSDateFormatter()
		dateFormatter.timeStyle = .ShortStyle
		return dateFormatter.stringFromDate(date)
	}
}

class RequestSchedulePickerCell : UITableViewCell
{
	@IBOutlet var timePicker : UIDatePicker!
	func setup(date: String)
	{
		backgroundColor = UIColor.clearColor()
		let dateFormatter = NSDateFormatter()
		dateFormatter.timeStyle = .ShortStyle
		let date = dateFormatter.dateFromString(date)
		let now = NSDate(timeIntervalSinceNow: 0)
		timePicker.date = date ?? now
	}
}
class CarPickerCell : UITableViewCell
{
	@IBOutlet var pagingContainer : UIView!
	var cars = [(image: UIImage(), productId: String(), capacity: Int())]
	let pagingViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
	var pageIndex = 0
	var viewControllers = [ImageViewController]()
	func setup(uberCars: [(image: UIImage, productId: String, capacity: Int)], storyboard: UIStoryboard?)
	{
		backgroundColor = UIColor.clearColor()
		cars = uberCars
		pagingViewController.delegate = self
		pagingViewController.dataSource = self
		pageIndex = 0
		setupViewControllers(storyboard)
		pagingViewController.view.frame.size = pagingContainer.frame.size
		pagingViewController.setViewControllers([viewControllerForIndex(0)!], direction: .Forward, animated: true, completion: nil)
		pagingContainer.addSubview(pagingViewController.view)
	}
	func setupViewControllers(storyboard: UIStoryboard?)
	{
		for (i, car) in enumerate(cars)
		{
			let imageViewController = storyboard!.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
			imageViewController.disableAnimations = true
			imageViewController.view.tag = i
			imageViewController.imageView.contentMode = .ScaleAspectFit
			imageViewController.view.frame.size = pagingContainer.frame.size
			imageViewController.setImage(car.image)
			viewControllers.append(imageViewController)
		}
	}
}
//MARK: - Paging View Stuff
extension CarPickerCell : UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
	func viewControllerForIndex(index: Int) -> UIViewController?
	{
		if (index < 0 || index >= viewControllers.count)
		{
			return nil
		}
		return viewControllers[index]
	}
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
	{
		return viewControllerForIndex(pageIndex - 1)
	}
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
	{
		return viewControllerForIndex(pageIndex + 1)
	}
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool)
	{
		if (completed)
		{
			pageIndex = (pageViewController.viewControllers.first as! UIViewController).view.tag
		}
	}
}

class CarCell : UICollectionViewCell
{
	@IBOutlet var imageView: UIImageView!
}