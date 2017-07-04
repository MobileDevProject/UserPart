
#import "AppDelegate.h"
#import "Request.h"
#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"
#import "useCouponViewController.h"
#import "actvatedRestaurantListViewController.h"
#import "NHNetworkTime.h"

@interface useCouponViewController () <QRCodeReaderDelegate>
{
    AppDelegate *app;
    NSString *ResID;
}
@end

@implementation useCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    app = [UIApplication sharedApplication].delegate;
    [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"Coupone_Active.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBarItem setImage:[[UIImage imageNamed:@"Coupone_InActive.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBarItem setTitle:@"Coupon"];
    [self.tabBarItem setTitleTextAttributes:@{
                                              NSFontAttributeName: [UIFont fontWithName:@"Avenir Next LT Pro" size:10],
                                              NSForegroundColorAttributeName: [UIColor colorWithRed:243/255.0 green:101/255.0 blue:35/255.0 alpha:1.0]
                                              } forState:UIControlStateNormal];
    [self.tabBarItem setTitleTextAttributes:@{
                                              NSFontAttributeName: [UIFont fontWithName:@"Avenir Next LT Pro" size:10],
                                              NSForegroundColorAttributeName: [UIColor colorWithRed:243/255.0 green:101/255.0 blue:35/255.0 alpha:1.0]
                                              } forState:UIControlStateSelected];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{

        [self scanAction];
    
}

#pragma mark - Scan QR code
- (void)scanAction
{
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *vc = nil;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            vc                   = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        vc.delegate = self;
        
        [vc setCompletionWithBlock:^(NSString *resultAsString) {
            NSLog(@"Completion with result: %@", resultAsString);
        }];
        
        //[self presentViewController:vc animated:YES completion:NULL];
        [self.navigationController pushViewController:vc animated:NO];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Reader not supported by the current device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    app.scannedCode = result;
    [self useCoupon:result];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self.navigationController popViewControllerAnimated:NO];
}


/*
 #pragma mark - type ID
- (IBAction)typeID:(UIButton *)sender {
    
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"RESTAURANT ID"
                                                                                  message: @"Input the RESTAURANT ID"
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Restaurant ID";
            textField.textColor = [UIColor blackColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            
        }];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray * textfields = alertController.textFields;
            UITextField * resIDTextField = textfields[0];
            ResID = resIDTextField.text;
            [self useCoupon:ResID];
            [alertController dismissViewControllerAnimated:YES completion:nil];
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    
}
*/
-(void)useCoupon: (NSString*)resID{
    
    if ([FIRAuth auth].currentUser.isAnonymous){
        UIAlertController * loginErrorAlert = [UIAlertController
                                               alertControllerWithTitle:@"you need to login"
                                               message:@"you can use the coupon with your own account."
                                               preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:loginErrorAlert animated:YES completion:nil];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        }];
        
        [loginErrorAlert addAction:ok];
    }else {
        UIAlertController * loginErrorAlert = [UIAlertController
                                               alertControllerWithTitle:@"Use Coupon"
                                               message:[NSString stringWithFormat:@"Are sure use Coupon?\nUsed Coupons: %d", app.user.numberOfCoupons + 1]
                                               preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:loginErrorAlert animated:YES completion:nil];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"resid ==[c] %@", resID];
            NSArray* arrSearchedRes = [[NSArray alloc]initWithArray:[app.arrRegisteredDictinaryRestaurantData filteredArrayUsingPredicate:predicate]];
            if (arrSearchedRes.count > 0) {
                //count down user's number of coupons
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:arrSearchedRes.firstObject];
                int numberOfCouponsRes = [[dic objectForKey:@"numberOfCoupons"] intValue] + 1;
                app.user.numberOfCoupons = app.user.numberOfCoupons + 1;
                NSString *ResName = [dic objectForKey:@"name"];
                
                //count up restaurant's number of coupons
                
                [dic setValue:[NSString stringWithFormat:@"%d", numberOfCouponsRes] forKey:@"numberOfCoupons"];
                FIRDatabaseReference* savedResData = [[[[FIRDatabase database] reference]child:@"restaurants"] child:ResName];
                [savedResData setValue:dic];
                [app.arrRegisteredDictinaryRestaurantData addObject:dic];
                
                //register date
                NSString* datetext = [self string_from_date:[NSDate networkDate]];
                [Request saveUsedCoupon:datetext ResName:ResName];
            }else{
                UIAlertController * loginErrorAlert = [UIAlertController
                                                       alertControllerWithTitle:@"Invalid ID"
                                                       message:@"Please enter the correct ID"
                                                       preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:loginErrorAlert animated:YES completion:nil];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
                    [self viewDidLoad];
                    
                }];
                [loginErrorAlert addAction:ok];
                
            }
            
            [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
            //[self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
        }];
        [loginErrorAlert addAction:ok];
        [loginErrorAlert addAction:cancel];
        
    }

    
    
   
}

-(NSDate*)date_from_string: (NSString*)string{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM_dd_yyyy_HH_mm_ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
    NSDate *dateReturn = [dateFormatter dateFromString:string];
    return dateReturn;
}

-(NSString*)string_from_date: (NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"MM_dd_yyyy_HH_mm_ss"];
    NSString *strReturn = [dateFormatter stringFromDate:date];
    return strReturn;
}


@end
