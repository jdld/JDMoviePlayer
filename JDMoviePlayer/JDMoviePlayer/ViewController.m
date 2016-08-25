//
//  ViewController.m
//  JDMoviePlayer
//
//  Created by Etong on 16/8/24.
//  Copyright © 2016年 Jdld. All rights reserved.
//

#import "ViewController.h"
#import "JDMoviePlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *arr = @[@"http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4",@"http://bos.nj.bpc.baidu.com/tieba-smallvideo/00093abf03a6501f7ae84d3c5f6ad92f.mp4"];
    JDMoviePlayer *movie = [[JDMoviePlayer alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,300)MovieUrl:arr];
    [movie.player play];
    [self.view addSubview:movie];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
