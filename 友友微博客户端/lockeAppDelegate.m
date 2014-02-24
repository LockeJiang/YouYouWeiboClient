//
//  lockeAppDelegate.m
//  友友微博客户端
//
//  Created by Jiang Jian on 14-2-16.
//  Copyright (c) 2014年 Locke Jiang. All rights reserved.
//

#import "lockeAppDelegate.h"
#import "FirstViewController.h"
#import "FollowerVC.h"
#import "SettingVC.h"
#import "ProfileVC.h"
#import "FollowAndFansVC.h"
#import "MetionsStatusesVC.h"
#import "ZJTProfileViewController.h"
#import "BilateralTableViewController.h"

@implementation lockeAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize managedObjContext = _managedObjContext;
@synthesize managedObjModel = _managedObjModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

/*
- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}
*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tag = 0;
    
    BilateralTableViewController *bilateral = [[BilateralTableViewController alloc] initWithNibName:@"lockeTableViewController" bundle:nil];
    FirstViewController *firstViewController = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
    MetionsStatusesVC *m = [[MetionsStatusesVC alloc] initWithNibName:@"FirstViewController" bundle:nil];
    //ZJTProfileViewController *profile = [[[ZJTProfileViewController alloc] initWithNibName:@"ZJTProfileViewController" bundle:nil] autorelease ];
    //FollowAndFansVC *followingVC = [[[FollowAndFansVC alloc] initWithNibName:@"FollowAndFansVC" bundle:nil] autorelease];
    SettingVC *settingVC = [[SettingVC alloc] initWithNibName:@"SettingVC" bundle:nil];
    
    //followingVC.title = @"好友";
    m.title = @"消息";
    //profile.title = @"我的账户";
    bilateral.title = @"朋友圈";
    firstViewController.title = @"关注";
    
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:bilateral];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:firstViewController];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:m];
    //  UINavigationController *nav3 = [[[UINavigationController alloc] initWithRootViewController:followingVC] autorelease];
    //UINavigationController *nav4 = [[[UINavigationController alloc] initWithRootViewController:profile] autorelease];
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:settingVC];
    
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:nav1, nav2, nav3, nav4,nil];
    //    self.tabBarController.selectedIndex = 2;
    self.window.rootViewController = self.tabBarController;
    
    self.tabBarController.tabBar.backgroundColor = [UIColor whiteColor];
    self.tabBarController.tabBar.opaque = NO;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjContext != nil) {
        return _managedObjContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjContext = [[NSManagedObjectContext alloc] init];
       // [NSManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjModel != nil) {
        return _managedObjModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"_______" withExtension:@"momd"];
    _managedObjModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"_______.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
