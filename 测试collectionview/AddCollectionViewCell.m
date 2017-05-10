//
//  AddCollectionViewCell.m
//  测试collectionview
//
//  Created by 闵哲 on 2017/3/9.
//  Copyright © 2017年 Gunmm. All rights reserved.
//

#import "AddCollectionViewCell.h"

@implementation AddCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle]loadNibNamed:@"AddCollectionViewCell" owner:nil options:nil ]lastObject];
        _nameL.layer.cornerRadius = 15;
        _nameL.layer.masksToBounds = YES;
        _nameL.adjustsFontSizeToFitWidth = YES;
        
        
        _imgV.layer.cornerRadius = 7;
        _imgV.layer.masksToBounds = YES;




        
    }
    return self;
}

@end
