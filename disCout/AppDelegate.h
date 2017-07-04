
#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "PayPalMobile.h"
@import Firebase;

@interface AppDelegate : UIResponder <UIApplicationDelegate>


//search result
@property (strong, nonatomic)UIWindow *window;
@property (nonatomic,retain)NSDictionary *dicRestaurantData;
@property (nonatomic)int selectedResNumberFromResList;
//@property (nonatomic,retain)NSDictionary *dicSearchedDictionaryRestaurantData;
@property (nonatomic,retain)NSMutableArray *arrSearchedDictinaryRestaurantData;
@property (nonatomic,retain)NSMutableArray *arrTempSearchedDictinaryRestaurantData;
@property (nonatomic,retain)NSMutableArray *arrRegisteredDictinaryRestaurantData;
@property (nonatomic,retain)NSMutableArray *arrPayDictinaryData;//dic->user, user->paydate and payamount

@property(nonatomic, retain) UITabBarController *MyTabBarController;

//they are moved into Backend
//@property (nonatomic,retain)NSArray *arrSearchedRestaurants;
@property(nonatomic, retain)NSArray* arrCuisine;
@property(nonatomic)BOOL isSelectedAllCuisine;

//temp array and variables
@property(nonatomic, retain)NSMutableArray* arrSelectedCuisine;

//user info
@property(nonatomic, retain) NSString *UserName;
@property(nonatomic, retain) NSString *UserID;
@property(nonatomic, retain) NSString *UserPhotoURL;
@property(nonatomic, retain) UserInfo *user;
@property(nonatomic, retain) NSError* Acterror;

//search
@property(nonatomic)int intSearchOption1;
@property(nonatomic)int intSearchOption2;
@property (nonatomic, retain)NSString *term;
@property (nonatomic, retain)NSString *location;
@property(nonatomic)BOOL IsMatch;

//manager mail
@property (nonatomic, retain)NSString *managerMail;
@property (nonatomic) BOOL boolOncePassed;
@property (nonatomic, retain) NSString *scannedCode;

//location
@property (nonatomic) float myLatitude;
@property (nonatomic) float mylongitued;

-(void)addTabBar;
@end

