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
	var images = [UIImage]()
	let pagingController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
	override func viewDidLoad()
	{
		let numberOfImages = 7
		for i in 0..<numberOfImages
		{
			images.append(UIImage(named: "\(i).png")!)
		}
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
	func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
	{
		return images.count
	}
	
	func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
	{
		return (pageViewController.viewControllers.first! as UIViewController).view.tag
	}
}
/*
extension InformationViewController : UIScrollViewDelegate
{
	func scrollViewDidScroll(scrollView: UIScrollView)
	{
		loadVisiblePages()
	}
	func loadPage(page: Int)
	{
		if (page < 0 || page >= pageControl.numberOfPages)
		{
			return
		}
		var frame = scrollView.bounds
		frame.origin.x = frame.size.width * CGFloat(page)
		frame.origin.y = 0.0
		images[page].frame = frame
		scrollView.addSubview(images[page])
	}
	func purgePage(page: Int)
	{
		if page < 0 || page >= pageControl.numberOfPages
		{
			return
		}
		images[page].removeFromSuperview()
	}
	func loadVisiblePages()
	{
		let pageWidth = scrollView.frame.width
		let page = Int(floor(scrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2))
		pageControl.currentPage = page
		let firstPage = page - 2
		let lastPage = page + 2
		if (firstPage > 0)
		{
			for i in 0..<firstPage
			{
				purgePage(i)
			}
		}
		for i in firstPage...lastPage
		{
			loadPage(i)
		}
		if (lastPage < pageControl.numberOfPages)
		{
			for i in lastPage..<pageControl.numberOfPages
			{
				purgePage(i)
			}
		}
	}
}*/