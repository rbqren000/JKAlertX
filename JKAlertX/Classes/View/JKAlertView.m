//
//  JKAlertView.m
//  TestVideoAndPicture
//
//  Created by albert on 2017/4/18.
//  Copyright © 2017年 安永博. All rights reserved.
//

#import "JKAlertView.h"
#import "JKAlertPiercedTableViewCell.h"
#import "JKAlertCollectionViewCell.h"
#import "JKAlertTableViewCell.h"
#import "UIView+JKAlertX.h"
#import "JKAlertPlainActionButton.h"
#import "JKAlertView+PrivateProperty.h"
#import "JKAlertVisualFormatConstraintManager.h"
#import "JKAlertView+Public.h"
#import "JKAlertView+HUD.h"

@interface JKAlertView ()

@end

@implementation JKAlertView

#pragma mark
#pragma mark - 类方法

+ (instancetype)alertViewWithTitle:(NSString *)title
                           message:(NSString *)message
                             style:(JKAlertStyle)style {
    
    JKAlertView *alertView = [[JKAlertView alloc] init];
    
    alertView.alertStyle = style;
    alertView.alertTitle = [title copy];
    alertView.alertMessage = [message copy];
    
    return alertView;
}

/** 链式实例化 */
+ (JKAlertView *(^)(NSString *title, NSString *message, JKAlertStyle style))alertView {
    
    return ^(NSString *title, NSString *message, JKAlertStyle style) {
        
        return [JKAlertView alertViewWithTitle:title message:message style:style];
    };
}

+ (instancetype)alertViewWithAttributedTitle:(NSAttributedString *)attributedTitle
                           attributedMessage:(NSAttributedString *)attributedMessage
                                       style:(JKAlertStyle)style {
    
    JKAlertView *alertView = [[JKAlertView alloc] init];
    
    alertView.alertStyle = style;
    alertView.alertAttributedTitle = [attributedTitle copy];
    alertView.attributedMessage = [attributedMessage copy];
    
    return alertView;
}

/** 函数式类方法 */
+ (JKAlertView *(^)(NSString *title, NSString *message, JKAlertStyle style, void(^)(JKAlertView *alertView)))show {
    
    return ^(NSString *title, NSString *message, JKAlertStyle style, void(^configuration)(JKAlertView *alertView)) {
        
        JKAlertView *view = [self alertViewWithTitle:title message:message style:style];
        
        !configuration ? : configuration(view);
        
        [view show];
        
        return view;
    };
}

/** 链式实例化 */
+ (JKAlertView *(^)(NSAttributedString *attributedTitle, NSAttributedString *attributedMessage, JKAlertStyle style))alertViewAttributed {
    
    return ^(NSAttributedString *attributedTitle, NSAttributedString *attributedMessage, JKAlertStyle style) {
        
        return [JKAlertView alertViewWithAttributedTitle:attributedTitle attributedMessage:attributedMessage style:style];
    };
}

/** 显示文字HUD */
+ (void (^)(NSString *title, void(^configuration)(JKAlertView *alertView)))showHUDWithTitle {
    
    return ^(NSString *title, void(^configuration)(JKAlertView *alertView)) {
        
        JKAlertView *alertView = [JKAlertView alertViewWithTitle:title message:nil style:(JKAlertStyleHUD)];
        
        !configuration ? : configuration(alertView);
        
        [alertView show];
    };
}

/** 显示富文本HUD */
+ (void (^)(NSAttributedString *attributedTitle, void(^configuration)(JKAlertView *alertView)))showHUDWithAttributedTitle {
    
    return ^(NSAttributedString *attributedTitle, void(^configuration)(JKAlertView *alertView)) {
        
        JKAlertView *alertView = [JKAlertView alertViewWithAttributedTitle:attributedTitle attributedMessage:nil style:(JKAlertStyleHUD)];
        
        !configuration ? : configuration(alertView);
        
        [alertView show];
    };
}

/**
 * 显示自定义HUD
 * 注意使用点语法调用，否则莫名报错 JKAlertView.showCustomHUD
 * customHUD尺寸将完全由自定义控制，默认显示在屏幕中间
 * 注意自己计算好自定义HUD的size，以避免横竖屏出现问题
 */
+ (void (^)(UIView *(^customHUD)(void), void(^configuration)(JKAlertView *alertView)))showCustomHUD {
    
    return ^(UIView *(^customHUD)(void), void(^configuration)(JKAlertView *alertView)) {
        
        JKAlertView *alertView = [JKAlertView alertViewWithTitle:nil message:nil style:(JKAlertStyleHUD)];
        
        UIView *customView = !customHUD ? nil : customHUD();
        
        !configuration ? : configuration(alertView);
        
        alertView.customHUD = customView;
        
        [alertView show];
    };
}

/**
 * 移除当前所有的JKAlertView
 * 本质是发送一个通知，让所有的JKAlertView对象执行消失操作
 * 注意如果某个对象setDismissAllNoneffective为YES时，该对象将不会响应通知
 * ***谨慎使用该方法***
 */
+ (void(^)(void))dismissAll {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:JKAlertDismissAllNotification object:nil];
    
    return ^{};
}

/**
 * 移除设置了dismissKey的JKAlertView
 * 本质是发送一个通知，让dismissKey为该值的JKAlertView对象执行消失操作
 */
+ (void(^)(NSString *dismissKey))dismissForKey {
    
    return ^(NSString *dismissKey) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:JKAlertDismissForKeyNotification object:dismissKey];
    };
}

/**
 * 移除设置了同一dismissCategory的多个JKAlertView
 * 本质是发送一个通知，让dismissCategory为该值的JKAlertView对象执行消失操作
 */
+ (void(^)(NSString *dismissCategory))dismissForCategory {
    
    return ^(NSString *dismissCategory) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:JKAlertDismissForCategoryNotification object:dismissCategory];
    };
}

/**
 * 清空当前所有的JKAlertView
 * 本质是发送一个通知，让所有的JKAlertView对象执行消失操作
 * 执行该操作会清空所有的JKAlertView，即使setDismissAllNoneffective为YES亦然，请谨慎操作
 * ***谨慎使用该方法***
 */
+ (void(^)(void))clearAll {
    
    return ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:JKAlertClearAllNotification object:nil];
    };
}

#pragma mark
#pragma mark - 显示

/** 显示 */
- (JKAlertView *(^)(void))show {
    
    [JKAlertKeyWindow() endEditing:YES];
    
    if (Showed) { return ^{ return self; }; }
    
    Showed = YES;
    
    switch (self.alertStyle) {
        case JKAlertStyleActionSheet:
        {
            [self showAcitonSheet];
        }
            break;
            
        case JKAlertStyleCollectionSheet:
        {
            [self showCollectionSheet];
        }
            break;
            
        default:
            [self calculateUI];
            break;
    }
    
    !self.alertContentViewConfiguration ? : self.alertContentViewConfiguration(self.alertContentView);
    
    // customSuperView没有则默认keyWindow
    [self.customSuperView addSubview:self];
    
    return ^{ return self; };
}

// sheet样式
- (void)showAcitonSheet{
    
    if (!self.cancelAction) {
        
        self.cancelAction = [JKAlertAction actionWithTitle:@"取消" style:(JKAlertActionStyleDefault) handler:^(JKAlertAction *action) {}];
        self.cancelAction.setTitleFont([UIFont systemFontOfSize:17]);
        self.cancelAction.setTitleColor(JKAlertAdaptColor(JKAlertSameRGBColor(51), JKAlertSameRGBColor(204)));
    }
    
    self.cancelAction.setSeparatorLineHidden(YES);
    [self.actions.lastObject setSeparatorLineHidden:YES];
    
    [self calculateUI];
}

// collectionSheet样式
- (void)showCollectionSheet{
    
    if (!self.cancelAction) {
        
        self.cancelAction = [JKAlertAction actionWithTitle:@"取消" style:(JKAlertActionStyleDefault) handler:^(JKAlertAction *action) {}];
        self.cancelAction.setTitleFont([UIFont systemFontOfSize:17]);
        self.cancelAction.setTitleColor(JKAlertAdaptColor(JKAlertSameRGBColor(51), JKAlertSameRGBColor(204)));
    }
    
    [self calculateUI];
}

#pragma mark
#pragma mark - 计算布局

- (void)updatePlainWidth {
    
    if (!self.autoReducePlainWidth) { return; }
    
    CGFloat safeAreaInset = 0;
    
    if (@available(iOS 11.0, *)) {
        
        safeAreaInset = MAX(self.customSuperView.safeAreaInsets.left, self.customSuperView.safeAreaInsets.right);
    }
    
    PlainViewWidth = MIN(OriginalPlainWidth, JKAlertScreenW - safeAreaInset * 2);
}

- (void)calculatePlainUI {
    
    [self updatePlainWidth];
    
    // TODO: JKTODO <#注释#>
    self.plainContentView.textContentView.alertTitle = self.alertTitle;
    self.plainContentView.textContentView.alertAttributedTitle = self.alertAttributedTitle;
    
    self.plainContentView.textContentView.alertMessage = self.alertMessage;
    self.plainContentView.textContentView.attributedMessage = self.attributedMessage;
    
    self.plainContentView.actionArray = self.actions;
    self.plainContentView.textFieldArray = self.textFieldArr;
    
    self.plainContentView.contentWidth = PlainViewWidth;
    self.plainContentView.maxHeight = JKAlertPlainViewMaxH;
    [self.plainContentView calculateUI];
    
    self.plainContentView.center = CGPointMake(JKAlertScreenW * 0.5, JKAlertScreenH * 0.5 + self.plainCenterOffsetY);
}

- (void)calculateHudUI {
    
    if (self.customHUD) {
        
        self.hudContentView.textContentView.customContentView = self.customHUD;
        
    } else {
        
        self.hudContentView.textContentView.alertTitle = self.alertTitle;
        self.hudContentView.textContentView.alertAttributedTitle = self.alertAttributedTitle;
        
        self.hudContentView.textContentView.alertMessage = self.alertMessage;
        self.hudContentView.textContentView.attributedMessage = self.attributedMessage;
    }
    
    [self updatePlainWidth];
    
    
    // TODO: JKTODO <#注释#>
    self.hudContentView.contentWidth = PlainViewWidth;
    self.hudContentView.maxHeight = JKAlertPlainViewMaxH;
    [self.hudContentView calculateUI];
    
    self.hudContentView.center = CGPointMake(JKAlertScreenW * 0.5, JKAlertScreenH * 0.5 + self.plainCenterOffsetY);
}

#pragma mark
#pragma mark - Setter

- (void)setAlertStyle:(JKAlertStyle)alertStyle {
    _alertStyle = alertStyle;
    
    _tapBlankDismiss = NO;
    
    switch (_alertStyle) {
        case JKAlertStylePlain:
        {
            _currentAlertContentView = self.plainContentView;
            _currentTextContentView = self.plainContentView.textContentView;
            
            [self addKeyboardWillChangeFrameNotification];
        }
            break;
            
        case JKAlertStyleHUD:
        {
            _currentAlertContentView = self.hudContentView;
            _currentTextContentView = self.hudContentView.textContentView;
            
            self.multiBackgroundColor = [JKAlertMultiColor colorWithNoColor];
        }
            break;
            
        case JKAlertStyleActionSheet:
        {
            _tapBlankDismiss = YES;
            
            [self tableView];
        }
            break;
            
        case JKAlertStyleCollectionSheet:
        {
            CancelMargin = 10;
            
            _tapBlankDismiss = YES;
            
            [self collectionView];
        }
            break;
            
        default: // 默认为JKAlertStylePlain样式
        {
            _alertStyle = JKAlertStylePlain;
            
            _currentAlertContentView = self.plainContentView;
            _currentTextContentView = self.plainContentView.textContentView;
            
            [self addKeyboardWillChangeFrameNotification];
        }
            break;
    }
}

/** 设置默认的取消action，不需要自带的可以自己设置，不可置为nil */
- (void)setCancelAction:(JKAlertAction *)cancelAction{
    
    if (cancelAction == nil) {
        return;
    }
    
    _cancelAction = cancelAction;
    
    [self setAlertViewToAction:_cancelAction];
}

- (void)setAlertViewToAction:(JKAlertAction *)action {
    
    action.alertView = self;
    
    if (self.alertStyle == JKAlertStyleActionSheet) {

        action.isPierced = self.isActionSheetPierced;
        action.piercedBackgroundColor = self.piercedBackgroundColor;
        
    } else {

        action.isPierced = NO;
        action.piercedBackgroundColor = nil;
    }
}

/**
 * 设置collection的itemSize的宽度
 * 最大不可超过屏幕宽度的一半
 * 注意图片的宽高是设置的宽度-30，即图片在cell中是左右各15的间距
 * 自动计算item之间间距，最小为0，可自己计算该值设置每屏显示个数
 * 默认的高度是宽度-6，暂不支持自定义高度
 */
- (void)setFlowlayoutItemWidth:(CGFloat)flowlayoutItemWidth{
    
    _flowlayoutItemWidth = flowlayoutItemWidth > JKAlertScreenW * 0.5 ? JKAlertScreenW * 0.5 : flowlayoutItemWidth;
}

- (void)setCustomHUD:(UIView *)customHUD {
    
    if (self.alertStyle != JKAlertStyleHUD) { return; }
    
    _customHUD = customHUD;
    
    // TODO: JKTODO <#注释#>
    if (self.customHUD.frame.size.width <= 0) { return; }
    
    PlainViewWidth = self.customHUD.frame.size.width;
    
    OriginalPlainWidth = PlainViewWidth;
}

- (void)setCustomSheetTitleView:(UIView *)customSheetTitleView{
    _customSheetTitleView = customSheetTitleView;
    
    if (!_customSheetTitleView) {
        return;
    }
    
    _titleTextView.hidden = YES;
    _messageTextView.hidden = YES;
    [_textContainerView addSubview:_customSheetTitleView];
    
    if (_alertStyle == JKAlertStyleActionSheet) {
        
        
        [_scrollView addSubview:_customSheetTitleView];
    }
}

- (void)setPlainCenterOffsetY:(CGFloat)plainCenterOffsetY{
    
    _plainCenterOffsetY = plainCenterOffsetY;
    
    // TODO: JKTODO <#注释#>
    //_plainView.center = CGPointMake(JKAlertScreenW * 0.5, JKAlertScreenH * 0.5 + _plainCenterOffsetY);
}

- (void)setAlertBackGroundView:(UIView *)alertBackGroundView{
    
    // TODO: JKTODO <#注释#>
    
    if (alertBackGroundView == nil) { return; }
    
    [_alertBackGroundView removeFromSuperview];
    
    _alertBackGroundView = alertBackGroundView;
    
    if (!_sheetContainerView) { return; }
    
    [_sheetContainerView insertSubview:_alertBackGroundView atIndex:0];
    //[_plainView insertSubview:_alertBackGroundView atIndex:0];
    
    alertBackGroundView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *cons1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sheetBackGroundView]-0-|" options:0 metrics:nil views:@{@"sheetBackGroundView" : alertBackGroundView}];
    [_sheetContainerView addConstraints:cons1];
    //[_plainView addConstraints:cons1];
    
    NSArray *cons2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[sheetBackGroundView]-0-|" options:0 metrics:nil views:@{@"sheetBackGroundView" : alertBackGroundView}];
    [_sheetContainerView addConstraints:cons2];
    //[_plainView addConstraints:cons2];
}

#pragma mark
#pragma mark - 链式Setter

/** 设置默认的取消action，不需要自带的可以自己设置，不可置为nil */
- (JKAlertView *(^)(JKAlertAction *action))setCancelAction{
    
    return ^(JKAlertAction *action) {
        
        self.cancelAction = action;
        
        return self;
    };
}

/** collection样式默认有一个取消按钮，设置这个可以在取消按钮的上面再添加一个按钮 */
- (JKAlertView *(^)(JKAlertAction *action))setCollectionAction{
    
    return ^(JKAlertAction *action) {
        
        self.collectionAction = action;
        
        [self setAlertViewToAction:self.collectionAction];
        
        return self;
    };
}

/** 设置colletion样式的底部按钮左右间距 */
- (JKAlertView *(^)(CGFloat margin))setCollectionButtonLeftRightMargin{
    
    return ^(CGFloat margin) {
        
        self.collectionButtonLeftRightMargin = margin;
        
        return self;
    };
}

/** 设置show的时候是否振动 默认NO */
- (JKAlertView *(^)(CGFloat shouldVibrate))setShouldVibrate{
    
    return ^(CGFloat shouldVibrate) {
        
        self.shouldVibrate = shouldVibrate;
        
        return self;
    };
}

/** 设置action和colletion样式的底部按钮上下间距 不可小于0 */
- (JKAlertView *(^)(CGFloat margin))setBottomButtonMargin{
    
    return ^(CGFloat margin) {
        
        self->CancelMargin = margin < 0 ? 0 : margin;
        
        return self;
    };
}

/**
 * 设置是否将两个collection合体
 * 设为YES可让两个collection同步滚动
 * 设置YES时会自动让两个collection的action数量保持一致，即向少的一方添加空的action
 */
- (JKAlertView *(^)(BOOL compoundCollection))setCompoundCollection{
    
    return ^(BOOL compoundCollection) {
        
        self.compoundCollection = compoundCollection;
        
        return self;
    };
}

/** 设置collection是否分页 */
- (JKAlertView *(^)(BOOL collectionPagingEnabled))setCollectionPagingEnabled{
    
    return ^(BOOL collectionPagingEnabled) {
        
        self.collectionPagingEnabled = collectionPagingEnabled;
        
        return self;
    };
}

/** 设置是否自动适配 iPhone X homeIndicator 默认YES */
- (JKAlertView *(^)(BOOL autoAdjust))setAutoAdjustHomeIndicator{
    
    return ^(BOOL autoAdjust) {
        
        self->AutoAdjustHomeIndicator = autoAdjust;
        
        return self;
    };
}

/** 设置是否填充底部 iPhone X homeIndicator 默认YES */
- (JKAlertView *(^)(BOOL fillHomeIndicator))setFillHomeIndicator{
    
    return ^(BOOL fillHomeIndicator) {
        
        if (!JKAlertIsDeviceX()) { return self; }
        
        self->FillHomeIndicator = fillHomeIndicator;
        
        return self;
    };
}

/**
 * 设置是否显示pageControl
 * 如果只有一组collection，则必须设置分页为YES才有效
 * 如果有两组collection，则仅在分页和合体都为YES时才有效
 * 注意自己计算好每页显示的个数相等
 * 可以添加空的action来保证每页显示个数相等
 * JKAlertAction使用类方法初始化时每个参数传nil或者直接自己实例化一个即为空action
 */
- (JKAlertView *(^)(BOOL showPageControl))setShowPageControl{
    
    return ^(BOOL showPageControl) {
        
        self.showPageControl = showPageControl;
        
        return self;
    };
}

/**
 * 设置pageControl
 * 必须setShowPageControl为YES之后才会有值
 */
- (JKAlertView *(^)(void (^)(UIPageControl *pageControl)))setCollectionPageControlConfig{
    
    return ^(void (^pageControlConfig)(UIPageControl *pageControl)) {
        
        if (self.showPageControl) {
            
            !pageControlConfig ? : pageControlConfig(self.pageControl);
        }
        
        return self;
    };
}

/**
 * 设置HUD样式centerY的偏移
 * 正数表示向下偏移，负数表示向上偏移
 */
- (JKAlertView *(^)(CGFloat centerOffsetY))setPlainCenterOffsetY{
    
    return ^(CGFloat centerOffsetY) {
        
        self.plainCenterOffsetY = centerOffsetY;
        
        return self;
    };
}

/**
 * 设置plain样式Y值
 */
- (JKAlertView *(^)(CGFloat Y, BOOL animated))setPlainY{
    
    return ^(CGFloat Y, BOOL animated) {
        
        CGRect frame = self.alertContentView.frame;
        frame.origin.y = Y;
        
        if (animated) {
            
            [UIView animateWithDuration:0.25 animations:^{
                
                self.alertContentView.frame = frame;
            }];
            
        } else {
            
            self.alertContentView.frame = frame;
        }
        
        return self;
    };
}

/**
 * 展示完成后 移动plain和HUD样式centerY
 * 正数表示向下偏移，负数表示向上偏移
 */
- (JKAlertView *(^)(CGFloat centerOffsetY, BOOL animated))movePlainCenterOffsetY{
    
    return ^(CGFloat centerOffsetY, BOOL animated) {
        
        // TODO: JKTODO <#注释#>
        
        if (animated) {
            
            [UIView animateWithDuration:0.25 animations:^{
                
                //self->_plainView.center = CGPointMake(self->_plainView.center.x, self->JKAlertScreenH * 0.5 + self.plainCenterOffsetY + centerOffsetY);
            }];
            
        } else {
            
            //self->_plainView.center = CGPointMake(self->_plainView.center.x, self->JKAlertScreenH * 0.5 + self.plainCenterOffsetY + centerOffsetY);
        }
        
        return self;
    };
}

/** 设置是否允许手势退出 仅限sheet样式 */
- (JKAlertView *(^)(BOOL enableVerticalGesture, BOOL enableHorizontalGesture, BOOL showGestureIndicator))setEnableGestureDismiss{
    
    return ^(BOOL enableVerticalGesture, BOOL enableHorizontalGesture, BOOL showGestureIndicator) {
        
        self.enableVerticalGestureDismiss = enableVerticalGesture;
        self.enableHorizontalGestureDismiss = enableHorizontalGesture;
        
        self.showGestureIndicator = showGestureIndicator;
        
        return self;
    };
}

/** 设置plain样式关闭按钮 */
- (JKAlertView *(^)(void (^)(UIButton *button)))setPlainCloseButtonConfig{
    
    return ^(void (^closeButtonConfig)(UIButton *button)) {
        
        !closeButtonConfig ? : closeButtonConfig(self.closeButton);
        
        return self;
    };
}

/**
 * 设置collection的itemSize的宽度
 * 最大不可超过屏幕宽度的一半
 * 注意图片的宽高是设置的宽度-30，即图片在cell中是左右各15的间距
 * 自动计算item之间间距，最小为0，可自己计算该值设置每屏显示个数
 * 默认的高度是宽度-6，暂不支持自定义高度
 */
- (JKAlertView *(^)(CGFloat width))setFlowlayoutItemWidth{
    
    return ^(CGFloat width) {
        
        self.flowlayoutItemWidth = width;
        
        return self;
    };
}

/**
 * 设置collection列数（每行数量）
 * 默认0，自动设置，不得大于自动设置的数量
 */
- (JKAlertView *(^)(NSInteger columnCount))setCollectionColumnCount{
    
    return ^(NSInteger columnCount) {
        
        self.collectionColumnCount = columnCount;
        
        return self;
    };
}

/**
 * 设置collection的水平（左右方向）的sectionInset
 * 默认0，为0时自动设置为item间距的一半
 */
- (JKAlertView *(^)(CGFloat inset))setCollectionHorizontalInset{
    
    return ^(CGFloat inset) {
        
        self.collectionHorizontalInset = inset;
        
        return self;
    };
}

/** 设置collection的title下分隔线是否隐藏 默认YES */
- (JKAlertView *(^)(BOOL hidden))setCollectionTitleSeperatorHidden{
    
    return ^(BOOL hidden) {
        
        self.collectionTitleSeparatorHidden = hidden;
        
        return self;
    };
}

/**
 * 设置两个collectionView之间的间距
 * 有第二个collectionView时有效 默认10, 最小为0
 */
- (JKAlertView *(^)(CGFloat margin))setCollectionViewMargin{
    
    return ^(CGFloat margin) {
        
        self.collectionViewMargin = margin < 0 ? 0 : margin;
        
        return self;
    };
}

/**
 * 设置actionSheet样式添加自定义的titleView
 * frmae给出高度即可，宽度将自适应
 * 请将该自定义view视为容器view，推荐使用自动布局在其上约束子控件
 * isClearContainerBackgroundColor : 是否让其容器视图透明
 */
- (JKAlertView *(^)(BOOL isClearContainerBackgroundColor, UIView *(^customView)(void)))setCustomActionSheetTitleView{
    
    return ^(BOOL isClearContainerBackgroundColor, UIView *(^customView)(void)) {
        
        self.customSheetTitleView = !customView ? nil : customView();
        
        self.isClearTextContainerBackground = isClearContainerBackgroundColor;
        
        if (isClearContainerBackgroundColor) {
            
            self->_textContainerView.backgroundColor = nil;
        }
        
        return self;
    };
}

/** 设置sheet样式最大高度 默认屏幕高度 * 0.85 */
- (JKAlertView *(^)(CGFloat height))setSheetMaxHeight{
    
    return ^(CGFloat height) {
        
        self->JKAlertSheetMaxH = height;
        
        self->SheetMaxHeightSetted = YES;
        
        return self;
    };
}

/** 自定义配置tableView */
- (JKAlertView *(^)(void(^)(UITableView *tableView)))setTableViewConfiguration{
    
    return ^(void(^tableViewConfiguration)(UITableView *tableView)) {
        
        !tableViewConfiguration ? : tableViewConfiguration(self->_tableView);
        
        return self;
    };
}

/** 设置UITableViewDataSource */
- (JKAlertView *(^)(id<UITableViewDataSource> dataSource))setCustomTableViewDataSource{
    
    return ^(id<UITableViewDataSource> dataSource) {
        
        self.tableViewDataSource = dataSource;
        self->_tableView.dataSource = dataSource ? dataSource : self;
        
        return self;
    };
}

/** 设置UITableViewDelegate */
- (JKAlertView *(^)(id<UITableViewDelegate> delegate))setCustomTableViewDelegate{
    
    return ^(id<UITableViewDelegate> delegate) {
        
        self.tableViewDelegate = delegate;
        self->_tableView.delegate = delegate ? delegate : self;
        
        return self;
    };
}

/** 设置actionSheet底部取消按钮是否固定在底部 默认NO */
- (JKAlertView *(^)(BOOL pinCancelButton))setPinCancelButton{
    
    return ^(BOOL pinCancelButton) {
        
        self.pinCancelButton = self.isActionSheetPierced ? YES : pinCancelButton;
        
        [self updateInsets];
        
        return self;
    };
}

/**
 * 设置actionSheet是否镂空
 * 类似UIAlertControllerStyleActionSheet效果
 * 设置为YES后，setPinCancelButton将强制为YES
 */
- (JKAlertView *(^)(BOOL isPierced, CGFloat cornerRadius, CGFloat horizontalMargin, CGFloat bottomMargin, UIColor *lightBackgroundColor, UIColor *darkBackgroundColor))setActionSheetPierced{
    
    return ^(BOOL isPierced, CGFloat cornerRadius, CGFloat horizontalMargin, CGFloat bottomMargin, UIColor *lightBackgroundColor, UIColor *darkBackgroundColor) {
        
        if (self.alertStyle != JKAlertStyleActionSheet) {
            
            return self;
        }
        
        self.isActionSheetPierced = isPierced;
        
        self.piercedBackgroundColor = JKAlertAdaptColor(lightBackgroundColor ? lightBackgroundColor : [UIColor whiteColor], darkBackgroundColor ? darkBackgroundColor : [UIColor blackColor]);
        
        [self.actions enumerateObjectsUsingBlock:^(JKAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            obj.isPierced = self.isActionSheetPierced;
            obj.piercedBackgroundColor = self.piercedBackgroundColor;
        }];
        
        if (!isPierced) {
            
            return self;
        }
        
        self.piercedCornerRadius = MAX(cornerRadius, 0);
        
        self.piercedHorizontalMargin = MAX(horizontalMargin, 0);
        
        self.pinCancelButton = YES;
        
        self.piercedBottomMargin = MAX(bottomMargin, 0);
        
        [self updateInsets];
        
        return self;
    };
}

/**
 * 设置collection样式添加自定义的titleView
 * frmae给出高度即可，宽度将自适应
 * 请将该自定义view视为容器view，推荐使用自动布局在其上约束子控件
 */
- (JKAlertView *(^)(UIView *(^customView)(void)))setCustomCollectionTitleView{
    
    return ^(UIView *(^customView)(void)) {
        
        self.customSheetTitleView = !customView ? nil : customView();
        
        return self;
    };
}

/**
 * 设置是否使JKAlertView.dismissAll(); 对当前JKAlertView无效
 * 请谨慎使用，若设置为YES 调用JKAlertView.dismissAll(); 将对当前JKAlertView无效
 */
- (JKAlertView *(^)(BOOL isNoneffective))setDismissAllNoneffective{
    
    return ^(BOOL isNoneffective) {
        
        self.isDismissAllNoneffective = isNoneffective;
        
        return self;
    };
}

/**
 * 设置用于通知消失的key
 * 设置该值后可以使用类方法 JKAlertView.DismissForKey(dismissKey); 来手动消失
 */
- (JKAlertView *(^)(NSString *dismissKey))setDismissKey{
    
    return ^(NSString *dismissKey) {
        
        self.dismissKey = dismissKey;
        
        return self;
    };
}

/**
 * 设置用于通知消失的类别
 * 可以将多个弹框设置同一类别，方便移除同一类别的弹框
 * 设置该值后可以使用类方法 JKAlertView.dismissForCategory(dismissCategory); 来手动消失
 */
- (JKAlertView *(^)(NSString *dismissCategory))setDismissCategory{
    
    return ^(NSString *dismissCategory) {
        
        self.dismissCategory = dismissCategory;
        
        return self;
    };
}

/**
 * 设置自定义展示动画，动画完成一定要调用showAnimationDidComplete
 * 此时所有frame已经计算好，plain样式animationView在中间，sheet样式animationView在底部
 */
- (JKAlertView *(^)(void (^)(JKAlertView *view, UIView *animationView)))setCustomShowAnimationBlock{
    
    return ^(void (^showAnimationBlock)(JKAlertView *view, UIView *animationView)) {
        
        self.customShowAnimationBlock = showAnimationBlock;
        
        return self;
    };
}

/** 设置自定义消失动画 */
- (JKAlertView *(^)(void (^)(JKAlertView *view, UIView *animationView)))setCustomDismissAnimationBlock{
    
    return ^(void (^dismissAnimationBlock)(JKAlertView *view, UIView *animationView)) {
        
        self.customDismissAnimationBlock = dismissAnimationBlock;
        
        return self;
    };
}

#pragma mark
#pragma mark - 监听屏幕旋转

- (void)orientationChanged:(NSNotification *)noti{
    
    !self.orientationChangeBlock ? : self.orientationChangeBlock(self, [UIApplication sharedApplication].statusBarOrientation);
    
    [self updateWidthHeight];
    
    [self calculateUI];
    
    [self updateInsets];
}

- (void)updateInsets{
    
    if (!_tableView && (_alertStyle != JKAlertStyleCollectionSheet)) { return; }
    
    CGFloat safeAreaInset = 0;
    
    if (@available(iOS 11.0, *)) {
        
        safeAreaInset = MAX(self.customSuperView.safeAreaInsets.left, self.customSuperView.safeAreaInsets.right);
    }
    
    if (_tableView) {
        
        CGFloat bottomInset = 0;
        
        if (!self.pinCancelButton) {
            
            bottomInset = JKAlertAdjustHomeIndicatorHeight;
            
            if (AutoAdjustHomeIndicator && FillHomeIndicator) {
                
                bottomInset = 0;
            }
        }
        
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, bottomInset, 0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, (self.pinCancelButton ? 0 : JKAlertCurrentHomeIndicatorHeight()), safeAreaInset);
    }
    
    if (_alertStyle == JKAlertStyleCollectionSheet) {
        
        _scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, JKAlertCurrentHomeIndicatorHeight(), safeAreaInset);
    }
}

#pragma mark
#pragma mark - 添加action

/** 添加action */
- (JKAlertView *(^)(JKAlertAction *action))addAction{
    
    return ^(JKAlertAction *action) {
        
        [self addAction:action];
        
        return self;
    };
}

/** 链式移除action */
- (JKAlertView *(^)(JKAlertAction *action))removeAction{
    
    return ^(JKAlertAction *action) {
        
        [self removeAction:action];
        
        return self;
    };
}

/** 链式添加action */
- (JKAlertView *(^)(JKAlertAction *action, NSUInteger atIndex))insertAction{
    
    return ^(JKAlertAction *action, NSUInteger atIndex) {
        
        [self insertAction:action atIndex:atIndex];
        
        return self;
    };
}

/** 链式移除action */
- (JKAlertView *(^)(NSUInteger index))removeActionAtIndex{
    
    return ^(NSUInteger index) {
        
        [self removeActionAtIndex:index];
        
        return self;
    };
}

/** 链式获取action */
- (JKAlertView *(^)(NSUInteger index, void(^)(JKAlertAction *action)))getActionAtIndex{
    
    return ^(NSUInteger index, void(^getAction)(JKAlertAction *action)) {
        
        JKAlertAction *action = [self getActionAtIndex:index];
        
        !getAction ? : getAction(action);
        
        return self;
    };
}

/** 添加第二个collectionView的action */
- (JKAlertView *(^)(JKAlertAction *action))addSecondCollectionAction{
    
    return ^(JKAlertAction *action) {
        
        [self addSecondCollectionAction:action];
        
        return self;
    };
}


/** collection链式添加第二个collectionView的action */
- (JKAlertView *(^)(JKAlertAction *action, NSUInteger atIndex))insertSecondCollectionAction{
    
    return ^(JKAlertAction *action, NSUInteger atIndex) {
        
        [self insertSecondCollectionAction:action atIndex:atIndex];
        
        return self;
    };
}

/** 添加action */
- (void)addAction:(JKAlertAction *)action{
    
    if (!action) { return; }
    
    [self setAlertViewToAction:action];
    
    [self.actions addObject:action];
}

/** 移除action */
- (void)removeAction:(JKAlertAction *)action{
    
    if (!action || ![self.actions containsObject:action]) { return; }
    
    [self.actions removeObject:action];
}

/** 添加action */
- (void)insertAction:(JKAlertAction *)action atIndex:(NSUInteger)index{
    
    if (!action) { return; }
    
    [self setAlertViewToAction:action];
    
    [self.actions insertObject:action atIndex:index];
}

/** 移除action */
- (void)removeActionAtIndex:(NSUInteger)index{
    
    if (index < 0 || index >= self.actions.count) { return; }
    
    [self.actions removeObjectAtIndex:index];
}

/** 获取action */
- (JKAlertAction *)getActionAtIndex:(NSUInteger)index{
    
    if (index < 0 || index >= self.actions.count) { return nil; }
    
    JKAlertAction *action = [self.actions objectAtIndex:index];
    
    return action;
}

/** 添加第二个collectionView的action */
- (void)addSecondCollectionAction:(JKAlertAction *)action{
    
    if (!action) { return; }
    
    [self setAlertViewToAction:action];
    
    [self.actions2 addObject:action];
}

/** 添加第二个collectionView的action */
- (void)insertSecondCollectionAction:(JKAlertAction *)action atIndex:(NSUInteger)index{
    
    if (!action) { return; }
    
    [self setAlertViewToAction:action];
    
    [self.actions2 insertObject:action atIndex:index];
}


#pragma mark
#pragma mark - action数组操作

/** 添加action */
- (JKAlertView *(^)(JKAlertAction *action, BOOL isSecondCollection))addActionTo{
    
    return ^(JKAlertAction *action, BOOL isSecondCollection) {
        
        [self addAction:action isSecondCollection:isSecondCollection];
        
        return self;
    };
}

/** 链式移除action */
- (JKAlertView *(^)(JKAlertAction *action, BOOL isSecondCollection))removeActionFrom{
    
    return ^(JKAlertAction *action, BOOL isSecondCollection) {
        
        [self removeAction:action isSecondCollection:isSecondCollection];
        
        return self;
    };
}

/** 链式添加action */
- (JKAlertView *(^)(JKAlertAction *action, NSUInteger atIndex, BOOL isSecondCollection))insertActionTo{
    
    return ^(JKAlertAction *action, NSUInteger atIndex, BOOL isSecondCollection) {
        
        [self insertAction:action atIndex:atIndex isSecondCollection:isSecondCollection];
        
        return self;
    };
}

/** 链式移除action */
- (JKAlertView *(^)(NSUInteger index, BOOL isSecondCollection))removeActionAtIndexFrom{
    
    return ^(NSUInteger index, BOOL isSecondCollection) {
        
        [self removeActionAtIndex:index isSecondCollection:isSecondCollection];
        
        return self;
    };
}

/** 链式获取action */
- (JKAlertView *(^)(NSUInteger index, BOOL isSecondCollection, void(^)(JKAlertAction *action)))getActionAtIndexFrom{
    
    return ^(NSUInteger index, BOOL isSecondCollection, void(^getAction)(JKAlertAction *action)) {
        
        JKAlertAction *action = [self getActionAtIndex:index isSecondCollection:isSecondCollection];
        
        !getAction ? : getAction(action);
        
        return self;
    };
}

/** 链式获取cancelAction或collectionAction */
- (JKAlertView *(^)(BOOL isCancelAction, void(^)(JKAlertAction *action)))getCancelOrCollectionAction{
    
    return ^(BOOL isCancelAction, void(^getAction)(JKAlertAction *action)) {
        
        JKAlertAction *action = isCancelAction ? [self getCancelAction] : [self getCollectionAction];
        
        !getAction ? : getAction(action);
        
        return self;
    };
}

/** 链式获取action数组 */
- (JKAlertView *(^)(BOOL isSecondCollection, void(^)(NSArray *actionArray)))getActionArrayFrom{
    
    return ^(BOOL isSecondCollection, void(^getActionArray)(NSArray *actionArray)) {
        
        !getActionArray ? : getActionArray([self getActionArrayIsSecondCollection:isSecondCollection]);
        
        return self;
    };
}

/** 链式清空action数组 */
- (JKAlertView *(^)(BOOL isSecondCollection))clearActionArrayFrom{
    
    return ^(BOOL isSecondCollection) {
        
        [self clearActionArrayIsSecondCollection:isSecondCollection];
        
        return self;
    };
}

/** 添加action */
- (void)addAction:(JKAlertAction *)action isSecondCollection:(BOOL)isSecondCollection{
    
    if (!action) { return; }
    
    [self setAlertViewToAction:action];
    
    if (isSecondCollection) {
        
        [self.actions2 addObject:action];
        
    } else {
        
        [self.actions addObject:action];
    }
}

/** 移除action */
- (void)removeAction:(JKAlertAction *)action isSecondCollection:(BOOL)isSecondCollection{
    
    if (!action) { return; }
    
    if (isSecondCollection) {
        
        if ([self.actions2 containsObject:action]) {
            
            [self.actions2 removeObject:action];
        }
        
    } else {
        
        if ([self.actions containsObject:action]) {
            
            [self.actions removeObject:action];
        }
    }
}

/** 添加action */
- (void)insertAction:(JKAlertAction *)action atIndex:(NSUInteger)index isSecondCollection:(BOOL)isSecondCollection{
    
    if (!action) { return; }
    
    [self setAlertViewToAction:action];
    
    if (isSecondCollection) {
        
        [self.actions2 insertObject:action atIndex:index];
        
    } else {
        
        [self.actions insertObject:action atIndex:index];
    }
}

/** 移除action */
- (void)removeActionAtIndex:(NSUInteger)index isSecondCollection:(BOOL)isSecondCollection{
    
    if (index < 0) { return; }
    
    if (isSecondCollection) {
        
        if (index >= self.actions2.count) { return; }
        
        [self.actions2 removeObjectAtIndex:index];
        
    } else {
        
        if (index >= self.actions.count) { return; }
        
        [self.actions removeObjectAtIndex:index];
    }
}

/** 获取action */
- (JKAlertAction *)getActionAtIndex:(NSUInteger)index isSecondCollection:(BOOL)isSecondCollection{
    
    if (index < 0) { return nil; }
    
    JKAlertAction *action = nil;
    
    if (isSecondCollection) {
        
        if (index >= self.actions2.count) { return nil; }
        
        action = [self.actions2 objectAtIndex:index];
        
    } else {
        
        if (index >= self.actions.count) { return nil; }
        
        action = [self.actions objectAtIndex:index];
    }
    
    return action;
}

/** 获取cancelAction */
- (JKAlertAction *)getCancelAction{
    
    return _cancelAction;
}

/** 获取collectionAction */
- (JKAlertAction *)getCollectionAction{
    
    return _collectionAction;
}

/** 获取action数组 */
- (NSArray *)getActionArrayIsSecondCollection:(BOOL)isSecondCollection{
    
    if (isSecondCollection) {
        
        return [self.actions2 copy];
        
    } else {
        
        return [self.actions copy];
    }
}

/** 清空action数组 */
- (void)clearActionArrayIsSecondCollection:(BOOL)isSecondCollection{
    
    if (isSecondCollection) {
        
        [_actions2 removeAllObjects];
        
    } else {
        
        [_actions removeAllObjects];
    }
}



#pragma mark
#pragma mark - 添加textField

/**
 * 添加textField 默认高度30
 * textField之间的间距是1，和其superView的上下左右间距也是1
 * textField可以直接对其superView进行一些属性修改，如背景色
 * block中的参数view用于调用dismiss()来移除当前弹框
 */
- (void)addTextFieldWithConfigurationHandler:(void (^)(JKAlertView *view, UITextField *textField))configurationHandler{
    
    UITextField *tf = [[UITextField alloc] init];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 1)];
    tf.leftView = leftView;
    tf.leftViewMode = UITextFieldViewModeAlways;
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 1)];
    tf.rightView = rightView;
    tf.rightViewMode = UITextFieldViewModeAlways;
    tf.font = [UIFont systemFontOfSize:13];
    tf.backgroundColor = JKAlertGlobalBackgroundColor();
    
    if (_textFieldContainerView == nil) {
        
        UIView *textFieldContainerView = [[UIView alloc] init];
        textFieldContainerView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];//[[UIColor blackColor] colorWithAlphaComponent:0.15];//nil;
        _textFieldContainerView = textFieldContainerView;
        [_plainTextContainerScrollView addSubview:_textFieldContainerView];
    }
    
    [self.textFieldArr addObject:tf];
    
    [_textFieldContainerView addSubview:tf];
    
    if (self.currentTextField == nil) {
        
        self.currentTextField = tf;
    }
    
    !configurationHandler ? : configurationHandler(self, tf);
}

/**
 * 链式添加textField 默认高度30
 * textField之间的间距是1，和其superView的上下左右间距也是1
 * textField可以直接对其superView进行一些属性修改，如背景色
 * block中的参数view用于调用dismiss()来移除当前弹框
 */
- (JKAlertView *(^)(void (^)(JKAlertView *view, UITextField *textField)))addTextFieldWithConfigurationHandler{
    
    return ^(void (^configurationHandler)(JKAlertView *view, UITextField *textField)) {
        
        [self addTextFieldWithConfigurationHandler:configurationHandler];
        
        return self;
    };
}

/** 监听屏幕旋转 */
- (JKAlertView *(^)(void(^orientationChangeBlock)(JKAlertView *view, UIInterfaceOrientation orientation)))setOrientationChangeBlock{
    
    return ^(void(^orientationChangeBlock)(JKAlertView *view, UIInterfaceOrientation orientation)) {
        
        self.orientationChangeBlock = orientationChangeBlock;
        
        return self;
    };
}

/** 设置监听superView尺寸改变时将要自适应的block */
- (JKAlertView *(^)(void(^willAdaptBlock)(JKAlertView *view, UIView *containerView)))setWillAutoAdaptSuperViewBlock{
    
    return ^JKAlertView *(void(^willAdaptBlock)(JKAlertView *view, UIView *containerView)) {
        
        self.willAdaptBlock = willAdaptBlock;
        
        return self;
    };
}

/** 设置监听superView尺寸改变时自适应完成的block */
- (JKAlertView *(^)(void(^didAdaptBlock)(JKAlertView *view, UIView *containerView)))setDidAutoAdaptSuperViewBlock{
    
    return ^JKAlertView *(void(^didAdaptBlock)(JKAlertView *view, UIView *containerView)) {
        
        self.didAdaptBlock = didAdaptBlock;
        
        return self;
    };
}

/** 显示并监听JKAlertView消失动画完成 */
- (void(^)(void(^dismissComplete)(void)))showWithDismissComplete{
    
    return ^(void(^dismissComplete)(void)) {
        
        [self show];
        
        self.didDismissHandler = dismissComplete;
    };
}

/** 监听即将开始显示动画 */
- (JKAlertView *(^)(void(^willShowHandler)(JKAlertView *view)))setWillShowHandler{
    
    return ^(void(^willShowHandler)(JKAlertView *view)) {
        
        self.willShowHandler = willShowHandler;
        
        return self;
    };
}

/** 监听JKAlertView显示动画完成 */
- (JKAlertView *(^)(void(^didShowHandler)(JKAlertView *view)))setDidShowHandler{
    
    return ^(void(^didShowHandler)(JKAlertView *view)) {
        
        self.didShowHandler = didShowHandler;
        
        return self;
    };
}

/** 监听JKAlertView即将消失 */
- (JKAlertView *(^)(void(^willDismissHandler)(void)))setWillDismissHandler{
    
    return ^JKAlertView * (void(^willDismissHandler)(void)) {
        
        self.willDismissHandler = willDismissHandler;
        
        return self;
    };
}

/** 监听JKAlertView消失动画完成 */
- (JKAlertView *(^)(void(^didDismissHandler)(void)))setDidDismissHandler{
    
    return ^(void(^didDismissHandler)(void)) {
        
        self.didDismissHandler = didDismissHandler;
        
        return self;
    };
}

/** 设置dealloc时会调用的block */
- (void(^)(void(^deallocBlock)(void)))setDeallocBlock{
    
    return ^(void(^deallocBlock)(void)) {
        
        self.deallocBlock = deallocBlock;
    };
}

#pragma mark
#pragma mark - 计算frame

- (void)solveTraitCollectionDidChange {
    
    if (@available(iOS 13.0, *)) {
        
        if ([self.alertBackGroundView isKindOfClass:[UIVisualEffectView class]]) {
            
            BOOL isLight = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight);
            
            [(UIVisualEffectView *)self.alertBackGroundView setEffect:[UIBlurEffect effectWithStyle:isLight ? UIBlurEffectStyleExtraLight : UIBlurEffectStyleDark]];
        }
    }
}

- (void)calculateUI {
    
    self.frame = CGRectMake(0, 0, JKAlertScreenW, JKAlertScreenH);
    
    switch (self.alertStyle) {
        case JKAlertStylePlain:
        {
            // TODO: JKTODO <#注释#>
            [self calculatePlainUI];
            
            return;
        }
            break;
            
        case JKAlertStyleActionSheet:
        {
            
        }
            break;
            
        case JKAlertStyleCollectionSheet:
        {
            
        }
            break;
            
        case JKAlertStyleHUD:
        {
            // TODO: JKTODO <#注释#>
            [self calculateHudUI];
            
            return;
        }
            break;
            
        default:
            break;
    }
    
    
    //_titleTextView.textAlignment = self.titleTextViewAlignment;
    //_messageTextView.textAlignment = self.messageTextViewAlignment;
    
    //_titleTextView.userInteractionEnabled = self.textViewUserInteractionEnabled;
    //_messageTextView.userInteractionEnabled = self.textViewUserInteractionEnabled;
    
    //_titleTextView.shouldSelectText = self.textViewShouldSelectText;
    //_messageTextView.shouldSelectText = self.textViewShouldSelectText;
    
    //_titleTextView.textColor = titleTextColor ? titleTextColor : _titleTextView.textColor;
    //_messageTextView.textColor = messageTextColor ? messageTextColor : _messageTextView.textColor;
    
    //_titleTextView.font = titleFont ? titleFont : _titleTextView.font;
    //_messageTextView.font = messageFont ? messageFont : _messageTextView.font;
    
    if (self.alertAttributedTitle) {
        
        _titleTextView.attributedText = self.alertAttributedTitle;
        
    } else if (self.alertTitle) {
        
        _titleTextView.text = self.alertTitle;
        
    } else {
        
        _titleTextView.hidden = YES;
    }
    
    if (self.attributedMessage) {
        
        _messageTextView.attributedText = self.attributedMessage;
        
    } else if (self.alertMessage) {
        
        _messageTextView.text = self.alertMessage;
        
    } else {
        
        _messageTextView.hidden = YES;
    }
    
    if (_alertStyle == JKAlertStyleHUD) {
        
        _messageTextView.hidden = YES;
    }
    
    switch (self.alertStyle) {
        case JKAlertStylePlain:
        {
        }
            break;
            
        case JKAlertStyleActionSheet:
        {
            [self layoutActionSheet];
        }
            break;
            
        case JKAlertStyleCollectionSheet:
        {
            [self layoutCollectionSheet];
        }
            break;
            
        case JKAlertStyleHUD:
        {
        }
            break;
            
        default:
            break;
    }
    
    [self calculateUIFinish];
}

- (void)calculateUIFinish{
    
    correctContainerY = JKAlertScreenH - _sheetContainerView.frame.size.height;
    
    [_tableView reloadData];
    
    [_collectionView reloadData];
    
    [_collectionView2 reloadData];
    
    //[_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x, lastTableViewOffsetY) animated:YES];
}

#pragma mark
#pragma mark - 布局actionSheet

- (void)layoutActionSheet{
    
    GestureIndicatorHeight = (self.enableVerticalGestureDismiss && self.showGestureIndicator) ? JKAlertTopGestureIndicatorHeight : 0;
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    
    if (@available(iOS 11.0, *)) {
        
        safeAreaInsets = self.customSuperView.safeAreaInsets;
    }
    
    CGFloat containerWidth = JKAlertScreenW;
    
    self.alertBackGroundView.hidden = NO;
    
    if (self.isActionSheetPierced) {
        
        containerWidth -= (self.piercedHorizontalMargin * 2 + safeAreaInsets.left + safeAreaInsets.right);
        
        self.alertBackGroundView.hidden = YES;
    }
    
    self.titleTextView.scrollEnabled = NO;
    self.messageTextView.scrollEnabled = NO;
    
    if (self.alertMessage && !self.alertTitle && !self.alertAttributedTitle) {
        
        self.messageTextView.font = [UIFont systemFontOfSize:15];
    }
    
    _textContainerView.frame = CGRectMake(0, GestureIndicatorHeight, containerWidth, JKAlertRowHeight);
    
    CGFloat tableViewH = 0;
    
    for (JKAlertAction *action in self.actions) {
        
        tableViewH += action.rowHeight;
    }
    
    if (self.cancelAction.rowHeight > 0) {
        
        tableViewH += (self.cancelAction.rowHeight + CancelMargin);
    }
    
    CGFloat realPiercedBottomMargin = 0;
    
    if (self.isActionSheetPierced) {
        
        realPiercedBottomMargin = MAX((self.piercedBottomMargin - JKAlertAdjustHomeIndicatorHeight), 0);
        
        tableViewH += realPiercedBottomMargin;
    }
    
    tableViewH += JKAlertAdjustHomeIndicatorHeight;
    
    _tableView.frame = CGRectMake(0, CGRectGetMaxY(_textContainerView.frame), containerWidth, tableViewH);
    
    _sheetContainerView.frame = CGRectMake((JKAlertScreenW - containerWidth) * 0.5, JKAlertScreenH, containerWidth, _textContainerView.frame.size.height + _tableView.frame.size.height);
    
    CGFloat maxWidth = _textContainerView.frame.size.width - 40/*self.textViewLeftRightMargin * 2*/ - (safeAreaInsets.left + safeAreaInsets.right);
    
    if (self.isActionSheetPierced) {
        
        maxWidth -= (self.piercedHorizontalMargin * 2);
    }
    
    [self.titleTextView calculateFrameWithMaxWidth:maxWidth minHeight:JKAlertMinTitleLabelH originY:JKAlertSheetTitleMargin superView:_textContainerView];
    
    [self.messageTextView calculateFrameWithMaxWidth:maxWidth minHeight:JKAlertMinMessageLabelH originY:CGRectGetMaxY(self.titleTextView.frame) + JKAlertSheetTitleMargin superView:_textContainerView];
    
    CGRect rect = _textContainerView.frame;
    rect.size.height = JKAlertSheetTitleMargin + self.titleTextView.frame.size.height + JKAlertSheetTitleMargin + self.messageTextView.frame.size.height + JKAlertSheetTitleMargin;
    
    if (self.titleTextView.hidden && self.messageTextView.hidden) {
        
        rect.size.height = 0;
        
    } else if (self.titleTextView.hidden && !self.messageTextView.hidden) {
        
        rect.size.height = JKAlertSheetTitleMargin + self.messageTextView.frame.size.height + JKAlertSheetTitleMargin;
        rect.size.height = rect.size.height < JKAlertRowHeight ? JKAlertRowHeight : rect.size.height;
        
        self.messageTextView.center = CGPointMake(self.textContainerView.frame.size.width * 0.5, rect.size.height * 0.5);
        
    } else if (self.messageTextView.hidden && !self.titleTextView.hidden) {
        
        rect.size.height = JKAlertSheetTitleMargin + self.titleTextView.frame.size.height + JKAlertSheetTitleMargin;
        rect.size.height = rect.size.height < JKAlertRowHeight ? JKAlertRowHeight : rect.size.height;
        
        self.titleTextView.center = CGPointMake(self.textContainerView.frame.size.width * 0.5, rect.size.height * 0.5);
    }
    
    if (_customSheetTitleView) {
        
        rect.size.height = _customSheetTitleView.frame.size.height;
        
        _customSheetTitleView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    }
    
    _textContainerBottomLineView.hidden = (rect.size.height == 0 || (!_customSheetTitleView && self.actions.count <= 0));
    
    _textContainerView.frame = rect;
    _scrollView.contentSize = rect.size;
    
    [self adjustSheetFrame];
    
    CGFloat sheetContainerHeight = _textContainerView.frame.size.height + _tableView.frame.size.height;
    
    sheetContainerHeight += GestureIndicatorHeight;
    
    _sheetContainerView.frame = CGRectMake((JKAlertScreenW - containerWidth) * 0.5, JKAlertScreenH - sheetContainerHeight, containerWidth, sheetContainerHeight);
    
    self.topGestureIndicatorView.backgroundColor = self.isActionSheetPierced ? self.piercedBackgroundColor : JKAlertGlobalBackgroundColor();
    
    self.textContainerView.backgroundColor = self.isActionSheetPierced ? self.piercedBackgroundColor : (self.isClearTextContainerBackground ? nil : JKAlertGlobalBackgroundColor());
    
    self.sheetContentView.backgroundColor = self.isActionSheetPierced ? self.piercedBackgroundColor : nil;
    
    self.topGestureIndicatorView.frame = CGRectMake(0, 0, _sheetContainerView.frame.size.width, GestureIndicatorHeight);
    
    self.topGestureLineView.frame = CGRectMake((self.topGestureIndicatorView.frame.size.width - JKAlertTopGestureIndicatorLineWidth) * 0.5, (JKAlertTopGestureIndicatorHeight - JKAlertTopGestureIndicatorLineHeight) * 0.5, JKAlertTopGestureIndicatorLineWidth, JKAlertTopGestureIndicatorLineHeight);
    
    self.topGestureIndicatorView.hidden = (!self.enableVerticalGestureDismiss || !self.showGestureIndicator);
    
    _sheetContentView.frame = CGRectMake(0, 0, _sheetContainerView.frame.size.width, sheetContainerHeight);
    
    _scrollView.frame = CGRectMake(0, 0, _textContainerView.bounds.size.width, _textContainerView.bounds.size.height);
    
    _tableView.scrollEnabled = _tableView.frame.size.height < tableViewH;
    
    _textContainerBottomLineView.frame = CGRectMake(0, self.textContainerView.frame.size.height - JKAlertSeparatorLineWH, self.textContainerView.frame.size.width, JKAlertSeparatorLineWH);
    
    [self updateInsets];
    
    if (!self.pinCancelButton || !self.cancelAction) {
        
        [_cancelButton removeFromSuperview];
        
        return;
    }
    
    if (self.cancelButton.superview != _sheetContainerView) {
        
        [_sheetContainerView addSubview:self.cancelButton];
    }
    
    self.cancelAction.piercedBackgroundColor = self.isActionSheetPierced ? self.piercedBackgroundColor : nil;
    
    self.cancelButton.action = self.cancelAction;
    
    CGFloat cancelHeight = self.cancelAction.rowHeight;
    
    CGRect frame = CGRectMake(self.collectionButtonLeftRightMargin, _sheetContentView.frame.size.height - cancelHeight - JKAlertAdjustHomeIndicatorHeight, JKAlertScreenW - self.collectionButtonLeftRightMargin * 2, cancelHeight);
    
    if (self.cancelAction.customView) {
        
        frame.size.height = self.cancelAction.customView.frame.size.height - (self.cancelButton.titleEdgeInsets.bottom > 0 ? JKAlertAdjustHomeIndicatorHeight : 0);
    }
    
    self.cancelButton.frame = frame;
    
    self.cancelAction.customView.frame = self.cancelButton.bounds;
    
    if (self.isActionSheetPierced) {
        
        frame = self.cancelButton.frame;
        
        frame.size.width = _sheetContentView.frame.size.width;
        
        frame.origin.y = _sheetContentView.frame.size.height - frame.size.height - JKAlertAdjustHomeIndicatorHeight - realPiercedBottomMargin;
        
        self.cancelButton.frame = frame;
        
        self.cancelAction.customView.frame = self.cancelButton.bounds;
        
        [self.cancelButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
    } else if (FillHomeIndicator) {
        
        frame = self.cancelButton.frame;
        frame.size.height += JKAlertAdjustHomeIndicatorHeight;
        frame.origin.y = _sheetContentView.frame.size.height - frame.size.height;
        self.cancelButton.frame = frame;
        
        self.cancelAction.customView.frame = self.cancelButton.bounds;
        
        [self.cancelButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, JKAlertAdjustHomeIndicatorHeight, 0)];
        
        //        NSLog(@"%@", NSStringFromUIEdgeInsets(self.cancelButton.titleEdgeInsets));
        
    } else {
        
        [self.cancelButton setTitleEdgeInsets:UIEdgeInsetsZero];
    }
    
    frame = self.tableView.frame;
    
    frame.size.height -= (_sheetContentView.frame.size.height - self.cancelButton.frame.origin.y + CancelMargin);
    
    self.tableView.frame = frame;
    
    if (self.isActionSheetPierced) {
        
        frame = self.sheetContentView.frame;
        frame.size.height = CGRectGetMaxY(self.tableView.frame);
        self.sheetContentView.frame = frame;
        
        self.sheetContentView.layer.cornerRadius = self.piercedCornerRadius;
        self.sheetContentView.layer.masksToBounds = YES;
        
        self.cancelButton.layer.cornerRadius = self.piercedCornerRadius;
        self.cancelButton.layer.masksToBounds = YES;
        
        if (JKAlertIsDeviceX() &&
            JKAlertAdjustHomeIndicatorHeight > 0) {
            
            frame = _sheetContainerView.frame;
            frame.origin.y += CancelMargin;
            frame.size.height -= CancelMargin;
            _sheetContainerView.frame = frame;
        }
    }
}

- (void)adjustSheetFrame{
    
    /*
     CGRect frame = self.tableView.frame;
     
     frame.origin.y = 0;
     frame.size.height += self.textContainerView.frame.size.height;
     
     _tableView.scrollEnabled = frame.size.height > JKAlertSheetMaxH;
     
     frame.size.height = frame.size.height > JKAlertSheetMaxH ? JKAlertSheetMaxH : frame.size.height;
     
     _tableView.frame = frame;
     
     UIView *tableHeader = _tableView.tableHeaderView;
     
     if (!tableHeader) {
     
     tableHeader = [[UIView alloc] init];
     }
     [tableHeader addSubview:_textContainerView];
     
     frame = tableHeader.frame;
     frame.size.height = _textContainerView.frame.size.height;
     
     tableHeader.frame = frame;
     
     _tableView.tableHeaderView = tableHeader; //*/
    
    CGRect frame = CGRectZero;
    
    if (self.textContainerView.frame.size.height > JKAlertSheetMaxH * 0.5 && self.tableView.frame.size.height > JKAlertSheetMaxH * 0.5) {
        
        frame = self.textContainerView.frame;
        frame.size.height = JKAlertSheetMaxH * 0.5;
        self.textContainerView.frame = frame;
        
        frame = self.tableView.frame;
        frame.origin.y = CGRectGetMaxY(self.textContainerView.frame);
        frame.size.height = JKAlertSheetMaxH * 0.5;
        self.tableView.frame = frame;
        
    } else if (self.textContainerView.frame.size.height > JKAlertSheetMaxH * 0.5) {
        
        frame = self.textContainerView.frame;
        frame.size.height = (frame.size.height + self.tableView.frame.size.height) > JKAlertSheetMaxH ? JKAlertSheetMaxH - self.tableView.frame.size.height : frame.size.height;
        self.textContainerView.frame = frame;
        
    } else if (self.tableView.frame.size.height > JKAlertSheetMaxH * 0.5) {
        
        frame = self.tableView.frame;
        frame.origin.y = CGRectGetMaxY(self.textContainerView.frame);
        frame.size.height = (frame.size.height + self.textContainerView.frame.size.height) > JKAlertSheetMaxH ? JKAlertSheetMaxH - self.textContainerView.frame.size.height : frame.size.height;
        self.tableView.frame = frame;
    }
    
    frame = self.tableView.frame;
    frame.origin.y = CGRectGetMaxY(self.textContainerView.frame);
    self.tableView.frame = frame;
}

#pragma mark
#pragma mark - 布局collectionSheet

- (void)layoutCollectionSheet{
    
    GestureIndicatorHeight = (self.enableVerticalGestureDismiss && self.showGestureIndicator) ? JKAlertTopGestureIndicatorHeight : 0;
    
    NSInteger count = self.actions.count;
    NSInteger count2 = self.actions2.count;
    
    if (count <= 0 && count2 > 0) {
        
        [self.actions addObjectsFromArray:self.actions2];
        
        [self.actions2 removeAllObjects];
        
        count = count2;
        count2 = 0;
        
        self.compoundCollection = NO;
    }
    
    if (count == 0 && count2 == 0) {
        
        self.compoundCollection = NO;
    }
    
    // 合体
    if (self.compoundCollection && count2 > 0 && count != count2) {
        
        if (count > count2) {
            
            for (NSInteger i = 0; i < count - count2; i++) {
                
                [self addSecondCollectionAction:[JKAlertAction actionWithTitle:nil style:(0) handler:nil]];
            }
            
            count2 = count;
            
        } else {
            
            for (NSInteger i = 0; i < count2 - count; i++) {
                
                [self addAction:[JKAlertAction actionWithTitle:nil style:(0) handler:nil]];
            }
            
            count = count2;
        }
    }
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    
    if (@available(iOS 11.0, *)) {
        
        safeAreaInsets = self.customSuperView.safeAreaInsets;
    }
    
    CGFloat maxWidth = JKAlertScreenW - 40/*self.textViewLeftRightMargin * 2*/ - (safeAreaInsets.left + safeAreaInsets.right);
    
    CGRect rect = [self.titleTextView calculateFrameWithMaxWidth:maxWidth minHeight:JKAlertMinTitleLabelH originY:0 superView:self.textContainerView];
    
    if (JKAlertSheetMaxH - 395 > JKAlertMinTitleLabelH) {
        
        rect.size.height = rect.size.height > JKAlertSheetMaxH - 395 ? JKAlertSheetMaxH - 395 : rect.size.height;
    }
    
    rect.size.height = self.titleTextView.hidden ? 0 : rect.size.height;
    
    self.titleTextView.frame = rect;
    
    self.textContainerView.frame = CGRectMake(0, GestureIndicatorHeight, JKAlertScreenW, /*TBMargin*/20 + rect.size.height + /*TBMargin*/20);
    self.titleTextView.center = CGPointMake(self.textContainerView.frame.size.width * 0.5, self.textContainerView.frame.size.height * 0.5);
    
    if (_customSheetTitleView) {
        
        self.textContainerView.frame = CGRectMake(0, GestureIndicatorHeight, JKAlertScreenW, _customSheetTitleView.frame.size.height);
        _customSheetTitleView.frame = CGRectMake(0, 0, JKAlertScreenW, _customSheetTitleView.frame.size.height);
    }
    
    if (self.collectionTitleSeparatorHidden) {
        
        _textContainerBottomLineView.hidden = YES;
        
    } else {
        
        _textContainerBottomLineView.hidden = (self.textContainerView.frame.size.height == 0 || (!_customSheetTitleView && self.actions.count <= 0 && self.actions2.count <= 0));
    }
    
    CGFloat collectionViewY = CGRectGetMaxY(self.textContainerView.frame) + (_textContainerBottomLineView.hidden ? 0 : 10);
    
    CGFloat collectionViewHeight = (self.actions.count <= 0) ? 0 : self.flowlayoutItemWidth - 6 + self.collectionViewMargin;
    
    self.collectionView.frame = CGRectMake(0, collectionViewY, JKAlertScreenW, collectionViewHeight);
    
    self.flowlayout.itemSize = CGSizeMake(self.flowlayoutItemWidth, self.flowlayoutItemWidth - 6);
    self.flowlayout.sectionInset = UIEdgeInsetsMake(self.flowlayout.itemSize.height - self.collectionView.frame.size.height, 0, 0, 0);
    
    if (count2 > 0) {
        
        self.collectionView2.frame = CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), JKAlertScreenW, self.collectionView.frame.size.height - self.collectionViewMargin);
        
        self.flowlayout2.itemSize = CGSizeMake(self.flowlayoutItemWidth, self.flowlayoutItemWidth - 6);
        self.flowlayout2.sectionInset = UIEdgeInsetsMake(self.flowlayout2.itemSize.height - self.collectionView2.frame.size.height, 0, 0, 0);
    }
    
    if (_showPageControl && _collectionPagingEnabled) {
        
        if (count2 <= 0) {
            
            self.pageControl.frame = CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), self.sheetContainerView.frame.size.width, 27);
            
        } else {
            
            if (_compoundCollection) {
                
                self.pageControl.frame = CGRectMake(0, CGRectGetMaxY(self.collectionView2.frame), self.sheetContainerView.frame.size.width, 27);
            }
        }
    }
    
    self.cancelButton.action = self.cancelAction;
    
    CGRect frame = CGRectZero;
    
    CGFloat Y = 0;
    
    if (self.collectionAction) {
        
        self.collectionButton.action = self.collectionAction;
        
        if (_pageControl) {
            
            Y = CGRectGetMaxY(_pageControl.frame);
            
        } else if (_collectionView2) {
            
            Y = CGRectGetMaxY(_collectionView2.frame) + 10;
            
        } else if (_collectionView) {
            
            Y = CGRectGetMaxY(_collectionView.frame) + (_collectionView.frame.size.height > 0 ? 10 : 0);
        }
        
        Y += CancelMargin;
        
        frame = CGRectMake(self.collectionButtonLeftRightMargin, Y, JKAlertScreenW - self.collectionButtonLeftRightMargin * 2, JKAlertActionButtonH);
        
        if (self.collectionAction.customView) {
            
            self.collectionButton.backgroundColor = nil;
            
            frame.size.height = self.collectionAction.customView.frame.size.height;
        }
        
        self.collectionButton.frame = frame;
        
        self.collectionAction.customView.frame = self.collectionButton.bounds;
    }
    
    Y = 0;
    
    if (_collectionButton) {
        
        Y = CGRectGetMaxY(_collectionButton.frame);
        
    } else if (_pageControl) {
        
        Y = CGRectGetMaxY(_pageControl.frame);
        
    } else if (_collectionView2) {
        
        Y = CGRectGetMaxY(_collectionView2.frame) + 10;
        
    } else if (_collectionView) {
        
        Y = CGRectGetMaxY(_collectionView.frame) + (_collectionView.frame.size.height > 0 ? 10 : 0);
    }
    
    Y += CancelMargin;
    
    frame = CGRectMake(self.collectionButtonLeftRightMargin, Y, JKAlertScreenW - self.collectionButtonLeftRightMargin * 2, JKAlertActionButtonH);
    
    if (self.cancelAction.customView) {
        
        self.cancelButton.backgroundColor = nil;
        
        frame.size.height = self.cancelAction.customView.frame.size.height - (self.cancelButton.titleEdgeInsets.bottom > 0 ? JKAlertAdjustHomeIndicatorHeight : 0);
    }
    
    self.cancelButton.frame = frame;
    
    self.cancelAction.customView.frame = self.cancelButton.bounds;
    
    rect = CGRectMake(0, JKAlertScreenH - (CGRectGetMaxY(self.cancelButton.frame) + JKAlertAdjustHomeIndicatorHeight), JKAlertScreenW, CGRectGetMaxY(self.cancelButton.frame) + JKAlertAdjustHomeIndicatorHeight);
    
    CGFloat height = 0;
    
    if (_pageControl) {
        
        height = CGRectGetMaxY(_pageControl.frame);
        
    } else if (_collectionView2) {
        
        height = CGRectGetMaxY(_collectionView2.frame) + 10;
        
    } else if (_collectionView) {
        
        height = CGRectGetMaxY(_collectionView.frame) + (_collectionView.frame.size.height > 0 ? 10 : 0);
    }
    
    self.collectionTopContainerView.frame = CGRectMake(0, 0, JKAlertScreenW, height);
    
    self.scrollView.contentSize = rect.size;
    
    if (rect.size.height > JKAlertSheetMaxH) {
        
        rect.size.height = JKAlertSheetMaxH;
        rect.origin.y = JKAlertScreenH - JKAlertSheetMaxH;
    }
    
    CGFloat sheetContainerHeight = rect.size.height;
    
    //sheetContainerHeight += GestureIndicatorHeight;
    
    rect.size.height = sheetContainerHeight;
    rect.origin.y = JKAlertScreenH - sheetContainerHeight;
    
    self.sheetContainerView.frame = rect;
    
    self.topGestureIndicatorView.frame = CGRectMake(0, 0, _sheetContainerView.frame.size.width, GestureIndicatorHeight);
    
    self.topGestureLineView.frame = CGRectMake((self.topGestureIndicatorView.frame.size.width - JKAlertTopGestureIndicatorLineWidth) * 0.5, (JKAlertTopGestureIndicatorHeight - JKAlertTopGestureIndicatorLineHeight) * 0.5, JKAlertTopGestureIndicatorLineWidth, JKAlertTopGestureIndicatorLineHeight);
    
    self.topGestureIndicatorView.hidden = (!self.enableVerticalGestureDismiss || !self.showGestureIndicator);
    
    _sheetContentView.frame = CGRectMake(0, 0, _sheetContainerView.frame.size.width, sheetContainerHeight);
    
    CGFloat totalMargin = 0;
    
    CGFloat itemMargin = 0;
    
    if (self.collectionColumnCount > 0) {
        
        totalMargin = (JKAlertScreenW - self.flowlayout.itemSize.width * self.collectionColumnCount - self.collectionHorizontalInset * 2);
        
        itemMargin = totalMargin / ((self.collectionHorizontalInset == 0) ? self.collectionColumnCount : self.collectionColumnCount - 1);
    }
    
    if (totalMargin < 0 || self.collectionColumnCount <= 0) {
        
        totalMargin = (JKAlertScreenW - self.flowlayout.itemSize.width * count - self.collectionHorizontalInset * 2);
        
        itemMargin = totalMargin / ((self.collectionHorizontalInset == 0) ? count : count - 1);
    }
    
    itemMargin = itemMargin < 0 ? 0 : itemMargin;
    
    CGFloat leftRightInset = self.collectionHorizontalInset == 0 ? itemMargin * 0.5 : self.collectionHorizontalInset;
    
    if (count2 > 0) {
        
        CGFloat itemMargin2 = 0;
        
        if (self.collectionColumnCount > 0) {
            
            totalMargin = (JKAlertScreenW - self.flowlayout.itemSize.width * self.collectionColumnCount - self.collectionHorizontalInset * 2);
            
            itemMargin2 = totalMargin / ((self.collectionHorizontalInset == 0) ? self.collectionColumnCount : self.collectionColumnCount - 1);
        }
        
        if (totalMargin < 0 || self.collectionColumnCount <= 0) {
            
            totalMargin = (JKAlertScreenW - self.flowlayout.itemSize.width * count - self.collectionHorizontalInset * 2);
            
            itemMargin2 = totalMargin / ((self.collectionHorizontalInset == 0) ? count2 : count2 - 1);
        }
        
        itemMargin2 = itemMargin2 < 0 ? 0 : itemMargin2;
        
        itemMargin = MIN(itemMargin, itemMargin2);
        
        leftRightInset = self.collectionHorizontalInset == 0 ? itemMargin * 0.5 : self.collectionHorizontalInset;
        
        self.flowlayout2.sectionInset = UIEdgeInsetsMake(self.flowlayout2.sectionInset.top, leftRightInset, 0, leftRightInset);
        self.flowlayout2.minimumLineSpacing = itemMargin;
        self.flowlayout2.minimumInteritemSpacing = itemMargin;
    }
    
    self.flowlayout.sectionInset = UIEdgeInsetsMake(self.flowlayout.sectionInset.top, leftRightInset, 0, leftRightInset);
    self.flowlayout.minimumLineSpacing = itemMargin;
    self.flowlayout.minimumInteritemSpacing = itemMargin;
    
    _pageControl.numberOfPages = ceil(((itemMargin + _flowlayout.itemSize.width) * count - 5) / JKAlertScreenW);
    
    // 处理iPhoneX并且横屏的情况
    _collectionView.contentInset = (JKAlertIsDeviceX() && JKAlertScreenW > JKAlertScreenH && itemMargin < 44) ? UIEdgeInsetsMake(0, 44, 0, 44) : UIEdgeInsetsZero;
    _collectionView2.contentInset = _collectionView.contentInset;
    
    // 分页
    _collectionView.pagingEnabled = self.collectionPagingEnabled && _pageControl.numberOfPages > 1;
    _collectionView2.pagingEnabled = _collectionView.pagingEnabled;
    
    if (FillHomeIndicator) {
        
        CGRect cancelButtonFrame = self.cancelButton.frame;
        cancelButtonFrame.size.height += JKAlertAdjustHomeIndicatorHeight;
        self.cancelButton.frame = cancelButtonFrame;
        
        self.cancelAction.customView.frame = self.cancelButton.bounds;
        
        [self.cancelButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, JKAlertAdjustHomeIndicatorHeight, 0)];
        
        //        NSLog(@"%@", NSStringFromUIEdgeInsets(self.cancelButton.titleEdgeInsets));
        
    } else {
        
        [self.cancelButton setTitleEdgeInsets:UIEdgeInsetsZero];
    }
    
    _textContainerBottomLineView.frame = CGRectMake(0, self.textContainerView.frame.size.height - JKAlertSeparatorLineWH, self.textContainerView.frame.size.width, JKAlertSeparatorLineWH);
    
    [self updateInsets];
}

#pragma mark
#pragma mark - 动画弹出来

- (void)solveDidMoveToSuperview {
    
    if (!self.superview) { return; }
    
    self.frame = self.superview.bounds;
    
    if (self.shouldVibrate) {
        
        JKAlertVibrateDevice();
    }
    
    [self startShowAnimation];
    
    if (self.observerSuperView && self.observerSuperView != self.superview) {
        
        [self removeAllOberserver];
    }
    
    if (ObserverAdded) { return; }
    
    self.observerSuperView = self.superview;
    
    [self.superview addObserver:self forKeyPath:@"frame" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
    
    ObserverAdded = YES;
}

- (void)removeAllOberserver{
    
    if (ObserverAdded) {
        
        [self.observerSuperView removeObserver:self forKeyPath:@"frame"];
    }
    
    ObserverAdded = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if (object == self.superview && [keyPath isEqualToString:@"frame"]) {
        
        CGRect oldFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
        CGRect currentFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        
        if (CGSizeEqualToSize(oldFrame.size, currentFrame.size)) { return; }
        
        [self updateWidthHeight];
        
        self.relayout(YES);
    }
}

- (void)startShowAnimation{
    
    self.window.userInteractionEnabled = NO;
    
    !self.willShowHandler ? : self.willShowHandler(self);
    
    if (self.customShowAnimationBlock) {
        
        self.customShowAnimationBlock(self, self.alertContentView);
        
    } else {
        
        switch (self.alertStyle) {
            case JKAlertStyleHUD:
            case JKAlertStylePlain:
            {
                self.alertContentView.alpha = 0;
                self.alertContentView.transform = CGAffineTransformMakeScale(1.2, 1.2);
            }
                break;
            case JKAlertStyleActionSheet:
            {
                
            }
                break;
            case JKAlertStyleCollectionSheet:
            {
                
            }
                break;
                
            default:
                break;
        }
        
        
        _sheetContainerView.frame = CGRectMake(_sheetContainerView.frame.origin.x, JKAlertScreenH, _sheetContainerView.frame.size.width, _sheetContainerView.frame.size.height);
        
        if (_enableVerticalGestureDismiss &&
            (_sheetContainerView != nil)) {
            _sheetContainerView.layer.anchorPoint = CGPointMake(0.5, 1);
        }
    }
    
    self.backgroundView.alpha = 0;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        self.backgroundView.alpha = 1;
        
        [self showAnimationOperation];
        
    } completion:^(BOOL finished) {
        
        if (self.customShowAnimationBlock) { return; }
        
        if (self.enableVerticalGestureDismiss &&
            (self->_sheetContainerView != nil)) {
            
            self.verticalDismissPanGesture.enabled = NO;
            
            self.window.userInteractionEnabled = YES;
            
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionAllowUserInteraction  animations:^{
                [UIView setAnimationCurve:(UIViewAnimationCurveEaseInOut)];
                
                self->_sheetContainerView.transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
                
                self.verticalDismissPanGesture.enabled = YES;

                self.showAnimationDidComplete();
            }];
            
        } else {
            
            self.showAnimationDidComplete();
        }
    }];
}

- (void)showAnimationOperation{
    
    if (self.customShowAnimationBlock) { return; }
    
    switch (self.alertStyle) {
        case JKAlertStyleHUD:
        case JKAlertStylePlain:
        {
            self.alertContentView.transform = CGAffineTransformIdentity;
            self.alertContentView.alpha = 1;
        }
            break;
        case JKAlertStyleActionSheet:
        {
            
        }
            break;
        case JKAlertStyleCollectionSheet:
        {
            
        }
            
        default:
            break;
    }
    
    if (_enableVerticalGestureDismiss &&
        (_sheetContainerView != nil)) {
        
        [UIView setAnimationCurve:(UIViewAnimationCurveEaseOut)];
        
        CGRect rect = _sheetContainerView.frame;
        
        rect.origin.y = JKAlertScreenH - rect.size.height;
        _sheetContainerView.frame = rect;
        
        _sheetContainerView.transform = CGAffineTransformMakeScale(1, (_sheetContainerView.frame.size.height + JKAlertSheetSpringHeight) / _sheetContainerView.frame.size.height);
        
    } else {
        
        CGRect rect = _sheetContainerView.frame;
        rect.origin.y = JKAlertScreenH - _sheetContainerView.frame.size.height;
        _sheetContainerView.frame = rect;
    }
}

- (void(^)(void))showAnimationDidComplete{
    
    self.window.userInteractionEnabled = YES;
    
    //self->_titleTextView.delegate = self.titleTextViewDelegate;
    //self->_messageTextView.delegate = self.messageTextViewDelegate;
    
    !self.didShowHandler ? : self.didShowHandler(self);
    
    if (_plainContentView.autoShowKeyboard && self.currentTextField) {
        
        if (!self.currentTextField.hidden) {
            
            if (!self.currentTextField.isFirstResponder) {
                
                [self.currentTextField becomeFirstResponder];
            }
            
        } else {
            
            for (UITextField *tf in _textFieldArr) {
                
                if (tf.hidden) { continue; }
                
                if (!tf.isFirstResponder) {
                    
                    [tf becomeFirstResponder];
                }
                
                break;
            }
        }
    }
    
    if (self.dismissTimeInterval > 0 && (self.alertStyle == JKAlertStyleHUD || self.customHUD)) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.dismissTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self dismiss];
        });
    }
    
    return ^{};
}

#pragma mark
#pragma mark - 监听键盘

//- (BOOL)isLandScape{
//
//    return JKAlertScreenW > JKAlertScreenH;
//}

- (void)keyboardWillChangeFrame:(NSNotification *)noti{
    
    CGRect keyboardFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame = self.alertContentView.frame;
    
    NSNumber *curve = noti.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    NSInteger animationCurve = (curve ? [curve integerValue] : 7);
    
    if (keyboardFrame.origin.y >= JKAlertScreenH) { // 退出键盘
        
        JKAlertPlainViewMaxH = JKAlertScreenH - 100;
        
        [self calculateUI];
        
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationCurve:animationCurve];
            
            [self layoutIfNeeded];
        }];
        
    } else { // 弹出键盘
        
        CGFloat maxH = JKAlertScreenH - (JKAlertIsDeviceX() ? 44 : 20) - keyboardFrame.size.height - 40;
        
        BOOL lockKeyboardMargin = (self.plainKeyboardMargin > 0);
        
        if ([self isLandScape]) {
            
            maxH = JKAlertScreenH - 5 - keyboardFrame.size.height - 5;
            
        } else if (lockKeyboardMargin) {
            
            maxH = maxH + 20 - self.plainKeyboardMargin;
        }
        
        if (frame.size.height <= maxH) {
            
            frame.origin.y = (JKAlertIsDeviceX() ? 44 : 20) + (maxH - frame.size.height) * 0.5;
            
            if (lockKeyboardMargin) {
                
                frame.origin.y = keyboardFrame.origin.y - self.plainKeyboardMargin - frame.size.height;
            }
            
            if ([self isLandScape]) {
                
                frame.origin.y = 5 + (maxH - frame.size.height) * 0.5;
            }
            
            self.setPlainY(frame.origin.y, YES);
            
            return;
        }
        
        JKAlertPlainViewMaxH = maxH;
        
        [self calculateUI];
        
        frame = self.alertContentView.frame;
        
        if ([self isLandScape]) {
            
            frame.origin.y = 5;
            
        } else if (lockKeyboardMargin) {
            
            frame.origin.y = keyboardFrame.origin.y - self.plainKeyboardMargin - frame.size.height;
            
            frame.origin.y = MAX(frame.origin.y, (JKAlertIsDeviceX() ? 44 : 20));
            
        } else {
            
            frame.origin.y = (JKAlertIsDeviceX() ? 44 : 20);
        }
        
        self.alertContentView.frame = frame;
        
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationCurve:animationCurve];
            
            [self layoutIfNeeded];
        }];
    }
}

#pragma mark
#pragma mark - 退出

- (void)dismissButtonClick:(UIButton *)button{
    
    [JKAlertKeyWindow() endEditing:YES];
    
    !self.blankClickBlock ? : self.blankClickBlock();
    
    !self.tapBlankHandler ? : self.tapBlankHandler(self);
    
    if (_tapBlankDismiss) {
        
        self.dismiss();
        
    } else {
        
        if ((self.enableVerticalGestureDismiss ||
             self.enableHorizontalGestureDismiss) &&
            (self.alertStyle == JKAlertStyleActionSheet ||
             self.alertStyle == JKAlertStyleCollectionSheet)) {
            
            if ([self.sheetContainerView.layer animationForKey:JKAlertDismissFailedShakeAnimationKey]) { return; }
            
            // 动画抖一下
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            animation.repeatCount = 1;
            animation.values = @[@(-2), @(-4), @(-6), @(3), @0];
            animation.duration = 0.5;
            [self.sheetContainerView.layer addAnimation:animation forKey:JKAlertDismissFailedShakeAnimationKey];
        }
    }
}

// 通过通知来dismiss
- (void)dismissAllNotification:(NSNotification *)noti{
    
    if (self.isDismissAllNoneffective) { return; }
    
    self.dismiss();
}

// 通过key通知来dismiss
- (void)dismissForKeyNotification:(NSNotification *)noti{
    
    if (!self.dismissKey) { return; }
    
    if ([noti.object isKindOfClass:[NSString class]] &&
        [noti.object isEqualToString:self.dismissKey]) {
        
        self.dismiss();
    }
}

// 通过category通知来dismiss
- (void)dismissForCategoryNotification:(NSNotification *)noti{
    
    if (!self.dismissCategory) { return; }
    
    if ([noti.object isKindOfClass:[NSString class]] &&
        [noti.object isEqualToString:self.dismissCategory]) {
        
        self.dismiss();
    }
}

// 通过通知来dismiss
- (void)clearAllNotification:(NSNotification *)noti{
    
    self.dismiss();
}

- (void(^)(void))dismiss{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self startDismissAnimation];
    
    return ^{};
}

- (void)startDismissAnimation{
    
    self.window.userInteractionEnabled = NO;
    
    // 即将消失
    !self.willDismissHandler ? : self.willDismissHandler();
    
    if (!isSheetDismissHorizontal || (self.alertStyle != JKAlertStyleActionSheet && self.alertStyle != JKAlertStyleCollectionSheet)) {
        
        // 自定义消失动画
        !self.customDismissAnimationBlock ? : self.customDismissAnimationBlock(self, self.alertContentView);
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.backgroundView.alpha = 0;
        
        [self dismissAnimationOperation];
        
    } completion:^(BOOL finished) {
        
        if (self.customDismissAnimationBlock) { return; }
        
        self.dismissAnimationDidComplete();
    }];
}

- (void)dismissAnimationOperation{
    
    if (self.customDismissAnimationBlock) {
        
        if (isSheetDismissHorizontal) {
            
            CGRect rect = _sheetContainerView.frame;
            rect.origin.x = JKAlertScreenW;
            _sheetContainerView.frame = rect;
        }
        
        return;
    }
    
    CGRect rect = _sheetContainerView.frame;
    
    if (isSheetDismissHorizontal) {
        
        rect.origin.x = JKAlertScreenW;
        
    } else {
        
        rect.origin.y = JKAlertScreenH;
    }
    
    _sheetContainerView.frame = rect;
    
    switch (self.alertStyle) {
        case JKAlertStyleHUD:
        case JKAlertStylePlain:
        {
            self.alertContentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
            self.alertContentView.alpha = 0;
        }
            break;
        case JKAlertStyleActionSheet:
        {
            
        }
            break;
        case JKAlertStyleCollectionSheet:
        {
            
        }
            
        default:
            break;
    }
}

- (void(^)(void))dismissAnimationDidComplete{
    
    self.window.userInteractionEnabled = YES;
    
    // 消失完成
    !self.didDismissHandler ? : self.didDismissHandler();
    
    [self.actions removeAllObjects];
    self.actions = nil;
    
    [self.actions2 removeAllObjects];
    self.actions2 = nil;
    
    _cancelAction = nil;
    _collectionAction = nil;
    
    [self removeFromSuperview];
    
    return ^{};
}

#pragma mark
#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return (self.alertStyle == JKAlertStyleActionSheet) ? ((self.cancelAction.rowHeight > 0 && !self.pinCancelButton) ? 2 : 1) : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? self.actions.count : (self.pinCancelButton ? 0 : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JKAlertBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.isActionSheetPierced ? [JKAlertPiercedTableViewCell class] : [JKAlertTableViewCell class])];
    
    if (cell == nil) {
        
        cell = [[JKAlertTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:NSStringFromClass([JKAlertTableViewCell class])];
    }
    
    cell.alertSuperView = self.customSuperView;
    
    if (indexPath.section == 0) {
        
        cell.action = self.actions[indexPath.row];
        
    } else {
        
        cell.action = self.cancelAction;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JKAlertAction *action = indexPath.section == 0 ? self.actions[indexPath.row] : self.cancelAction;
    
    if (!FillHomeIndicator) { return action.rowHeight; }
    
    return indexPath.section == 0 ? action.rowHeight : action.rowHeight + JKAlertAdjustHomeIndicatorHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return (section == 0) ? CGFLOAT_MIN : CancelMargin;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    JKAlertAction *action = indexPath.section == 0 ? self.actions[indexPath.row] : self.cancelAction;
    
    if (action.autoDismiss && ![action isEmpty]) { [self dismiss]; }
    
    !action.handler ? : action.handler(action);
}

#pragma mark
#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return collectionView == self.collectionView ? self.actions.count : self.actions2.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    JKAlertCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([JKAlertCollectionViewCell class]) forIndexPath:indexPath];
    
    cell.action = collectionView == self.collectionView ? self.actions[indexPath.item] : self.actions2[indexPath.item];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    JKAlertAction *action = collectionView == self.collectionView ? self.actions[indexPath.item] : self.actions2[indexPath.item];
    
    if (action.autoDismiss && ![action isEmpty]) { [self dismiss]; }
    
    !action.handler ? : action.handler(action);
}

#pragma mark
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!self.enableVerticalGestureDismiss) { return; }
    
    switch (self.alertStyle) {
        case JKAlertStyleActionSheet:
        {
            if ((scrollView == self.scrollView &&
                _tableView.isDecelerating) ||
                (scrollView == _tableView &&
                self.scrollView.isDecelerating)) {
                    return;
            }
            
            [self solveVerticalScroll:scrollView];
        }
            break;
        case JKAlertStyleCollectionSheet:
        {
            if (scrollView == self.scrollView) {
                
                if (scrollView.isDecelerating) { return; }
                
                [self solveVerticalScroll:scrollView];
                
            } else {
                
                [self solveHorizontalScroll:scrollView];
                
                if (self.compoundCollection) {
                    
                    _collectionView.contentOffset = scrollView.contentOffset;
                    
                    _collectionView2.contentOffset = scrollView.contentOffset;
                }
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    switch (self.alertStyle) {
        case JKAlertStyleActionSheet:
        {
            if (!self.enableVerticalGestureDismiss) { return; }
            
            beginScrollDirection = JKAlertScrollDirectionNone;
            endScrollDirection = JKAlertScrollDirectionNone;
            
            lastContainerY = self.sheetContainerView.frame.origin.y;
            
            if (scrollView.contentOffset.y + scrollView.contentInset.top < 0) {
                
                disableScrollToDismiss = YES;
            }
        }
            break;
        case JKAlertStyleCollectionSheet:
        {
            if (scrollView == self.scrollView) {
                
                if (!self.enableVerticalGestureDismiss) { return; }
                
                beginScrollDirection = JKAlertScrollDirectionNone;
                endScrollDirection = JKAlertScrollDirectionNone;
                
                lastContainerY = self.sheetContainerView.frame.origin.y;
                
                if (scrollView.contentOffset.y + scrollView.contentInset.top < 0) {
                    
                    disableScrollToDismiss = YES;
                }
                
            } else {
                
                if (!self.enableHorizontalGestureDismiss) { return; }
                
                isBeginDragging = YES;
                beginScrollDirection = JKAlertScrollDirectionNone;
                endScrollDirection = JKAlertScrollDirectionNone;
                
                lastContainerX = self.sheetContainerView.frame.origin.x;
                
                if (scrollView.contentOffset.x + scrollView.contentInset.left < 0) {
                    
                    disableScrollToDismiss = YES;
                }
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    switch (self.alertStyle) {
        case JKAlertStyleActionSheet:
        {
            [self solveWillEndDraggingVertically:scrollView withVelocity:velocity];
        }
            break;
        case JKAlertStyleCollectionSheet:
        {
            if (scrollView == self.scrollView) {
                
                [self solveWillEndDraggingVertically:scrollView withVelocity:velocity];
                
            } else {
                
                [self solveWillEndDraggingHorizontally:scrollView withVelocity:velocity];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    if (self.alertStyle == JKAlertStyleCollectionSheet &&
        [scrollView isKindOfClass:[UICollectionView class]]) {
        
        _pageControl.currentPage = ceil((scrollView.contentOffset.x - 5) / JKAlertScreenW);
    }
}
///*
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    switch (self.alertStyle) {
        case JKAlertStyleActionSheet:
        {
            if (!self.enableVerticalGestureDismiss) { return; }
            
            if (self.scrollView.isDecelerating ||
                _tableView.isDecelerating) {
                return;
            }
            
            disableScrollToDismiss = NO;
            
            //[self checkVerticalSlideShouldDismiss];
        }
            break;
        case JKAlertStyleCollectionSheet:
        {
            if (scrollView == self.scrollView) {
                
                if (!self.enableVerticalGestureDismiss) { return; }
                
                disableScrollToDismiss = NO;
                
                //[self checkVerticalSlideShouldDismiss];
                
            } else {
                
                _pageControl.currentPage = ceil((scrollView.contentOffset.x - 5) / JKAlertScreenW);
                
                if (!self.enableHorizontalGestureDismiss) { return; }
                
                if (self.collectionView.isDecelerating ||
                    self.collectionView2.isDecelerating) {
                    return;
                }
                
                disableScrollToDismiss = NO;
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)solveVerticalScroll:(UIScrollView *)scrollView{
    
    if (!self.enableVerticalGestureDismiss ||
        !self.tapBlankDismiss ||
        !scrollView.isDragging ||
        disableScrollToDismiss) { return; }
    
    //NSLog(@"contentOffset-->%@", NSStringFromCGPoint(scrollView.contentOffset));
    
    if (scrollView.contentOffset.y + scrollView.contentInset.top < 0) {
        
        CGRect frame = self.sheetContainerView.frame;
        
        frame.origin.y -= (scrollView.contentOffset.y + scrollView.contentInset.top);
        
        frame.origin.y = (frame.origin.y < correctContainerY) ? correctContainerY : frame.origin.y;
        
        self.sheetContainerView.frame = frame;
        
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -scrollView.contentInset.top);
        
        //NSLog(@"1");
        
    } else if (self.sheetContainerView.frame.origin.y > correctContainerY + 0.1) {
        
        CGRect frame = self.sheetContainerView.frame;
        
        frame.origin.y -= (scrollView.contentOffset.y + scrollView.contentInset.top);
        
        frame.origin.y = (frame.origin.y < correctContainerY) ? correctContainerY : frame.origin.y;
        
        self.sheetContainerView.frame = frame;
        
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -scrollView.contentInset.top);
        
        //NSLog(@"2");
    }
    
    if (scrollView.isDragging) {
        
        [self checkVerticalSlideDirection];
    }
}

- (void)solveHorizontalScroll:(UIScrollView *)scrollView{
    
    if (!self.enableHorizontalGestureDismiss || !self.tapBlankDismiss) { return; }
    
    if ((scrollView == self.collectionView &&
        self.collectionView2.isDecelerating) ||
        (scrollView == self.collectionView2 &&
        self.collectionView.isDecelerating)) {
            return;
    }
    
    if (!scrollView.isDragging || disableScrollToDismiss) { return; }
    
    //NSLog(@"contentOffset-->%@", NSStringFromCGPoint(scrollView.contentOffset));
    
    if (scrollView.contentOffset.x + scrollView.contentInset.left < 0) {
        
        CGRect frame = self.sheetContainerView.frame;
        
        frame.origin.x -= (scrollView.contentOffset.x + scrollView.contentInset.left);
        
        self.sheetContainerView.frame = frame;
        
        scrollView.contentOffset = CGPointMake(-scrollView.contentInset.left, scrollView.contentOffset.y);
        
    } else if (self.sheetContainerView.frame.origin.x > JKAlertScreenW - self.sheetContainerView.frame.size.width) {
        
        CGRect frame = self.sheetContainerView.frame;
        
        frame.origin.x -= (scrollView.contentOffset.x + scrollView.contentInset.left);
        
        self.sheetContainerView.frame = frame;
        
        scrollView.contentOffset = CGPointMake(-scrollView.contentInset.left, scrollView.contentOffset.y);
    }
    
    if (scrollView.isDragging) {
        
        [self checkHorizontalSlideDirection];
    }
}

- (void)solveWillEndDraggingVertically:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity{
    
    if (!self.enableVerticalGestureDismiss || !self.tapBlankDismiss || disableScrollToDismiss) { return; }
    
    if (scrollView.contentOffset.y + scrollView.contentInset.top > 0) {
        
        disableScrollToDismiss = YES;
        
        return;
    }
    
    if (velocity.y < -1.5 && beginScrollDirection == endScrollDirection) {
        
        [self dismiss];
        
    } else {
        
        [self checkVerticalSlideShouldDismiss];
    }
}

- (void)solveWillEndDraggingHorizontally:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity{
    
    if (!self.enableHorizontalGestureDismiss || !self.tapBlankDismiss || disableScrollToDismiss) { return; }
    
    if (scrollView.contentOffset.x + scrollView.contentInset.left > 0) {
        
        disableScrollToDismiss = YES;
        
        return;
    }
    
    if (velocity.x < -1.5 && beginScrollDirection == endScrollDirection) {
        
        isSheetDismissHorizontal = YES;
        
        [self dismiss];
        
    } else {
        
        [self checkHorizontalSlideShouldDismiss];
    }
}

- (void)checkVerticalSlideDirection{

    currentContainerY = self.sheetContainerView.frame.origin.y;
    
    if (currentContainerY < lastContainerY) {
        
        if (beginScrollDirection == JKAlertScrollDirectionNone) {
            
            beginScrollDirection = JKAlertScrollDirectionUp;
        }
        
        endScrollDirection = JKAlertScrollDirectionUp;
        
        //NSLog(@"上滑-------current:%.3f  last:%.3f", currentContainerY, lastContainerY);
    }
    
    if (currentContainerY > lastContainerY) {
        
        //NSLog(@"下滑-------current:%.3f  last:%.3f", currentContainerY, lastContainerY);
        
        if (beginScrollDirection == JKAlertScrollDirectionNone) {
            
            beginScrollDirection = JKAlertScrollDirectionDown;
        }
        
        endScrollDirection = JKAlertScrollDirectionDown;
    }
    
    lastContainerY = currentContainerY;
}

- (void)checkHorizontalSlideDirection{

    currentContainerX = self.sheetContainerView.frame.origin.x;
    
    if (currentContainerX < lastContainerX) {
        
        if (beginScrollDirection == JKAlertScrollDirectionNone) {
            
            beginScrollDirection = JKAlertScrollDirectionLeft;
        }
        
        endScrollDirection = JKAlertScrollDirectionLeft;
        
        //JKLog("左滑-------")
    }
    
    if (currentContainerX > lastContainerX) {
        
        //JKLog("右滑-------")
        
        if (beginScrollDirection == JKAlertScrollDirectionNone) {
            
            beginScrollDirection = JKAlertScrollDirectionRight;
        }
        
        endScrollDirection = JKAlertScrollDirectionRight;
    }
    
    lastContainerX = currentContainerX;
}

- (void)checkVerticalSlideShouldDismiss{
    
    CGFloat correctSheetContainerY = (correctContainerY);
    
    CGFloat currentSheetContainerY = self.sheetContainerView.frame.origin.y;
    
    CGFloat delta = currentSheetContainerY - correctSheetContainerY;
    
    if ((delta > self.sheetContainerView.frame.size.height * 0.5) &&
        beginScrollDirection == endScrollDirection) {
        
        [self dismiss];
        
    } else {
        
        //self.relayout(YES);
        
        [self relayoutSheetContainerView];
    }
}

- (void)checkHorizontalSlideShouldDismiss{
    
    CGFloat correctSheetContainerX = (JKAlertScreenW - self.sheetContainerView.frame.size.width);
    
    CGFloat currentSheetContainerX = self.sheetContainerView.frame.origin.x;
    
    CGFloat delta = currentSheetContainerX - correctSheetContainerX;
    
    if ((delta > self.sheetContainerView.frame.size.width * 0.5) &&
        beginScrollDirection == endScrollDirection) {
        
        isSheetDismissHorizontal = YES;
        
        [self dismiss];
        
    } else {
        
        //self.relayout(YES);
        
        [self relayoutSheetContainerView];
    }
}

- (void)relayoutSheetContainerView{
    
    CGRect frame = self.sheetContainerView.frame;
    frame.origin.y = JKAlertScreenH - frame.size.height;
    frame.origin.x = (JKAlertScreenW - frame.size.width) * 0.5;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.sheetContainerView.frame = frame;
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark
#pragma mark - 滑动手势

- (void)verticalPanGestureAction:(UIPanGestureRecognizer *)panGesture{
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            beginScrollDirection = JKAlertScrollDirectionNone;
            endScrollDirection = JKAlertScrollDirectionNone;
            
            lastContainerY = self.sheetContainerView.frame.origin.y;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            // 获取偏移
            CGPoint point = [panGesture translationInView:self.sheetContainerView];
            
            CGRect frame = self.sheetContainerView.frame;
            
            if (point.y > 0) {
                
                if (!self.tapBlankDismiss) {
                    
                    frame.origin.y += (point.y * 0.01);
                    
                } else {
                    
                    frame.origin.y += point.y;
                }
                
            } else {
                
                if (!self.tapBlankDismiss ||
                    (frame.origin.y <= (correctContainerY))) {
                    
                    frame.origin.y += (point.y * 0.01);
                    
                } else {
                    
                    frame.origin.y += point.y;
                }
            }
            
            frame.origin.y = MAX(frame.origin.y, correctContainerY - 5);
            
            self.sheetContainerView.frame = frame;
            
            // 归零
            [panGesture setTranslation:CGPointZero inView:self.sheetContainerView];
            
            [self checkVerticalSlideDirection];
        }
            break;
            
        default:
        {
            if (!self.tapBlankDismiss) {
                
                [self relayoutSheetContainerView];
                
                return;
            }
            
            CGPoint velocity = [panGesture velocityInView:panGesture.view];
            CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
            CGFloat slideMult = magnitude / 200;
            
            float slideFactor = 0.1 * slideMult;
            CGPoint finalPoint = CGPointMake(0, self.sheetContainerView.frame.origin.y + (velocity.y * slideFactor));
            
            BOOL isSlideHalf = (finalPoint.y - correctContainerY > self.sheetContainerView.frame.size.height * 0.5);
            
            if (isSlideHalf &&
                self.tapBlankDismiss &&
                (endScrollDirection == JKAlertScrollDirectionDown)) {
                
                [self dismiss];
                
            } else {
                
                //self.relayout(YES);
                
                [self relayoutSheetContainerView];
            }
        }
            break;
    }
}

- (void)horizontalPanGestureAction:(UIPanGestureRecognizer *)panGesture{
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            beginScrollDirection = JKAlertScrollDirectionNone;
            endScrollDirection = JKAlertScrollDirectionNone;
            
            lastContainerX = self.sheetContainerView.frame.origin.x;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            // 获取偏移
            CGPoint point = [panGesture translationInView:self.contentView];
            
            CGPoint center = self.sheetContainerView.center;
            
            if (point.x > 0) {
                
                if (!self.tapBlankDismiss) {
                    
                    center.x += (point.x * 0.02);
                    
                } else {
                    
                    center.x += point.x;
                }
                
            } else {
                
                if (!self.tapBlankDismiss ||
                    (center.x <= (JKAlertScreenW * 0.5))) {
                    
                    center.x += (point.x * 0.02);
                    
                } else {
                    
                    center.x += point.x;
                }
            }
            
            self.sheetContainerView.center = center;
            
            // 归零
            [panGesture setTranslation:CGPointZero inView:self.contentView];
            
            [self checkHorizontalSlideDirection];
        }
            break;
            
        default:
        {
            if (!self.tapBlankDismiss) {
                
                [self relayoutSheetContainerView];
                
                return;
            }
            
            CGPoint velocity = [panGesture velocityInView:panGesture.view];
            CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
            CGFloat slideMult = magnitude / 200;
            
            float slideFactor = 0.1 * slideMult;
            CGPoint finalPoint = CGPointMake(self.sheetContainerView.center.x + (velocity.x * slideFactor), self.sheetContainerView.center.y + (velocity.y * slideFactor));
            BOOL isSlideHalf = ((finalPoint.x - self.sheetContainerView.frame.size.width * 0.5) - (JKAlertScreenW - self.sheetContainerView.frame.size.width) > self.sheetContainerView.frame.size.width * 0.5);
            if (isSlideHalf &&
                self.tapBlankDismiss &&
                beginScrollDirection == endScrollDirection) {
                
                isSheetDismissHorizontal = YES;
                
                [self dismiss];
                
            } else {
                
                //self.relayout(YES);
                
                [self relayoutSheetContainerView];
            }
        }
            break;
    }
}

#pragma mark
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer == self.verticalDismissPanGesture) {
        
        return self.enableVerticalGestureDismiss;
    }
    
    if (gestureRecognizer == self.horizontalDismissPanGesture) {
        
        return self.enableHorizontalGestureDismiss;
    }
    
    return YES;
}

#pragma mark
#pragma mark - plain样式按钮点击

- (void)plainButtonClick:(UIButton *)button{
    
    JKAlertAction *action = self.actions[button.tag - JKAlertPlainButtonBeginTag];
    
    if (action.autoDismiss) { [self dismiss]; }
    
    !action.handler ? : action.handler(action);
}

#pragma mark
#pragma mark - collection样式按钮点击

- (void)collectionButtonClick{
    
    if (self.collectionAction.autoDismiss) { [self dismiss]; }
    
    !self.collectionAction.handler ? : self.collectionAction.handler(self.collectionAction);
}

- (void)cancelButtonClick{
    
    !self.cancelAction.handler ? : self.cancelAction.handler(self.cancelAction);
    
    if (self.cancelAction.autoDismiss) { [self dismiss]; }
}

#pragma mark
#pragma mark - Relayout

/** 重新布局 */
- (JKAlertView *(^)(BOOL animated))relayout{
    
    //lastTableViewOffsetY = _tableView.contentOffset.y;
    
    return ^(BOOL animated) {
        
        !self.willAdaptBlock ? : self.willAdaptBlock(self, (self.alertContentView));
        
        if (animated) {
            
            [UIView animateWithDuration:0.25 animations:^{
                
                [self calculateUI];
                
            } completion:^(BOOL finished) {
                
                !self.relayoutComplete ? : self.relayoutComplete(self);
                
                !self.didAdaptBlock ? : self.didAdaptBlock(self, (self.alertContentView));
            }];
            
        } else {
            
            [self calculateUI];
            
            !self.relayoutComplete ? : self.relayoutComplete(self);
            
            !self.didAdaptBlock ? : self.didAdaptBlock(self, (self.alertContentView));
        }
        
        return self;
    };
}

/** 监听重新布局完成 */
- (JKAlertView *(^)(void(^relayoutComplete)(JKAlertView *view)))setRelayoutComplete{
    
    return ^(void(^relayoutComplete)(JKAlertView *view)) {
        
        self.relayoutComplete = relayoutComplete;
        
        return self;
    };
}

/** 重新设置alertTitle */
- (JKAlertView *(^)(NSString *alertTitle))resetAlertTitle{
    
    return ^(NSString *alertTitle) {
        
        self.alertTitle = alertTitle;
        
        return self;
    };
}

/** 重新设置alertAttributedTitle */
- (JKAlertView *(^)(NSAttributedString *alertAttributedTitle))resetAlertAttributedTitle{
    
    return ^(NSAttributedString *alertAttributedTitle) {
        
        self.alertAttributedTitle = alertAttributedTitle;
        
        return self;
    };
}

/** 重新设置message */
- (JKAlertView *(^)(NSString *message))resetMessage{
    
    return ^(NSString *message) {
        
        self.alertMessage = message;
        
        return self;
    };
}

/** 重新设置attributedMessage */
- (JKAlertView *(^)(NSAttributedString *attributedMessage))resetAttributedMessage{
    
    return ^(NSAttributedString *attributedMessage) {
        
        self.attributedMessage = attributedMessage;
        
        return self;
    };
}

#pragma mark
#pragma mark - Override

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self solveDidMoveToSuperview];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    [self solveTraitCollectionDidChange];
}

#pragma mark
#pragma mark - Private Methods

- (void)addNotifications {
    
    // 屏幕旋转的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    // 移除全部的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissAllNotification:) name:JKAlertDismissAllNotification object:nil];
    
    // 根据key来移除的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissForKeyNotification:) name:JKAlertDismissForKeyNotification object:nil];
    
    // 根据category来移除的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissForCategoryNotification:) name:JKAlertDismissForCategoryNotification object:nil];
    
    // 清空全部的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearAllNotification:) name:JKAlertClearAllNotification object:nil];
}

- (void)addKeyboardWillChangeFrameNotification {
    
    // 键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)removeKeyboardWillChangeFrameNotification {
    
    // 键盘
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark
#pragma mark - Initialization & Build UI

/** 初始化自身属性 */
- (void)initializeProperty {
    [super initializeProperty];
    
    /** 屏幕宽度 */
    JKAlertScreenW = self.customSuperView.bounds.size.width;
    
    /** 屏幕高度 */
    JKAlertScreenH = self.customSuperView.bounds.size.height;
    
    _isLandScape = [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight;
    
    JKAlertPlainViewMaxH = (JKAlertScreenH - 100);
    
    JKAlertSheetMaxH = (JKAlertScreenH > JKAlertScreenW) ? JKAlertScreenH * 0.85 : JKAlertScreenH * 0.8;
    
    _enableDeallocLog = NO;
    
    _dismissTimeInterval = 1;
    
    _collectionTitleSeparatorHidden = YES;
    
    PlainViewWidth = 290;
    OriginalPlainWidth = PlainViewWidth;
    _collectionViewMargin = 10;
    
    CancelMargin = ((JKAlertScreenW > 321) ? 7 : 5);
    JKAlertSeparatorLineWH = (1 / [UIScreen mainScreen].scale);
    textContainerViewCurrentMaxH_ = (JKAlertScreenH - 100 - JKAlertActionButtonH * 4);
    
    FillHomeIndicator = YES;
    AutoAdjustHomeIndicator = YES;
    
    _autoAdaptKeyboard = YES;
    
    self.flowlayoutItemWidth = 76;
    
    _enableVerticalGestureDismiss = NO;
    _enableHorizontalGestureDismiss = NO;
    
    _piercedHorizontalMargin = 15;
}

/** 构造函数初始化时调用 注意调用super */
- (void)initialization {
    [super initialization];
    
    [self addNotifications];
}

/** 创建UI */
- (void)createUI {
    [super createUI];
    
}

/** 布局UI */
- (void)layoutUI {
    [super layoutUI];
    
}

/** 初始化UI数据 */
- (void)initializeUIData {
    [super initializeUIData];
    
}

#pragma mark
#pragma mark - Private Property

- (UIView *)customSuperView {
    
    if (!_customSuperView) {
        
        _customSuperView = JKAlertKeyWindow();
    }
    
    return _customSuperView;
}

- (UIView *)alertContentView {
    
    if (self.currentAlertContentView) {
        
        return self.currentAlertContentView;
    }
    
    UIView *alertContentView = nil;
    
    // TODO: JKTODO <#注释#>
    
    switch (self.alertStyle) {
        case JKAlertStylePlain:
        {
            alertContentView = self.plainContentView;
        }
            break;
        case JKAlertStyleActionSheet:
        {
            alertContentView = self.sheetContainerView;
        }
            break;
        case JKAlertStyleCollectionSheet:
        {
            alertContentView = self.sheetContainerView;
        }
            break;
        case JKAlertStyleHUD:
        {
            alertContentView = self.hudContentView;
        }
            break;
            
        default:
            break;
    }
    
    return self.currentAlertContentView;
}

- (JKAlertPlainContentView *)plainContentView {
    if (!_plainContentView) {
        JKAlertPlainContentView *plainContentView = [[JKAlertPlainContentView alloc] init];
        plainContentView.alertView = self;
        [self addSubview:plainContentView];
        _plainContentView = plainContentView;
    }
    return _plainContentView;
}

- (JKAlertHUDContentView *)hudContentView {
    if (!_hudContentView) {
        JKAlertHUDContentView *hudContentView = [[JKAlertHUDContentView alloc] init];
        hudContentView.alertView = self;
        [self addSubview:hudContentView];
        _hudContentView = hudContentView;
    }
    return _hudContentView;
}

- (NSMutableArray *)actions {
    if (!_actions) {
        _actions = [NSMutableArray array];
    }
    return _actions;
}

- (NSMutableArray *)actions2 {
    if (!_actions2) {
        _actions2 = [NSMutableArray array];
    }
    return _actions2;
}

- (NSMutableArray *)textFieldArr {
    if (!_textFieldArr) {
        _textFieldArr = [NSMutableArray array];
    }
    return _textFieldArr;
}

- (UIView *)textContainerView {
    if (!_textContainerView) {
        UIView *textContainerView = [[UIView alloc] init];
        [self addSubview:textContainerView];
        _textContainerView = textContainerView;
    }
    return _textContainerView;
}

- (UIScrollView *)plainTextContainerScrollView {
    if (!_plainTextContainerScrollView) {
        UIScrollView *plainTextContainerScrollView = [[UIScrollView alloc] init];
        plainTextContainerScrollView.delegate = self;
        [self addSubview:plainTextContainerScrollView];
        
        [self adjustScrollView:plainTextContainerScrollView];
        
        _plainTextContainerScrollView = plainTextContainerScrollView;
        
        [self.textContainerView insertSubview:_plainTextContainerScrollView atIndex:0];
        
        [JKAlertVisualFormatConstraintManager addZeroEdgeConstraintsWithTargetView:_plainTextContainerScrollView constraintsView:_textContainerView];
    }
    return _plainTextContainerScrollView;
}

- (JKAlertTextView *)titleTextView {
    if (!_titleTextView) {
        JKAlertTextView *titleTextView = [[JKAlertTextView alloc] init];
        titleTextView.textColor = self.alertStyle == JKAlertStylePlain ? JKAlertAdaptColor(JKAlertSameRGBColor(25.5), JKAlertSameRGBColor(229.5)) : JKAlertAdaptColor(JKAlertSameRGBColor(89.25), JKAlertSameRGBColor(165.75));
        titleTextView.font = self.alertStyle == JKAlertStylePlain ? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17];
        [self addSubview:titleTextView];
        
        _titleTextView = titleTextView;
    }
    return _titleTextView;
}

- (JKAlertTextView *)messageTextView {
    if (!_messageTextView) {
        JKAlertTextView *messageTextView = [[JKAlertTextView alloc] init];
        messageTextView.textColor = self.alertStyle == JKAlertStyleActionSheet ? JKAlertAdaptColor(JKAlertSameRGBColor(140.25), JKAlertSameRGBColor(114.75)) : JKAlertAdaptColor(JKAlertSameRGBColor(76.5), JKAlertSameRGBColor(178.5));
        messageTextView.font = self.alertStyle == JKAlertStylePlain ? [UIFont systemFontOfSize:14] : [UIFont systemFontOfSize:13];
        [self addSubview:messageTextView];
        
        _messageTextView = messageTextView;
    }
    return _messageTextView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.delegate = self;
        [self addSubview:scrollView];
        
        [self adjustScrollView:scrollView];
        
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIView *)alertBackGroundView {
    if (!_alertBackGroundView) {
        
        BOOL isLight = YES;
        
        if (@available(iOS 13.0, *)) {
            
            isLight = ([self.traitCollection userInterfaceStyle] == UIUserInterfaceStyleLight);
        }
        
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:isLight ? UIBlurEffectStyleExtraLight : UIBlurEffectStyleDark]];
        effectView.clipsToBounds = YES;
        self.alertBackGroundView = effectView;
    }
    return _alertBackGroundView;
}

- (UIView *)sheetContainerView {
    if (!_sheetContainerView) {
        UIView *sheetContainerView = [[UIView alloc] init];
        [self.contentView addSubview:sheetContainerView];
        _sheetContainerView = sheetContainerView;
        
        _verticalDismissPanGesture = [[JKAlertPanGestureRecognizer alloc] initWithTarget:self action:@selector(verticalPanGestureAction:)];
        _verticalDismissPanGesture.direction = JKAlertPanGestureDirectionVertical;
        _verticalDismissPanGesture.delegate = self;
        
        _horizontalDismissPanGesture = [[JKAlertPanGestureRecognizer alloc] initWithTarget:self action:@selector(horizontalPanGestureAction:)];
        _horizontalDismissPanGesture.direction = JKAlertPanGestureDirectionToRight;
        _horizontalDismissPanGesture.delegate = self;
        
        [sheetContainerView addGestureRecognizer:_verticalDismissPanGesture];
        [sheetContainerView addGestureRecognizer:_horizontalDismissPanGesture];
        
        // 背景
        [self alertBackGroundView];
    }
    return _sheetContainerView;
}

- (UIView *)sheetContentView {
    if (!_sheetContentView) {
        UIView *sheetContentView = [[UIView alloc] init];
        [self.sheetContainerView insertSubview:sheetContentView aboveSubview:self.alertBackGroundView];
        _sheetContentView = sheetContentView;
    }
    return _sheetContentView;
}

- (UIView *)topGestureIndicatorView {
    if (!_topGestureIndicatorView) {
        UIView *topGestureIndicatorView = [[UIView alloc] init];
        topGestureIndicatorView.hidden = YES;
        topGestureIndicatorView.userInteractionEnabled = NO;
        //topGestureIndicatorView.backgroundColor = JKAlertGlobalBackgroundColor();
        [self.sheetContentView addSubview:topGestureIndicatorView];
        _topGestureIndicatorView = topGestureIndicatorView;
        
        UIView *topGestureLineView = [[UIView alloc] init];
        
        //UIToolbar *topGestureLineView = [[UIToolbar alloc] init];
        //topGestureLineView.alpha = 0.9;
        topGestureLineView.userInteractionEnabled = NO;
        topGestureLineView.layer.cornerRadius = 2;
        //topGestureLineView.layer.masksToBounds = YES;
        topGestureLineView.backgroundColor = JKAlertAdaptColor(JKAlertSameRGBColor(208), JKAlertSameRGBColor(47));
        [topGestureIndicatorView addSubview:topGestureLineView];
        
        _topGestureLineView = topGestureLineView;
    }
    return _topGestureIndicatorView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        
        // 分隔线
        UIView *hline = [UIView new];
        hline.backgroundColor = JKAlertGlobalSeparatorLineColor();
        [self.textContainerView addSubview:hline];
        _textContainerBottomLineView = hline;
        
        // title和message的容器view
        self.textContainerView.backgroundColor = JKAlertGlobalBackgroundColor();
        [self.sheetContentView addSubview:self.textContainerView];
        
        [self.textContainerView insertSubview:self.scrollView atIndex:0];
        
        [self.scrollView addSubview:self.titleTextView];
        
        [self.scrollView addSubview:self.messageTextView];
        
        UITableView *tableView = [self createTableViewWithStyle:(UITableViewStyleGrouped)];
        
        tableView.dataSource = self.tableViewDataSource ? self.tableViewDataSource : self;
        tableView.delegate = self.tableViewDelegate ? self.tableViewDelegate : self;
        
        [tableView registerClass:[JKAlertTableViewCell class] forCellReuseIdentifier:NSStringFromClass([JKAlertTableViewCell class])];
        [tableView registerClass:[JKAlertPiercedTableViewCell class] forCellReuseIdentifier:NSStringFromClass([JKAlertPiercedTableViewCell class])];
        
        tableView.rowHeight = JKAlertRowHeight;
        
        tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JKAlertScreenW, CGFLOAT_MIN)];
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JKAlertScreenW, CGFLOAT_MIN)];
        
        tableView.showsHorizontalScrollIndicator = NO;
        
        [_sheetContentView insertSubview:tableView belowSubview:self.textContainerView];
        
        _tableView = tableView;
    }
    return _tableView;
}

- (UIView *)collectionTopContainerView {
    if (!_collectionTopContainerView) {
        UIView *collectionTopContainerView = [[UIView alloc] init];
        collectionTopContainerView.backgroundColor = JKAlertGlobalBackgroundColor();
        [self.sheetContentView addSubview:collectionTopContainerView];
        _collectionTopContainerView = collectionTopContainerView;
    }
    return _collectionTopContainerView;
}

- (JKAlertActionButton *)cancelButton {
    if (!_cancelButton) {
        
        JKAlertActionButton *cancelButton = [JKAlertActionButton buttonWithType:(UIButtonTypeCustom)];
        [self.scrollView addSubview:cancelButton];
        [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:(UIControlEventTouchUpInside)];
        
        _cancelButton = cancelButton;
    }
    return _cancelButton;
}

- (JKAlertActionButton *)collectionButton {
    if (!_collectionButton) {
        JKAlertActionButton *collectionButton = [JKAlertActionButton buttonWithType:(UIButtonTypeCustom)];
        [self.scrollView addSubview:collectionButton];
        [collectionButton addTarget:self action:@selector(collectionButtonClick) forControlEvents:(UIControlEventTouchUpInside)];
        _collectionButton = collectionButton;
    }
    return _collectionButton;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.backgroundColor = nil;
        pageControl.pageIndicatorTintColor = JKAlertAdaptColor(JKAlertSameRGBColor(217), JKAlertSameRGBColor(38));
        pageControl.currentPageIndicatorTintColor = JKAlertAdaptColor(JKAlertSameRGBColor(102), JKAlertSameRGBColor(153));
        pageControl.userInteractionEnabled = NO;
        
        [self.collectionTopContainerView addSubview:pageControl];
        
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        [self.sheetContentView insertSubview:self.scrollView atIndex:1];
        
        [self updateInsets];
        
        [JKAlertVisualFormatConstraintManager addZeroEdgeConstraintsWithTargetView:self.scrollView constraintsView:self];
        
        [self.scrollView insertSubview:self.collectionTopContainerView atIndex:0];
        
        // title和message的容器view
        self.textContainerView.backgroundColor = nil;
        [self.collectionTopContainerView addSubview:self.textContainerView];
        
        [self.textContainerView addSubview:self.titleTextView];
        
        UIView *hline = [UIView new];
        hline.backgroundColor = JKAlertGlobalSeparatorLineColor();
        [self.textContainerView addSubview:hline];
        _textContainerBottomLineView = hline;
        
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowlayout = flowlayout;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.textContainerView.frame), JKAlertScreenW, 80) collectionViewLayout:flowlayout];
        collectionView.backgroundColor = nil;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        
        collectionView.dataSource = self;
        collectionView.delegate = self;
        
        collectionView.scrollsToTop = NO;
        
        [collectionView registerClass:[JKAlertCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([JKAlertCollectionViewCell class])];
        
        if (@available(iOS 11.0, *)) {
            
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        if (@available(iOS 13.0, *)) {
            
            collectionView.automaticallyAdjustsScrollIndicatorInsets = NO;
        }
        
        [self.collectionTopContainerView insertSubview:collectionView belowSubview:self.textContainerView];
        
        [self cancelButton];
        
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (UICollectionView *)collectionView2 {
    if (!_collectionView2) {
        
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowlayout2 = flowlayout;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowlayout2];
        collectionView.backgroundColor = nil;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        
        collectionView.dataSource = self;
        collectionView.delegate = self;
        
        collectionView.scrollsToTop = NO;
        
        [collectionView registerClass:[JKAlertCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([JKAlertCollectionViewCell class])];
        
        if (@available(iOS 11.0, *)) {
            
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        if (@available(iOS 13.0, *)) {
            
            collectionView.automaticallyAdjustsScrollIndicatorInsets = NO;
        }
        
        [self.collectionTopContainerView addSubview:collectionView];
        
        _collectionView2 = collectionView;
    }
    return _collectionView2;
}

- (UIButton *)closeButton {
    
    if (_alertStyle != JKAlertStylePlain) {
        
        return nil;
    }
    
    if (!_closeButton) {
        
        UIButton *closeButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [closeButton setTitleColor:[UIColor lightGrayColor] forState:(UIControlStateNormal)];
        closeButton.titleLabel.font = [UIFont systemFontOfSize:13];
        closeButton.frame = CGRectMake(PlainViewWidth - 30, 5, 25, 25);
        [self.alertContentView addSubview:closeButton];
        
        [closeButton addTarget:self action:@selector(dismiss) forControlEvents:(UIControlEventTouchUpInside)];
        
        _closeButton = closeButton;
    }
    return _closeButton;
}

- (BOOL)pinCancelButton {
    
    if (self.isActionSheetPierced) { return YES; }
    
    return _pinCancelButton;
}

#pragma mark
#pragma mark - dealloc

/** 允许dealloc打印，用于检查循环引用 */
- (JKAlertView *(^)(BOOL enable))enableDeallocLog {
    
    return ^(BOOL enable) {
        
        self->_enableDeallocLog = enable;
        
        return self;
    };
}

- (void)dealloc {
    
    [self removeAllOberserver];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_enableDeallocLog) {
        
        NSLog(@"%d, %s",__LINE__, __func__);
    }
    
    !self.deallocBlock ? : self.deallocBlock();
}
@end
