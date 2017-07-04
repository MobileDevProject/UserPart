
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UserInfo : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *photoURL;
@property (nonatomic, copy) NSString *membership;
@property (nonatomic, copy) NSString *cardCVID;
@property (nonatomic, copy) NSString *cardDate;
@property (nonatomic, copy) NSString *cardNumber;
@property (nonatomic, copy) NSMutableArray *payData;
@property (nonatomic, copy) NSDate *dateCycleStart;
@property (nonatomic) int numberOfCoupons;
@property (nonatomic) BOOL isCancelled;

- (instancetype) initWithDictionary:(NSDictionary*) dict;
@end
