//
//  NilDataTip.h
//  HeraldleasingWorkAssistant
//
//  Created by Mesada on 15/7/12.
//  Copyright (c) 2015年 mesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NilDataTipView : UIView
@property (strong, nonatomic) IBOutlet UILabel *tipTextLabel;
+ (instancetype)getInstance;
@end
