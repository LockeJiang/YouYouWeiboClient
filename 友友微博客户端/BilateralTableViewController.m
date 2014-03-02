//
//  FirstViewController.m
//  zjtSinaWeiboClient
//
//  Created by jtone z on 11-11-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BilateralTableViewController.h"
#import "ZJTHelpler.h"
#import "ZJTStatusBarAlertWindow.h"
#import "CoreDataManager.h"

@interface BilateralTableViewController()
-(void)getDataFromCD;
@end

@implementation BilateralTableViewController
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
                    Status *sts = [[Status alloc] init];
                    [sts updataStatusFromStatusCDItem:s];
                    if (i == 0) {
                        sts.isRefresh = @"YES";
                    }
                    if (s) {
                        [statuesArr insertObject:sts atIndex:s.index.intValue];
                    }
                                     //  [sts release];
                }
            }
        }
        [[CoreDataManager getInstance] cleanEntityRecords:@"StatusCDItem"];
        [[CoreDataManager getInstance] cleanEntityRecords:@"UserCDItem"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //CGFloat offset = self.tableView.contentOffset.y;
           // NSLog(@"BVC: Before getdatafromCD: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
            
            [self.tableView reloadData];
            
            //NSLog(@"BVC: after getdatafromCD: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
            
            //self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
            //self.tableView.contentOffset = CGPointMake(0.0f, offset);
            
           // NSLog(@"BVC: set after getdatafromCD: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
        });
       // dispatch_release(readQueue);
    });
    
    NSLog(@"bilateralTableViewController: getDataFromCD: statuesArr Count:%lu", (unsigned long)statuesArr.count);

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.automaticallyAdjustsScrollViewInsets = NO;
    refreshFooterView.hidden = NO;
    _page = 1;
    _maxID = -1;
    _shouldAppendTheDataArr = NO;
    self.title = @"朋友圈";
    
    refreshFooterView.hidden = NO;
    
    UIBarButtonItem *retwitterBtn = [[UIBarButtonItem alloc]initWithTitle:@"发微博" style:UIBarButtonItemStylePlain target:self action:@selector(twitter)];
    self.navigationItem.rightBarButtonItem = retwitterBtn;
    // [retwitterBtn release];
    
    [defaultNotifCenter addObserver:self selector:@selector(didGetPublicTimeLine:) name:MMSinaGotPublicTimeLine          object:nil];
   
    //CGFloat offset = self.tableView.contentOffset.y;
    //self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    //self.tableView.contentOffset = CGPointMake(0.0f, -65);
    
    //NSLog(@"BVC: after viewDidLoad: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    //NSLog(@"bilateralTableViewController: viewDidLoad: statuesArr Count:%lu", (unsigned long)statuesArr.count);

}

-(void)viewDidUnload
{
    [defaultNotifCenter removeObserver:self name:MMSinaGotPublicTimeLine   object:nil];
    [super viewDidUnload];
    NSLog(@"viewDidUnload");
}

- (void)viewWillAppear:(BOOL)animated
{
   if (shouldLoad)
    {
        shouldLoad = NO;
        [manager getPublicTimeLine:-1 maxID:-1 count:-1 page:-1 baseApp:-1 feature:-1];
        [[SHKActivityIndicator currentIndicator] displayActivity:@"正在载入..." inView:self.view];
        [self.tableView reloadData];
        NSLog(@"bilateralTableViewController: viewWillAppear: shouldload");
   }
    [super viewWillAppear:animated];
    [self.view setAlpha:1];
    
    //CGFloat offset = self.tableView.contentOffset.y;
    // self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    //self.tableView.contentOffset = CGPointMake(0.0f, -65);
    
    //NSLog(@"BVC: after viewWillAppear: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    //NSLog(@"bilateralTableViewController: viewWillAppear: not shouldload: statuesArr Count:%i", statuesArr.count);

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view setAlpha:1];
    //NSLog(@"bilateralTableViewController: viewWillDisappear: statuesArr Count:%i", statuesArr.count);

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
      //  [webV release];
    }
    else
    {
        [self getDataFromCD];
        
        if (!statuesArr || statuesArr.count == 0) {
            [manager getPublicTimeLine:-1 maxID:-1 count:-1 page:-1 baseApp:-1 feature:-1];
            [[SHKActivityIndicator currentIndicator] displayActivity:@"正在载入..." inView:self.view];
        }
        
    }
    
    //CGFloat offset = self.tableView.contentOffset.y;
    //self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    //self.tableView.contentOffset = CGPointMake(0.0f, -65);
    
    //NSLog(@"BVC: after viewDidAppear: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    //NSLog(@"BVC: ViewDidAppear: statuesArr Count:%i", statuesArr.count);
}

#pragma mark - Methods
//上拉
-(void)refresh
{
    //CGFloat offset = self.tableView.contentOffset.y;
    //NSLog(@"BVC: Before Refresh: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    [manager getPublicTimeLine:-1 maxID:_maxID count:-1 page:_page baseApp:-1 feature:-1];
    _shouldAppendTheDataArr = YES;
    
    //self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    //self.tableView.contentOffset = CGPointMake(0.0f, offset);
    //NSLog(@"BVC: After Refresh: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    //NSLog(@"bilateralTableViewController: refresh");
}

-(void)appWillResign:(id)sender
{
    for (int i = 0; i < statuesArr.count; i++) {
        NSLog(@"i = %d",i);
        [[CoreDataManager getInstance] insertStatusesToCD:[statuesArr objectAtIndex:i] index:i isHomeLine:YES];
    }
   // NSLog(@"bilateralTableViewController: appWillResign");
}

-(void)timerOnActive
{
    [manager getUnreadCount:userID];
    //NSLog(@"bilateralTableViewController: getUnreadCount");
}

-(void)relogin
{
    shouldLoad = YES;
    OAuthWebView *webV = [[OAuthWebView alloc]initWithNibName:@"OAuthWebView" bundle:nil];
    webV.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webV animated:NO];
   // [webV release];
    //NSLog(@"bilateralTableViewController: relogin");
}

-(void)didGetPublicTimeLine:(NSNotification*)sender
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
           //     [webV release];
            }
            return;
        }
    }
    
    //CGFloat offset = self.tableView.contentOffset.y;
    //NSLog(@"BVC: Before reloaddata: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    
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
       // [statuesArr removeAllObjects];
        [statuesArr addObjectsFromArray:sender.object];
    }
    _page++;
    refreshFooterView.hidden = NO;
    
    [self.tableView reloadData];
    
    [[SHKActivityIndicator currentIndicator] hide];
    [self refreshVisibleCellsImages];
    
    if (timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timerOnActive) userInfo:nil repeats:YES];
    }
    
    //NSLog(@"BVC: After reloaddata: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    
    //self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, //UIEdgeInsetsOriginal.right) ;
    //self.tableView.contentOffset = CGPointMake(0.0f, offset);
    
    //NSLog(@"BVC: Set After reloaddata: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
    
    //NSLog(@"bilateralTableViewController: didGetPublicTimeLine: statuesArr Count:%i", statuesArr.count);

}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    _reloading = YES;
    //CGFloat offset = self.tableView.contentOffset.y;
    //NSLog(@"BVC: Before SegoRefresh: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
	[manager getPublicTimeLine:-1 maxID:-1 count:-1 page:-1 baseApp:-1 feature:-1];
    _shouldAppendTheDataArr = NO;
    
    //CGFloat offset = self.tableView.contentOffset.y;
    //self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    //self.tableView.contentOffset = CGPointMake(0.0f, offset);
    
    //NSLog(@"BVC: After SegoRefresh: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top,self.tableView.contentOffset.y);
}

@end