//
//  NilDataTip.m
//  HeraldleasingWorkAssistant
//
//  Created by Mesada on 15/7/12.
//  Copyright (c) 2015年 mesada. All rights reserved.
//

#import "NilDataTipView.h"

@implementation NilDataTipView
+ (instancetype)getInstance
{
    NilDataTipView* instance;
    NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"NilDataTip" owner:self options:nil];
    instance = [nibs objectAtIndex:0];
    return instance;
}
@end
