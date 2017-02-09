//
//  MyPlayViewController.h
//  videoRecordingDemo
//
//  Created by ule_zhangfanglin on 2017/2/8.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//@class MyPlayViewContent;
#import "MyPlayViewContent.h"
@interface MyPlayViewController : UIViewController

{
    NSURL* mURL;
    AVPlayer* mPlayer;
    AVPlayerItem * mPlayerItem;
    
    
    
    
    BOOL seekToZeroBeforePlay;
    BOOL isSeeking;
    id mTimeObserver;
    float mRestoreAfterScrubbingRate;
    
}
@property (nonatomic, copy) NSURL* URL;
@property (strong, nonatomic) IBOutlet MyPlayViewContent *playViewContent;
@property(strong,readwrite,setter=setPlay:,getter=player)AVPlayer* mPlayer;
@property (strong) AVPlayerItem* mPlayerItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mPlayButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mStopButton;
@property (strong, nonatomic) IBOutlet UIToolbar *mToolbar;
@property (strong, nonatomic) IBOutlet UISlider *mScrubber;

- (void)setURL:(NSURL*)URL;
- (NSURL*)URL;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;

@end
