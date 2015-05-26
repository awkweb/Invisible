//
//  AppDelegate.swift
//  Invisible
//
//  Created by thomas on 5/9/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    Parse.setApplicationId(kParseApplicationId, clientKey: kParseClientKey)
    
    // Determine initialViewController
    var initialViewController: UIViewController
    
    if PFUser.currentUser() != nil {
      initialViewController = kStoryboard.instantiateViewControllerWithIdentifier("MessageViewController") as! MessageViewController
    } else {
      initialViewController = kStoryboard.instantiateViewControllerWithIdentifier("LogInViewController") as! LogInViewController
    }
    
    window?.rootViewController = initialViewController
    let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0))
    statusBarView.backgroundColor = UIColor.purpleColor()
    window?.rootViewController!.view.addSubview(statusBarView)
    window?.makeKeyAndVisible()
    
    //TODO: Register every time?
    // Register for Push Notitications
    if application.applicationState != .Background {
      // Track an app open here if we launch with a push, unless
      // "content_available" was used to trigger a background push (introduced in iOS 7).
      // In that case, we skip tracking here to avoid double counting the app-open.
      
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
  
  //TODO: Change in-app notification here
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    PFPush.handlePush(userInfo)
    if application.applicationState == .Inactive {
      PFAnalytics.trackAppOpenedWithRemoteNotificationPayloadInBackground(userInfo, block: nil)
    }
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    
    if let info = userInfo["aps"] as? [String: AnyObject] {
      if let alert = info["alert"] as? String {
        let messageText = alert
        println("App delegate \(messageText)")
        completionHandler(.NewData)
      }
    }
    completionHandler(.NoData)
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    let currentInstallation = PFInstallation.currentInstallation()
    
    if currentInstallation.badge != 0 {
      currentInstallation.badge = 0
      currentInstallation.saveEventually(nil)
    }
  }
  
}

