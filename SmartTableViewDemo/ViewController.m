//
//  ViewController.m
//  SmartTableViewDemo
//
//  Created by anjohnlv on 2017/9/6.
//  Copyright © 2017年 anjohnlv. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"

#define IMAGE_WIDTH [[UIScreen mainScreen] bounds].size.width/3
#define IMAGE_HEIGHT IMAGE_WIDTH*9/16
static NSInteger kMaxImageCount = 9;
static NSString *kCellIdentifier = @"SmartCell";

#pragma mark - model
@interface Info : NSObject
@property(nonatomic, strong)NSString *name, *message;
@property(nonatomic, strong)NSMutableArray *images;
@end

@implementation Info
@end

#pragma mark - cell
@interface SmartTableViewCell : UITableViewCell
@property(nonatomic, strong)Info *info;
@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UILabel *messageLabel;
@property(nonatomic, strong)NSMutableArray *imageViews;
@end

@implementation SmartTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _nameLabel = [UILabel new];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
        }];
        
        _messageLabel = [[UILabel alloc]init];
        _messageLabel.backgroundColor = [UIColor lightGrayColor];
        _messageLabel.numberOfLines = 0;
        [self.contentView addSubview:_messageLabel];
        [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(_nameLabel.mas_bottom);
            make.bottom.equalTo(self.contentView).priorityLow();
        }];
        
        _imageViews = [NSMutableArray new];
        for (int i=0; i<kMaxImageCount; i++) {
            UIImageView *imageView = [UIImageView new];
            [self.contentView addSubview:imageView];
            [_imageViews addObject:imageView];
        }
    }
    return self;
}

- (void)setInfo:(Info *)info {
    _info = info;
    self.nameLabel.text = _info.name;
    self.messageLabel.text = _info.message;
    NSInteger count = [[_info images]count];
    for (int i=0; i<kMaxImageCount; i++) {
        [_imageViews[i] setHidden:YES];
        [_imageViews[i] mas_remakeConstraints:^(MASConstraintMaker *make){
            make.width.mas_equalTo(IMAGE_WIDTH);
            make.height.mas_equalTo(IMAGE_HEIGHT);
            make.centerX.equalTo(self.contentView).multipliedBy(((i%3)*2+1.0)/3);
            make.top.equalTo(_messageLabel.mas_bottom).offset(IMAGE_HEIGHT*(i/3));
        }];
    }
    if (count>0) {
        for (int i=0; i<count; i++) {
            [_imageViews[i] setImage:[_info images][i]];
            [_imageViews[i] setHidden:NO];
            if (i==count-1) {
                [_imageViews[i] mas_makeConstraints:^(MASConstraintMaker *make){
                    make.bottom.equalTo(self.contentView).priorityHigh();
                }];
            }
        }
    }
}

@end

#pragma mark - viewController
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSMutableArray<Info *> *infoArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [UITableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.allowsSelection = NO;
    [_tableView registerClass:[SmartTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(20);
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.width.equalTo(self.view);
    }];
    _tableView.estimatedRowHeight = 60;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.infoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SmartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[SmartTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    NSInteger row = [indexPath row];
    cell.info = self.infoArray[row];
    return cell;
}

-(NSMutableArray *)infoArray {
    if (!_infoArray) {
        _infoArray = [NSMutableArray new];
        for (int i=0; i<10; i++) {
            Info *info = [Info new];
            info.name = [NSString stringWithFormat:@"人造人%d",i+1];
            info.message = [self message];
            info.images = [self images];
            [_infoArray addObject:info];
        }
    }
    return _infoArray;
}

-(NSString *)message {
    NSInteger length = arc4random()%200;
    NSString *message = @"";
    for (int i=0; i<length; i++) {
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSInteger randomH = 0xA1+arc4random()%(0xFE - 0xA1+1);
        NSInteger randomL = 0xB0+arc4random()%(0xF7 - 0xB0+1);
        NSInteger number = (randomH<<8)+randomL;
        NSData *data = [NSData dataWithBytes:&number length:2];
        NSString *string = [[NSString alloc] initWithData:data encoding:gbkEncoding];
        message = [message stringByAppendingString:string];
    }
    return message;
}

-(NSMutableArray *)images{
    NSInteger count = arc4random()%kMaxImageCount;
    NSMutableArray *images = [NSMutableArray new];
    for (int i=0; i<count; i++) {
        int index = (arc4random() % 14) + 1;
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"recorder_background_thumbnail_truecolor_%d",index]];
        [images addObject:image];
    }
    return images;
}

@end
