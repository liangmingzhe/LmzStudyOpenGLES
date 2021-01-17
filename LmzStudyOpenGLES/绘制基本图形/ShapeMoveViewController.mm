//
//  ShapeMoveViewController.m
//  OpenGL_Picture
//
//  Created by benjaminlmz@qq.com on 2021/1/15.
//

#import "ShapeMoveViewController.h"
/*
 通过改变顶点坐标使物体移动
 */
@interface ShapeMoveViewController () {
    EAGLContext     *mContext;
    GLKBaseEffect   *basicEffect;
}
@end
GLfloat x = 0.5f;
GLfloat squareVertexData[] = {
    x, -0.25, 0.0f,
    -x, -0.25, 0.0f,
    -x, 0.25, 0.0f,
    x, 0.25, 0.0f,
    x, -0.25, 0.0f,
};
@implementation ShapeMoveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    for (int i = 0; i < 5; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50+i*60, [UIScreen mainScreen].bounds.size.height - 100, 50, 50)];
        button.tag = i;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        switch (i) {
            case 0:
                [button setTitle:[NSString stringWithFormat:@"上"] forState:UIControlStateNormal];
                break;
            case 1:
                [button setTitle:[NSString stringWithFormat:@"左"] forState:UIControlStateNormal];
                break;
            case 2:
                [button setTitle:[NSString stringWithFormat:@"下"] forState:UIControlStateNormal];
                break;
            case 3:
                [button setTitle:[NSString stringWithFormat:@"右"] forState:UIControlStateNormal];
                break;
            default:
                [button setTitle:[NSString stringWithFormat:@"复位"] forState:UIControlStateNormal];
                break;
        }
        [button addTarget:self action:@selector(stepMove:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:mContext];
    
    GLKView *view = (GLKView *)self.view;
    view.context = mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;  //颜色缓冲区格式
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);


    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    //使能顶点数组
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //绑定顶点坐标
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, (GLfloat *)NULL + 0);


//    //着色器
    basicEffect = [[GLKBaseEffect alloc] init];
    basicEffect.useConstantColor = GL_TRUE;
    basicEffect.constantColor = GLKVector4Make(0.4f, 0.4f, 1.0f, 1.0f);
    
}

- (void)stepMove:(UIButton *)sender {
    GLfloat step_length = 0.05f;
    
    if (sender.tag == 0) {
        //上
        if (squareVertexData[7] >= 1) {
            return;
        }
        squareVertexData[1] = squareVertexData[1] + step_length;
        squareVertexData[4] = squareVertexData[4] + step_length;
        squareVertexData[7] = squareVertexData[7] + step_length;
        squareVertexData[10] = squareVertexData[10] + step_length;
        squareVertexData[13] = squareVertexData[13] + step_length;
    }else if(sender.tag == 1){
        if (squareVertexData[3] <= -1) {
            return;
        }
        //左
        squareVertexData[0] = squareVertexData[0] - step_length;
        squareVertexData[3] = squareVertexData[3] - step_length;
        squareVertexData[6] = squareVertexData[6] - step_length;
        squareVertexData[9] = squareVertexData[9] - step_length;
        squareVertexData[12] = squareVertexData[12] - step_length;

    }else if(sender.tag == 2){
        if (squareVertexData[1] <= -1) {
            return;
        }
        //下
        squareVertexData[1] = squareVertexData[1] - step_length;
        squareVertexData[4] = squareVertexData[4] - step_length;
        squareVertexData[7] = squareVertexData[7] - step_length;
        squareVertexData[10] = squareVertexData[10] - step_length;
        squareVertexData[13] = squareVertexData[13] - step_length;
     
    }else if(sender.tag == 3){
        if (squareVertexData[0] >= 1) {
            return;
        }
        //右
        squareVertexData[0] = squareVertexData[0] + step_length;
        squareVertexData[3] = squareVertexData[3] + step_length;
        squareVertexData[6] = squareVertexData[6] + step_length;
        squareVertexData[9] = squareVertexData[9] + step_length;
        squareVertexData[12] = squareVertexData[12] + step_length;
    }else {
        squareVertexData[0] = 0.5;
        squareVertexData[3] = -0.5;
        squareVertexData[6] = -0.5;
        squareVertexData[9] = 0.5;
        squareVertexData[12] = 0.5;
        
        squareVertexData[1] =  -0.25;
        squareVertexData[4] =  -0.25;
        squareVertexData[7] =  0.25;
        squareVertexData[10] = 0.25;
        squareVertexData[13] = -0.25;
    }
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    //使能顶点数组
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //绑定顶点坐标
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, (GLfloat *)NULL + 0);

}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.9f, 0.8f, 0.7f, 1.0f);//背景颜色
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //启动着色器
    [basicEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 5);

}
- (void)dealloc {
    NSLog(@"DrawImageViewController dealloc");
}

@end
