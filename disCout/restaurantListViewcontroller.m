
#import "Request.h"
#import "AppDelegate.h"
#import "YPAPISample.h"
#import "RestaurantInfoViewController.h"
#import "restaurantListViewcontroller.h"
#import "LocationMapOfRestaurants.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@import Firebase;
@interface restaurantListViewcontroller ()
{
    int count;
    AppDelegate * app;
    NSArray *ArrResThumbnailsName;
    NSArray *ArrResNames;
    NSMutableArray* registeredRestaurants;
    NSMutableArray *muarResName;
    NSSortDescriptor * descriptor;
    bool checkScroll;
    
}
@property (weak, nonatomic) IBOutlet UICollectionView *tableResList;

@end

@implementation restaurantListViewcontroller

#pragma mark - set environment
- (void)viewDidLoad {
    
    [super viewDidLoad];
    app = [UIApplication sharedApplication].delegate;
    checkScroll = false;
    [self.tableResList setCanCancelContentTouches:NO];
   
}
- (void)viewWillAppear:(BOOL)animated{
    muarResName = [[NSMutableArray alloc]init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            for (int count1 = 0; app.arrRegisteredDictinaryRestaurantData.count>count1; count1++) {
                [tempArray addObject:[[app.arrRegisteredDictinaryRestaurantData objectAtIndex:count1] objectForKey:@"name"]];
            }
            registeredRestaurants = [[NSMutableArray alloc]initWithArray:tempArray];
            
            for (int count1 = 0; app.arrSearchedDictinaryRestaurantData.count>count1; count1++) {
                [muarResName addObject:[[app.arrSearchedDictinaryRestaurantData objectAtIndex:count1] objectForKey:@"name"]];
            }
            [tempArray removeObjectsInArray:muarResName];
            [registeredRestaurants removeObjectsInArray:tempArray];
            [self.tableResList reloadData];
        });
    });
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

#pragma mark - go side
- (IBAction)goSideMenu:(UIButton *)sender {
    [self.navigationController.revealViewController rightRevealToggle:nil];
}

#pragma mark - exchange map
- (IBAction)ExchangeMap:(UIButton *)sender {

        [self.navigationController popViewControllerAnimated:YES];
  
}
- (IBAction)GoBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - sort
- (IBAction)Sort:(UIButton *)sender {
    
    
    if (app.intSearchOption2==1) {
        descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        app.arrSearchedDictinaryRestaurantData = [[NSMutableArray alloc]initWithArray:[app.arrSearchedDictinaryRestaurantData sortedArrayUsingDescriptors:@[descriptor]]];
    }else if(app.intSearchOption2==2)
    {
        descriptor = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:NO];
        app.arrSearchedDictinaryRestaurantData = [[NSMutableArray alloc]initWithArray:[app.arrSearchedDictinaryRestaurantData sortedArrayUsingDescriptors:@[descriptor]]];
    }
    
    [self.tableResList reloadData];

    
}

#pragma mark - restaurant collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return app.arrSearchedDictinaryRestaurantData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    static NSString *identifier = @"resCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *resAddress = (UILabel *)[cell viewWithTag:101];
    NSDictionary *dice = (NSDictionary*)[app.arrSearchedDictinaryRestaurantData objectAtIndex:indexPath.row];
    resAddress.text = (NSString*)[dice objectForKey:@"address"];
    
    UILabel *membershipLabel= (UILabel *)[cell viewWithTag:102];
    [membershipLabel setHidden:YES];

    UIImageView *resImageView = (UIImageView *)[cell viewWithTag:103];
    [resImageView sd_setImageWithURL:[NSURL URLWithString:[[app.arrSearchedDictinaryRestaurantData objectAtIndex:indexPath.row] objectForKey:@"image_url"]]
                    placeholderImage:[UIImage imageNamed:@"Splash.png"]];
    
    UILabel *resName = (UILabel *)[cell viewWithTag:104];
    resName.text = [[app.arrSearchedDictinaryRestaurantData objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    UIImageView *resRatingImageView = (UIImageView *)[cell viewWithTag:105];
    [resRatingImageView sd_setImageWithURL:[NSURL URLWithString:[[app.arrSearchedDictinaryRestaurantData objectAtIndex:indexPath.row] objectForKey:@"rating_img_url"]]
                    placeholderImage:[UIImage imageNamed:@"Splash.png"]];
    
    UILabel *reviewCount = (UILabel *)[cell viewWithTag:106];
    reviewCount.text = [NSString stringWithFormat:@"%@ reviews",[[app.arrSearchedDictinaryRestaurantData objectAtIndex:indexPath.row] objectForKey:@"review_count"]];
    
    UILabel *resCategories = (UILabel *)[cell viewWithTag:107];
    resCategories.text = [[app.arrSearchedDictinaryRestaurantData objectAtIndex:indexPath.row] objectForKey:@"categories"];
    
    UILabel *resPhoneNumber = (UILabel *)[cell viewWithTag:109];
    resPhoneNumber.text = [[app.arrSearchedDictinaryRestaurantData objectAtIndex:indexPath.row] objectForKey:@"display_phone"];
    
    UIImageView *regImageView = (UIImageView *)[cell viewWithTag:110];
    [regImageView setHidden:YES];
    for (int i = 0; registeredRestaurants.count>i; i++) {
        if ([[muarResName objectAtIndex:indexPath.row] isEqualToString:[registeredRestaurants objectAtIndex:i]]) {
            [regImageView setHidden:NO];
            
            continue;
        }
        
    }
    
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    app.selectedResNumberFromResList = (int)indexPath.row;
    app.dicRestaurantData = [[NSDictionary alloc]initWithDictionary:[app.arrSearchedDictinaryRestaurantData objectAtIndex:app.selectedResNumberFromResList] copyItems:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RestaurantInfoViewController *restaurantInfoViewController = [storyboard instantiateViewControllerWithIdentifier:@"RestaurantInfoViewController"];
    [self.navigationController pushViewController:restaurantInfoViewController animated:YES];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width, 100);
}




@end
