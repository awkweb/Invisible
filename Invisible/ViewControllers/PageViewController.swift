//
//  PageViewController.swift
//  Invisible
//
//  Created by thomas on 5/11/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

let pageController = PageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)

class PageViewController: UIPageViewController {
  
  let settingsVC = kStoryboard.instantiateViewControllerWithIdentifier("SettingsNavController") as! UIViewController
  let messageVC = kStoryboard.instantiateViewControllerWithIdentifier("MessageNavController") as! UIViewController
  
  required init(coder aDecoder: NSCoder) {
    super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
  }
  
  override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [NSObject : AnyObject]?) {
    super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.whiteColor()
    dataSource = self
    setViewControllers([messageVC], direction: .Forward, animated: true, completion: nil)
  }
  
  func goToNextVC() {
    let nextVC = pageViewController(self, viewControllerAfterViewController: viewControllers[0] as! UIViewController)!
    setViewControllers([nextVC], direction: .Forward, animated: true, completion: nil)
  }
  
  func goToPreviousVC() {
    let previousVC = pageViewController(self, viewControllerBeforeViewController: viewControllers[0] as! UIViewController)!
    setViewControllers([previousVC], direction: .Reverse, animated: true, completion: nil)
  }
  
}

// MARK: - UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource {
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    
    switch viewController {
    case messageVC: return settingsVC
    default: return nil
    }
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    
    switch viewController {
    case settingsVC: return messageVC
    default: return nil
    }
  }
}
