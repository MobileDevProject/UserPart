

#import "OfferViewController.h"
#import "SWRevealViewController.h"
@interface OfferViewController ()
@property (strong, nonatomic) IBOutlet UIButton *buttonBack;
@property (strong, nonatomic) IBOutlet UIButton *buttonSlideMenu;

@end

@implementation OfferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    if (self.revealViewController) {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
        [self.buttonBack setHidden:YES];
        [self.buttonSlideMenu setHidden:NO];
    }else{
        [self.buttonBack setHidden:NO];
        [self.buttonSlideMenu setHidden:YES];
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)goSlide:(UIButton *)sender {
    [self.revealViewController rightRevealToggle:nil];
}


@end
