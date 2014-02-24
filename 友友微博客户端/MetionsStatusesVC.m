//
//  MetionsStatusesVC.m
//  zjtSinaWeiboClient
//
//  Created by Jianting Zhu on 12-6-21.
//  Copyright (c) 2012年 ZUST. All rights reserved.
//

#import "MetionsStatusesVC.h"

@interface MetionsStatusesVC ()

@end

@implementation MetionsStatusesVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"消息";
     NSLog(@"MVC: before ViewDidLoad: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top
           ,self.tableView.contentOffset.y);
    
    [defaultNotifCenter addObserver:self selector:@selector(didGetMetionsStatus:)    name:MMSinaGotMetionsStatuses   object:nil];
    
   // CGFloat offset = self.tableView.contentOffset.y;
    NSLog(@"MVC: after ViewDidLoad: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top
          ,self.tableView.contentOffset.y);
    self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    self.tableView.contentOffset = CGPointMake(0.0f, -65.0f);
    
    NSLog(@"MVC: done ViewDidLoad: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top
          ,self.tableView.contentOffset.y);

}

- (void)viewDidUnload
{
    [defaultNotifCenter removeObserver:self name:MMSinaGotMetionsStatuses object:nil];
    [super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (self.statuesArr != nil) {
        return;
    }
    
    NSLog(@"MVC: vieWillAppear: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top
          ,self.tableView.contentOffset.y);
    
    [manager getMetionsStatuses];
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"正在载入..." inView:self.view]; 
//    [[ZJTStatusBarAlertWindow getInstance] showWithString:@"正在载入，请稍后..."];
}

-(void)didGetMetionsStatus:(NSNotification*)sender
{    
    [self stopLoading];
    [self doneLoadingTableViewData];
    
    [statuesArr removeAllObjects];
    self.statuesArr = sender.object;
    
    NSLog(@"MVC: before reloaddata: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top
          ,self.tableView.contentOffset.y);
    [self.tableView reloadData];
    
    NSLog(@"MVC: after reloaddata: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top
          ,self.tableView.contentOffset.y);
    
    self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    self.tableView.contentOffset = CGPointMake(0.0f, -65.0f);
    
    NSLog(@"MVC: set after reloaddata: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top
          ,self.tableView.contentOffset.y);
    
    [[SHKActivityIndicator currentIndicator] hide];
//    [[ZJTStatusBarAlertWindow getInstance] hide];
    [self refreshVisibleCellsImages];
}

@end
