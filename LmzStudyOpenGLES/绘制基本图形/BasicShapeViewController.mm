//
//  BasicShapeViewController.m
//  LmzStudyOpenGLES
//
//  Created by lmz on 2021/1/17.
//

#import "BasicShapeViewController.h"

@interface BasicShapeViewController () {
    EAGLContext     *mContext;
    GLKBaseEffect   *basicEffect;
    int mCount;

}

@end


@implementation BasicShapeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:mContext];
    
    GLKView *view = (GLKView *)self.view;
    view.context = mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;  //颜色缓冲区格式
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);

    
    GLfloat squareVertexData1[] = {
      //顶点                     颜色                     纹理坐标
        -0.5f, 0.5f, 0.0f,      0.5f, 0.5f, 0.5f,       0.0f, 1.0f,//左上
        0.5f, 0.5f, 0.0f,       0.0f, 0.5f, 0.0f,       1.0f, 1.0f,//右上
        -0.5f, -0.5f, 0.0f,     0.5f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
        0.5f, -0.5f, 0.0f,      0.5f, 0.5f, 0.5f,       1.0f, 0.0f,//右下
        0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点

    };
    GLuint indices[] = {
        0, 2, 3,
        0, 3, 1,
        
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };

    mCount = sizeof(indices)/sizeof(GLuint);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);    //不是用GL_ELEMENT_ARRAY_BUFFER 会崩溃
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData1), squareVertexData1, GL_STATIC_DRAW);
    
    //使用顶点数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, NULL);
    
    //使用颜色数据
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 3);
    
    //使用纹理数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 6);


//    //着色器
    //纹理 将图片转换成纹理
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"dolaameng" ofType:@"jpg"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil]; //从左下角加载
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    //着色器
    basicEffect = [[GLKBaseEffect alloc] init];
    basicEffect.texture2d0.enabled = GL_TRUE;
    basicEffect.texture2d0.name = textureInfo.name;
    
    //设置投影 矩阵
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height); //宽高比
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1f, 10.f); //透视参数
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);     //矩阵缩放
    basicEffect.transform.projectionMatrix = projectionMatrix;
    
    //模型矩阵
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    basicEffect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.9f, 0.8f, 0.7f, 1.0f);//背景颜色
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //启动着色器
    [basicEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, mCount, GL_UNSIGNED_INT, 0);


}

@end
