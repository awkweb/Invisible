//
//  AppDelegate.swift
//  Invisible
//
//  Created by thomas on 5/9/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    Parse.setApplicationId(kParseApplicationId, clientKey: kParseClientKey)
    
    // Register for Push Notitications
    if application.applicationState != .Background {
      let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
      let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
      var pushPayload = false
      if let options = launchOptions {
        pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
      }
      if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
      }
    }
    if application.respondsToSelector("registerUserNotificationSettings:") {
      let userNotificationTypes: UIUserNotificationType = .Alert | .Badge | .Sound
      let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
      application.registerUserNotificationSettings(settings)
      application.registerForRemoteNotifications()
    } else {
      let types: UIUserNotificationType = .Badge | .Alert | .Sound
      application.registerForRemoteNotifications()
    }
    
    // UI
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.grayD()]
    
    // Determine initialViewController
    var initialViewController: UIViewController
    if PFUser.currentUser() != nil {
      initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MessagesNavController") as! UIViewController
    } else {
      initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LogInViewController") as! LogInViewController
    }
    window?.rootViewController = initialViewController
    window?.makeKeyAndVisible()
    
    // Extract notification data from app open
    if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
      handlePush(application, userInfo: launchOptions!)
    }
    
    return true
  }
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    let installation = PFInstallation.currentInstallation()
    installation.setDeviceTokenFromData(deviceToken)
    installation.saveInBackgroundWithBlock(nil)
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    if error.code == 3010 {
      println("Push notifications are not supported in the iOS Simulator.")
    } else {
      println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
    }
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    handlePush(application, userInfo: userInfo)
    completionHandler(.NewData)
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    clearBadge()
  }
  
  private func clearBadge() {
    let currentInstallation = PFInstallation.currentInstallation()
    if currentInstallation.badge != 0 {
      currentInstallation.badge = 0
      currentInstallation.saveEventually(nil)
    }
  }
  
  private func handlePush(application: UIApplication, userInfo: [NSObject : AnyObject]) {
    switch application.applicationState {
    case .Active:
      SoundPlayer().playSound(.Alert)
      var pushText = userInfo["aps"]!["alert"] as! String
      if count(pushText) > 72 {
        pushText = pushText.substringToIndex(advance(pushText.startIndex, 72))
        pushText += "..."
      }
      pushText = pushText.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
      
      let options = [
        kCRToastTextKey: pushText,
        kCRToastFontKey: UIFont.systemFontOfSize(16.0),
        kCRToastTextAlignmentKey: NSTextAlignment.Left.rawValue,
        kCRToastTextMaxNumberOfLinesKey: 2,
        kCRToastSubtitleTextKey: "tap to view",
        kCRToastSubtitleFontKey: UIFont.systemFontOfSize(12.0),
        kCRToastSubtitleTextMaxNumberOfLinesKey: 1,
        kCRToastSubtitleTextAlignmentKey: NSTextAlignment.Left.rawValue,
        kCRToastImageKey: UIImage(named: "bell") as! AnyObject,
        kCRToastImageAlignmentKey: CRToastAccessoryViewAlignment.Left.rawValue,
        kCRToastImageContentModeKey: UIViewContentMode.Center.rawValue,
        kCRToastBackgroundColorKey: UIColor.red(),
        kCRToastNotificationTypeKey: CRToastType.NavigationBar.rawValue,
        kCRToastNotificationPresentationTypeKey: CRToastPresentationType.Cover.rawValue,
        kCRToastAnimationInTypeKey: CRToastAnimationType.Spring.rawValue,
        kCRToastAnimationOutTypeKey: CRToastAnimationType.Spring.rawValue,
        kCRToastAnimationInDirectionKey: CRToastAnimationDirection.Top.rawValue,
        kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.Top.rawValue,
        kCRToastTimeIntervalKey: 10,
        kCRToastInteractionRespondersKey: [
          CRToastInteractionResponder(interactionType: .Tap, automaticallyDismiss: true) {
            interaction in
            NSNotificationCenter.defaultCenter().postNotificationName("handlePushNotification", object: nil, userInfo: userInfo)
          },
          CRToastInteractionResponder(interactionType: .SwipeUp, automaticallyDismiss: true, block: nil)
        ]
      ]
      CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    case .Inactive:
      NSNotificationCenter.defaultCenter().postNotificationName("handlePushNotification", object: nil, userInfo: userInfo)
      PFAnalytics.trackAppOpenedWithRemoteNotificationPayloadInBackground(userInfo, block: nil)
    default:
      CRToastManager.showNotificationWithMessage("New Message", completionBlock: nil)
    }
  }
  
}
