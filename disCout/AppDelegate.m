
#import "SWRevealViewController.h"
#import "actvatedRestaurantListViewController.h"
#import "LocationMapOfRestaurants.h"
#import "SearchViewController.h"
#import "MapViewController.h"
#import "NHNetworkClock.h"
#import "AppDelegate.h"

@interface AppDelegate ()



@end



@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [FIRApp configure];
    [[NHNetworkClock sharedNetworkClock] synchronize];
//    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction: @"access_token$sandbox$zgrh228hyxstypw8$6b17be511257d0b2c1af1718b3728d78", PayPalEnvironmentSandbox : @"cal.j@yandex.com"}];
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"AbgxN7fmfy2rca5rbVfzYcYieyvdGr71QkgvDR2CTW9D-HxcJaUTBPzTUPaI9ckYi7-8D1YSwylSDyUo",
                                                           PayPalEnvironmentSandbox : @"AXj0jzKZzl3guDk375m8FZUtAQVU_XBw2W_4AfuQUXjJ1HJTEFsrm-pQ_-yOigDgDNnMoDjkQBZw95WJ"}];
    _dicRestaurantData = [[NSDictionary alloc]init];
    self.arrPayDictinaryData = [[NSMutableArray alloc]init];
    //self.dicSearchedDictionaryRestaurantData = [[NSDictionary alloc] init];
    self.boolOncePassed = false;
    self.scannedCode = @"";
    //init condition
    self.intSearchOption1 = 1;
    self.intSearchOption2 = 1;
    //1. init Cuisign type
    self.arrCuisine = [[NSArray alloc]initWithObjects:@"All", @"Mexican",@"Fast Food", @"Deli", @"Burgers", @"Pizza", @"American (Traditional)", @"Chinese", @"Chicken Wings", @"Seafood", @"Bars", @"Breakfast & Brunch", @"Italian", @"American (New)", @"Tex-Mex", @"Barbeque", @"Vietnamese", @"Cajun/Creole", @"Food Trucks", @"Latin American", @"Mediterranean", @"European", @"Thai", @"Indian", @"Asian", @"Sushi", @"Vegetarian", @"Steakhouse", nil];
    self.user = [[UserInfo alloc]init];
    //init selected cuisine type
    self.arrSelectedCuisine = [[NSMutableArray alloc]init];
    for (int index = 0; index < self.arrCuisine.count; index++) {
        
        [self.arrSelectedCuisine addObject:@"1"];
        
    }
    [self.arrSelectedCuisine setObject:@"1" atIndexedSubscript:self.arrSelectedCuisine.count];
    // Add this if you only want to change Selected Image color
    NSLog(@"System Version is %@",[[UIDevice currentDevice] systemVersion]);
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    if (ver_float >= 10.0) {
        [[UITabBar appearance] setUnselectedItemTintColor:[UIColor colorWithRed:243/255.0 green:101/255.0 blue:35/255.0 alpha:1.0]];
    }else{
        [[UIView appearanceWhenContainedInInstancesOfClasses:[[NSArray alloc] initWithObjects:[UITabBar class],nil]] setTintColor:[UIColor colorWithRed:243/255.0 green:101/255.0 blue:35/255.0 alpha:1.0]];
        [UITabBar appearance].tintColor = [UIColor colorWithRed:243/255.0 green:101/255.0 blue:35/255.0 alpha:1.0];
    }
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:243/255.0 green:101/255.0 blue:35/255.0 alpha:1.0]];
    
    [UITabBarItem.appearance setTitleTextAttributes:
     @{NSForegroundColorAttributeName : [UIColor colorWithRed:243/255.0 green:101/255.0 blue:35/255.0 alpha:1.0]}
                                           forState:UIControlStateNormal];
    
    
    // then if StateSelected should be different, you should add this code
    [UITabBarItem.appearance setTitleTextAttributes:
     @{
       NSFontAttributeName: [UIFont fontWithName:@"Avenir Next LT Pro" size:10],
       NSForegroundColorAttributeName: [UIColor colorWithRed:243/255.0 green:101/255.0 blue:35/255.0 alpha:1.0]
       } forState:UIControlStateSelected];
    [UITabBarItem.appearance setTitleTextAttributes:
     @{
       NSFontAttributeName: [UIFont fontWithName:@"Avenir Next LT Pro" size:10],
       NSForegroundColorAttributeName: [UIColor colorWithRed:243/255.0 green:101/255.0 blue:35/255.0 alpha:1.0]
       } forState:UIControlStateNormal];
    return YES;
}

-(void)addTabBar{
    SWRevealViewController *swRevealViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
    self.window.rootViewController = swRevealViewController;
    [self.window makeKeyAndVisible];
}
- (void)applicationWillResignActive:(UIApplication *)application {

    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
