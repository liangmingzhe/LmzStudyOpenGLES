//
//  BasicShapeViewController.m
//  LmzStudyOpenGLES
//
//  Created by lmz on 2021/1/17.
//

#import "BasicShapeViewController.h"
#import "sphere.h"
#import "cube.h"

@interface BasicShapeViewController ()
{
    EAGLContext     *mContext;
    
    int mCount;

    NSTimer *timer;
    float randiusX;
    float randiusY;
    float randiusZ;
    BOOL  isRotationX;
    BOOL  isRotationY;
    BOOL  isRotationZ;
    
    BOOL useElement;
}


@end


@implementation BasicShapeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    useElement = YES;
    [self setupButton];
    
    
    mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:mContext];
    
    GLKView *view = (GLKView *)self.view;
    view.context = mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;  //颜色缓冲区格式
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);

    glEnable(GL_DEPTH_TEST);
    
//    [self pyramid];
//    [self cube];
    
    useElement = NO;
    [self sphere];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateModelView) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)cube {
    GLuint indices[] = {
        0,  1,  2,
        3,  4,  5,
        6,  7,  8,
        9,  10, 11,
        12, 13, 14,
        15, 16, 17,
        18, 19, 20,
        21, 22, 23,
        24, 25, 26,
        27, 28, 29,
        30, 31, 32,
        33, 34, 35,
    };

    mCount = sizeof(indices)/sizeof(GLuint);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);    //不是用GL_ELEMENT_ARRAY_BUFFER 会崩溃
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVerts), cubeVerts, GL_STATIC_DRAW);

    //使用顶点数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    
    //使用纹理数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);


//    //着色器
    //纹理 将图片转换成纹理
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"dolaameng" ofType:@"jpg"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil]; //从左下角加载
    self.sphereTextureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    //着色器
    self.basicEffect = [[GLKBaseEffect alloc] init];
    self.self.basicEffect.texture2d0.enabled = GL_TRUE;
    self.basicEffect.texture2d0.name = self.sphereTextureInfo.name;

    //设置投影 矩阵
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height); //宽高比
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1f, 10.f); //透视参数
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);     //矩阵缩放
    self.basicEffect.transform.projectionMatrix = projectionMatrix;
}
- (void)pyramid {
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
    self.basicEffect = [[GLKBaseEffect alloc] init];
    self.basicEffect.texture2d0.enabled = GL_TRUE;
    self.basicEffect.texture2d0.name = textureInfo.name;
    
    //设置投影 矩阵
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height); //宽高比
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1f, 10.f); //透视参数
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);     //矩阵缩放
    self.basicEffect.transform.projectionMatrix = projectionMatrix;
}

- (void)sphere {
    
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ARRAY_BUFFER, index);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereVerts), sphereVerts, GL_STATIC_DRAW);    //不是用GL_ELEMENT_ARRAY_BUFFER 会崩溃
    
    //使用顶点数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, NULL);

    GLuint index2;
    glGenBuffers(1, &index2);
    glBindBuffer(GL_ARRAY_BUFFER, index2);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereTexCoords), sphereTexCoords, GL_STATIC_DRAW);
    //使用纹理数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 2, NULL);


//    //着色器
    //纹理 将图片转换成纹理
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Earth512x256" ofType:@"jpg"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil]; //从左下角加载
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    //着色器
    self.basicEffect = [[GLKBaseEffect alloc] init];
    self.basicEffect.texture2d0.enabled = GL_TRUE;
    self.basicEffect.texture2d0.name     = textureInfo.name;
    
    
    //设置投影 矩阵
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height); //宽高比
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1f, 10.f); //透视参数
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);     //矩阵缩放
    self.basicEffect.transform.projectionMatrix = projectionMatrix;
}

//设置按键
- (void)setupButton {
    for (int i = 0; i < 5; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50+i*60, [UIScreen mainScreen].bounds.size.height - 100, 50, 50)];
        button.tag = i;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        switch (i) {
            case 0:
                [button setTitle:[NSString stringWithFormat:@"X"] forState:UIControlStateNormal];
                break;
            case 1:
                [button setTitle:[NSString stringWithFormat:@"Y"] forState:UIControlStateNormal];
                break;
            case 2:
                [button setTitle:[NSString stringWithFormat:@"Z"] forState:UIControlStateNormal];
                break;
            case 3:
                [button setTitle:[NSString stringWithFormat:@"Stop"] forState:UIControlStateNormal];
                break;
            case 4:
                [button setTitle:[NSString stringWithFormat:@"Reset"] forState:UIControlStateNormal];
                break;
            default:
                [button setTitle:[NSString stringWithFormat:@"Stop"] forState:UIControlStateNormal];
                break;
        }
        [button addTarget:self action:@selector(rotation:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)rotation:(UIButton *)sender {
    if (sender.tag == 0) {
        isRotationX = !isRotationX;
    }
    else if (sender.tag == 1) {
        isRotationY = !isRotationY;
    }
    else if (sender.tag == 2) {
        isRotationZ = !isRotationZ;
    }
    else if (sender.tag == 3) {
        isRotationX = NO;
        isRotationY = NO;
        isRotationZ = NO;
    }else {
        randiusX = 0;
        randiusY = 0;
        randiusZ = -2;
    }

}
- (void)updateModelView {
    //模型矩阵
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, isRotationX==YES?randiusX+=0.1:randiusX);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, isRotationY==YES?randiusY+=0.1:randiusY);
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, isRotationZ==YES?randiusZ+=0.1:randiusZ);
    self.basicEffect.transform.modelviewMatrix = modelViewMatrix;
}



- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.9f, 0.8f, 0.7f, 1.0f);//背景颜色
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self updateModelView];
    //启动着色器
    [self.basicEffect prepareToDraw];
    
    if (useElement == YES) {
        glDrawElements(GL_TRIANGLES, mCount, GL_UNSIGNED_INT, 0);
    } else {
        glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    }



}

@end
