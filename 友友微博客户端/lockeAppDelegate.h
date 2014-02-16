//
//  lockeAppDelegate.h
//  友友微博客户端
//
//  Created by Jiang Jian on 14-2-16.
//  Copyright (c) 2014年 Locke Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface lockeAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>
{
    NSManagedObjectContext         *_managedObjContext;
    NSManagedObjectModel           *_managedObjModel;
    NSPersistentStoreCoordinator   *_persistentStoreCoordinator;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)setPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator;

@end

