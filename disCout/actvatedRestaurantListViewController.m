

#import "Request.h"
#import "AppDelegate.h"
#import "YPAPISample.h"
#import "RestaurantInfoViewController.h"
#import "MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LocationMapOfRestaurants.h"
#import "SWRevealViewController.h"
@import Firebase;
#import "actvatedRestaurantListViewController.h"
@interface actvatedRestaurantListViewController ()
{
    int count;
    AppDelegate *app;
    NSArray *ArrResThumbnailsName;
    NSArray *ArrResNames;
    NSMutableArray* registeredRestaurants;
    NSMutableArray *muarResName;
    
    NSArray *businessArray;
    bool *checkScroll;
}
@property (weak, nonatomic) IBOutlet UICollectionView *tableResList;

@end

@implementation actvatedRestaurantListViewController
#pragma mark - set environment
- (void)viewDidLoad {
    
    [super viewDidLoad];
    app = [UIApplication sharedApplication].delegate;
    
    
    checkScroll = false;
    
    [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"Activity_Active.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBarItem setImage:[[UIImage imageNamed:@"Activity_Inactive.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBarItem setTitle:@"ACTIVITY"];
    [self.tabBarItem setTitleTextAttributes:@{
                                              NSFontAttributeName: [UIFont fontWithName:@"Avenir Next LT Pro" size:10],
                                              NSForegroundColorAttributeName: [UIColor colorWithRed:243/255.0 green:101/255.0 blue:35/255.0 alpha:1.0]
                                              } forState:UIControlStateNormal];
    [self.tabBarItem setTitleTextAttributes:@{
                                              NSFontAttributeName: [UIFont fontWithName:@"Avenir Next LT Pro" size:10],
                                              NSForegroundColorAttributeName: [UIColor colorWithRed:243/255.0 green:101/255.0 blue:35/255.0 alpha:1.0]
                                              } forState:UIControlStateSelected];
    
}
- (void)viewWillAppear:(BOOL)animated{
    registeredRestaurants = [[NSMutableArray alloc]init];
    for (int count1 = 0; app.arrRegisteredDictinaryRestaurantData.count>count1; count1++) {
        NSString *name = [[app.arrRegisteredDictinaryRestaurantData objectAtIndex:count1] objectForKey:@"name"];
        [registeredRestaurants addObject:name];
    }
    [self.tableResList reloadData];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

#pragma mark - restaurant collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return app.arrRegisteredDictinaryRestaurantData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    static NSString *identifier = @"resCell";
    
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *resAddress = (UILabel *)[cell viewWithTag:101];
    NSDictionary *dice = (NSDictionary*)[app.arrRegisteredDictinaryRestaurantData objectAtIndex:indexPath.row];
    resAddress.text = (NSString*)[dice objectForKey:@"address"];
    
    UILabel *membershipLabel= (UILabel *)[cell viewWithTag:102];
    [membershipLabel setHidden:YES];
    
    UIImageView *resImageView = (UIImageView *)[cell viewWithTag:103];
    [resImageView sd_setImageWithURL:[NSURL URLWithString:[[app.arrRegisteredDictinaryRestaurantData objectAtIndex:indexPath.row] objectForKey:@"image_url"]]
                    placeholderImage:[UIImage imageNamed:@"Splash.png"]];
    
    UILabel *resName = (UILabel *)[cell viewWithTag:104];
    resName.text = [[app.arrRegisteredDictinaryRestaurantData objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    UIImageView *resRatingImageView = (UIImageView *)[cell viewWithTag:105];
    [resRatingImageView sd_setImageWithURL:[NSURL URLWithString:[[app.arrRegisteredDictinaryRestaurantData objectAtIndex:indexPath.row] objectForKey:@"rating_img_url"]]
                          placeholderImage:[UIImage imageNamed:@"Splash.png"]];
    
    UILabel *reviewCount = (UILabel *)[cell viewWithTag:106];
    reviewCount.text = [NSString stringWithFormat:@"%@ reviews",[[app.arrRegisteredDictinaryRestaurantData objectAtIndex:indexPath.row] objectForKey:@"review_count"]];
    
    UILabel *resCategories = (UILabel *)[cell viewWithTag:107];
    resCategories.text = [[app.arrRegisteredDictinaryRestaurantData objectAtIndex:indexPath.row] objectForKey:@"categories"];
    
    UILabel *resPhoneNumber = (UILabel *)[cell viewWithTag:109];
    resPhoneNumber.text = [[app.arrRegisteredDictinaryRestaurantData objectAtIndex:indexPath.row] objectForKey:@"display_phone"];
    
    UIImageView *regImageView = (UIImageView *)[cell viewWithTag:110];
    [regImageView setHidden:NO];
    
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    app.selectedResNumberFromResList = (int)indexPath.row;
    app.dicRestaurantData = [[NSDictionary alloc]initWithDictionary:[app.arrRegisteredDictinaryRestaurantData objectAtIndex:app.selectedResNumberFromResList] copyItems:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RestaurantInfoViewController *restaurantInfoViewController = [storyboard instantiateViewControllerWithIdentifier:@"RestaurantInfoViewController"];
    [self.navigationController pushViewController:restaurantInfoViewController animated:YES];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width, 100);
}

#pragma mark - exchange map
- (IBAction)exchangeMap:(UIButton *)sender{
UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LocationMapOfRestaurants *restaurantInfoViewController = [storyboard instantiateViewControllerWithIdentifier:@"LocationMapOfRestaurants"];
    [self.navigationController pushViewController:restaurantInfoViewController animated:YES];
}
#pragma mark - sort
- (IBAction)Sort:(UIButton *)sender {
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    app.arrRegisteredDictinaryRestaurantData = [[NSMutableArray alloc]initWithArray:[app.arrRegisteredDictinaryRestaurantData sortedArrayUsingDescriptors:@[descriptor]]];
    [self.tableResList reloadData];
}
#pragma mark - go side
- (IBAction)goSlide:(UIButton *)sender {
    [self.navigationController.revealViewController rightRevealToggle:nil];
}

@end
