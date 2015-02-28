//
//  InformationViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 2/10/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import Foundation
import UIKit


class InformationViewController: UIViewController
{
	@IBOutlet var pagingContainerView : UIView!
	@IBOutlet var pageControl : UIPageControl!
	@IBOutlet var tableView : UITableView!
	var images = [UIImage]()
	let pagingController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
	var cells = [InformationTableViewCell]()
	//MARK: - View Controller Lifecycle
	override func viewDidLoad()
	{
		let numberOfImages = 7
		for i in 0..<numberOfImages
		{
			images.append(UIImage(named: "\(i).png")!)
		}
		pageControl.numberOfPages = numberOfImages
		pagingController.delegate = self
		pagingController.dataSource = self
		pagingController.setViewControllers([viewControllerForIndex(0)!], direction: .Forward, animated: true, completion: nil)
		pagingContainerView.addSubview(pagingController.view)
		pagingContainerView.sendSubviewToBack(pagingController.view)
		tableView.delegate = self
		tableView.dataSource = self
		
		let headers = ["INVITE FRIENDS", "VIPP WILL PICK YOU UP", "VIPP WILL GET YOU IN"]
		let subtitles = ["INVITE YOUR FRIENDS TO JOIN VIPP AND CREATE YOUR GROUP TO GO OUT WITH.", "TOWN CAR OR ESCALADE?\nYOU CHOOSE.", "SHOW THE BOUNCER YOUR VIPP TICKET\nFOLLOW YOUR VIPP REPRESENTATIVE\nFREE BOTTLES INCLUDED."]
		let imagesForTable = [UIImage(named: "friends.png")!, UIImage(named: "ride.png")!, UIImage(named: "ropes.png")!]
		for (i, image) in enumerate(imagesForTable)
		{
			let cell = tableView.dequeueReusableCellWithIdentifier("TableCell") as! InformationTableViewCell
			cell.numberLabel.text = "\(i+1)"
			cell.headingLabel.text = headers[i]
			cell.subtitleLabel.text = subtitles[i]
			cell.imageDisplay.image = image
			cell.background.hidden = (i + 1) % 2 == 0
			cells.append(cell)
		}
	}
	override func viewDidLayoutSubviews()
	{
		pagingController.view.frame.size = pagingContainerView.frame.size
		if (tableView.contentSize.height < tableView.frame.height)
		{
			tableView.scrollEnabled = false
		}
	}
	//MARK: - Actions
	@IBAction func closeButton(_ : UIButton)
	{
		dismissViewControllerAnimated(true, completion: nil)
	}
}
//MARK: - Paging View Controller
extension InformationViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource
{
	func viewControllerForIndex(index: Int) -> UIViewController?
	{
		if (index < 0)
		{
			return viewControllerForIndex(images.count - 1)
		}
		if (index >= images.count)
		{
			return viewControllerForIndex(0)
		}
		let viewController = storyboard!.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
		viewController.view.tag = index
		viewController.imageView.image = images[index]
		viewController.view.frame.size = pagingContainerView.frame.size
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
			pageControl.currentPage = (pageViewController.viewControllers.first! as! UIViewController).view.tag
		}
	}
	@IBAction func pageControlValueChange(pageControl: UIPageControl)
	{
		let currentIndex = (pagingController.viewControllers.first as! UIViewController).view.tag
		if (pageControl.currentPage < currentIndex)
		{
			pagingController.setViewControllers([viewControllerForIndex(pageControl.currentPage)!], direction: .Reverse, animated: true, completion: nil)
		}
		else
		{
			pagingController.setViewControllers([viewControllerForIndex(pageControl.currentPage)!], direction: .Forward, animated: true, completion: nil)
		}
	}
}
//MARK: - TableViewController
extension InformationViewController : UITableViewDelegate, UITableViewDataSource
{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return cells.count
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = cells[indexPath.row]
		return cell
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		return (tableView.frame.height - 15) / CGFloat(cells.count)
	}
}

class InformationTableViewCell : UITableViewCell
{
	@IBOutlet var numberLabel : UILabel!
	@IBOutlet var headingLabel : UILabel!
	@IBOutlet var subtitleLabel : UILabel!
	@IBOutlet var imageDisplay : UIImageView!
	@IBOutlet var background : UIImageView!
}