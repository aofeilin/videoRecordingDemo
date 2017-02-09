//
//  PlayViewController.m
//  videoRecordingDemo
//
//  Created by ule_zhangfanglin on 2017/2/7.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "PlayViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayViewController ()
{
    AVPlayerItem *  _myPlayerItem1;
    AVPlayerLayer *_playerLayer1;
    
}
//废弃 MPMoviePlayerController
//@property (nonatomic, retain) MPMoviePlayerController* player;


@end

@implementation PlayViewController
- (void)playMovie
{
    NSString * path=
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"myvideo.mov"];
    
    NSURL * url=[NSURL fileURLWithPath:path];
    // 播放本地视频
   // NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"movie02" ofType:@"mov"];
   // NSURL *url = [NSURL fileURLWithPath:urlStr];
    //播放网络视频
  //   NSURL *url = [NSURL URLWithString:@"https://flv2.bn.netease.com/videolib3/1510/25/bIHxK3719/SD/bIHxK3719-mobile.mp4"];
    if (self.player)
    {
        // 已经创建则不再创建
        return;
    }
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:item];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = CGRectMake(10.0, 50.0, (self.view.bounds.size.width - 10.0 * 2), 200.0);
    [self.view.layer addSublayer:layer];
    [self.player play];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"播放" style:UIBarButtonItemStyleDone target:self action:@selector(playMovie)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
