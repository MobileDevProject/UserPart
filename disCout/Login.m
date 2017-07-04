
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
    AppDelegate *app;
    int childCount;
}

@property (weak, nonatomic) IBOutlet UITextField *txtFieldEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (weak, nonatomic) IBOutlet UIButton *btnSignWithFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btnDismissKeyboard;

@end

@implementation Login

#pragma mark - set environment
-(void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [self.btnDismissKeyboard setHidden:YES];

}

//keyboard show/hidden
- (IBAction)hideKeyboard:(UIButton *)sender {
    [self.view endEditing:YES];
}
- (void)keyboardWasShown:(NSNotification *)aNotification {
    [self.btnDismissKeyboard setHidden:NO];
}
- (void)keyboardBeHidden:(NSNotification *)aNotification {
    
    [self.btnDismissKeyboard setHidden:YES];
}
- (void) drawPlaceholderInRect:(CGRect)rect{
    
    [[UIColor whiteColor] setFill];

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if (textField.tag == 101) {
        
        [(UITextField*)[self.view viewWithTag:102] becomeFirstResponder];
        return YES;
    }else if(textField.tag == 102){
        [textField resignFirstResponder];
        [self goFromLogin:nil];
        return YES;
        
        
    }
    [textField resignFirstResponder];
    return YES;
    
}

#pragma mark - check last login and go main view
- (void)viewWillAppear:(BOOL)animated{
    [self.view setUserInteractionEnabled:YES];
    app = [UIApplication sharedApplication].delegate;
    
    NSDictionary * attributes = (NSMutableDictionary *)[ (NSAttributedString *)self.txtFieldEmail.attributedPlaceholder attributesAtIndex:0 effectiveRange:NULL];
    NSMutableDictionary * newAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    [newAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.txtFieldEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.txtFieldEmail.attributedPlaceholder string] attributes:newAttributes];
    self.txtFieldPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.txtFieldPassword.attributedPlaceholder string] attributes:newAttributes];
    FIRUser *user = [Request currentUser];
    if (user !=nil && !user.anonymous) {
        
        [self.view setUserInteractionEnabled:NO];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        //get manager data
        app.user.userId = [NSString stringWithFormat:@"%@", [Request currentUserUid]];
        NSString *userID = app.user.userId;
        FIRDatabaseReference *refManagerInfor = [[[Request dataref] child:@"users"]child: userID];
        //FIRDatabaseReference *ref = [Request dataref];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [refManagerInfor observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                if (snapshot.exists) {
                    NSDictionary *dic = [snapshot.value objectForKey:@"general info"];
                    app.user.name = [dic objectForKey:@"name"];
                    app.user.userId = userID;
                    app.user.email = [dic objectForKey:@"email"];
                    app.user.photoURL = [NSURL URLWithString:[dic objectForKey:@"photourl"]];
                    app.user.cardCVID = [dic objectForKey:@"cardcvid"];
                    app.user.cardDate = [dic objectForKey:@"carddate"];
                    
                    app.user.cardNumber = [dic objectForKey:@"cardnumber"];
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                    [dateFormatter setTimeZone:gmt];
                    app.user.dateCycleStart = [[NSDate alloc]init];
                    app.user.dateCycleStart  = [dateFormatter dateFromString:(NSString*)[dic objectForKey:@"dateCycleStart"]];
                    int numberOfMonths = [self checkDateInterval:app.user.dateCycleStart];
                    NSString *isCancelled = [dic objectForKey:@"iscancelled"];
                    if (numberOfMonths >= 1) {
                        isCancelled = @"true";
                    }else{
                        isCancelled = @"false";
                    }
                    
                    app.user.numberOfCoupons = [[dic objectForKey:@"numberOfCoupons"] intValue];
                    app.user.isCancelled = [isCancelled boolValue];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //go maim workspace
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self.view setUserInteractionEnabled:YES];
                        [self loadResData];
                        [self loadPayData];
                        [MBProgressHUD hideHUDForView:self.view animated:YES];/////
                        [self.view setUserInteractionEnabled:YES];
                    });
                    
                }else{
                    UIAlertController * loginErrorAlert = [UIAlertController
                                                           alertControllerWithTitle:@"Cannot find your info"
                                                           message:@"cannot access your info. please check your membership."
                                                           preferredStyle:UIAlertControllerStyleAlert];
                    [self presentViewController:loginErrorAlert animated:YES completion:nil];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self.view setUserInteractionEnabled:YES];
                        [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
                    }];
                    [loginErrorAlert addAction:ok];
                    
                }
                
            }withCancelBlock:^(NSError * _Nonnull error) {
                UIAlertController * loginErrorAlert = [UIAlertController
                                                       alertControllerWithTitle:@"Cannot find your info"
                                                       message:error.localizedDescription
                                                       preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:loginErrorAlert animated:YES completion:nil];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.view setUserInteractionEnabled:YES];
                    [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
                }];
                [loginErrorAlert addAction:ok];
            }];
            
        });
        
    }
    
}

#pragma mark - login
- (IBAction)goFromLogin:(id)sender {

    [self.view endEditing:YES];
    
    NSString *strUserEmail = _txtFieldEmail.text;
    NSString *strUserPass = _txtFieldPassword.text;
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
                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                                             [self.view setUserInteractionEnabled:YES];
                                             [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
                                         [loginErrorAlert addAction:ok];
                                         NSError *error1;
                                         [[FIRAuth auth] signOut:&error1];
                                     }
                                     else
                                     {
                                         
                                         FIRAuthCredential *credential = [FIREmailPasswordAuthProvider credentialWithEmail:strUserEmail password:strUserPass];
                                         [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * user, NSError * error) {
                                             
                                             
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{///////
                                                 

                                                 if (error==nil) {
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];/////
                                                     [self.view setUserInteractionEnabled:YES];
                                                     [self loadUserDataAndGo];
                                                     
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

#pragma mark - reset password
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

#pragma mark - sign skip and go main view
- (IBAction)SignSkip:(UIButton *)sender {
    
    // go to main view
    [self.view setUserInteractionEnabled:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser  * _Nullable user, NSError  * _Nullable error) {
            
            // [START_EXCLUDE]
            if (error != nil) {
                UIAlertController * loginErrorAlert = [UIAlertController
                                                       alertControllerWithTitle:@"Login Failed"
                                                       message:error.localizedDescription
                                                       preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:loginErrorAlert animated:YES completion:nil];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
                }];
                [loginErrorAlert addAction:ok];
                [MBProgressHUD hideHUDForView:self.view animated:YES];/////
                [self.view setUserInteractionEnabled:YES];
            }
            else
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{///////
                    
                    if (error==nil) {
                        {
                            
                            //current photo save
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
                            NSString *documentsDirectory = [paths objectAtIndex:0];
                            NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
                            NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"person0.jpg"]);
                            [imageData writeToFile:savedImagePath atomically:NO];
                            //register user
                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                                // Do something...
                                
                                
                                FIRUser *user = [FIRAuth auth].currentUser;
                                FIRUserProfileChangeRequest *changeRequest = [user profileChangeRequest];
                                NSString *userId = user.uid;
                                FIRStorage *storage = [FIRStorage storage];
                                FIRStorageReference *storageRef = [storage reference];
                                app.user.isCancelled = true;
                                app.user.numberOfCoupons = 0;
                                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                                    FIRStorageReference *photoImagesRef = [storageRef child:[NSString stringWithFormat:@"users photo/%@/photo.jpg", [Request currentUserUid]] ];
                                    NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"person0.jpg"]);
                                    
                                    
                                    //image compress until size < 1 MB
                                    int count = 0;
                                    while ([imageData length] > 1000000) {
                                        imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"person0.jpg"], powf(0.9, count));
                                        count++;
                                        NSLog(@"just shrunk it once.");
                                    }
                                    
                                    // Upload the file to the path "images/userID.PNG"f
                                    
                                    [photoImagesRef putData:imageData metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
                                        if (error != nil) {
                                            // Uh-oh, an error occurred!
                                            [self.view setUserInteractionEnabled:YES];
                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        } else {
                                            // Metadata contains file metadata such as size, content-type, and download URL.
                                            changeRequest.displayName = user.email;
                                            changeRequest.photoURL = metadata.downloadURL;
                                            [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if (error) {
                                                        // An error happened.
                                                        NSLog(@"%@", error.description);
                                                    } else {
                                                        // Profile updated.
                                                        
                                                        NSDictionary *userData = @{@"name":user.displayName?user.displayName:@"",
                                                                                   @"email":user.email?user.email:@" ",
                                                                                   @"photourl":[metadata.downloadURL absoluteString]?[metadata.downloadURL absoluteString]:@" ",                                                   @"userid":userId?userId:@" ",
                                                                                   @"numberofcomments":@"0"
                                                                                   };
                                                        [[[[[[FIRDatabase database] reference] child:@"users"] child:userId]child:@"general info"]setValue:userData];
                                                        //after progress
                                                        dispatch_async(dispatch_get_main_queue(), ^{///////
                                                            
                                                            
                                                            [self loadUserDataAndGo];
                                                            [self.view setUserInteractionEnabled:YES];
                                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                            
                                                        });
                                                        
                                                    }
                                                    
                                                });
                                            }];
                                            
                                        }
                                    }];
                                    
                                });

                                
                            });
                            
                            
                        }
                    }else{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];/////
                        [self.view setUserInteractionEnabled:YES];
                        UIAlertController * loginErrorAlert = [UIAlertController
                                                               alertControllerWithTitle:@"Login Failed"
                                                               message:error.localizedDescription
                                                               preferredStyle:UIAlertControllerStyleAlert];
                        [self presentViewController:loginErrorAlert animated:YES completion:nil];
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                            [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
                        }];
                        [loginErrorAlert addAction:ok];
                    }
                });
                
                
                //NSLog(@"succeed login");
            }
        }];
    });//Add MBProgressBar (dispatch)
    

}

#pragma mark - load data from backend
- (void)loadUserDataAndGo{
    app.user.userId = [NSString stringWithFormat:@"%@", [Request currentUserUid]];
    app.arrPayDictinaryData = [[NSMutableArray alloc]init];
    
    childCount = 1;
    [self.view setUserInteractionEnabled:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        //get manager data
        app.user.userId = [NSString stringWithFormat:@"%@", [Request currentUserUid]];
        NSString *userID = app.user.userId;
        FIRDatabaseReference *refManagerInfor = [[[[Request dataref] child:@"users"]child: userID] child:@"general info"];
        [refManagerInfor observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.exists) {
                app.user.name = [(NSDictionary*)(snapshot.value) objectForKey:@"name"];
                app.user.userId = userID;
                app.user.email = [(NSDictionary*)(snapshot.value) objectForKey:@"email"];
                app.user.photoURL = [NSURL URLWithString:[(NSDictionary*)(snapshot.value) objectForKey:@"photourl"]];
                app.user.cardCVID = [(NSDictionary*)(snapshot.value) objectForKey:@"cardcvid"];
                app.user.cardDate = [(NSDictionary*)(snapshot.value) objectForKey:@"carddate"];
                app.user.cardNumber = [(NSDictionary*)(snapshot.value) objectForKey:@"cardnumber"];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                [dateFormatter setTimeZone:gmt];
                app.user.dateCycleStart  = [dateFormatter dateFromString:[(NSDictionary*)(snapshot.value) objectForKey:@"dateCycleStart"]];
                int numberOfMonths = [self checkDateInterval:app.user.dateCycleStart];
                NSString *isCancelled = [(NSDictionary*)(snapshot.value) objectForKey:@"iscancelled"];
                if (numberOfMonths>=1) {
                    isCancelled = @"true";
                }
                
                app.user.isCancelled = [isCancelled boolValue];
                app.user.numberOfCoupons = [[(NSDictionary*)(snapshot.value) objectForKey:@"numberOfCoupons"] intValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                //go maim workspace
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.view setUserInteractionEnabled:YES];
                [self loadResData];
                [self loadPayData];
                
            });
        
            }else{
                
                UIAlertController * loginErrorAlert = [UIAlertController
                                                       alertControllerWithTitle:@"Cannot find your info"
                                                       message:@"cannot access your info. please check your info."
                                                       preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:loginErrorAlert animated:YES completion:nil];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self.view setUserInteractionEnabled:YES];
                    });
                    
                }];
                [loginErrorAlert addAction:ok];
                
                }
            }];
    });

    

}

-(int)checkDateInterval: (NSDate*)RegisterDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    
    //internet time
    NSURL *url = [NSURL URLWithString:@"http://www.timeapi.org/utc/now"];
    NSString *str = [[NSString alloc] initWithContentsOfURL:url usedEncoding:Nil error:Nil];
    
    str = [str stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    str = [str stringByReplacingOccurrencesOfString:@"+00:00" withString:@""];
    
    
    NSDate *nowGMTDate = [dateFormatter dateFromString:str];
    
    int numberOfMonth = (int)[[[NSCalendar currentCalendar] components: NSCalendarUnitMonth
                                                               fromDate: RegisterDate
                                                                 toDate: nowGMTDate
                                                                options: 0] month];
    return numberOfMonth;
}

-(void)loadResData{
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //get all restaurant info
        FIRDatabaseReference* ref = [[[FIRDatabase database] reference] child:@"restaurants"];
        [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary*dic = snapshot.value;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *keys;
                if (![dic isKindOfClass:[NSNull class]]) {
                    keys = dic.allKeys;
                }
            //////////////////////////////////////___correct
                app.arrRegisteredDictinaryRestaurantData = [[NSMutableArray alloc]init];
                for (int countData = 0;keys.count>countData;countData++) {
                    NSDictionary *restaurantData = [dic objectForKey:[keys objectAtIndex:countData]];
                    [app.arrRegisteredDictinaryRestaurantData addObject:restaurantData];
                }
                if (!app.boolOncePassed) {
                    app.boolOncePassed = true;
                    [app addTabBar];
                }
                
            });
        }];

    });
    
    

}
- (void)loadPayData{
    //get users' pay data
    app.arrPayDictinaryData = [[NSMutableArray alloc]init];
    FIRDatabaseReference* refPay = [[[[FIRDatabase database] reference] child:@"users"] child:app.user.userId];
    [refPay observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary*dic = snapshot.value;
        
            NSDictionary *payData = [dic objectForKey:@"pay info"];
            
            
            NSMutableArray * dataarray = [[NSMutableArray alloc]init];
            NSArray *keysPay = [payData allKeys];
            NSArray *values = [payData allValues];
            
            
            for (int count = 0 ; keysPay.count > count; count++) {
                NSString *datetext = [NSString stringWithFormat:@"%@", [keysPay objectAtIndex:count]] ;
                
                NSDate *date = [self date_from_string:datetext];
                NSDictionary *dicpay = [[NSDictionary alloc]initWithObjectsAndKeys:date, @"date", [values objectAtIndex:count], @"amount",  nil];
                [dataarray addObject:dicpay];
            }
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"date" ascending: NO];
            dataarray = [[NSMutableArray alloc]initWithArray:[dataarray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
            NSDictionary* PersonPayData = [[NSDictionary alloc]initWithObjectsAndKeys:app.user.name, @"name", dataarray,@"pay info", app.user.photoURL,@"photourl",  nil];
            [app.arrPayDictinaryData addObject:PersonPayData];
        
    }];
    

}

-(NSDate*)date_from_string: (NSString*)string{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM_dd_yyyy_HH_mm_ss"];
    NSDate *dateReturn = (__bridge NSDate *)([dateFormatter dateFromString:string]?[string isEqualToString:@"defaultTime"]:nil);
    return dateReturn;
}

@end
