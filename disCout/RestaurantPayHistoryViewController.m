
#import "Request.h"
#import "AppDelegate.h"
#import "SWRevealViewController.h"
#import "RestaurantPayHistoryViewController.h"
#import "PayHistoryCollectionReusableView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MBProgressHUD.h"
@interface RestaurantPayHistoryViewController ()
{
    AppDelegate *app;
    int childCount;
}
@property (strong, nonatomic) IBOutlet UICollectionView *payHistoryTableView;
@property (strong, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (strong, nonatomic) IBOutlet UILabel *JobID;
@property (strong, nonatomic) IBOutlet UILabel *Membership;
@property (strong, nonatomic) IBOutlet UILabel *UserName;
@property (strong, nonatomic) IBOutlet UIImageView *imgIsPaid;

@end

@implementation RestaurantPayHistoryViewController
#pragma mark - set environment
- (void) viewDidLoad{
    app = [UIApplication sharedApplication].delegate;
    
}
- (void) viewWillAppear:(BOOL)animated{
    
    [self.imgIsPaid setHidden:app.user.isCancelled];
    
    childCount = 1;
    //membership
    if (app.user.numberOfCoupons > 0) {
        NSDictionary *payDic = [app.arrPayDictinaryData objectAtIndex:app.arrPayDictinaryData.count-1];
        NSArray *payData = [payDic objectForKey:@"pay info"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd-yyyy"];
        ;
        NSString* amount =(NSString*)[[payData objectAtIndex:payData.count-1]objectForKey:@"amount"];
        self.Membership.text = [NSString stringWithFormat:@"$%@ / Month : %d%%", amount,2*[amount intValue]];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setMonth:1];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:app.user.dateCycleStart options:0];
        
        self.JobID.text = [NSString stringWithFormat:@"you can use %d coupons until %@.",app.user.numberOfCoupons, [dateFormatter stringFromDate:newDate] ];
    }
    
    if (app.user.numberOfCoupons==0) {
        self.JobID.text = [NSString stringWithFormat:@"you have not any coupon."];    }
    
    
    self.UserName.text = app.user.name;
    
    
    
    [self.imgIsPaid setHidden:!app.user.isCancelled];
    
    [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"MyCard_Active.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBarItem setImage:[[UIImage imageNamed:@"MyCard_InActive.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBarItem setTitle:@"PAID"];
    [self.imgPhoto sd_setImageWithURL:app.user.photoURL placeholderImage:[UIImage imageNamed:@"person0.jpg"]];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    [self.payHistoryTableView reloadData];
}

#pragma mark - collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([FIRAuth auth].currentUser.isAnonymous) {
        return 0;
    }
    return [[[app.arrPayDictinaryData objectAtIndex:section] objectForKey:@"pay info"] count] ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    static NSString *identifier = @"payCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UILabel *date = (UILabel *)[cell viewWithTag:101];
    UILabel *Amount = (UILabel *)[cell viewWithTag:102];
    UILabel *memberShip = (UILabel *)[cell viewWithTag:103];
    NSDictionary *payDic = [app.arrPayDictinaryData objectAtIndex:indexPath.section];
    NSArray *payData = [payDic objectForKey:@"pay info"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
     ;
    NSString* amount =(NSString*)[[payData objectAtIndex:indexPath.row]objectForKey:@"amount"];
    Amount.text =  [NSString stringWithFormat:@"$%@",amount];
    NSDate *datePay = (NSDate*)[[payData objectAtIndex:indexPath.row] objectForKey:@"date"];
    memberShip.text = [NSString stringWithFormat:@"$%@ / Month : %d%%", amount,2*[amount intValue]];
    date.text = [dateFormatter stringFromDate: datePay];
    return  cell;

}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width, 50);
}

- (CGFloat)collectionView: (UICollectionView*)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}
#pragma mark - go side
- (IBAction)goSideMenu:(UIButton *)sender {
    [self.navigationController.revealViewController rightRevealToggle:nil];
}
@end
