//
//  JKAlertUtility.m
//  JKAlertX
//
//  Created by albert on 2018/10/22.
//  Copyright © 2018 Albert. All rights reserved.
//

#import "JKAlertUtility.h"
#import "JKAlertX.h"
#import <AudioToolbox/AudioToolbox.h>
#import "JKAlertThemeManager.h"

#pragma mark
#pragma mark - 通知

/// 移除全部的通知
NSString * const JKAlertDismissAllNotification = @"JKAlertDismissAllNotification";

/// 根据key来移除的通知
NSString * const JKAlertDismissForKeyNotification = @"JKAlertDismissForKeyNotification";

/// 根据category来移除的通知
NSString * const JKAlertDismissForCategoryNotification = @"JKAlertDismissForCategoryNotification";

/// 清空全部弹框的通知
NSString * const JKAlertClearAllNotification = @"JKAlertClearAllNotification";


#pragma mark
#pragma mark - 常量

/// 可以手势滑动退出时 点击空白处不dismiss的抖动动画key
NSString * const JKAlertDismissFailedShakeAnimationKey = @"JKAlertDismissFailedShakeAnimationKey";

CGFloat    const JKAlertSheetSpringHeight = 15.0;

CGFloat    const JKAlertTopGestureIndicatorHeight = 20.0;

CGFloat    const JKAlertTopGestureIndicatorLineWidth = 40.0;

CGFloat    const JKAlertTopGestureIndicatorLineHeight = 4.0;



#pragma mark
#pragma mark - 函数



#pragma mark
#pragma mark - 封装定时器

/**
 开启一个定时器，默认在dispatch_get_global_queue队里执行
 warning : 注意循环引用！！！
 
 @param target 定时器判断对象，若该对象销毁，定时器将自动销毁
 @param delay 延时执行时间
 @param timeInterval 执行间隔时间
 @param repeat 是否重复执行
 @param handler 重复执行事件
 */
JKAlertXStopTimerBlock JKAlertX_dispatchTimer(id target, double delay, double timeInterval, BOOL repeat, void (^handler)(dispatch_source_t timer, void(^stopTimerBlock)(void))) {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    return JKAlertX_dispatchTimerWithQueue(queue, target, delay, timeInterval, repeat, handler);
}

/**
 开启一个定时器
 warning : 注意循环引用！！！
 
 @param queue 定时器执行的队列
 @param target 定时器判断对象，若该对象销毁，定时器将自动销毁
 @param delay 延时执行时间
 @param timeInterval 执行间隔时间
 @param repeat 是否重复执行
 @param handler 重复执行事件
 */
JKAlertXStopTimerBlock JKAlertX_dispatchTimerWithQueue(dispatch_queue_t queue, id target, double delay, double timeInterval, BOOL repeat, void (^handler)(dispatch_source_t timer, void(^stopTimerBlock)(void))) {
    
    __block dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    uint64_t interval = (uint64_t)(timeInterval * NSEC_PER_SEC);
    
    dispatch_time_t delayTime = dispatch_walltime(NULL, (int64_t)(delay * NSEC_PER_SEC));
    
    dispatch_source_set_timer(timer, delayTime, interval, 0);
    
    JKAlertXStopTimerBlock stopTimerBlock = ^{
        
        if (!timer) { return; }
        
        dispatch_source_cancel(timer);
        
        timer = nil;
    };
    
    // 设置回调
    __weak __typeof(target) weakTarget = target;
    
    dispatch_source_set_event_handler(timer, ^{
        
        if (!timer) { return; }
        
        if (weakTarget)  {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (!timer) { return; }
                
                !handler ? : handler(timer, stopTimerBlock);
                
                if (repeat) { return; }
                
                dispatch_source_cancel(timer);
                
                timer = nil;
            });
            
        } else {
            
            // target已销毁
            
            if (!timer) { return; }
            
            dispatch_source_cancel(timer);
            
            timer = nil;
        }
    });
    
    // 启动定时器
    dispatch_resume(timer);
    
    return stopTimerBlock;
}

#pragma mark
#pragma mark - 工具方法

@implementation JKAlertUtility

/// 判断当前是否深色模式
+ (BOOL)isDarkMode {
    
    return [[JKAlertThemeManager sharedManager] checkIsDarkMode];
}

/// 全局背景色 浅色模式 rgb 247
+ (UIColor *)globalLightBackgroundColor {
    
    return JKAlertSameRGBColor(247.0);
}

/// 全局背景色 深色模式 rgb 24
+ (UIColor *)globalDarkBackgroundColor {
    
    return JKAlertSameRGBColor(24.0);
}

/// 背景色 浅色模式 rgb254
+ (UIColor *)lightBackgroundColor {
    
    return JKAlertSameRGBColor(255.0);
}

/// 背景色 深色模式 rgb 30
+ (UIColor *)darkBackgroundColor {
    
    return JKAlertSameRGBColor(30.0);
}

/// 高亮背景色 浅色模式 rgb 229
+ (UIColor *)highlightedLightBackgroundColor {
    
    return JKAlertSameRGBColor(229.0);
}

/// 高亮背景色 深色模式 rgb 37.5
+ (UIColor *)highlightedDarkBackgroundColor {
    
    return JKAlertSameRGBColor(37.5);
}

/// 全局分隔线粗细 1.0 / [UIScreen mainScreen].scale
+ (CGFloat)separatorLineThickness {
    
    static CGFloat separatorLineThickness_ = 0;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        separatorLineThickness_ = 1.0 / [UIScreen mainScreen].scale;
    });
    
    return separatorLineThickness_;
}

/// 全局分隔线背景色 浅色模式
+ (UIColor *)separatorLineLightColor {
    
    return JKAlertColorAlpha(60.0, 60.0, 67.0, 0.29);
}

/// 全局分隔线背景色 深色模式
+ (UIColor *)separatorLineDarkColor {
    
    return JKAlertColorAlpha(84.0, 84.0, 88.0, 0.6);
}

/// 是否X设备
+ (BOOL)isDeviceX {
    
    static BOOL isDeviceX_ = NO;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (![self isDeviceiPhone]) { return; }
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        
        BOOL isDeviceXType = CGSizeEqualToSize(CGSizeMake(375.0, 812.0), screenBounds.size);
        BOOL isDeviceXMaxType = CGSizeEqualToSize(CGSizeMake(414.0, 896.0), screenBounds.size);
        
        BOOL isDevice12Type = CGSizeEqualToSize(CGSizeMake(390.0, 844.0), screenBounds.size);
        BOOL isDevice12MaxType = CGSizeEqualToSize(CGSizeMake(428.0, 926.0), screenBounds.size);
        
        BOOL isDevice14ProType = CGSizeEqualToSize(CGSizeMake(393.0, 852.0), screenBounds.size);
        BOOL isDevice14ProMaxType = CGSizeEqualToSize(CGSizeMake(430.0, 932.0), screenBounds.size);
        
        // 如有新设备，在此添加
        
        isDeviceX_ = (isDeviceXType ||
                      isDeviceXMaxType ||
                      isDevice12Type ||
                      isDevice12MaxType ||
                      isDevice14ProType ||
                      isDevice14ProMaxType);
    });
    
    return isDeviceX_;
}

/// 是否iPhone
+ (BOOL)isDeviceiPhone {
    
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
}

/// 是否iPad
+ (BOOL)isDeviceiPad {
    
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

/// 当前是否横屏
+ (BOOL)isLandscape {
    
    return [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
}

/// 当前HomeIndicator高度
+ (CGFloat)currentHomeIndicatorHeight {
    
    return self.safeAreaInset.bottom;
}

/// 当前的windowScene
+ (UIWindowScene *)currentWindowScene API_AVAILABLE(ios(13.0)) {
    
    NSSet *connectedScenes = UIApplication.sharedApplication.connectedScenes;
    
    if (connectedScenes.count < 1) {
        
        return nil;
    }
    
    if (connectedScenes.count == 1) {
        
        UIWindowScene *windowScene = connectedScenes.anyObject;
        
        if ([windowScene isKindOfClass:[UIWindowScene class]]) {
            
            return windowScene;
        }
        
        return nil;
    }
    
    for (UIWindowScene *windowScene in connectedScenes) {
        
        if (![windowScene isKindOfClass:[UIWindowScene class]]) { continue; }
        
        if (windowScene.activationState != UISceneActivationStateForegroundActive) {
            
            continue;
        }
        
        return windowScene;
    }
    
    return nil;
}

/// 当前windowScene的window
+ (UIWindow *)currentSceneWindow {
    
    if (@available(iOS 13.0, *)) {
        
        UIWindowScene *windowScene = [self currentWindowScene];
        
        if (!windowScene ||
            ![windowScene isKindOfClass:[UIWindowScene class]]) {
            
            return nil;
        }
        
        id delegate = windowScene.delegate;
        
        if ([delegate conformsToProtocol:@protocol(UIWindowSceneDelegate)] &&
            [delegate respondsToSelector:@selector(window)]) {
            
            return [delegate window];
        }
        
        if (@available(iOS 15.0, *)) {
            
            if (windowScene.keyWindow != nil) {
                
                return windowScene.keyWindow;
            }
        }
        
        if (windowScene.windows.count < 1) {
            
            return nil;
        }
        
        if (windowScene.windows.count == 1) {
            
            return windowScene.windows.firstObject;
        }
        
        for (UIWindow * window in windowScene.windows) {
            
            if (window.isHidden) { continue; }
            
            if (window.isKeyWindow) {
                
                return window;
            }
            
            return window;
        }
    }
    
    return nil;
}

/// keyWindow
+ (UIWindow *)keyWindow {
    
    if (defaultWindow_ != nil &&
        [defaultWindow_ isKindOfClass:[UIWindow class]]) {
        
        return defaultWindow_;
    }
    
    UIWindow *keyWindow = nil;
    
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        
        keyWindow = [[UIApplication sharedApplication].delegate window];
        
    } else {
        
        keyWindow = [self currentSceneWindow];
    }
    
    return keyWindow;
}

/// 获取keyWindow的safeAreaInsets
+ (UIEdgeInsets)safeAreaInset {
    
    UIEdgeInsets safeAreaInset = UIEdgeInsetsZero;
    
    if (@available(iOS 11.0, *)) {
        
        safeAreaInset = self.keyWindow.safeAreaInsets;
    }
    
    return safeAreaInset;
}

/// 状态栏高度
+ (CGFloat)statusBarHeight {
    
    if (@available(iOS 11.0, *)) {
        
        CGFloat topInset = [self safeAreaInset].top;
        
        if ([self isDeviceiPad]) {
            
            return topInset > 0.0 ? topInset : 24.0;
        }
        
        return topInset;
    }
    
    return 20.0;
}

/// 导航条高度
+ (CGFloat)navigationBarHeight {
    
    // 小屏iPad高度为70，这里全部处理为74
    if ([self isDeviceiPad]) { return 74.0; }
    
    if ([self isLandscape]) {
        
        return MIN(JKAlertScreenWidth, JKAlertScreenHeight) > 400.0 ? 44.0 : 32.0;
    }
    
    return [self statusBarHeight] + 44.0;
}

/// plain样式最大高度减去的高度
+ (CGFloat)plainMinusHeight {
    
    return 120.0;
}

/// 让手机振动一下
+ (void)vibrateDevice {
    
    // iPad没有振动
    if (self.isDeviceiPad) { return; }
    
    // 普通短振，3D Touch 中 Peek 振动反馈
    //AudioServicesPlaySystemSound(1519);
    
    // 普通短振，3D Touch 中 Pop 振动反馈
    //AudioServicesPlaySystemSound(1520);
    
    // 连续三次短振
    //AudioServicesPlaySystemSound(1521);
    
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    if (@available(iOS 10.0, *)) {
        
        UIImpactFeedbackGenerator *feedbackGenertor = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        
        [feedbackGenertor impactOccurred];
    }
}

static __weak UIWindow *defaultWindow_ = nil;

/// 设置默认window，设置后若有值则keyWindow返回此值
+ (void)makeDefaultWindow:(UIWindow *)window {
    
    defaultWindow_ = window;
}

/// 仅DEBUG下执行
+ (void)debugExecute:(void (^)(void))executeBlock {
#if defined(DEBUG)
    !executeBlock ? : executeBlock();
#endif
}

/// 在DEBUG/Develop下执行
+ (void)debugDevelopExecute:(void (^)(void))executeBlock {
#if defined(DEBUG) || defined(CONFIGURATION_Develop)
    !executeBlock ? : executeBlock();
#endif
}

/// 弹框展示debug信息 仅debug
+ (void)showDebugAlertWithTitle:(NSString *)title
                        message:(NSString *)message
                          delay:(NSTimeInterval)delay
        configurationBeforeShow:(void(^)(JKAlertView *alertView))configuration {
#if defined(DEBUG)
    [self jk_showAlertWithTitle:title message:message delay:delay configurationBeforeShow:configuration];
#endif
}

/// 弹框展示debug信息 debug & develop
+ (void)showDebugDevelopAlertWithTitle:(NSString *)title
                               message:(NSString *)message
                                 delay:(NSTimeInterval)delay
               configurationBeforeShow:(void(^)(JKAlertView *alertView))configuration {
#if defined(DEBUG) || defined(CONFIGURATION_Develop)
    [self jk_showAlertWithTitle:title message:message delay:delay configurationBeforeShow:configuration];
#endif
}

+ (void)jk_showAlertWithTitle:(NSString *)title
                      message:(NSString *)message
                        delay:(NSTimeInterval)delay
      configurationBeforeShow:(void(^)(JKAlertView *alertView))configuration {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        JKAlertView *alertView = [JKAlertView alertViewWithTitle:[@"JKDebug-" stringByAppendingString:(title ? title : @"")] message:[@"--- 此弹框仅用于调试 ---\n\n" stringByAppendingString:(message ? message : @"")] style:(JKAlertStyleAlert)];
        
        alertView.makeMessageAlignment(NSTextAlignmentLeft)
        .makeTitleMessageShouldSelectText(YES)
        .makePlainWidth([UIScreen mainScreen].bounds.size.width - 30.0)
        .makePlainAutoReduceWidth(YES);
        
        [alertView addAction:[JKAlertAction actionWithTitle:@"Copy" style:(JKAlertActionStyleDefault) handler:^(JKAlertAction *action) {
            
            [UIPasteboard generalPasteboard].string = message ? message : @"";
        }]];
        
        [alertView addAction:[JKAlertAction actionWithTitle:@"OK" style:(JKAlertActionStyleDefault) handler:^(JKAlertAction *action) {
            
        }]];
        
        if (delay <= 0) {
            
            !configuration ? : configuration(alertView);
            
            [alertView show];
            
            return;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            !configuration ? : configuration(alertView);
            
            [alertView show];
        });
    });
}
@end
