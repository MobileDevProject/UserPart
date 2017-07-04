
@import Firebase;
@import FirebaseAuth;
#import "SWRevealViewController.h"
#import "SideMenuViewController.h"
#import "AppDelegate.h"
#import "Request.h"
@interface SideMenuViewController ()

@end

@implementation SideMenuViewController
{
    NSArray *menuItems;
    AppDelegate* app;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    app = [UIApplication sharedApplication].delegate;

}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row==0) {
        [self.revealViewController performSegueWithIdentifier:@"sw_front" sender:nil];
        [self.revealViewController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
    }else if(indexPath.row==1){
        NSError *error;
        app.boolOncePassed = false;
        [[FIRAuth auth] signOut:&error];
        NSLog(@"error: %@", error.localizedDescription);
        UINavigationController *homeViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignViewController"];
        [self presentViewController:homeViewController animated:YES completion:nil];
    }
    
}


@end
