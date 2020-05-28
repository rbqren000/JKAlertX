//
//  JKAlertVisualFormatConstraintManager.h
//  JKAlertX
//
//  Created by albert on 2020/5/20.
//

#import <Foundation/Foundation.h>

@interface JKAlertVisualFormatConstraintManager : NSObject

+ (void)addConstraintsWithHorizontalFormat:(NSString *)horizontalFormat
                            verticalFormat:(NSString *)verticalFormat
                               viewKeyName:(NSString *)viewKeyName
                                targetView:(UIView *)targetView
                           constraintsView:(UIView *)constraintsView;

+ (void)addZeroEdgeConstraintsWithTargetView:(UIView *)targetView
                             constraintsView:(UIView *)constraintsView;
@end
