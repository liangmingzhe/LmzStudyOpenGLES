//
//  OGImageView.m
//  OGDemo_图像显示
//
//  Created by benjaminlmz@qq.com on 2020/11/5.
//
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "OGImageView.h"
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
};
@interface OGImageView() {
    GLuint glProgram;
    GLuint texture0Uniform;
    GLuint mbuffer;
    GLint mBackingWidth;
    GLint mBackingHeight;
}
@property (nonatomic , strong) EAGLContext *mContext;       //OpenGL 句柄
@property (nonatomic , assign) GLuint texture0;
@property (nonatomic , assign) GLuint mRenderBufferHandle;
@property (nonatomic , assign) GLuint mframeBufferHandle;
@end
@implementation OGImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setupUI];
    }
    return self;
}
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupUI {
    //---------------------------- 第一步：初始化句柄    ----------------------------
    BOOL retCode = [self initContext];
    if (retCode == NO) return;
//    glEnable(GL_DEPTH_TEST);
    //---------------------------- 第二步：帧缓冲对象  ----------------------------

    glGenFramebuffers(1, &_mframeBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, _mframeBufferHandle);
    
    //---------------------------- 第三步：渲染缓冲 ----------------------------
    glGenRenderbuffers(1, &_mRenderBufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, _mRenderBufferHandle);
    [self.mContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer]; // 为渲染缓冲对象分配存储空间

    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _mRenderBufferHandle); //关联帧缓冲对象和渲染缓冲对象
    
    //检查状态帧缓冲对象
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return;
    }
    //---------------------------- 第四步：加载着色器程序 ----------------------------
    [self loadShaders];
    //---------------------------- 第五步：将图片转换成纹理 ----------------------------
    [self drawImage];
    //---------------------------- 第六步：绑定顶点矩阵并将设置顶点读取规则 ----------------------------
    [self setupVertexAttribArray];
    //---------------------------- 第七步：执行渲染   ----------------------------
    glViewport(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height); //设    置窗口大小
    glDrawArrays(GL_TRIANGLES, 0, 6);
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
}

//初始化句柄
- (BOOL)initContext {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO],
                                    kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8,
                                    kEAGLDrawablePropertyColorFormat,
                                    nil];
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.mContext) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        return  NO;
    }
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:self.mContext]) {
        NSLog(@"Failed to set current OpenGL context");
        return  NO;
    }

    return YES;
}


// 加载着色器程序
- (BOOL)loadShaders{
    GLuint vertShader = 0;
    GLuint fragShader = 0;
    // Create the shader program.
    glProgram = glCreateProgram();
    
    NSURL *vertShaderURL = [[NSBundle mainBundle] URLForResource:@"Shader" withExtension:@"vsh"];
    BOOL vertexRet = [self compileShaderString:&vertShader type:GL_VERTEX_SHADER shaderUrl:vertShaderURL];
    if (vertexRet == NO) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    NSURL *frameShaderURL = [[NSBundle mainBundle] URLForResource:@"Shader" withExtension:@"fsh"];
    BOOL fragmentRet = [self compileShaderString:&fragShader type:GL_FRAGMENT_SHADER shaderUrl:frameShaderURL];
    
    if (fragmentRet == NO) {
        NSLog(@"Failed to compile frame shader");
        return NO;
    }
    // Attach vertex shader to program.
    glAttachShader(glProgram, vertShader);
    // Attach fragment shader to program.
    glAttachShader(glProgram, fragShader);
    glBindAttribLocation(glProgram, ATTRIB_VERTEX,   "position");
    glBindAttribLocation(glProgram, ATTRIB_TEXCOORD, "textCoordinate");


    // Link the program.
    BOOL linkState = [self linkProgram:glProgram];
    if (linkState == NO) {
        NSLog(@"Failed to link program: %d", glProgram);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (glProgram) {
            glDeleteProgram(glProgram);
            glProgram = 0;
        }
        
        return NO;
    }
    glUseProgram(glProgram);
    
    texture0Uniform = glGetUniformLocation(glProgram, "myTexture0");

    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(glProgram, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(glProgram, fragShader);
        glDeleteShader(fragShader);
    }
    return YES;
    
    
}


#pragma mark    编译着色器程序
/**
 *  @abstract:  编译GLSL着色器程序
 *  @param  shader   着色器标示
 *  @param  type        着色器类型
 *  @param  shaderUrl   着色器程序路径
 *  @return 返回值 YES 成功  NO  失败
 */
- (BOOL)compileShaderString:(GLuint *)shader type:(GLenum)type shaderUrl:(NSURL *)shaderUrl{
    *shader = glCreateShader(type);
    
    NSError *error;
    NSString *sourceString = [[NSString alloc] initWithContentsOfURL:shaderUrl encoding:NSUTF8StringEncoding error:&error];
    if (sourceString == nil) {
        NSLog(@"Failed to load vertex shader: %@", [error localizedDescription]);
        return NO;
    }
    
    const GLchar *source;
    source = (GLchar *)[sourceString UTF8String];
    
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    GLint status = 0;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}
#pragma mark    连接 Program
- (BOOL)linkProgram:(GLuint)prog{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif

    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

//绑定顶点矩阵并将设置顶点读取规则
- (void)setupVertexAttribArray {
    //顶点数据，前三个是顶点坐标，后面两个是纹理坐标
    GLfloat squareVertexData[] = {
        1, -1, 0.0f,    0.0f, 0.0f, //左下
        -1, -1, 0.0f,   1.0f, 0.0f, //右下
        -1, 1, 0.0f,    1.0f, 1.0f, //左上
        
        1, 1, -0.0f,    0.0f, 1.0f, //左上
        1, -1, 0.0f,    0.0f, 0.0f, //左下
        -1, 1, 0.0f,    1.0f, 1.0f, //右下
    };
    
    glGenBuffers(1, &mbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, mbuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    /*
        默认情况下，出于性能考虑，所有顶点着色器的属性（Attribute）变量都是关闭的，意味着数据在着色器端是不可见的，哪怕数据已经上传到GPU。
     由glEnableVertexAttribArray启用指定属性，才可在顶点着色器中访问逐顶点的属性数据
     */
    //使能属性 ATTRIB_VERTEX    该属性对象是顶点着色器的 position
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    //绑定顶点坐标
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    //使能纹理数组
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    //绑定纹理坐标点
    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    glUniform1i(texture0Uniform, 0);
    
    
}

- (void)drawImage {
    UIImage *img = [UIImage imageNamed:@"dolaameng.jpg"];
    
    CGImageRef cgImg = [img CGImage];
    
    size_t width = self.frame.size.width;
    
    size_t height = self.frame.size.height;
    
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte)); //rgba共4个byte
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(cgImg), kCGImageAlphaPremultipliedLast);
    // 3在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), cgImg);
    
    CGContextRelease(spriteContext);
        
    glActiveTexture(GL_TEXTURE0); //激活纹理单元
    glEnable(GL_TEXTURE_2D);
    glGenTextures(1, &_texture0);
    glBindTexture(GL_TEXTURE_2D, _texture0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //如果你想加载视频帧，或图片序列，你需要将以下的glTexImage2D（）代码放到display()函数中，并且加上计时函数以便更新画面，如果从摄像机读的帧数据直接贴也是可以的
    float fw = width, fh = height;
    mBackingWidth = fw;
    mBackingHeight = fh;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    free(spriteData);
}


@end
