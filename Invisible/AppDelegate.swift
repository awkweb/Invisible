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
    
    // Extract notification data from app open
    if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
      println(notificationPayload)
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
    
    if application.applicationState == .Active {
      let alertSound = "ringring.wav"
      let soundPlayer = SoundPlayer()
      soundPlayer.playSound(alertSound)
      
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
        kCRToastSubtitleTextKey: "slide to view",
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
        kCRToastAnimationInDirectionKey: CRToastAnimationDirection.Left.rawValue,
        kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.Right.rawValue,
        kCRToastTimeIntervalKey: DBL_MAX,
        kCRToastInteractionRespondersKey: [CRToastInteractionResponder(interactionType: .SwipeRight, automaticallyDismiss: true, block: nil)]
      ]
      CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    }
    
    // Track app open
    if application.applicationState == .Inactive {
      PFAnalytics.trackAppOpenedWithRemoteNotificationPayloadInBackground(userInfo, block: nil)
    }
    completionHandler(.NewData)
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    let currentInstallation = PFInstallation.currentInstallation()
    if currentInstallation.badge != 0 {
      currentInstallation.badge = 0
      currentInstallation.saveEventually(nil)
    }
  }
  
}

