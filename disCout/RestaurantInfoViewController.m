
#import "Request.h"
#import "AppDelegate.h"
#import "SWRevealViewController.h"
#import "RestaurantInfoViewController.h"
#import "actvatedRestaurantListViewController.h"
#import "LocationMapOfRestaurants.h"
#import "MapViewController.h"
#import "restaurantListViewcontroller.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "webViewController.h"
@interface RestaurantInfoViewController ()
{
    NSString *ResName;
    NSString *ResAddress;
    NSString *ResPostalcode;
    NSString *ResLatitude;
    NSString *ResLonggitude;
    NSString *ResCategories;
    NSString *ResRating;
    NSString *ResSnnipetImageURL;
    NSString *ResRatingImageURL;
    NSString *ResSnippetText;
    NSString *ResDisplayPhone;
    NSString *ResReviewCount;
    NSString *ResID;
    NSURL *ResMobileURL;
    NSDictionary *dicRestaurantData;
    NSDictionary *tempDic;
    
}

@property (weak, nonatomic) IBOutlet UIImageView *imgRestaurnat;
@property (strong, nonatomic) IBOutlet UIImageView *registerMarkImage;
@property (nonatomic, strong) webViewController* webViewVC;
@property (strong, nonatomic) IBOutlet UIImageView *imgResRating;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblCategories;
@property (strong, nonatomic) IBOutlet UILabel *lblReviewNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblResID;
@property (strong, nonatomic) IBOutlet UITextView *txtViewSnippetText;
@end

@implementation RestaurantInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}
- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    self.webViewVC = [[webViewController alloc] initWithNibName:@"webViewController" bundle:nil];
    dicRestaurantData = app.dicRestaurantData;
    
    ResName = [dicRestaurantData objectForKey: @"name"];
    ResAddress = [dicRestaurantData objectForKey: @"address"];
    ResPostalcode = [dicRestaurantData objectForKey: @"postal_code"];
    ResLatitude = [dicRestaurantData objectForKey: @"latitude"];
    ResLonggitude = [dicRestaurantData objectForKey: @"longitude"];
    ResCategories = [dicRestaurantData objectForKey: @"categories"];
    ResRating = [dicRestaurantData objectForKey: @"rating"];
    ResSnippetText = [dicRestaurantData objectForKey: @"snippet_text"];
    ResReviewCount = [dicRestaurantData objectForKey: @"review_count"];
    ResSnnipetImageURL = [dicRestaurantData objectForKey: @"image_url"];
    ResRatingImageURL = [dicRestaurantData objectForKey: @"rating_img_url"];
    ResID = [dicRestaurantData objectForKey:@"resid"];
    if ([[dicRestaurantData objectForKey:@"mobile_url"] isEqualToString:@""]) {
        self.lblReviewNumber.text =[NSString stringWithFormat:@"no review"] ;
    }else{
        ResMobileURL = [[NSURL alloc]initWithString:(NSString*)[dicRestaurantData objectForKey:@"mobile_url"]];
    }
    self.lblPhoneNumber.text = [dicRestaurantData objectForKey:@"display_phone"];
    [self.imgRestaurnat sd_setImageWithURL:[NSURL URLWithString:ResSnnipetImageURL]
                          placeholderImage:[UIImage imageNamed:@"Splash.png"]];
    [self.imgResRating sd_setImageWithURL:[NSURL URLWithString:ResRatingImageURL] placeholderImage:[UIImage imageNamed:@"Splash.png"]];
    
    //check if the restaurant is registered in user database.
    [self.registerMarkImage setImage:[UIImage imageNamed:@"registerMark.png"]];
    self.lblName.text = ResName;
    self.lblAddress.text = ResAddress;
    self.lblCategories.text = ResCategories;
    [self.lblResID setText:ResID];
    [self.lblResID setHidden:YES];
    
    if ([ResReviewCount intValue] == 0) {
        self.lblReviewNumber.text =[NSString stringWithFormat:@"no review"] ;
    }else{
        self.lblReviewNumber.text =[NSString stringWithFormat:@"%@ reviews", ResReviewCount] ;
    }
    self.txtViewSnippetText.text = ResSnippetText;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)goSideMenu:(UIButton *)sender {
    [self.navigationController.revealViewController rightRevealToggle:nil];
}
- (IBAction)goToSite:(UIButton *)sender {
    if (ResMobileURL) {
        self.webViewVC = [[webViewController alloc]initWithNibName:@"webViewController" bundle:nil];
        self.webViewVC.url = ResMobileURL;
        [self.navigationController pushViewController:self.webViewVC animated:YES];
    }
    
}

@end
