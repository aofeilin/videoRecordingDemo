//
//  MyPlayViewContent.m
//  videoRecordingDemo
//
//  Created by ule_zhangfanglin on 2017/2/8.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MyPlayViewContent.h"
#import <AVFoundation/AVFoundation.h>
@implementation MyPlayViewContent

//UIView有个layer属性 可以返回它的主CALayer实例 UIView有一个layerClass方法，返回主layer所使用的类，UIView的子类，可以通过重载这个方法，来让UIView使用不同的CALayer来显示  default is [CALayer class] 单纯使用AVPlayer类是无法显示视频的，要将视频层添加至AVPlayerLayer中
+(Class)layerClass
{
    return [AVPlayerLayer class];
}

-(AVPlayer *)player
{
    return [(AVPlayerLayer *)[self layer] player];
}

-(void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)[self layer]  setPlayer:player];
}
-(void)setVidoFillMode:(NSString *)fillMode
{
    AVPlayerLayer * playerLayer=(AVPlayerLayer *)[self layer];
    playerLayer.videoGravity=fillMode;//默认是AVLayerVideoGravityResizeAspect
}

@end
