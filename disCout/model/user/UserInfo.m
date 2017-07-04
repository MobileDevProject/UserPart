
#import "UserInfo.h"


@implementation UserInfo

- (instancetype) initWithDictionary:(NSDictionary*) dict {

    self = [super init];
    
    if (self) {
        self.userId = dict[@"id"];
        self.email = dict[@"email"];
        self.name = dict[@"name"];
        self.photoURL = dict[@"photo URL"];
        self.membership = dict[@"membership"] ? dict[@"membership"] : nil;
        self.cardCVID = dict[@"card cvid"] ? dict[@"card cvid"] : nil;
        self.cardDate = dict[@"card date"] ? dict[@"card date"] : nil;
        self.cardNumber = dict[@"card number"] ? dict[@"card number"] : nil;
        self.payData = dict[@"pay info"] ? dict[@"pay info"] : nil;
        self.isCancelled = dict[@"isCancelled"];
        self.numberOfCoupons = dict[@"numberOfCoupons"];
    }
    
    return self;
}



@end
