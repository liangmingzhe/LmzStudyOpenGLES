//
//  DrawShapeViewController.m
//  OpenGL_Picture
//
//  Created by benjaminlmz@qq.com on 2021/1/15.
//

#import "DrawShapeViewController.h"

@interface DrawShapeViewController () {
    EAGLContext     *mContext;
    GLKBaseEffect   *basicEffect;
    GLuint buffer;
    float delta;
    BOOL state;
}

@end

@implementation DrawShapeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:mContext];
    
    GLKView *view = (GLKView *)self.view;
    view.context = mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;  //颜色缓冲区格式
    delta = 0;
    state = YES;
    
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    
//    //使能纹理数组
//    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//    //绑定纹理坐标点
//    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    
//    //纹理贴图
//    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"dolaameng" ofType:@"jpg"];
//    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
//    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
//
//    //着色器
    basicEffect = [[GLKBaseEffect alloc] init];
    basicEffect.useConstantColor = GL_TRUE;
    basicEffect.constantColor = GLKVector4Make(0.4f, 0.4f, 1.0f, 1.0f);
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    if (state == YES) {
        if (delta >= 0.5) {
            state = NO;
        }else {
            delta = delta + 0.004;
        }
    }else {
        if (delta <= -0.5) {
            state = YES;
        }else {
            delta = delta - 0.004;
        }
    }
    
    GLfloat squareVertexData[] = {
        0.5 + delta, -0.25, 0.0f,
        -0.5 + delta, -0.25, 0.0f,
        -0.5 + delta, 0.25, 0.0f,
        0.5 + delta, 0.25, 0.0f,
        0.5 + delta, -0.25, 0.0f,
    };


    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    //使能顶点数组
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //绑定顶点坐标
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, (GLfloat *)NULL + 0);

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
