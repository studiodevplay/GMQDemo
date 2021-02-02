//
//  JoypacPrivacyViewController.m
//  Unity-iPhone
//
//  Created by 洋吴 on 2019/9/4.
//

#import "JoypacPrivacyViewController.h"
#import "Masonry.h"
#import "JoypacGDPR.h"
#import "JPCConst.h"

@interface JoypacPrivacyViewController ()


@end

@implementation JoypacPrivacyViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLab = [[UILabel alloc]init];
    titleLab.textColor = [UIColor blackColor];
    titleLab.text = @"Your privacy is important！";
    titleLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    [self.view addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(35);
        make.left.equalTo(self.view).offset(18);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    
    UIView *underLine = [[UIView alloc]init];
    underLine.backgroundColor = [UIColor grayColor];
    underLine.alpha = 0.4;
    [self.view addSubview:underLine];
    [underLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLab.mas_bottom).offset(20);
        make.left.right.equalTo(titleLab);
        make.height.equalTo(@1);
    }];
    
    UITextView *textView = [[UITextView alloc]init];
    textView.backgroundColor = [UIColor whiteColor];
    textView.layoutManager.allowsNonContiguousLayout = NO;
    textView.text = @"Thank you for downloading Joypac game, we want to list a few data we collect and why.\n\nBy consenting this statement, we will collect a few data points, such as:\n\n● Device identifiers (iOS Identifier for Advertising)\n● Location data\n● Brand and Model\n● OS type and version\n\nThese data are collected using tools called SDKs and will let us and our partners provide ads based on your interests.\n\nBy agreeing, you are confirming that you are a citizen older than 16 and allow us to provide you with personalized advertising services.\n\nIf you refuse, we will still show you the same amount of advertisements that you may not be interested in.";
    
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc]initWithString:textView.text];
    [attributed addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0,161)];
    [attributed addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(162,110)];
    [attributed addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(273,textView.text.length - 273)];
    [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(162,110)];
    
    textView.attributedText = attributed;
//    textView.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(underLine.mas_bottom).offset(20);
        make.left.right.equalTo(underLine);
    }];
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    sureBtn.backgroundColor = [UIColor colorWithRed:68/255.0 green:121/255.0 blue:249/255.0 alpha:1];
    [sureBtn setTitle:@"Yes, I Agree" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(textView);
        make.top.equalTo(textView.mas_bottom).offset(30);
        make.height.equalTo(@50);
    }];
    sureBtn.layer.cornerRadius = 25;
    sureBtn.layer.masksToBounds = YES;
    [sureBtn addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancleBtn setTitle:@"No, thanks" forState:UIControlStateNormal];
    [self.view addSubview:cancleBtn];
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(sureBtn);
        make.height.equalTo(@50);
        make.top.equalTo(sureBtn.mas_bottom).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-50);
    }];
    cancleBtn.layer.cornerRadius = 25;
    cancleBtn.layer.masksToBounds = YES;
    cancleBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cancleBtn.layer.borderWidth = 1;
    [cancleBtn addTarget:self action:@selector(cancleButtonClick) forControlEvents:UIControlEventTouchUpInside];

}


- (void)confirmButtonClick{
    
    if (self.responeCallback) {
        self.responeCallback();
    }
    [kUserDefault  setInteger:JoypacDataConsentSetPersonalized forKey:kJoypacGDPRStatus];
}

- (void)cancleButtonClick{
    
    if (self.responeCallback) {
        self.responeCallback();
    }
    [kUserDefault  setInteger:JoypacDataConsentSetNonpersonalized forKey:kJoypacGDPRStatus];
    
}

@end
