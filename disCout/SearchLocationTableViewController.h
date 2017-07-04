
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SearchLocationTableViewController : UITableViewController<CLLocationManagerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *places;

@end
