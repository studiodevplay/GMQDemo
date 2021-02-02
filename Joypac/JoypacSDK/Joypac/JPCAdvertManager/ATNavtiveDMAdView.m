//
//
//  Created by 洋吴 on 2018/12/29.
//  Copyright © 2018 yodo1. All rights reserved.
//

#import "ATNavtiveDMAdView.h"

static NSString *const kMediaFrameKey = @"meida_frame";

@interface ATNavtiveDMAdView ()
@property(nonatomic, readonly) UILabel *advertiserLabel;
@property(nonatomic, readonly) UILabel *textLabel;
@property(nonatomic, readonly) UILabel *titleLabel;
@property(nonatomic, readonly) UILabel *ctaLabel;
@property(nonatomic, readonly) UILabel *ratingLabel;
@property(nonatomic, readonly) UIImageView *iconImageView;
@property(nonatomic, readonly) UIImageView *mainImageView;
@property(nonatomic, readonly) UIImageView *sponsorImageView;
@property(nonatomic, strong) UILabel* downLoadLabel;
@end

@implementation ATNavtiveDMAdView

-(NSArray<UIView*>*)clickableViews {
    
    if (self.mediaView) {
        return @[self.mediaView,self.ctaLabel];
    }else{
        if (self.mainImageView&&self.iconImageView&&self.textLabel&&self.titleLabel) {
            return @[self.mainImageView,
                     self.ctaLabel,
                     self.titleLabel,
                     self.textLabel,
                     self.iconImageView];
        }
        else{
            return @[self.ctaLabel];
        }
        
    }
}

-(void) layoutSubviews{
    [super layoutSubviews];
    self.mediaView.frame = self.mainImageView.frame;
    _downLoadLabel.backgroundColor = _titleLabel.text ? [UIColor colorWithRed:241/255.0 green:205/255.0 blue:83/255.0 alpha:1] : [UIColor clearColor];
    //self.backgroundColor = _titleLabel.text ? [UIColor whiteColor]:[UIColor clearColor];
}

-(void) initSubviews{
    [super initSubviews];
    self.backgroundColor = [UIColor whiteColor];
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = [UIFont systemFontOfSize:13];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_titleLabel];
    
    _mainImageView = [UIImageView new];
    _mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_mainImageView];
    
    _iconImageView = [[UIImageView alloc]init];
    _iconImageView.layer.cornerRadius = 10.0f;
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_iconImageView];
    
    _sponsorImageView = [[UIImageView alloc]init];
    _sponsorImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_sponsorImageView];
    
    _textLabel = [[UILabel alloc]init];
    _textLabel.font = [UIFont systemFontOfSize:12];
    _textLabel.textColor = [UIColor blackColor];
    _textLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_textLabel];
    
    _downLoadLabel = [[UILabel alloc]init];
    _downLoadLabel.font = [UIFont systemFontOfSize:12];
    _downLoadLabel.textColor = [UIColor blackColor];
    _downLoadLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:_downLoadLabel];
    _ctaLabel = _downLoadLabel;
    
}


-(void) makeConstraintsForSubviews{
    
    [super makeConstraintsForSubviews];
    self.mediaView.frame = self.mainImageView.frame;
    self.mainImageView.frame = CGRectMake(8, 8, self.bounds.size.width-16, self.bounds.size.height*0.65);
    
    CGFloat iconWidth = self.bounds.size.height - self.bounds.size.height*0.65 - 30;
    self.iconImageView.frame = CGRectMake(8,CGRectGetMaxY(self.mainImageView.frame)+10, iconWidth, iconWidth);
    
    CGFloat titleWidth =self.bounds.size.width - 8 - iconWidth - 10 - 78;
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame)+10, CGRectGetMinY(self.iconImageView.frame)+5, titleWidth, iconWidth/3);
    
    self.textLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.titleLabel.frame)+5, titleWidth, iconWidth/3);
    
    self.downLoadLabel.frame = CGRectMake(self.bounds.size.width - 78, CGRectGetMidY(self.iconImageView.frame)-12.5, 70, 25);
    
    
    self.sponsorImageView.frame = CGRectMake(self.bounds.size.width - 38, CGRectGetMaxY(self.mainImageView.frame), 30, 10);
    
    
}

@end
