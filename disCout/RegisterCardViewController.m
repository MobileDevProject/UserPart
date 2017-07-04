
#import "RegisterCardViewController.h"
#import "AppDelegate.h"
@import Firebase;
#import "SWRevealViewController.h"
#import "Request.h"
#import "SignUp.h"
#import "OfferViewController.h"

//payment
#import "PayPalMobile.h"
#import "PayPalConfiguration.h"

@interface RegisterCardViewController ()<PayPalPaymentDelegate>
{
    NSString* memberShip;
    AppDelegate *app;
}

@property (strong, nonatomic) IBOutlet UIButton *button5Membership;
@property (strong, nonatomic) IBOutlet UIButton *button10Membership;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelMembership;
@property (weak, nonatomic) IBOutlet UIScrollView *scrOffer;


//payment
@property(nonatomic, strong)PayPalConfiguration * configration;
@property(nonatomic, strong, readwrite) NSString *environment;

@end

@implementation RegisterCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    app = [UIApplication sharedApplication].delegate;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view setClipsToBounds:YES];
    //selected the btnCheckrate button
    [self.button5Membership setBackgroundImage:[UIImage imageNamed:@"btn_Search_InActive.png"] forState:UIControlStateNormal];
    [self.button5Membership setTintColor:[UIColor colorWithWhite:1 alpha:0]];
    [self.button5Membership setBackgroundImage:[UIImage imageNamed:@"btn_Search_Active.png"] forState:UIControlStateSelected];
    [self.button5Membership setSelected:YES];
    
    [self.button10Membership setBackgroundImage:[UIImage imageNamed:@"btn_Search_InActive.png"] forState:UIControlStateNormal];
    [self.button10Membership setTintColor:[UIColor colorWithWhite:1 alpha:0]];
    [self.button10Membership setBackgroundImage:[UIImage imageNamed:@"btn_Search_Active.png"] forState:UIControlStateSelected];
    [self.button10Membership setSelected:NO];

    [self.btnCancelMembership setHidden:YES];
    [self.btnRegister setHidden:NO];
    [self.scrOffer sizeToFit];

    memberShip = @"5";
    
    
    //payment
    _configration = [[PayPalConfiguration alloc]init];
    _configration.acceptCreditCards = YES;
    _configration.merchantName = @"discOut.com";
    _configration.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.webapps/mpp/ua/privacy-full"];
    _configration.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.webapps/mpp/ua/useragreement-full"];
    _configration.languageOrLocale = [NSLocale preferredLanguages][0];
    _configration.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
    NSLog(@"PAY PAL SDK: %@", [PayPalMobile libraryVersion]);
    
    self.environment = @"live";
    [self setPayPalEnvironment:self.environment];
    
    self.scrOffer.contentSize = CGSizeMake(self.scrOffer.contentSize.width,self.scrOffer.frame.size.height);
}
- (void) viewWillAppear:(BOOL)animated{
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
}
- (void)setPayPalEnvironment:(NSString *)environment {
    [PayPalMobile preconnectWithEnvironment:environment];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - PayPalSDKDelegate Methods
-(void)payPalPaymentDidCancel:(PayPalPaymentViewController*)paymentViewController
{
    NSLog(@"PayPal Payment Cancel!");
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment{
    
    
    FIRDatabaseReference* ref = [[[[[FIRDatabase database] reference] child:@"users"]child:app.user.userId] child:@"general info"];
    //register date
    NSURL *url = [NSURL URLWithString:@"http://www.timeapi.org/utc/now"];
    NSString *str = [[NSString alloc] initWithContentsOfURL:url usedEncoding:Nil error:Nil];
    
    str = [str stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    str = [str stringByReplacingOccurrencesOfString:@"+00:00" withString:@""];
    NSString* numberOfCoupons ;
    if (completedPayment.amount.integerValue >= 5 && completedPayment.amount.integerValue <10) {
        numberOfCoupons = @"10";
    }else if (completedPayment.amount.integerValue >= 10){
        numberOfCoupons = @"25";
    }
    //save payment data
    NSString* datetext = [NSString stringWithFormat:@"%@_%@_%@", [str substringWithRange:NSMakeRange(0, 4)], [str substringWithRange:NSMakeRange(5, 2)], [str substringWithRange:NSMakeRange(8, 2)]];
    
    NSDictionary* commentDict  = @{
                                   @"dateCycleStart":str,
                                   @"iscancelled":@"false",
                                   @"numberOfCoupons":numberOfCoupons
                                   };
    //write
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [ref updateChildValues:commentDict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    UIAlertController * loginErrorAlert = [UIAlertController
                                                           alertControllerWithTitle:@"PayPal Payment Success"
                                                           message:@""
                                                           preferredStyle:UIAlertControllerStyleAlert];
                    
                    [self presentViewController:loginErrorAlert animated:YES completion:nil];
                    
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    }];
                    
                    [loginErrorAlert addAction:ok];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    UIAlertController * loginErrorAlert = [UIAlertController
                                                           alertControllerWithTitle:@"Cannot register the payment info"
                                                           message:error.localizedDescription
                                                           preferredStyle:UIAlertControllerStyleAlert];
                    
                    [self presentViewController:loginErrorAlert animated:YES completion:nil];
                    
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    }];
                    
                    [loginErrorAlert addAction:ok];
                }
                
                
            });
        }];
    });
    
}
//#pragma mark - PayPalFuturePaymentDelegate Methods
//-(void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization{
//    
//}
//-(void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController{
//    
//}
//-(void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController willAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization completionBlock:(PayPalFuturePaymentDelegateCompletionBlock)completionBlock{
//    
//}
#pragma mark - select membership
- (IBAction)set5Membership:(UIButton *)sender {
    memberShip = @"5";
    [self.button10Membership setSelected:NO];
    [sender setSelected:YES];
    
}
- (IBAction)set10Membership:(UIButton *)sender {
    memberShip = @"10";
    [self.button5Membership setSelected:NO];
    [sender setSelected:YES];
    
}
- (IBAction)cancelMembership:(UIButton *)sender {
    NSString *membership;
    if (self.button5Membership.selected) {
        membership = @"5";
    }else{
        membership = @"10";
    }
    UIAlertController * loginErrorAlert = [UIAlertController
                                           alertControllerWithTitle:@"Cancel Membership"
                                           message:@"Are you sure cancel your membership?"
                                           preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:loginErrorAlert animated:YES completion:nil];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
        [Request saveCardInfo:@"" cvid:@"" date:@"" membership:@""];
        [Request cancelMembership];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [loginErrorAlert addAction:ok];
    [loginErrorAlert addAction:cancel];
}

#pragma mark - Pay
-(void)oncePay: (NSString*)membership{
    PayPalItem *item1 = [PayPalItem itemWithName:[NSString stringWithFormat:@"%@", app.user.name] withQuantity:1 withPrice:[NSDecimalNumber decimalNumberWithString:membership] withCurrency:@"USD" withSku:@"membership"];

    NSArray *items = @[item1];
    NSDecimalNumber * subTotal = [PayPalItem totalPriceForItems:items];
    NSDecimalNumber *shipping = [[NSDecimalNumber alloc]initWithString:@"0"];
    NSDecimalNumber *tax = [[NSDecimalNumber alloc]initWithString:@"0"];
    PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subTotal withShipping:shipping withTax:tax];
    NSDecimalNumber* total = [[subTotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];
    PayPalPayment* payment = [[PayPalPayment alloc]init];
    payment.amount = total;
    payment.currencyCode = @"USD";
    
    payment.shortDescription = @"My Payment";
    payment.items = items;
    payment.paymentDetails = paymentDetails;
    if (payment.processable) {
        PayPalPaymentViewController* paymentViewController = [[PayPalPaymentViewController alloc]initWithPayment:payment configuration:self.configration delegate:self];
        
        //PayPalFuturePaymentViewController* paymentViewController = [[PayPalFuturePaymentViewController alloc]initWithConfiguration:_configration delegate:self];
        [self presentViewController:paymentViewController animated:YES completion:nil];
    }
    
}
- (IBAction)registerCard:(UIButton *)sender {
    //app = [UIApplication sharedApplication].delegate;
    
    //please check  1. user is signup on your app?
    //              2. user's membership is cancelled?
    //              3. in user's card is there any money as adequate as membership?
    
    if ([FIRAuth auth].currentUser.isAnonymous){
        UIAlertController * loginErrorAlert = [UIAlertController
                                               alertControllerWithTitle:@"you need to login"
                                               message:@"you can use the coupon with your own account."
                                               preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:loginErrorAlert animated:YES completion:nil];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        }];
        
        [loginErrorAlert addAction:ok];
    }else {//1. signup?
        if (app.user.isCancelled || app.user.numberOfCoupons==0) {//cycle start day check
            [self oncePay:memberShip];
        }else{
            UIAlertController * loginErrorAlert = [UIAlertController
                                                   alertControllerWithTitle:@"Please check"
                                                   message:@"1. your payment cycle.\n2. there is no coupon."
                                                   preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:loginErrorAlert animated:YES completion:nil];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            }];
            
            [loginErrorAlert addAction:ok];
        }
        
    }
    
    
}

#pragma mark - go side
- (IBAction)goSlide:(UIButton *)sender {
    [self.revealViewController rightRevealToggle:nil];
}

@end
