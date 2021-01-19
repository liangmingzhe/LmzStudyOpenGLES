//
//  BasicShapeViewController.h
//  LmzStudyOpenGLES
//
//  Created by lmz on 2021/1/17.
//

#import <GLKit/GLKit.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface BasicShapeViewController : GLKViewController
@property (nonatomic,strong)GLKBaseEffect   *basicEffect;
@property (nonatomic,strong)GLKTextureInfo  *sphereTextureInfo;

@end

NS_ASSUME_NONNULL_END
