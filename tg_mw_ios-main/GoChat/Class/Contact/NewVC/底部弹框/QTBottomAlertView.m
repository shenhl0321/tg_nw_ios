//
//  QTBottomAlertView.m
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/4/9.
//

#import "QTBottomAlertView.h"
#import "QTBottomAlertCell.h"

@interface QTBottomAlertView () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (strong, nonatomic) QTBottomAlertChooseBlock chooseBlock;
@property (strong, nonatomic) NSArray *dataArr;

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewHeiCon;

@end
@implementation QTBottomAlertView

#define kQTBottomAlertCell @"QTBottomAlertCell"
static QTBottomAlertView *currentView = nil;

+(QTBottomAlertView *)sharedInstance {
    @synchronized(self) {
        if(!currentView) {
            currentView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([QTBottomAlertView class]) owner:nil options:nil] firstObject];
            currentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        }
    }
    return currentView;
}

- (void)layoutSubviews{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, 60) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.topView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.topView.layer.mask = maskLayer;
}

- (void)alertViewTitle:(NSString *)title DataArr:(NSArray *)dataArr ChooseSuccess:(QTBottomAlertChooseBlock)chooseBlock{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:currentView];
    
    self.titleLab.text = title;
    self.dataArr = dataArr;
    self.chooseBlock = chooseBlock;
    
    [self initUI];
    
    [self.tableview reloadData];
}
- (void)initUI{
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.rowHeight  = 50;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableview registerNib:[UINib nibWithNibName:kQTBottomAlertCell bundle:nil] forCellReuseIdentifier:kQTBottomAlertCell];
    
    CGFloat viewHei = self.dataArr.count * self.tableview.rowHeight;
    if (viewHei > 400){
        viewHei = 400;
    }
    self.tableviewHeiCon.constant = viewHei;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QTBottomAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:kQTBottomAlertCell forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentLab.text = self.dataArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.chooseBlock){
        self.chooseBlock(indexPath.row, self.dataArr[indexPath.row]);
    }
    [self dismiss];
}
- (IBAction)buttonClick:(UIButton *)sender {
    if (sender.tag == 1){
        [self dismiss];
    }else if (sender.tag == 2){
        [self dismiss];
    }
}


- (void)dismiss{
    [self removeFromSuperview];
}

@end
