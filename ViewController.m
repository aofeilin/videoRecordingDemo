//
//  ViewController.m
//  videoRecordingDemo
//
//  Created by ule_zhangfanglin on 2017/2/7.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayViewController.h"
#import "VideoRecordViewController.h"
#import "MyPlayViewController.h"
@interface ViewController ()<AVCaptureFileOutputRecordingDelegate>
{
    AVCaptureMovieFileOutput * output;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton * button_startButton1=[[UIButton alloc] initWithFrame:CGRectMake(100,100 ,150 , 50)];
    [button_startButton1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button_startButton1 setTitle:@"录制" forState:UIControlStateNormal];
    [button_startButton1 addTarget:self action:@selector(startAction1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_startButton1];
    
    
    
    UIButton * button_startButton2=[[UIButton alloc] initWithFrame:CGRectMake(100,400 ,150 , 50)];
    [button_startButton2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button_startButton2 setTitle:@"播放" forState:UIControlStateNormal];
    [button_startButton2 addTarget:self action:@selector(startAction2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_startButton2];
    
   
    
    
    
    

}
-(void)startAction2:(UIButton *)sender
{
    /** 播放
    PlayViewController *mPlayViewController = [[PlayViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:mPlayViewController animated:YES];*/
    
    
    /** 播放 */
    NSString * path=
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"myvideo.mov"];
    NSURL * url=[NSURL fileURLWithPath:path];
    if (!self.playbackViewController)
    {
        self.playbackViewController = [[MyPlayViewController alloc] initWithNibName:@"MyPlayViewController" bundle:nil];
    }
    [self.playbackViewController setURL:url];
    

    [self.navigationController pushViewController:self.playbackViewController animated:YES];
    
    
    
    
    
}
-(void)startAction1:(UIButton *)sender
{
    //录制
    VideoRecordViewController *mVideoRecordViewController = [[VideoRecordViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:mVideoRecordViewController animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
