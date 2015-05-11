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
  
  let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SettingsNavController") as! UIViewController
  let messageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MessageNavController") as! UIViewController
  let contactsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ContactsNavController") as! UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    case settingsVC:
      return nil
    case messageVC:
      return settingsVC
    case contactsVC:
      return messageVC
    default:
      return nil
    }
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    
    switch viewController {
    case settingsVC:
      return messageVC
    case messageVC:
      return contactsVC
    case contactsVC:
      return nil
    default:
      return nil
    }
  }
}