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
	var images = [UIImage]()
	let pagingController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
	override func viewDidLoad()
	{
		let numberOfImages = 7
		for i in 0..<numberOfImages
		{
			images.append(UIImage(named: "\(i).png")!)
		}
		pageControl.numberOfPages = numberOfImages
		//addChildViewController(pagingController)
		pagingController.delegate = self
		pagingController.dataSource = self
		pagingController.setViewControllers([viewControllerForIndex(0)!], direction: .Forward, animated: true, completion: nil)
		pagingContainerView.addSubview(pagingController.view)
		pagingContainerView.sendSubviewToBack(pagingController.view)
	}
	override func viewDidLayoutSubviews()
	{
		pagingController.view.frame.size = pagingContainerView.frame.size
	}
	func viewControllerForIndex(index: Int) -> UIViewController?
	{
		if (index < 0 || index >= images.count)
		{
			return nil
		}
		let viewController = storyboard!.instantiateViewControllerWithIdentifier("ImageViewController") as ImageViewController
		viewController.view.tag = index
		viewController.imageView.image = images[index]
		viewController.view.frame.size = pagingContainerView.frame.size
		return viewController
	}
}
extension InformationViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource
{
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
			pageControl.currentPage = (pageViewController.viewControllers.first! as UIViewController).view.tag
		}
	}
	/*
	func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
	{
		return images.count
	}
	
	func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
	{
		return (pageViewController.viewControllers.first! as UIViewController).view.tag
	}*/
}