//
//  JKAlertView+CollectionSheet.h
//  JKAlertX
//
//  Created by albert on 2020/6/8.
//

#import "JKAlertView.h"

@interface JKAlertView (CollectionSheet)

/**
 * 设置collection的itemSize的宽度
 * 最大不可超过屏幕宽度的一半
 * 注意图片的宽高是设置的宽度-30，即图片在cell中是左右各15的间距
 * 自动计算item之间间距，最小为0，可自己计算该值设置每屏显示个数
 * 默认的高度是宽度-6，暂不支持自定义高度
 */
@property (nonatomic, copy, readonly) JKAlertView *(^setFlowlayoutItemWidth)(CGFloat width);

/**
 * 设置collection列数（每行数量）
 * 默认0，自动设置，不得大于自动设置的数量
 */
@property (nonatomic, copy, readonly) JKAlertView *(^setCollectionColumnCount)(NSInteger columnCount);

/**
 * 设置collection的水平（左右方向）的sectionInset
 * 默认0，为0时自动设置为item间距的一半
 */
@property (nonatomic, copy, readonly) JKAlertView *(^setCollectionHorizontalInset)(CGFloat inset);

/** 设置collection的title下分隔线是否隐藏 默认YES */
@property (nonatomic, copy, readonly) JKAlertView *(^setCollectionTitleSeperatorHidden)(BOOL hidden);

/**
 * 设置两个collectionView之间的间距
 * 有第二个collectionView时有效 默认10, 最小为0
 */
@property (nonatomic, copy, readonly) JKAlertView *(^setCollectionViewMargin)(CGFloat margin);

/**
 * 设置是否将两个collection合体
 * 设为YES可让两个collection同步滚动
 * 设置YES时会自动让两个collection的action数量保持一致，即向少的一方添加空的action
 */
@property (nonatomic, copy, readonly) JKAlertView *(^setCompoundCollection)(BOOL compoundCollection);

/** 设置collection是否分页 */
@property (nonatomic, copy, readonly) JKAlertView *(^setCollectionPagingEnabled)(BOOL collectionPagingEnabled);

/**
 * 设置collection是否显示pageControl
 * 如果只有一组collection，则必须设置分页为YES才有效
 * 如果有两组collection，则仅在分页和合体都为YES时才有效
 * 注意自己计算好每页显示的个数相等
 * 可以添加空的action来保证每页显示个数相等
 * JKAlertAction使用类方法初始化时每个参数传nil或者直接自己实例化一个即为空action
 */
@property (nonatomic, copy, readonly) JKAlertView *(^setShowPageControl)(BOOL showPageControl);

/**
 * 设置pageControl
 * 必须setShowPageControl为YES之后才会有值
 */
@property (nonatomic, copy, readonly) JKAlertView *(^setCollectionPageControlConfig)(void(^)(UIPageControl *pageControl));

/** 设置colletion样式的底部按钮左右间距 */
@property (nonatomic, copy, readonly) JKAlertView *(^setCollectionButtonLeftRightMargin)(CGFloat margin);

/** collection样式默认有一个取消按钮，设置这个可以在取消按钮的上面再添加一个按钮 */
@property (nonatomic, copy, readonly) JKAlertView *(^setCollectionAction)(JKAlertAction *action);

/**
 * 设置collection样式添加自定义的titleView
 * frmae给出高度即可，宽度将自适应
 * 请将该自定义view视为容器view，推荐使用自动布局在其上约束子控件
 */
@property (nonatomic, copy, readonly) JKAlertView *(^setCustomCollectionTitleView)(UIView *(^customView)(void));

/** collection添加第二个collectionView的action */
- (void)addSecondCollectionAction:(JKAlertAction *)action;

/** 添加第二个collectionView的action */
- (void)insertSecondCollectionAction:(JKAlertAction *)action atIndex:(NSUInteger)index;

/** collection链式添加第二个collectionView的action */
@property (nonatomic, copy, readonly) JKAlertView *(^addSecondCollectionAction)(JKAlertAction *action);

/** collection链式添加第二个collectionView的action */
@property (nonatomic, copy, readonly) JKAlertView *(^insertSecondCollectionAction)(JKAlertAction *action, NSUInteger atIndex);
@end
