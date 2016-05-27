//
//  AudioListCell.h
//  MyDemo
//
//  Created by ENIAC on 15/12/25.
//  Copyright © 2015年 yyb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordView.h"
#import "AudioFileInfoModel.h"
@protocol AudioListCellDelegate<NSObject>
@optional
- (void)cleanTheMediaPlayViewWithRecord:(UIButton *)sender;

@end
//重新上传
typedef void (^ReuploderBlock)(BOOL reuploder);
@interface AudioListCell : UITableViewCell<finisedPlayDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *sizeLab;
@property (weak, nonatomic) IBOutlet UILabel *durationLab;
@property (weak, nonatomic) IBOutlet UIButton *uploderStatusBtn;
@property (weak, nonatomic) IBOutlet UIButton *hiddenUploderBtn;
- (IBAction)reUploder:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *bgView;

- (void)setValueWithfileInfo:(AudioFileInfoModel *)fileInfo;
/**
 * 是否重新上传
 */
@property (nonatomic,copy) ReuploderBlock reuploderBlock;
@property (nonatomic,weak) id<AudioListCellDelegate> delegate;
@end
