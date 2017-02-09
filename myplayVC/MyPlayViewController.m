//
//  MyPlayViewController.m
//  videoRecordingDemo
//
//  Created by ule_zhangfanglin on 2017/2/8.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MyPlayViewController.h"

@interface MyPlayViewController ()

@end
static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;
@implementation MyPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setPlay:nil];
    //按钮 间距 滑动条
    UIBarButtonItem *  scrubberItem=[[UIBarButtonItem alloc] initWithCustomView:self.mScrubber];
//    UIBarButtonItem * flexItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    self.mToolbar.items=@[self.mPlayButton,scrubberItem];
    
    isSeeking=NO;
    [self initScrubberTimer];
    [self syncPlayPauseButtons];
    [self syncScrubber];
    [self prepareToPlayURL:mURL];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self setPlay:nil];
        
      
    }
    
    return self;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isPlaying
{
    return mRestoreAfterScrubbingRate != 0.f || [self.mPlayer rate] != 0.f;
}
#pragma mark ----play stop button
- (void)syncPlayPauseButtons
{
    if ([self isPlaying])
    {
        [self showStopButton];
    }
    else
    {
        [self showPlayButton];
    }
}

//显示停止按钮
-(void)showStopButton
{
    NSMutableArray * toolbarItems=[NSMutableArray arrayWithArray:self.mToolbar.items];
    [toolbarItems replaceObjectAtIndex:0 withObject:self.mStopButton];
     self.mToolbar.items = toolbarItems;
}

//显示播放按钮
-(void)showPlayButton
{
    NSMutableArray * toolbarIteams=[NSMutableArray arrayWithArray:self.mToolbar.items];
    [toolbarIteams replaceObjectAtIndex:0 withObject:self.mPlayButton];
     self.mToolbar.items = toolbarIteams;
}

//播放
- (IBAction)play:(id)sender {
    if (YES == seekToZeroBeforePlay) {
        seekToZeroBeforePlay = NO;
        [self.mPlayer seekToTime:kCMTimeZero];
    }
    [self.mPlayer play];
    [self showStopButton];
   
}
//停止
- (IBAction)pause:(id)sender {
    [self.mPlayer pause];
    [self showPlayButton];

}
-(void)enablePlayerButtons
{
    self.mPlayButton.enabled = YES;
    self.mStopButton.enabled = YES;
}

-(void)disablePlayerButtons
{
    self.mPlayButton.enabled = NO;
    self.mStopButton.enabled = NO;
}

#pragma  mark  ---slider

//同步slider change 
- (void)syncScrubber
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        _mScrubber.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue=[self.mScrubber minimumValue];
        float maxValue=[self.mScrubber maximumValue];
        double time=CMTimeGetSeconds([self.mPlayer currentTime]) ;
        [self.mScrubber setValue:(maxValue-minValue)* time/duration +minValue];
    }
}
//touch down
- (IBAction)beginScrubbing:(id)sender {
    //rate ==1.0，表示正在播放；rate == 0.0，暂停；rate == -1.0，播放失败
    mRestoreAfterScrubbingRate = [self.mPlayer rate];
    [self.mPlayer setRate:0.f];
    [self removePlayerTimeObserver];
    
}
//touch  cancel ----touch up inside  -----touch up outside
- (IBAction)endScrubbing:(id)sender {
    if (!mTimeObserver)
    {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            CGFloat width = CGRectGetWidth([self.mScrubber bounds]);
            double tolerance = 0.5f * duration / width;
            
            __weak MyPlayViewController  * weakSelf = self;
            mTimeObserver = [self.mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:
                             ^(CMTime time)
                             {
                                 [weakSelf syncScrubber];
                             }];
        }
    }
    
    if (mRestoreAfterScrubbingRate)
    {
        [self.mPlayer setRate:mRestoreAfterScrubbingRate];
        mRestoreAfterScrubbingRate = 0.f;
    }

    
    
}
//----drag inside  ------value change
- (IBAction)scrub:(id)sender {
    if ([sender isKindOfClass:[UISlider class]]&&!isSeeking) {
        isSeeking =YES;
        UISlider * slider=sender;
        CMTime playDuration=[self playerItemDuration];
        double duration = CMTimeGetSeconds(playDuration);
        if (isfinite(duration))
        {
            float minValue = [slider minimumValue];
            float maxValue = [slider maximumValue];
            float value = [slider value];
            double time = duration * (value - minValue) / (maxValue - minValue);
            [self.mPlayer seekToTime:CMTimeMakeWithSeconds(time,NSEC_PER_SEC)
                   completionHandler:^(BOOL finished) {
                       isSeeking = NO;
                   }];
        }
    }
    

}
-(void)enableScrubber
{
    self.mScrubber.enabled = YES;
}

-(void)disableScrubber
{
    self.mScrubber.enabled = NO;
}

- (BOOL)isScrubbing
{
    return mRestoreAfterScrubbingRate != 0.f;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self.mPlayer pause];
    
    [super viewWillDisappear:animated];
}




#pragma mark ----play

//监听间隔变动
-(void)initScrubberTimer
{
    double interval=.1f;
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_VALID(playerDuration)) {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        CGFloat width= CGRectGetWidth([self.mScrubber bounds]);
        interval=duration / width*0.5;
    }
    
    __weak MyPlayViewController * weakSelf=self;
    //添加监听间隔变动
    mTimeObserver =[self.mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval,NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf  syncScrubber];
    }];
    
}
//监听取消
/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
    if (mTimeObserver)
    {
        [self.mPlayer removeTimeObserver:mTimeObserver];
        mTimeObserver = nil;
    }
}
//总时长
-(CMTime)playerItemDuration
{
    
    AVPlayerItem  * playItem =[self.mPlayer currentItem];
    if (playItem.status == AVPlayerItemStatusReadyToPlay) {
        return [playItem duration];
    }
    return kCMTimeInvalid;
}

#pragma mark Asset URL

- (void)setURL:(NSURL*)URL
{
    if (mURL != URL)
    {
        mURL = [URL copy];
    }
}
-(void)prepareToPlayURL:(NSURL *) url
{
    if (self.mPlayer) {
        [self.mPlayerItem removeObserver:self forKeyPath:@"status"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.mPlayerItem];
    }
    
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.mPlayerItem = [AVPlayerItem playerItemWithURL:url];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.mPlayerItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.mPlayerItem];
     seekToZeroBeforePlay = NO;
    
    if (!self.mPlayer)
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlay:[AVPlayer playerWithPlayerItem:self.mPlayerItem]];
        
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [self.player addObserver:self
                      forKeyPath:@"currentItem"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self
                      forKeyPath:@"rate"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.mPlayerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur
         
         If needed, configure player item here (example: adding outputs, setting text style rules,
         selecting media options) before associating it with a player
         */
        [self.mPlayer replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        
        [self syncPlayPauseButtons];
    }
    
    [self.mScrubber setValue:0.0];

}
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    /* After the movie has played to its end time, seek back to time zero
     to play it again. */
    seekToZeroBeforePlay = YES;
}
- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* AVPlayerItem "status" property value observer. */
    if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext)
    {
        [self syncPlayPauseButtons];
        
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerItemStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                
                [self disableScrubber];
                [self disablePlayerButtons];
            }
                break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                [self initScrubberTimer];
                
                [self enableScrubber];
                [self enablePlayerButtons];
            }
                break;
                
            case AVPlayerItemStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
               [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
    }
    /* AVPlayer "rate" property value observer. */
    else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext)
    {
        [self syncPlayPauseButtons];
    }
    /* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
    else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
            [self disablePlayerButtons];
            [self disableScrubber];
        }
        else /* Replacement of player currentItem has occurred */
        {
            [self.playViewContent setPlayer:self.mPlayer];
            
            /* Specifies that the player should preserve the video’s aspect ratio and
             fit the video within the layer’s bounds. */
//            [self.playViewContent setVidoFillMode:AVLayerVideoGravityResizeAspect];
            
            [self syncPlayPauseButtons];
        }
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}
-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self disableScrubber];
    [self disablePlayerButtons];
    
    /* Display the error. */
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


- (NSURL*)URL
{
    return mURL;
}








@end
