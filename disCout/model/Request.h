
@import Firebase;
#import <Foundation/Foundation.h>

@interface Request : NSObject
+ (FIRDatabaseReference*)dataref;
+ (FIRStorageReference*)storageref;
+ (FIRUser*)currentUser;
+ (NSString*)currentUserUid;
+ (void)saveUserEmail:email;
+ (void)saveUserName:name;
+ (void)saveUsedCoupon:dateString ResName:ResName;
+ (void)saveNumberOfCoupons:numbers;
+ (NSError*)saveCardInfo:number cvid:cvid date:date membership:membership;
+ (void)cancelMembership;
//+ (NSError)
+ (void)saveRestaurantData:dicRestaurantData;
+ (void)saveUserPhoto:UserPhotoURL;
//+ (void)retrieveAllRestaurantsID;
+ (void)retrieveAllRestaurantsData;


@end
