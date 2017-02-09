//
//  MyPlayViewContent.h
//  videoRecordingDemo
//
//  Created by ule_zhangfanglin on 2017/2/8.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVPlayer;
@interface MyPlayViewContent : UIView
-(void)setPlayer:(AVPlayer *)player;
-(void)setVidoFillMode:(NSString *)fillMode;
@end
