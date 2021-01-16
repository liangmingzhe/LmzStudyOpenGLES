//
//  GLKImageViewController.m
//  OpenGL_Picture
//
//  Created by benjaminlmz@qq.com on 2020/11/4.
//

#import "GLKImageViewController.h"
#define USE_GLDRAWELEMENTS YES
@interface GLKImageViewController (){
    EAGLContext *mContext;
    GLKBaseEffect *basicEffect;
    int mCount;
    
}

@end


@implementation GLKImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (USE_GLDRAWELEMENTS == YES) {
        [self drawMethod1];
    }else {
        [self drawMethod2];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    glFlush();
}

- (void)drawMethod1 {
    mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:mContext];
    
    GLKView *view = (GLKView *)self.view;
    view.context = mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;  //颜色缓冲区格式
    
    //顶点数据，前三个是顶点坐标，后面两个是   纹理坐标
    GLfloat squareVertexData[] =
    {
        1, -1, 0.0f,    1.0f, 0.0f, //右下
        -1, 1, 0.0f,    0.0f, 1.0f, //左上
        -1, -1, 0.0f,   0.0f, 0.0f, //左下
        1, 1, -0.0f,    1.0f, 1.0f, //右上

    };
    
    //顶点索引
    GLuint indices[] =
    {
        0, 1, 2,
        1, 3, 0
    };
    
    mCount = sizeof(indices)/sizeof(GLuint);
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);    //不是用GL_ELEMENT_ARRAY_BUFFER 会崩溃
    
    //使能顶点数组
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //绑定顶点坐标
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    
    //使能纹理数组
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    //绑定纹理坐标点
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    
    //纹理贴图
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"dolaameng" ofType:@"jpg"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    //着色器
    basicEffect = [[GLKBaseEffect alloc] init];
    basicEffect.texture2d0.enabled = GL_TRUE;
    basicEffect.texture2d0.name = textureInfo.name;
    
}

- (void)drawMethod2 {
    mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:mContext];
    
    GLKView *view = (GLKView *)self.view;
    view.context = mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;  //颜色缓冲区格式
    
    
    //顶点数据，前三个是顶点坐标，后面两个是纹理坐标
    GLfloat squareVertexData[] =
    {
        1, -1, 0.0f,    1.0f, 0.0f, //右下
        -1, 1, 0.0f,    0.0f, 1.0f, //左上
        -1, -1, 0.0f,   0.0f, 0.0f, //左下
        
        1, 1, -0.0f,    1.0f, 1.0f, //右上
        1, -1, 0.0f,    1.0f, 0.0f, //右下
        -1, 1, 0.0f,    0.0f, 1.0f, //左上

    };

    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    //使能顶点数组
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //绑定顶点坐标
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    
    //使能纹理数组
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    //绑定纹理坐标点
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    
    //纹理贴图
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"dolaameng" ofType:@"jpg"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    //着色器
    basicEffect = [[GLKBaseEffect alloc] init];
    basicEffect.texture2d0.enabled = GL_TRUE;
    basicEffect.texture2d0.name = textureInfo.name;
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //启动着色器
    [basicEffect prepareToDraw];
    if (USE_GLDRAWELEMENTS == YES) {
        glDrawElements(GL_TRIANGLES, mCount, GL_UNSIGNED_INT, 0);
    }else {
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }

}
- (void)dealloc {
    NSLog(@"GLKImageViewController dealloc...");
}
@end
