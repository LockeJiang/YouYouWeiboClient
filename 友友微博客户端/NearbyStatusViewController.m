//
//  NearbyStatusViewController.m
//  zjtSinaWeiboClient
//
//  Created by Jiang Jian on 14-2-15.
//
//

#import "NearbyStatusViewController.h"
#import "SHKActivityIndicator.h"

@interface NearbyStatusViewController ()

@end

@implementation NearbyStatusViewController

@synthesize locationManager = _locationManager;
@synthesize coordinate = _coordinate;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // _manager = [WeiBoMessageManager getInstance];
    }
    return self;
    NSLog(@"NearbyStatusVC: init");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"附近的微博";
    [defaultNotifCenter addObserver:self selector:@selector(didGetNearbyStatus:)    name:MMSinaGotNearbyStatuses   object:nil];
    
    //解决tableview被导航栏遮挡的问题
    self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    self.tableView.contentOffset = CGPointMake(0.0f, -65.0f);
    
    NSLog(@"NSVC: viewDidLoad: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top
          ,self.tableView.contentOffset.y);
    
     NSLog(@"NearbyStatusVC: viewDidLoad:%lu", (unsigned long)statuesArr.count);
}

- (void)viewDidUnload
{
    [defaultNotifCenter removeObserver:self name:MMSinaGotNearbyStatuses object:nil];
    [super viewDidUnload];
     NSLog(@"NearbyStatusVC: viewDidUnload:%lu", (unsigned long)statuesArr.count);
}

-(void)viewDidAppear:(BOOL)animated
{
    if (self.statuesArr != nil) {
        return;
    }
    
    /*
    if (_locationManager) {
        _locationManager.delegate = nil;
        [_locationManager release];
        _locationManager = nil;
    }
     */
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetNearbyStatus:) name:MMSinaGotNearbyStatuses object:nil];
    
    [manager getNearbyStatuses:_locationManager.location.coordinate];
    [self.tableView reloadData];
    self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    self.tableView.contentOffset = CGPointMake(0.0f, -65.0f);
    
    NSLog(@"NSVC: set after reloaddata: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top
          ,self.tableView.contentOffset.y);
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"正在定位..." inView:self.view];
    
    NSLog(@"NearbyStatusVC: viewDidAppear:%f,%f,statusArr: %i",_locationManager.location.coordinate.latitude,_locationManager.location.coordinate.longitude,statuesArr.count);
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (_locationManager) {
        [_locationManager stopUpdatingLocation];
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



-(void)didGetNearbyStatus:(NSNotification*)sender
{
    [self stopLoading];
    [self doneLoadingTableViewData];
    
    [statuesArr removeAllObjects];
    self.statuesArr = sender.object;
    [self.tableView reloadData];
    
    self.tableView.contentInset = UIEdgeInsetsMake(64, UIEdgeInsetsOriginal.left, UIEdgeInsetsOriginal.bottom, UIEdgeInsetsOriginal.right) ;
    self.tableView.contentOffset = CGPointMake(0.0f, -65.0f);
    
    NSLog(@"NSVC: did reloaddata: tableview.contentinset.top:%f; tableview.contentoffset.y:%f", self.tableView.contentInset.top
          ,self.tableView.contentOffset.y);
    
    [[SHKActivityIndicator currentIndicator] hide];
    //    [[ZJTStatusBarAlertWindow getInstance] hide];
    [self refreshVisibleCellsImages];
    
     NSLog(@"NearbyStatusVC: didGetNearbyStatus:%i", statuesArr.count);
}

#pragma mark - location Delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位出错");
    [[SHKActivityIndicator currentIndicator] hide];
}

- (void)locationManager:(CLLocationManager *)managerr
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{

    [manager getNearbyStatuses:newLocation.coordinate];
    [_locationManager stopUpdatingLocation];
    
    // NSLog(@"%f,%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
  
    //[_manager getNearbyStatuses:newLocation.coordinate];
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"正在载入..." inView:self.view];
    
     NSLog(@"NearbyStatusVC: didUpdateToLocation:%i", statuesArr.count);
}

@end
