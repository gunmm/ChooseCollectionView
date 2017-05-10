//
//  ViewController.m
//  测试collectionview
//
//  Created by 闵哲 on 2017/3/9.
//  Copyright © 2017年 Gunmm. All rights reserved.
//

#import "ViewController.h"
#import "AddCollectionViewCell.h"
#import "UIViewExt.h"


#define kDeviceHeight [UIScreen mainScreen].bounds.size.height
#define kDeviceWidth  [UIScreen mainScreen].bounds.size.width

static NSString *identifier = @"addCell";
static NSString *head = @"header";
static NSString *foot = @"footer";

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    //存放数据的数组
    NSMutableArray *upArr;
    NSMutableArray *downArr;
    
    //主collectionView
    UICollectionView *_collectionView;
    AddCollectionViewCell *_dragingCell;
    
    //操作的cell的indexpath
    NSIndexPath *_dragingIndexPath;
    //目标位置cell的indexpath
    NSIndexPath *_targetIndexPath;
    
    //显示 数据
    UITextView *textV;
    
    
    
    CGFloat _cellHeight;
    CGFloat _cellWeight;
    CGFloat _lineWidth;
    
    //这个值是设置如果在拖拽中就不让点击cell=
    BOOL _theLongG;



    
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //造一个数据源
    NSArray *b = @[@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19"];
    NSArray *a = @[@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09"];

    upArr = [[NSMutableArray alloc]initWithArray:a];
    downArr = [[NSMutableArray alloc]initWithArray:b];

    _theLongG = YES;
    
    //创建_collectionView
    [self createUICollectionView];
    
    
    //初始化测试的view
    textV = [[UITextView alloc]initWithFrame:CGRectMake(10, 400, kDeviceWidth-20, kDeviceHeight-400)];
    [self.view addSubview:textV];

    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
}


/**
 创建_collectionView
 */
- (void)createUICollectionView{
    //创建布局类
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    
    //设置单元格大小
    _cellHeight = 35;
    _lineWidth = 15;
    _cellWeight = (kDeviceWidth-5*_lineWidth)/4;
    layout.itemSize = CGSizeMake(_cellWeight, _cellHeight);
    
    //设置单元格之间的间隙 水平方向 默认为10
    layout.minimumInteritemSpacing = _lineWidth;
    //设置单元格之间的间隙 竖直方向 默认为10
    layout.minimumLineSpacing = _lineWidth;
    
    //设置滚动方向
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    //设置头部视图大小
    layout.headerReferenceSize = CGSizeMake(100 , 35);

    
    //实例化UICollectionView
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    
    //注册单元格  系统自动复用池查看
    [_collectionView registerClass:[AddCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    
    //6.注册头部和尾部视图
    //头部视图
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:head];
    //尾部视图
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:foot];
    
    
    
    //添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMethod:)];
    longPress.minimumPressDuration = 0.3f;
    [_collectionView addGestureRecognizer:longPress];
    
    //一个假的cell   就是手里拿的那个cell   先隐藏
    _dragingCell = [[AddCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, (kDeviceWidth-5*10)/4, 30)];
    _dragingCell.hidden = true;
    _dragingCell.nameL.backgroundColor = [UIColor blueColor];
    [_collectionView addSubview:_dragingCell];
    
    _collectionView.backgroundColor = [UIColor clearColor];
}


/**
 长按手势相应的方法

 @param gesture 手势
 */
-(void)longPressMethod:(UILongPressGestureRecognizer*)gesture
{
    //判断一下手势当前的状态
    switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
            //开始拖拽
            [self dragBegin:gesture];
            break;
            case UIGestureRecognizerStateChanged:
            //拖拽中
            [self dragChanged:gesture];
            break;
            case UIGestureRecognizerStateEnded:
            //拖拽结束
            [self dragEnd:gesture];
            break;
        default:
            break;
    }  
}


/**
 开始拖拽

 @param gesture 手势
 */
-(void)dragBegin:(UILongPressGestureRecognizer*)gesture{
    _theLongG = NO;

    //手势作用点坐标
    CGPoint point = [gesture locationInView:_collectionView];
    //根据该point计算该点是否落在_collectionView的某个cell上 有返回cell的indexPath 否则返回nil
    _dragingIndexPath = [self getDragingIndexPathWithPoint:point];
    if (!_dragingIndexPath) {return;}
    NSLog(@"拖拽开始 indexPath = %@",_dragingIndexPath);
    
    //让假的cell出场  用来拖拽
    [_collectionView bringSubviewToFront:_dragingCell];
    //更新被拖拽的cell的frame 为刚才返回的的indexPath对应的cell的frame
    _dragingCell.frame = [_collectionView cellForItemAtIndexPath:_dragingIndexPath].frame;
    //调整 假的cell 的显示  及label的text值和对应cell相同  并且放大
    AddCollectionViewCell *midCell = (AddCollectionViewCell *)[_collectionView cellForItemAtIndexPath:_dragingIndexPath];
    _dragingCell.nameL.text = midCell.nameL.text;
    _dragingCell.hidden = false;
    [UIView animateWithDuration:0.3 animations:^{
        [_dragingCell setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
    }];
    
    [UIView animateWithDuration:0.1 delay:0 options:0  animations:^
     {
        _dragingCell.transform=CGAffineTransformMakeRotation(-0.05);
         
     } completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionAllowUserInteraction  animations:^
          {
              _dragingCell.nameL.transform=CGAffineTransformMakeRotation(0.1);
              
          } completion:^(BOOL finished) {}];
     }];

    
    //让所有的cell抖动起来
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems) {
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
        
        [UIView animateWithDuration:0.1 delay:0 options:0  animations:^
         {
             //顺时针旋转0.05 = 0.05 * 180 = 9°
             cell.transform=CGAffineTransformMakeRotation(-0.05);
         } completion:^(BOOL finished)
         {
             //  重复  反向动画时接收交互
             /**
              UIViewAnimationOptionAllowUserInteraction      //动画过程中可交互
              UIViewAnimationOptionBeginFromCurrentState     //从当前值开始动画
              UIViewAnimationOptionRepeat                    //动画重复执行
              UIViewAnimationOptionAutoreverse               //来回运行动画
              UIViewAnimationOptionOverrideInheritedDuration //忽略嵌套的持续时间
              UIViewAnimationOptionOverrideInheritedCurve    = 1 <<  6, // ignore nested curve
              UIViewAnimationOptionAllowAnimatedContent      = 1 <<  7, // animate contents (applies to transitions only)
              UIViewAnimationOptionShowHideTransitionViews   = 1 <<  8, // flip to/from hidden state instead of adding/removing
              UIViewAnimationOptionOverrideInheritedOptions  = 1 <<  9, // do not inherit any options or animation type
              */
             [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionAllowUserInteraction  animations:^
              {
                  ((AddCollectionViewCell *)cell).nameL.transform=CGAffineTransformMakeRotation(0.1);
              } completion:^(BOOL finished) {}];
         }];
        
    }

}

/**
 根据坐标计算point 计算该点坐落在_collectionView的cell的indexPath

 @param point 要计算的点
 @return 相对应的indexPath
 */
-(NSIndexPath*)getDragingIndexPathWithPoint:(CGPoint)point
{
    NSIndexPath* dragingIndexPath = nil;
    //遍历所有屏幕上的cell
    for (NSIndexPath *indexPath in [_collectionView indexPathsForVisibleItems]) {
        //判断cell是否包含这个点
        if (CGRectContainsPoint([_collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            dragingIndexPath = indexPath;
            break;
        }
    }
    return dragingIndexPath;
}


-(void)dragChanged:(UILongPressGestureRecognizer*)gesture{
    //获取对应的点
    CGPoint point = [gesture locationInView:_collectionView];
    
    //假cell的center设置为对应点  实现让假cell跟着手指跑
    _dragingCell.center = point;
    
    //根据点 计算 目前的手指所对应的 indexPath
    _targetIndexPath = [self getTargetIndexPathWithPoint:point];
    
    //两个indexPath都存在执行操作
    if (_targetIndexPath && _dragingIndexPath) {

        //如果在同组
        if(_dragingIndexPath.section == _targetIndexPath.section){
            [_collectionView moveItemAtIndexPath:_dragingIndexPath toIndexPath:_targetIndexPath];
            //数据源交换
            if (_dragingIndexPath.section == 0) {
                NSString *sstr = upArr[_dragingIndexPath.row];
                [upArr removeObjectAtIndex:_dragingIndexPath.row];
                [upArr insertObject:sstr atIndex:_targetIndexPath.row];
            }else{
                NSString *sstr = downArr[_dragingIndexPath.row];
                [downArr removeObjectAtIndex:_dragingIndexPath.row];
                [downArr insertObject:sstr atIndex:_targetIndexPath.row];
            }
            _dragingIndexPath = _targetIndexPath;
        }else{
            //不在同组
            if (_dragingIndexPath.section == 0) {
                NSString *str = upArr[_dragingIndexPath.row];
                [upArr removeObjectAtIndex:_dragingIndexPath.row];
                [downArr insertObject:str atIndex:_targetIndexPath.row];
            }else{
                NSString *str = downArr[_dragingIndexPath.row];
                [downArr removeObjectAtIndex:_dragingIndexPath.row];
                [upArr insertObject:str atIndex:_targetIndexPath.row];
            }
            [_collectionView moveItemAtIndexPath:_dragingIndexPath toIndexPath:_targetIndexPath];
            _dragingIndexPath = _targetIndexPath;
        }
    }
}


//获取目标IndexPath的方法
-(NSIndexPath*)getTargetIndexPathWithPoint:(CGPoint)point
{
    NSIndexPath *targetIndexPath = nil;
    //遍历所有屏幕上的cell
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems) {
        //避免和当前拖拽的cell重复
        if ([indexPath isEqual:_dragingIndexPath]) {continue;}
        //判断是否包含这个点
        if (CGRectContainsPoint([_collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            targetIndexPath = indexPath;
        }
    }
    

    //如果上面或者下面是空的 也就是目标点在空的组里  是找不到相对应的cell的   但是我们还要把它拖下去  这时候造一个indexPath
    if (!targetIndexPath) {
        if (_dragingIndexPath.section == 0) {
            if (point.y>([_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].frame.size.height+[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].frame.origin.y)) {
                targetIndexPath = [NSIndexPath indexPathForRow:downArr.count inSection:1];
                
            }
        }else{
            if (upArr.count>0) {
                if (point.y<([_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:upArr.count-1 inSection:0]].frame.size.height+[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:upArr.count-1 inSection:0]].frame.origin.y)) {
                    targetIndexPath = [NSIndexPath indexPathForRow:upArr.count inSection:0];
                    
                }

            }else{
                if (point.y<([_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].frame.size.height+[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].frame.origin.y)) {
                    targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    
                }
            }
            
        }
    }
    return targetIndexPath;
}

-(void)dragEnd:(UILongPressGestureRecognizer*)gesture{
    _theLongG = YES;

    NSLog(@"拖拽结束");
    if (!_dragingIndexPath) {return;}
    //目标位置frame
    CGRect endFrame = [_collectionView cellForItemAtIndexPath:_dragingIndexPath].frame;
    //加动画 将假cell 放下去动画结束 隐藏假cell
    [UIView animateWithDuration:0.3 animations:^{
        [_dragingCell setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        _dragingCell.frame = endFrame;
    }completion:^(BOOL finished) {
        _dragingCell.hidden = true;
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^
         {
            _dragingCell.nameL.transform=CGAffineTransformIdentity;
         } completion:^(BOOL finished) {}];
    }];
    
    
    
    //在下面textView中打印数据源
    NSString *text1 = [upArr componentsJoinedByString:@"*"];
    NSString *text2 = [downArr componentsJoinedByString:@"*"];
    NSString *str4444 = [NSString stringWithFormat:@"-----%@=====%@",text1,text2];
    textV.font = [UIFont systemFontOfSize:17];
    textV.text = str4444;
    
    
    
    
    //调整下颜色   因为我一组设置的是红的 一组是蓝的  😂
    for (int i = 0; i < upArr.count; i++) {
        AddCollectionViewCell *cell = (AddCollectionViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.nameL.backgroundColor = [UIColor redColor];
        cell.imgV.hidden = NO;
    }
    for (int i = 0; i < downArr.count; i++) {
        AddCollectionViewCell *cell = (AddCollectionViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        cell.nameL.backgroundColor = [UIColor greenColor];
        cell.imgV.hidden = YES;
    }
    
    //让抖动结束
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems) {
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             ((AddCollectionViewCell *)cell).nameL.transform=CGAffineTransformIdentity;
         } completion:^(BOOL finished) {}];
    }
}

#pragma mark----------UICollectionView  Delegate  DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section==0) {
        return upArr.count;
    }
    return downArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AddCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    //上面一组的右上角有叉
    if (indexPath.section==0) {
        cell.imgV.hidden = NO;
        cell.nameL.backgroundColor = [UIColor redColor];
        cell.nameL.text = upArr[indexPath.row];
        cell.hidden = NO;
    }else{
        cell.nameL.backgroundColor = [UIColor greenColor];
        cell.imgV.hidden = YES;
        cell.nameL.text = downArr[indexPath.row];
        cell.hidden = NO;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //这个值是设置如果在拖拽中就不让点击cell
    if (!_theLongG) {
        return;
    }
    
    if (indexPath.section == 0) {
        NSString *midStr = [upArr objectAtIndex:indexPath.row];
        [upArr removeObject:midStr];
        [downArr insertObject:midStr atIndex:0];
        [_collectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    }else{
        NSString *midStr = [downArr objectAtIndex:indexPath.row];
        [downArr removeObject:midStr];
        [upArr addObject:midStr];
        [_collectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:upArr.count - 1 inSection:0]];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        for (int i = 0; i < upArr.count; i++) {
            AddCollectionViewCell *cell = (AddCollectionViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.nameL.backgroundColor = [UIColor redColor];
            cell.imgV.hidden = NO;

        }
        
        for (int i = 0; i < downArr.count; i++) {
            AddCollectionViewCell *cell = (AddCollectionViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
         
            cell.nameL.backgroundColor = [UIColor greenColor];
            cell.imgV.hidden = YES;

        }
        
    });
}


//创建头部视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    //判断是否为头视图
    if (kind == UICollectionElementKindSectionHeader) {
        //创建头部视图
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:head forIndexPath:indexPath];
        header.backgroundColor = [UIColor grayColor];
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, 100, 35)];
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(125, 8, kDeviceWidth-125, 25)];
        label2.font = [UIFont systemFontOfSize:13];
        if (indexPath.section == 0) {
            label1.text = @"已选模块";
            label2.text = @"单击删除，按住拖动";
        }
        else{
            label1.text = @"未选模块";
            label2.text = @"";
        }
        [header addSubview:label1];
        [header addSubview:label2];
        return header;
    }
    return nil;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
