//
//  ViewController.m
//  OGL_demo_display_picture
//
//  Created by benjaminlmz@qq.com on 2020/11/6.
//

#import "ViewController.h"
#define kFunctionCell @"Default"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray <NSDictionary *>* funcNameArray;
}
@property (weak, nonatomic) IBOutlet UITableView *functionTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"功能列表";
    funcNameArray = @[
        @{
            @"description":@"使用GLKView渲染",
            @"class":@"GLKImageViewController",
            @"param":@{}
        },
        @{
            @"description":@"使用CAEAGLLayer渲染",
            @"class":@"GLKImageViewController",
            @"param":@{}
        },
        @{
            @"description":@"绘制基本图形",
            @"class":@"DrawShapeViewController",
            @"param":@{}
        }
    ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return funcNameArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFunctionCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFunctionCell];
    }
    cell.textLabel.text = [funcNameArray[indexPath.row] valueForKey:@"description"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * className = [funcNameArray[indexPath.row] valueForKey:@"class"];
    Class cls = NSClassFromString(className);
    UIViewController *vc = [[cls alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
    
