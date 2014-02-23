//
//  AddCommentVC.m
//  zjtSinaWeiboClient
//
//  Created by Jianting Zhu on 12-3-28.
//  Copyright (c) 2012年 ZUST. All rights reserved.
//

#import "AddCommentVC.h"
#import "WeiBoMessageManager.h"

@interface AddCommentVC ()

@end

@implementation AddCommentVC
@synthesize imageV;
@synthesize contentV;
@synthesize contentStr;
@synthesize weiboID;
@synthesize commentID;
@synthesize status;
@synthesize vctype = _vctype;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _vctype = kRepost;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imageV.image = [[UIImage imageNamed:@"input_window.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:20];
    self.contentV.text = contentStr;
    
    UIBarButtonItem *sendBtn;
    
    //回复微博
    if (_vctype == kReplyAStatus) {
        sendBtn = [[UIBarButtonItem alloc] initWithTitle:@"评论" style:UIBarButtonItemStylePlain target:self action:@selector(commentStatus)];
        self.title = @"评论微博";
    }
    
    //转发
    else if(_vctype == kRepost){
        sendBtn = [[UIBarButtonItem alloc] initWithTitle:@"转发" style:UIBarButtonItemStylePlain target:self action:@selector(repost)];
        self.title = @"转发微博";
    }
    
    //回复评论
    else{
        sendBtn = [[UIBarButtonItem alloc] initWithTitle:@"回复评论" style:UIBarButtonItemStylePlain target:self action:@selector(commentComment)];
        self.title = @"回复评论";
    }

    self.navigationItem.rightBarButtonItem = sendBtn;
    //[sendBtn release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetRepostResult:) name:MMSinaGotRepost object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCommentAStatusResult:) name:MMSinaCommentAStatus object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetReplyACommentResult:) name:MMSinaReplyAComment object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [contentV becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setImageV:nil];
    [self setContentV:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MMSinaGotRepost object:nil];
    [super viewDidUnload];
}



-(void)didGetRepostResult:(NSNotification*)sender
{
     NSLog(@"AddCommentVC: didGetRepostResult: sender :%@", sender);
}

-(void)didGetCommentAStatusResult:(NSNotification*)sender
{
     NSLog(@"AddCommentVC: didGetCommentAStatusResult: sender :%@", sender);}

-(void)didGetReplyACommentResult:(NSNotification*)sender
{
     NSLog(@"AddCommentVC: didGetReplyACommentResult: sender :%@", sender);
}


//转发
-(void)repost
{
    NSLog(@"AddCommentVC: repost: weiboID :%@", weiboID);
    [[WeiBoMessageManager getInstance] repost:weiboID content:contentV.text withComment:1];
}

//评论微博
-(void)commentStatus
{
    NSLog(@"AddCommentVC: commentStatus: weiboID :%@", weiboID);
    [[WeiBoMessageManager getInstance] commentAStatus:weiboID content:contentV.text];
}

//回复评论
-(void)commentComment
{    NSLog(@"AddCommentVC: commentComment: weiboID :%@; commentID: %@", weiboID, commentID);
    [[WeiBoMessageManager getInstance] replyACommentWeiboId:weiboID commentID:commentID content:contentV.text];
}
@end
