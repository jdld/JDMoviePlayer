//
//  JDMoviePlayer.m
//  JDMoviePlayer
//
//  Created by Etong on 16/8/24.
//  Copyright © 2016年 Jdld. All rights reserved.
//

#import "JDMoviePlayer.h"

@interface JDMoviePlayer(){
    BOOL playState;
    BOOL fullScreen;
    BOOL flag;
    BOOL tapFlag;
    int MVindex;
}
@property (strong, nonatomic)NSArray *urlStr;

@property (strong, nonatomic)UIProgressView *insertProgress;
@property (strong, nonatomic)UILabel *timeLab;
@property (strong, nonatomic)UILabel *allTimeLab;
@property (strong, nonatomic)UIView *crlView;

@property (nonatomic)float totalTime;

@end

@implementation JDMoviePlayer

- (instancetype)initWithFrame:(CGRect)frame MovieUrl:(NSArray *)urlArr{
    self = [super initWithFrame:frame];
    if (self) {
        _urlStr = urlArr;
        [self setUI];
        [self addNotification];
        [self setValue];
    }
    return self;
}

- (void)dealloc {
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self removeNotification];
}

//初始化常量
- (void)setValue {
    playState = NO;
    fullScreen = NO;
    flag = YES;
    tapFlag = YES;
    MVindex = 0;
}

//初始化UI
- (void)setUI {
    CGSize viewSize = self.frame.size;
    //创建播放器层
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//视频填充模式
    [self.layer addSublayer:playerLayer];
    
    _crlView = [[UIView alloc]initWithFrame:CGRectMake(0, viewSize.height - 60, viewSize.width, 60)];
    
    _insertProgress = [[UIProgressView alloc]initWithFrame:CGRectMake(45, 14, self.frame.size.width - 90, 10)];
    
    _playOrPause = [[UIButton alloc]initWithFrame:CGRectMake(viewSize.width/2 - 10, 30, 20, 20)];
    
    _beforeBtn = [[UIButton alloc]initWithFrame:CGRectMake(viewSize.width/2 - 70, 30, 20, 20)];
    
    _afterBtn = [[UIButton alloc]initWithFrame:CGRectMake(viewSize.width/2 + 50, 30, 20, 20)];
    
    _timeLab = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 40, 20)];
    
    _allTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 40, 5, 40, 20)];
    
    _slider = [[UISlider alloc]initWithFrame:CGRectMake(-2, -4, self.frame.size.width - 86, 10)];
    
    [self setUIValue];
    
    [self addSubview:_crlView];
    [self.insertProgress addSubview:_slider];
    [self.crlView addSubview:_insertProgress];
    [self.crlView addSubview:_playOrPause];
    [self.crlView addSubview:_afterBtn];
    [self.crlView addSubview:_beforeBtn];
    [self.crlView addSubview:_allTimeLab];
    [self.crlView addSubview:_timeLab];
}

//设置控件属性
- (void)setUIValue {
    //主视图
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
    UITapGestureRecognizer *DoubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    [singleTap requireGestureRecognizerToFail:DoubleTap];//防止双击被单击截获
    [DoubleTap setNumberOfTapsRequired:2];//设置成双击
    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:singleTap];
    [self addGestureRecognizer:DoubleTap];
    
    //控制栏视图
    _crlView.backgroundColor = [UIColor blackColor];
    _crlView.alpha = 0.7;
    UITapGestureRecognizer *crlViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:nil];
    UITapGestureRecognizer *crlDoubleViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:nil];
    [crlDoubleViewTap setNumberOfTapsRequired:2];
    [_crlView addGestureRecognizer:crlViewTap];
    [_crlView addGestureRecognizer:crlDoubleViewTap];
    [_crlView setHidden:YES];
    
    //缓冲条
    _insertProgress.transform = CGAffineTransformMakeScale(1.0f, 2.0f);
    _insertProgress.progressTintColor = [UIColor grayColor];
    
    //滑动条
    _slider.maximumTrackTintColor = [UIColor clearColor];
    _slider.tintColor = [UIColor greenColor];
    _slider.layer.cornerRadius = 2;
    [_slider setThumbImage:[self OriginImage:[UIImage imageNamed:@"hot"] scaleToSize:CGSizeMake(5, 5)] forState:UIControlStateNormal];
    UITapGestureRecognizer *SliderTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sliderTapAction:)];
    [_slider addGestureRecognizer:SliderTap];
    
    //播放按钮
    [_playOrPause addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    [self setButton:_playOrPause imageName:@"pause"];
    
    //上一个视频按钮
    [_beforeBtn setImage:[UIImage imageNamed:@"before"] forState:UIControlStateNormal];
    [_beforeBtn addTarget:self action:@selector(beforeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //下一个视频按钮
     [_afterBtn setImage:[UIImage imageNamed:@"after"] forState:UIControlStateNormal];
     [_afterBtn addTarget:self action:@selector(afterAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //当前时间
    _timeLab.text = @"00:00:00";
    _timeLab.font = [UIFont systemFontOfSize:8];
    _timeLab.textColor = [UIColor whiteColor];
    
    //总时间
    _allTimeLab.text = @"00:00:00";
    _allTimeLab.font = [UIFont systemFontOfSize:8];
    _allTimeLab.textColor = [UIColor whiteColor];
    
    
    if (_urlStr.count == 1) {
        _beforeBtn.enabled = NO;
        _afterBtn.enabled = NO;
    }
}


#pragma mark - AVPlayer

- (AVPlayer *)player {
    if (!_player) {
        AVPlayerItem *playerItem = [self getPlayWithItem:MVindex];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        [self addProgressObserver];
        [self addObserverToPlayerItem:playerItem];
    }
    return _player;
}

/**
 *  根据视频索引取得AVPlayerItem对象
 *
 *  @param videoIndex 视频顺序索引
 *
 *  @return AVPlayerItem对象
 */
- (AVPlayerItem *)getPlayWithItem:(int)index {
    NSString *UrlStr = _urlStr[index];
    UrlStr = [UrlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<>"].invertedSet];
    NSURL *url = [NSURL URLWithString:UrlStr];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    return playerItem;
}


#pragma mark - 通知

- (void)addNotification {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playbackBegin:) name:AVPlayerItemTimeJumpedNotification object:self.player.currentItem];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    [self setButton:_playOrPause imageName:@"pause"];
    [_slider setValue:0];
    _timeLab.text = [NSString stringWithFormat:@"00:00:00"];
    [self.player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {}];
    playState = NO;
}

- (void)playbackBegin:(NSNotification *)notification {
    if (flag) {
        [self setButton:_playOrPause imageName:@"play"];
        playState = YES;
        flag = NO;
    }
}


#pragma mark - 监控
/**
 *  给播放器添加进度更新
 */
- (void)addProgressObserver {
    __weak typeof(self) weakself = self;
    //设置每秒更新一次
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = weakself.totalTime;
        weakself.timeLab.text = [NSString stringWithFormat:@"%@",[weakself timeFormatFromSeconds:current]];
        if (current) {
            [weakself.slider setValue:(current/total)];
        }
    }];
}

/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */
- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem {
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]){
        AVPlayerStatus status = [[change objectForKey:@"new"]intValue];
        if (status == AVPlayerStatusReadyToPlay) {
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            _totalTime = CMTimeGetSeconds(playerItem.duration);
            _allTimeLab.text = [self timeFormatFromSeconds:_totalTime];
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        if (totalBuffer) {
            [_insertProgress setProgress:totalBuffer animated:YES];
        }
    }
}

#pragma mark - UI事件
/**
 *  点击播放/暂停按钮
 *
 *  @param sender 播放/暂停按钮
 */
- (void)playClick:(UIButton *)sender  {
    if (playState) {
        [self pause];
        playState = NO;
    }else{
        [self play];
        playState = YES;
    }
}

//- (void)sliderAction:(UISlider *)sender {
//    float i = sender.value * (CMTimeGetSeconds([self.player.currentItem duration]));
//    [self.player seekToTime:CMTimeMake(i, 1) completionHandler:^(BOOL finished) {}];
//}

- (void)sliderTapAction:(UITapGestureRecognizer *)sender {
    if (sender.state == 3) {
        CGPoint touchPoint = [sender locationInView:_slider];
        CGFloat value = (_slider.maximumValue - _slider.minimumValue) * (touchPoint.x / _slider.frame.size.width);
        float i = value * (CMTimeGetSeconds([self.player.currentItem duration]));
        [self.player seekToTime:CMTimeMake(i, 1) completionHandler:^(BOOL finished) {}];
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)sender {
    float i = (_slider.value + [sender translationInView:self].x/5000)*(CMTimeGetSeconds([self.player.currentItem duration]));
    if (sender.state == 2) {
        [self.player seekToTime:CMTimeMake(i, 1) completionHandler:^(BOOL finished) {}];
    }
}

- (void)singleTapAction:(UITapGestureRecognizer *)sender {
    
    if (tapFlag) {
        [_crlView setHidden:NO];
        tapFlag = NO;
    }else{
        [_crlView setHidden:YES];
        tapFlag = YES;
    }
}

- (void)doubleTapAction:(UITapGestureRecognizer *)sender {
    if (playState){
        [self pause];
        playState = NO;
    }else{
        [self play];
        playState = YES;
    }
}

- (void)beforeAction:(UITapGestureRecognizer *)sender {
    if (MVindex > 0) {
        MVindex --;
    }
    [self changeMVindex];
}

- (void)afterAction:(UITapGestureRecognizer *)sender {
    if (MVindex < _urlStr.count - 1) {
        MVindex ++;
    }
    [self changeMVindex];
}

- (void)changeMVindex {
    [self removeNotification];
    [self removeObserverFromPlayerItem:self.player.currentItem];
    AVPlayerItem *playerItem=[self getPlayWithItem:MVindex];
    [self addProgressObserver];
    [self addObserverToPlayerItem:playerItem];
    //切换视频
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [self addNotification];
    _slider.value = 0;
    [self play];
}

#pragma mark - Utilities
/**
 * 获取自定义大小图片
 */
-(UIImage*) OriginImage:(UIImage*)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);//size为CGSize类型，即你所需要的图片尺寸
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

/**
 *  秒转时间
 */
- (NSString *)timeFormatFromSeconds:(NSInteger)seconds {
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    NSString *str_min = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    NSString *str_sec = [NSString stringWithFormat:@"%02ld",seconds%60];
    NSString *time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_min,str_sec];
    return time;
}

- (void)setButton:(UIButton *)btn imageName:(NSString *)imageName {
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)pause {
    [_player pause];
    [self setButton:_playOrPause imageName:@"pause"];
}

- (void)play {
    [self.player play];
    [self setButton:_playOrPause imageName:@"play"];
}

@end
