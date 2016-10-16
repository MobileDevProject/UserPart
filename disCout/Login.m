//
//  Login.m
//  disCout
//
//  Created by Theodor Hedin on 7/20/16.
//  Copyright © 2016 THedin. All rights reserved.
//
#import "Request.h"
#import "Login.h"
#import "SignUp.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
@import Firebase;
@import FirebaseDatabase;
@interface Login ()<UITextFieldDelegate>

{
    int childCount;
}

@property (weak, nonatomic) IBOutlet UITextField *txtFieldEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (weak, nonatomic) IBOutlet UIButton *btnSignWithFacebook;





@end

@implementation Login

-(void)viewDidLoad{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    //[Request retrieveAllRestaurantsID];
    NSDictionary * attributes = (NSMutableDictionary *)[ (NSAttributedString *)self.txtFieldEmail.attributedPlaceholder attributesAtIndex:0 effectiveRange:NULL];
    NSMutableDictionary * newAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    [newAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.txtFieldEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.txtFieldEmail.attributedPlaceholder string] attributes:newAttributes];
    self.txtFieldPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.txtFieldPassword.attributedPlaceholder string] attributes:newAttributes];
    FIRUser *user = [Request currentUser];
    if (user !=nil) {
        ///////////////***********************************************************************************
        //Manager Module
        NSString *email = [Request currentUser].email;
        app.isManager = NO;
        if ([email isEqualToString:@"mera.lahid@yandex.com"]) {
            app.isManager = YES;
            
            [self loadResDataAndGo];
        }
        //[self loadUserDataAndGo];
        ///////////////***********************************************************************************
        
        
        
    }else{

    }

}


- (IBAction)goFromLogin:(id)sender {

    
    
    NSString *strUserEmail = _txtFieldEmail.text;
    NSString *strUserPass = _txtFieldPassword.text;
    
    [self playSound:@"m3"];
    // [START headless_email_auth]
    
    if ([strUserEmail isEqual:@""] && [strUserPass isEqual:@""]) {
        UIAlertController * loginErrorAlert = [UIAlertController
                                               alertControllerWithTitle:@"Invalid name and password"
                                               message:@"Please enter the UserName and Password."
                                               preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:loginErrorAlert animated:YES completion:nil];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSLog(@"reset password cancelled.");
            [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
        }];
        [loginErrorAlert addAction:ok];
        
    } else if ([strUserEmail isEqual:@""]) {
        
        UIAlertController * loginErrorAlert = [UIAlertController
                                               alertControllerWithTitle:@"Invalid username or email"
                                               message:@"Please enter the UserName."
                                               preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:loginErrorAlert animated:YES completion:nil];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
        }];
        [loginErrorAlert addAction:ok];
        
    } else if([strUserPass isEqual:@""]) {
        
        UIAlertController * loginErrorAlert = [UIAlertController
                                               alertControllerWithTitle:@"Invalid password"
                                               message:@"Please enter the Password."
                                               preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:loginErrorAlert animated:YES completion:nil];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
        }];
        [loginErrorAlert addAction:ok];
    } else{
        // [START headless_email_auth]
        [self.view setUserInteractionEnabled:NO];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do something...
            
            [[FIRAuth auth] signInWithEmail:strUserEmail
                                   password:strUserPass
                                 completion:^(FIRUser *user, NSError *error) {
                                     
                                     
                                     // [START_EXCLUDE]
                                     if (error != nil) {
                                         UIAlertController * loginErrorAlert = [UIAlertController
                                                                                alertControllerWithTitle:@"Login Failed"
                                                                                message:@"Authorization was not granted for the given email and password. Please checke for errors and try again."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                                         [self presentViewController:loginErrorAlert animated:YES completion:nil];
                                         UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                                             [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
                                         }];
                                         [loginErrorAlert addAction:ok];
                                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                                         [self.view setUserInteractionEnabled:YES];
                                     }
                                     else
                                     {
                                         
                                         FIRAuthCredential *credential = [FIREmailPasswordAuthProvider credentialWithEmail:strUserEmail password:strUserPass];
                                         [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * user, NSError * error) {
                                             
                                             if (error==nil) {
                                                 
                                                 //[self loadUserDataAndGo];
                                             }
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{///////
                                                 

                                                 if (error==nil) {
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];/////
                                                     [self.view setUserInteractionEnabled:YES];
                                                     NSString *email = [Request currentUser].email;
                                                     AppDelegate *app = [UIApplication sharedApplication].delegate;
                                                     app.isManager = NO;
                                                     if ([email isEqualToString:@"mera.lahid@yandex.com"]) {
                                                         app.isManager = YES;
                                                         [self loadResDataAndGo];
                                                     }
                                                     //[self loadUserDataAndGo];
                                                 }
                                             });
                                             //after progress
                                         }];
                                         
                                         //NSLog(@"succeed login");
                                     }
                                     
                                     // [END_EXCLUDE]
                                 }];
        });//Add MBProgressBar (dispatch)
        
        // [END headless_email_auth]
    }
    
    
}
- (IBAction)goSignUp:(id)sender {
    
    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    SignUp *signUp = [storyboard instantiateViewControllerWithIdentifier:@"SignUp"];
                    [self.navigationController pushViewController:signUp animated:YES];
   
    
}

- (IBAction)didRequestPasswordReset:(UIButton *)sender {
    
    
    UIAlertController *requestResetPass = [UIAlertController
                                            alertControllerWithTitle:@"Reset Password"
                                            message:@"are you sure want reset your password?"
                                            preferredStyle:UIAlertControllerStyleAlert];
    

    UIAlertAction *prompt = [UIAlertAction actionWithTitle:@"reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *emailTextField = requestResetPass.textFields.firstObject;
        NSString* email = emailTextField.text;
        if ([email isEqualToString:@""]) {
            [requestResetPass dismissViewControllerAnimated:YES completion:nil];
        }
        [[FIRAuth auth] sendPasswordResetWithEmail:(email) completion:^(NSError *error){
            if (error) {
                NSLog(@"%@-%ld",error.localizedDescription, (long)error.code);
            }
            else
            {
                NSLog(@"request is sent to your email");
            }
        }];
        [requestResetPass dismissViewControllerAnimated:YES completion:nil];
        
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSLog(@"reset password cancelled.");
        [requestResetPass dismissViewControllerAnimated:YES completion:nil];
        
    }];
    [requestResetPass addAction:prompt];
    [requestResetPass addAction:cancel];
    [requestResetPass addTextFieldWithConfigurationHandler:^(UITextField *emailText){
        emailText.placeholder = NSLocalizedString(@"email", "Address");
    }];
    
    [self presentViewController:requestResetPass animated:YES completion:nil];
                                           
    
    
}

-(void)playSound:fileName{
    
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundPath], &soundID);
    AudioServicesPlaySystemSound(soundID);
    
}

- (IBAction)SignSkip:(UIButton *)sender {
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    [app addTabBar];


}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // do whatever you have to do
    
    [textField resignFirstResponder];
    return YES;
}
- (void) drawPlaceholderInRect:(CGRect)rect{
    [[UIColor whiteColor] setFill];
    //[[self placeholder] drawInRect:rect withFont:[UIFont systemFontOfSize:16]];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [self.view setUserInteractionEnabled:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUserDataAndGo{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.user.userId = [NSString stringWithFormat:@"%@", [Request currentUserUid]];
    NSString *userID = app.user.userId;
    app.arrPayDictinaryData = [[NSMutableArray alloc]init];

    childCount = 1;
    [self.view setUserInteractionEnabled:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        FIRDatabaseReference *refGeneralInfo = [[[[Request dataref] child:@"users"]child: userID]child:@"general info"];
        //FIRDatabaseReference *ref = [Request dataref];
        [refGeneralInfo observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            if (snapshot!=nil) {
                app.user.name = [(NSDictionary*)(snapshot.value) objectForKey:@"name"];
                app.user.userId = userID;
                app.user.email = [(NSDictionary*)(snapshot.value) objectForKey:@"email"];
                app.user.photoURL = [NSURL URLWithString:[(NSDictionary*)(snapshot.value) objectForKey:@"photourl"]];
                app.user.membership = [(NSDictionary*)(snapshot.value) objectForKey:@"membership"];
                app.user.cardCVID = [(NSDictionary*)(snapshot.value) objectForKey:@"cardcvid"];
                app.user.cardDate = [(NSDictionary*)(snapshot.value) objectForKey:@"carddate"];
                app.user.cardNumber = [(NSDictionary*)(snapshot.value) objectForKey:@"cardnumber"];
                app.user.isCancelled = [(NSDictionary*)(snapshot.value) objectForKey:@"iscancelled"];
            }
            
        }];
        
        FIRDatabaseReference* refPay = [[[FIRDatabase database] reference] child:@"users"];
        [self loadResData];
        [refPay observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary*dic = snapshot.value;
            NSArray *keys;
            if (![dic isKindOfClass:[NSNull class]]) {
                keys = dic.allKeys;
            }
            
            
                NSDictionary *payData = [[dic objectForKey:[Request currentUserUid]] objectForKey:@"pay info"];
                NSString *userName = (NSString*)[[[dic objectForKey:[Request currentUserUid]] objectForKey:@"general info"] objectForKey:@"name"];
                NSDictionary* PersonPayData = [[NSDictionary alloc]initWithObjectsAndKeys:userName, @"name", payData,@"pay info", nil];
                [app.arrPayDictinaryData addObject:PersonPayData];
            dispatch_async(dispatch_get_main_queue(), ^{
                //go maim workspace
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.view setUserInteractionEnabled:YES];
                [app addTabBar];
            });
        }];

    });

    

}

-(void)loadResData{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.arrRegisteredDictinaryRestaurantData = [[NSMutableArray alloc]init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //get all restaurant info
        FIRDatabaseReference* ref = [[[FIRDatabase database] reference] child:@"restaurants"];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary*dic = snapshot.value;
            
            NSArray *keys;
            if (![dic isKindOfClass:[NSNull class]]) {
                keys = dic.allKeys;
            }
            //////////////////////////////////////___correct
            for (int countData = 0;keys.count>countData;countData++) {
                NSDictionary *restaurantData = [dic objectForKey:[keys objectAtIndex:countData]];
                [app.arrRegisteredDictinaryRestaurantData addObject:restaurantData];
            }
        }];

    });
    
    

}

- (void)loadResDataAndGo{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.arrRegisteredDictinaryRestaurantData = [[NSMutableArray alloc]init];
    app.arrPayDictinaryData = [[NSMutableArray alloc]init];
    [self.view setUserInteractionEnabled:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //get all restaurant info
            FIRDatabaseReference* ref = [[[FIRDatabase database] reference] child:@"restaurants"];
            [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                NSDictionary*dic = snapshot.value;
                
                NSArray *keys;
                if (![dic isKindOfClass:[NSNull class]]) {
                    keys = dic.allKeys;
                }
                //////////////////////////////////////___correct
                for (int countData = 0;keys.count>countData;countData++) {
                    NSDictionary *restaurantData = [dic objectForKey:[keys objectAtIndex:countData]];
                    [app.arrRegisteredDictinaryRestaurantData addObject:restaurantData];
                }
            }];
            
            
            //get all users' payment info
            FIRDatabaseReference* refPay = [[[FIRDatabase database] reference] child:@"users"];

            [refPay observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                NSDictionary*dic = snapshot.value;
                NSArray *keys;
                if (![dic isKindOfClass:[NSNull class]]) {
                    keys = dic.allKeys;
                }
                
                for (int countData = 0;keys.count>countData;countData++) {
                    NSDictionary *payData = [[dic objectForKey:[keys objectAtIndex:countData]] objectForKey:@"pay info"];
                    NSString *userName = (NSString*)[[[dic objectForKey:[keys objectAtIndex:countData]] objectForKey:@"general info"] objectForKey:@"name"];
                    NSDictionary* PersonPayData = [[NSDictionary alloc]initWithObjectsAndKeys:userName, @"name", payData,@"pay info", nil];
                    [app.arrPayDictinaryData addObject:PersonPayData];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    //go maim workspace
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.view setUserInteractionEnabled:YES];
                    [app addTabBar];
                });
            }];
        });
    
    
}



@end