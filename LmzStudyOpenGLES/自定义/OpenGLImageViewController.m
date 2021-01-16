//
//  OpenGLImageViewController.m
//  OGDemo_图像显示
//
//  Created by benjaminlmz@qq.com on 2020/11/5.
//

#import "OpenGLImageViewController.h"
#import "OGImageView.h"

@interface OpenGLImageViewController ()
@end

@implementation OpenGLImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    OGImageView *OGView = [[OGImageView alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:OGView];
    
}


@end
