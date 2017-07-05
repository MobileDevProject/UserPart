

@import Firebase;
#import "Request.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "OfferViewController.h"
#import "Login.h"
#import "SignUp.h"

@interface SignUp ()<UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnRegisterCard;
//user info
@property (weak, nonatomic) IBOutlet UITextField *textUserName;
@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UITextField *textPass;
@property (weak, nonatomic) IBOutlet UITextField *textConfirmPass;
//card info
@property (strong, nonatomic) IBOutlet UIButton *btnPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnHideKeyboard;

@end

@implementation SignUp
{
    NSArray *businessArray;
    NSNotification *noti;
}
#pragma mark - set environment
- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnRegisterCard.layer.cornerRadius = 3;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [self.btnHideKeyboard setHidden:YES];
    [self.btnPhoto setShowsTouchWhenHighlighted:NO];
}
- (void) viewWillAppear:(BOOL)animated{
    
    UIImage *image1 = self.btnPhoto.currentBackgroundImage;
    if (!image1) {
        [self.btnPhoto setBackgroundImage:[UIImage imageNamed:@"person0.jpg"] forState:UIControlStateNormal];
    }
    
}
-(IBAction)DismissKeyboard:(UIButton *)sender {
    [self.view endEditing:YES];
}
- (void)keyboardWasShown:(NSNotification *)aNotification {
    [self.btnHideKeyboard setHidden:NO];
}
- (void)keyboardBeHidden:(NSNotification *)aNotification {
    
    [self.btnHideKeyboard setHidden:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 101) {
        
        [(UITextField*)[self.view viewWithTag:102] becomeFirstResponder];
        return YES;
    }else if(textField.tag == 102) {
        
        [(UITextField*)[self.view viewWithTag:103] becomeFirstResponder];
        return YES;
    }
    else if(textField.tag == 103){
        [(UITextField*)[self.view viewWithTag:104] becomeFirstResponder];
        return YES;
        
        
    }else if(textField.tag == 104){
        [textField resignFirstResponder];
        [self RegisterCard:nil];
        return YES;
        
        
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - change photo
- (IBAction)changePhoto:(UIButton *)sender {

    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Take photo"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Take a photo"
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                  imagePickerController.delegate = self;
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Use Gallery"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Choose existing"
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                  imagePickerController.delegate = self;
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
    [self presentViewController:alert animated:YES completion:nil];
    

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage*image1 = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.btnPhoto setBackgroundImage:image1 forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - SignUp
- (IBAction)RegisterCard:(UIButton *)sender {
    [self.view endEditing:YES];
    NSString *strUserEmail = self.textEmail.text;
    NSString *strUserPass = self.textPass.text;
    NSString *strConfirmPass = self.textConfirmPass.text;
    
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
        
    } else if (![strUserPass isEqual:strConfirmPass]) {
        UIAlertController * loginErrorAlert = [UIAlertController
                                               alertControllerWithTitle:@"The passwords don't match"
                                               message:@"Please confirm the password."
                                               preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:loginErrorAlert animated:YES completion:nil];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
            
        }];
        [loginErrorAlert addAction:ok];
        
    }else if ([strUserEmail isEqual:@""]) {
        
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
        
        [self.view setUserInteractionEnabled:NO];
        
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do something...
            
            [[FIRAuth auth] createUserWithEmail:strUserEmail password:strUserPass completion:^(FIRUser *user, NSError *error)
             {
                 //after progress
                 dispatch_async(dispatch_get_main_queue(), ^{///////
                     [MBProgressHUD hideHUDForView:self.view animated:YES];/////
                     if (error != nil) {
                         // [START_EXCLUDE]
                         UIAlertController * loginErrorAlert = [UIAlertController
                                                                alertControllerWithTitle:@"Inavalid email address"
                                                                message:error.localizedDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];
                         [self presentViewController:loginErrorAlert animated:YES completion:nil];
                         UIAlertAction *ok = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                             //NSLog(@"reset password cancelled.");
                             [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
                         }];
                         [loginErrorAlert addAction:ok];
                         // [END_EXCLUDE]
                     }
                     else{
                         
                         
                             
                         
                         UIAlertController * loginErrorAlert = [UIAlertController
                                                                alertControllerWithTitle:@"Success!"
                                                                message:@"Complete your Singup."
                                                                preferredStyle:UIAlertControllerStyleAlert];
                         
                         //go sign in
                         [self presentViewController:loginErrorAlert animated:YES completion:nil];
                         UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                             [Request saveUserEmail:self.textEmail.text];
                             [Request saveUserName:self.textUserName.text];
                             AppDelegate *app = [UIApplication sharedApplication].delegate;
                             app.user.userId = [Request currentUserUid];
                             app.user.name = self.textUserName.text;
                             app.user.email = self.textEmail.text;
                             app.user.isCancelled = true;
                             app.user.numberOfCoupons = 0;
                             
                             [Request saveNumberOfCoupons:@"0"];
                             [Request cancelMembership];
                             //current photo save
                             if (self.btnPhoto.currentBackgroundImage) {
                                
                                 [Request saveUserPhoto:self.btnPhoto.currentBackgroundImage];
                                 
                             }
                             [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
                             //go register card
                             [self.navigationController popViewControllerAnimated:YES];
                             //[app addTabBar];
                         }];
                         [loginErrorAlert addAction:ok];
                         
                     }
                     [self.view setUserInteractionEnabled:YES];
                 });
                 //after progress
             }
             ];
        });//Add MBProgressBar (dispatch)
    }
}
#pragma mark - go Offer
- (IBAction)SeeOffer:(UIButton *)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OfferViewController *offerViewController = [storyboard instantiateViewControllerWithIdentifier:@"OfferViewController"];
    [self.navigationController pushViewController:offerViewController animated:YES];
}

#pragma mark - go login
- (IBAction)BackToSignIn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)goSignIn:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
