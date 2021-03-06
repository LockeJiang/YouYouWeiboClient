//
//  FirstViewController.m
//  zjtSinaWeiboClient
//
//  Created by jtone z on 11-11-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "ZJTHelpler.h"
#import "ZJTStatusBarAlertWindow.h"
#import "CoreDataManager.h"

@interface FirstViewController() 
-(void)timerOnActive;
-(void)getDataFromCD;
@end

@implementation FirstViewController
@synthesize userID;
@synthesize timer;


- (void)twitter
{
    TwitterVC *tv = [[TwitterVC alloc]initWithNibName:@"TwitterVC" bundle:nil];
    [self.navigationController pushViewController:tv animated:YES];
  //  [tv release];
}

-(void)getDataFromCD
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"homePageMaxID"];
    if (number) {
        _maxID = number.longLongValue;
    }
    
    dispatch_queue_t readQueue = dispatch_queue_create("read from db", NULL);
    dispatch_async(readQueue, ^(void){
        if (!statuesArr || statuesArr.count == 0) {
            statuesArr = [[NSMutableArray alloc] initWithCapacity:70];
            NSArray *arr = [[CoreDataManager getInstance] readStatusesFromCD];
            if (arr && arr.count != 0) {
                for (int i = 0; i < arr.count; i++) 
                {
                    StatusCDItem *s = [arr objectAtIndex:i];
                    Status *sts = [[Status alloc]init];
                    [sts updataStatusFromStatusCDItem:s];
                    if (i == 0) {
                        sts.isRefresh = @"YES";
                    }
                    [statuesArr insertObject:sts atIndex:s.index.intValue];
         //           [sts release];
                }
            }
        }
        [[CoreDataManager getInstance] cleanEntityRecords:@"StatusCDItem"];
        [[CoreDataManager getInstance] cleanEntityRecords:@"UserCDItem"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //CGFloat offset = self.tableView.contentOffset.y;
            
             //NSLog(@"FVC: before getDataFromCD: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
            
            
            [self.tableView reloadData];
            
             //NSLog(@"FVC: after getDataFromCD: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
            
            
            //self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
            //self.tableView.contentOffset = CGPointMake(0.0f, offset);
            
             //NSLog(@"FVC:  set after getDataFromCD: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
        });
       // dispatch_release(readQueue);
    });
    
    NSLog(@"FirstViewController: getDataFromCD");
}

							
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    refreshFooterView.hidden = NO;
    _page = 1;
    _maxID = -1;
    _shouldAppendTheDataArr = NO;
    UIBarButtonItem *retwitterBtn = [[UIBarButtonItem alloc]initWithTitle:@"发微博" style:UIBarButtonItemStylePlain target:self action:@selector(twitter)];
    self.navigationItem.rightBarButtonItem = retwitterBtn;
   // [retwitterBtn release];
        
    [defaultNotifCenter addObserver:self selector:@selector(didGetUserID:)      name:MMSinaGotUserID            object:nil];
    [defaultNotifCenter addObserver:self selector:@selector(didGetHomeLine:)    name:MMSinaGotHomeLine          object:nil];
    [defaultNotifCenter addObserver:self selector:@selector(didGetUserInfo:)    name:MMSinaGotUserInfo          object:nil];
    [defaultNotifCenter addObserver:self selector:@selector(relogin)            name:NeedToReLogin              object:nil];
    [defaultNotifCenter addObserver:self selector:@selector(didGetUnreadCount:) name:MMSinaGotUnreadCount       object:nil];
    [defaultNotifCenter addObserver:self selector:@selector(appWillResign:)            name:UIApplicationWillResignActiveNotification             object:nil];
    
    //NSLog(@"FirstViewController: viewDidLoad");
    
     //NSLog(@"FVC: before ViewDidLoad: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    
    //self.tableView.contentInset = UIEdgeInsetsMake(64.0f, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    //self.tableView.contentOffset = CGPointMake(0.0f, -65.0f);
     //NSLog(@"FVC: set after ViewDidLoad: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
}

-(void)viewDidUnload
{
    [defaultNotifCenter removeObserver:self name:MMSinaGotUserID            object:nil];
    [defaultNotifCenter removeObserver:self name:MMSinaGotHomeLine          object:nil];
    [defaultNotifCenter removeObserver:self name:MMSinaGotUserInfo          object:nil];
    [defaultNotifCenter removeObserver:self name:NeedToReLogin              object:nil];
    [defaultNotifCenter removeObserver:self name:MMSinaGotUnreadCount       object:nil];
    
    [super viewDidUnload];
    
    NSLog(@"FirstViewController: viewDidUnload");
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    if (shouldLoad) 
    {
        shouldLoad = NO;
        [manager getUserID];
        [manager getHomeLine:-1 maxID:-1 count:-1 page:-1 baseApp:-1 feature:-1];
        [[SHKActivityIndicator currentIndicator] displayActivity:@"正在载入..." inView:self.view];
//        [[ZJTStatusBarAlertWindow getInstance] showWithString:@"正在载入，请稍后..."];
    }
    NSLog(@"FirstViewController: viewWillAppear");
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"FirstViewController: viewWillDisappear");
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //如果未授权，则调入授权页面。
    if (statuesArr != nil && statuesArr.count != 0) {
        return;
    }
    NSString *authToken = [[NSUserDefaults standardUserDefaults] objectForKey:USER_STORE_ACCESS_TOKEN];
    NSLog([manager isNeedToRefreshTheToken] == YES ? @"need to login":@"did login");
    if (authToken == nil || [manager isNeedToRefreshTheToken]) 
    {
        shouldLoad = YES;
        OAuthWebView *webV = [[OAuthWebView alloc]initWithNibName:@"OAuthWebView" bundle:nil];
        webV.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webV animated:NO];
     //   [webV release];
    }
    else
    {
        [self getDataFromCD];
        
        if (!statuesArr || statuesArr.count == 0) {
            [manager getHomeLine:-1 maxID:-1 count:-1 page:-1 baseApp:-1 feature:-1];
            [[SHKActivityIndicator currentIndicator] displayActivity:@"正在载入..." inView:self.view];
        }
        
        [manager getUserID];
        // [manager getHOtTrendsDaily];
    }
    
    //self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    NSLog(@"FirstViewController: viewDidAppear");
}

#pragma mark - Methods

//上拉
-(void)refresh
{
    //CGFloat offset = self.tableView.contentOffset.y;
    //NSLog(@"FVC: before Refresh: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    
    [manager getHomeLine:-1 maxID:_maxID count:-1 page:_page baseApp:-1 feature:-1];
    _shouldAppendTheDataArr = YES;
    
    //NSLog(@"FVC: after Refresh: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    
    //self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    //self.tableView.contentOffset = CGPointMake(0.0f, offset);
    //NSLog(@"FVC: set after Refresh: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    
    //NSLog(@"FirstViewController: refresh");
}

-(void)appWillResign:(id)sender
{
    for (int i = 0; i < statuesArr.count; i++) {
        NSLog(@"i = %d",i);
        if ([statuesArr objectAtIndex:i] ) {
            [[CoreDataManager getInstance] insertStatusesToCD:[statuesArr objectAtIndex:i] index:i isHomeLine:YES];
        }
    }
    NSLog(@"FirstViewController: appWillResign");
}

-(void)timerOnActive
{
    [manager getUnreadCount:userID];
    NSLog(@"FirstViewController: timerOnActive");
}

-(void)relogin
{
    shouldLoad = YES;
    OAuthWebView *webV = [[OAuthWebView alloc]initWithNibName:@"OAuthWebView" bundle:nil];
    webV.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webV animated:NO];
 //   [webV release];
    NSLog(@"FirstViewController: relogin");
}

-(void)didGetUserID:(NSNotification*)sender
{
    self.userID = sender.object;
    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USER_STORE_USER_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [manager getUserInfoWithUserID:[userID longLongValue]];
    NSLog(@"FirstViewController: didGetUserID");
}

-(void)didGetUserInfo:(NSNotification*)sender
{
    User *user = sender.object;
    [ZJTHelpler getInstance].user = user;
    [[NSUserDefaults standardUserDefaults] setObject:user.screenName forKey:USER_STORE_USER_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"FirstViewController: didGetUserInfo");
}

-(void)didGetHomeLine:(NSNotification*)sender
{
    if ([sender.object count] == 1) {
        NSDictionary *dic = [sender.object objectAtIndex:0];
        NSString *error = [dic objectForKey:@"error"];
        if (error && ![error isEqual:[NSNull null]]) {
            if ([error isEqualToString:@"expired_token"]) 
            {
                [[SHKActivityIndicator currentIndicator] hide];
//                [[ZJTStatusBarAlertWindow getInstance] hide];
                shouldLoad = YES;
                OAuthWebView *webV = [[OAuthWebView alloc]initWithNibName:@"OAuthWebView" bundle:nil];
                webV.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:webV animated:NO];
            //    [webV release];
            }
            return;
        }
    }
    
    //CGFloat offset = self.tableView.contentOffset.y;
    //NSLog(@"FVC: before Didgethomeline: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    
    [self stopLoading];
    [self doneLoadingTableViewData];
    
    if (statuesArr == nil || _shouldAppendTheDataArr == NO || _maxID < 0) {
        self.statuesArr = sender.object;
        Status *sts = [statuesArr objectAtIndex:0];
        _maxID = sts.statusId;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:_maxID] forKey:@"homePageMaxID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _page = 1;
    }
    else {
        [statuesArr addObjectsFromArray:sender.object];
    }
    _page++;
    refreshFooterView.hidden = NO;
    
    /*
    if (statuesArr && statuesArr.count > 0 ) {
        for (int i=0; i<statuesArr.count;i++ ) {
            Status *ddd = [statuesArr objectAtIndex:i];
            if (!ddd.user.follow_me) {
              //   [ddd retain];
                [statuesArr removeObjectAtIndex:i];
            }
            [ddd release];
        }
    }
    */
    
    [self.tableView reloadData];
    
    [[SHKActivityIndicator currentIndicator] hide];
    [self refreshVisibleCellsImages];
    
    if (timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timerOnActive) userInfo:nil repeats:YES];
    }
    NSLog(@"FirstViewController: didGetHomeLine");
    
    //NSLog(@"FVC: after didGetHomeline: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    
    //self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    //self.tableView.contentOffset = CGPointMake(0.0f, offset);
    
    //NSLog(@"FVC: set after didGetHomeline: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    _reloading = YES;
	[manager getHomeLine:-1 maxID:-1 count:-1 page:-1 baseApp:-1 feature:-1];
    _shouldAppendTheDataArr = NO;
    NSLog(@"FirstViewController: egoRefreshTableHeaderDidTriggerRefresh");
}

-(void)didGetUnreadCount:(NSNotification*)sender
{
    //CGFloat offset = self.tableView.contentOffset.y;
    NSDictionary *dic = sender.object;
    NSNumber *num = [dic objectForKey:@"status"];
    
    NSLog(@"num = %@",num);
    if ([num intValue] == 0) {
        return;
    }
    
    [[ZJTStatusBarAlertWindow getInstance] showWithString:[NSString stringWithFormat:@"有%@条新微博",num]];
    [[ZJTStatusBarAlertWindow getInstance] performSelector:@selector(hide) withObject:nil afterDelay:10];
    NSLog(@"FirstViewController: didGetUnreadCount");
    
    //self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    //NSLog(@"FVC: after didGetUnreadCount: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    //self.tableView.contentOffset = CGPointMake(0.0f, offset);
}

@end