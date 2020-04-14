//
//  JKAlertConst.m
//  JKAlertX
//
//  Created by albert on 2018/10/22.
//  Copyright © 2018 安永博. All rights reserved.
//

#import "JKAlertConst.h"
#import "JKAlertView.h"

#pragma mark
#pragma mark - 通知

/** 移除全部的通知 */
NSString * const JKAlertDismissAllNotification = @"JKAlertDismissAllNotification";

/** 根据key来移除的通知 */
NSString * const JKAlertDismissForKeyNotification = @"JKAlertDismissForKeyNotification";

/** 清空全部弹框的通知 */
NSString * const JKAlertClearAllNotification = @"JKAlertClearAllNotification";


#pragma mark
#pragma mark - 常量

CGFloat    const JKAlertMinTitleLabelH = (22.0);
CGFloat    const JKAlertMinMessageLabelH = (17.0);
CGFloat    const JKAlertScrollViewMaxH = 176.0; // (JKAlertButtonH * 4.0)

CGFloat    const JKAlertButtonH = 46.0;

NSInteger  const JKAlertPlainButtonBeginTag = 100;

CGFloat    const JKAlertSheetTitleMargin = 6.0;

CGFloat    const JKAlertTopGestureIndicatorHeight = 20.0;

CGFloat    const JKAlertTopGestureIndicatorLineWidth = 40.0;

CGFloat    const JKAlertTopGestureIndicatorLineHeight = 4.0;



#pragma mark
#pragma mark - 函数

/// 判断黑暗模式获取其中一个对象
id JKAlertJudgeDarkMode (id <UITraitEnvironment> environment, id light, id dark) {
    
    if (!environment.traitCollection) { return light; }
    
    if (@available(iOS 13.0, *)) {
        
        BOOL isLight = ([environment.traitCollection userInterfaceStyle] == UIUserInterfaceStyleLight);
        
        return isLight ? light : dark;
    }
    
    return light;
}

/// 颜色适配
UIColor * JKAlertAdaptColor (UIColor *lightColor, UIColor *darkColor) {
    
    if (@available(iOS 13.0, *)) {
        
        UIColor *color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            
            if ([traitCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                
                return lightColor;
            }

            return darkColor;
        }];
        
        return color;
        
    } else {
        
        return lightColor;
    }
}

/// 全局背景色
UIColor * JKAlertGlobalBackgroundColor (void) {
    
    static UIColor *GlobalBackgroundColor_ = nil;
    
    if (!GlobalBackgroundColor_) {
        
        GlobalBackgroundColor_ = JKAlertAdaptColor(JKAlertSameRGBColorAlpha(247.0, 0.7), JKAlertSameRGBColorAlpha(8.0, 0.7));
    }
    
    return GlobalBackgroundColor_;
}

/// 全局高亮背景色
UIColor * JKAlertGlobalHighlightedBackgroundColor (void) {
    
    static UIColor *HighlightedBackgroundColor_ = nil;
    
    if (!HighlightedBackgroundColor_) {
        
        HighlightedBackgroundColor_ = JKAlertAdaptColor(JKAlertSameRGBColorAlpha(247.0, 0.3), JKAlertSameRGBColorAlpha(8.0, 0.3));
    }
    
    return HighlightedBackgroundColor_;
}

/// 是否X设备
BOOL JKAlertIsDeviceX (void) {
    
    static BOOL JKAlertIsDeviceX_ = NO;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (@available(iOS 11.0, *)) {
            
            if (!JKAlertIsDeviceiPad()) {
                
                JKAlertIsDeviceX_ = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom > 0.0;
            }
        }
    });
    
    return JKAlertIsDeviceX_;
}

/// 是否iPad
BOOL JKAlertIsDeviceiPad (void) {
    
    static BOOL JKAlertIsDeviceiPad_ = NO;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (@available(iOS 11.0, *)) {
            
            JKAlertIsDeviceiPad_ = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
        }
    });
    
    return JKAlertIsDeviceiPad_;
}

/// 当前是否横屏
BOOL JKAlertIsLandscape (void) {
    
    return [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
}

/// 当前HomeIndicator高度
CGFloat JKAlertCurrentHomeIndicatorHeight (void) {
    
    return JKAlertIsDeviceX() ? (JKAlertIsLandscape() ? 21.0 : 34.0) : 0.0;
}

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
        
        if (!timer) {
            
            NSLog(@"timer已销毁");
            
            return;
        }
        
        if (weakTarget)  {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (!timer) {
                    
                    NSLog(@"timer已销毁");
                    
                    return;
                }
                
                !handler ? : handler(timer, stopTimerBlock);
                
                if (repeat) { return; }
                    
                if (!timer) { return; }
                        
                dispatch_source_cancel(timer);
                
                timer = nil;
            });
            
        } else {

            NSLog(@"timer-->target已销毁");
                
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
#pragma mark - DEBUG

/// 仅DEBUG下执行
void JKTodo_Debug_Execute(void(^executeBlock)(void)) {
#if defined(DEBUG)
    !executeBlock ? : executeBlock();
#endif
}

/// 在DEBUG/Develop下执行
void JKTodo_Debug_Develop_Execute(void(^executeBlock)(void)) {
#if defined(DEBUG) || defined(CONFIGURATION_Develop)
    !executeBlock ? : executeBlock();
#endif
}

void JKTodo_Alert(NSString *title, NSString *message, NSTimeInterval showDelay);

/// 弹框展示debug信息
void JKTodo_Debug_Alert(NSString *title, NSString *message, NSTimeInterval showDelay) {
#if defined(DEBUG) || defined(CONFIGURATION_Develop)
    JKTodo_Alert(title, message, showDelay);
#endif
}

/// 弹框展示debug信息
void JKTodo_Debug_Develop_Alert(NSString *title, NSString *message, NSTimeInterval showDelay) {
#if defined(DEBUG) || defined(CONFIGURATION_Develop)
    JKTodo_Alert(title, message, showDelay);
#endif
}

void JKTodo_Alert(NSString *title, NSString *message, NSTimeInterval showDelay) {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        JKAlertView *alertView = [JKAlertView alertViewWithTitle:[@"JKDebug-" stringByAppendingString:(title ? title : @"")] message:[@"--- 此弹框仅用于调试 ---\n" stringByAppendingString:(message ? message : @"")] style:(JKAlertStyleAlert)];
        
        alertView.setMessageTextViewAlignment(NSTextAlignmentLeft).setTextViewCanSelectText(YES);
        
        [alertView addAction:[JKAlertAction actionWithTitle:@"OK" style:(JKAlertActionStyleDefault) handler:^(JKAlertAction *action) {
            
        }]];
        
        if (showDelay <= 0) {
            
            [alertView show];
            
            return;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(showDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [alertView show];
        });
    });
}
