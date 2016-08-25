//
//  JDMoviePlayer.h
//  JDMoviePlayer
//
//  Created by Etong on 16/8/24.
//  Copyright © 2016年 Jdld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface JDMoviePlayer : UIView

/**
 *  初始化JDMoviePlayer
 *
 *  @param frame  JDMoviePlayer的frame
 *  @param urlArr 视频网址的数组
 *
 *  @return   JDMoviePlayer
 */
- (instancetype)initWithFrame:(CGRect)frame MovieUrl:(NSArray *)urlArr;

/**
 *  播放视频 [movie.player play]
 *  暂停视频 [movie.player pause];
 *  初始化后默认为暂停状态
 */
@property (strong, nonatomic)AVPlayer *player;

/**
 *  视频播放状态按钮
 */
@property (strong, nonatomic)UIButton *playOrPause;

/**
 *  上一个视频按钮
 */
@property (strong, nonatomic)UIButton *beforeBtn;

/**
 *  下一个视频按钮
 */
@property (strong, nonatomic)UIButton *afterBtn;

/**
 *  进度条滑动块
 */
@property (strong, nonatomic)UISlider *slider;

@end
