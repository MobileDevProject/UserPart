
#import "SearchViewController.h"
#import "YPAPISample.h"
#import "restaurantListViewcontroller.h"
#import "LocationMapOfRestaurants.h"
@import Firebase;
#import "MBProgressHUD.h"
#import "Request.h"
#import "AppDelegate.h"
#import "SWRevealViewController.h"
@implementation SearchViewController
{
    AppDelegate *app;
    NSMutableArray *arrSelectedCuisine;
    NSArray *arrCuisine;
    __weak IBOutlet UIButton *btnSearchLocation;
    __weak IBOutlet UITextField *txtFieldSearchKey;
    __weak IBOutlet UIButton *btnCheckByName;
    
    __weak IBOutlet UIButton *btnCheckAlphabetical;

    __weak IBOutlet UIButton *btnCheckrate;
    IBOutlet UIButton *btnCheckMatch;
    
    __weak IBOutlet UIView *viewSelectCuisine;
    __weak IBOutlet UICollectionView *tableCuisine;
    __weak IBOutlet UIImageView *imgCheckSelectAll;
    IBOutlet UILabel *lblSelectedCuisineType;
    __weak IBOutlet UIButton *dismissButton;
    
    int count;
}

#pragma mark - set environment
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init
    app = [UIApplication sharedApplication].delegate;
    arrCuisine = [[NSMutableArray alloc]init];
    arrCuisine = app.arrCuisine;
    lblSelectedCuisineType.text = @"All";
    arrSelectedCuisine = [[NSMutableArray alloc]init];
    arrSelectedCuisine = app.arrSelectedCuisine;
    [viewSelectCuisine setHidden:YES];
    app.isSelectedAllCuisine = true;
    
    //if checkedSearchKeyType ==1 -> check the location button, 2 : by Name, 3:All
    app.intSearchOption1 = 1;
    //selected the checkSearchLocation button
    [btnSearchLocation setBackgroundImage:[UIImage imageNamed:@"btn_Search_InActive.png"] forState:UIControlStateNormal];
    [btnSearchLocation setTintColor:[UIColor colorWithWhite:1 alpha:0]];
    [btnSearchLocation setBackgroundImage:[UIImage imageNamed:@"btn_Search_Active.png"] forState:UIControlStateSelected];
    [btnSearchLocation setSelected:NO];
    
    //selected the checkByName button
    [btnCheckByName setBackgroundImage:[UIImage imageNamed:@"btn_Search_InActive.png"] forState:UIControlStateNormal];
    [btnCheckByName setTintColor:[UIColor colorWithWhite:1 alpha:0]];
    [btnCheckByName setBackgroundImage:[UIImage imageNamed:@"btn_Search_Active.png"] forState:UIControlStateSelected];
    [btnCheckByName setSelected:YES];
    
    
    //if checkedSearchKeyType ==1 -> check the location button, 2 : by Name, 3:All
    app.intSearchOption2 = 1;
    
    //selected the btnCheckAlphabetical button
    [btnCheckAlphabetical setBackgroundImage:[UIImage imageNamed:@"btn_Search_InActive.png"] forState:UIControlStateNormal];
    [btnCheckAlphabetical setTintColor:[UIColor colorWithWhite:1 alpha:0]];
    [btnCheckAlphabetical setBackgroundImage:[UIImage imageNamed:@"btn_Search_Active.png"] forState:UIControlStateSelected];
    [btnCheckAlphabetical setSelected:YES];
    
    
    //selected the btnCheckrate button
    [btnCheckrate setBackgroundImage:[UIImage imageNamed:@"btn_Search_InActive.png"] forState:UIControlStateNormal];
    [btnCheckrate setTintColor:[UIColor colorWithWhite:1 alpha:0]];
    [btnCheckrate setBackgroundImage:[UIImage imageNamed:@"btn_Search_Active.png"] forState:UIControlStateSelected];
    [btnCheckrate setSelected:NO];
    
    //selected the btnCheckrate button
    [btnCheckMatch setBackgroundImage:[UIImage imageNamed:@"btn_Search_InActive.png"] forState:UIControlStateNormal];
    [btnCheckMatch setTintColor:[UIColor colorWithWhite:1 alpha:0]];
    [btnCheckMatch setBackgroundImage:[UIImage imageNamed:@"btn_Search_Active.png"] forState:UIControlStateSelected];
    [btnCheckMatch setSelected:NO];
    
    [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"Search_Active.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBarItem setImage:[[UIImage imageNamed:@"Search_InActive.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [dismissButton setHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    }

-(void)viewWillAppear:(BOOL)animated{
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

-(void)viewWillDisappear:(BOOL)animated{
    app.isSelectedAllCuisine = true;
    for (int index = 0; index<arrCuisine.count; index++) {
        
        
        if ([(NSString*)[arrSelectedCuisine objectAtIndex:index] isEqualToString:@"0"]) {
            app.isSelectedAllCuisine = false;
            
        }
    }
}

- (IBAction)dismissKeyboard:(UIButton *)sender {
    [self.view endEditing:YES];
}

- (void)keyboardWasShown:(NSNotification *)aNotification {
    [dismissButton setHidden:NO];
}

- (void)keyboardBeHidden:(NSNotification *)aNotification {
    
    [dismissButton setHidden:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    [self search:nil];
    return YES;
}

- (IBAction)setOptionSearchLocation:(UIButton *)sender {
    [btnCheckByName setSelected:NO];
    [sender setSelected:YES];
    app.intSearchOption1 = 2;
}

- (IBAction)setOptionSearchByName:(UIButton *)sender {
    [btnSearchLocation setSelected:NO];
    [sender setSelected:YES];
    app.intSearchOption1 = 1;
}

- (IBAction)setOptionAlphabetical:(UIButton *)sender {
    [btnCheckrate setSelected:NO];
    [btnCheckMatch setSelected:NO];
    [sender setSelected:YES];
    app.intSearchOption2 = 1;
}

- (IBAction)setOptionRate:(UIButton *)sender {
    [btnCheckAlphabetical setSelected:NO];
    [btnCheckMatch setSelected:NO];
    [sender setSelected:YES];
    app.intSearchOption2 = 2;
    
}

- (IBAction)setOptionMatch:(UIButton *)sender {
    [btnCheckAlphabetical setSelected:NO];
    [btnCheckrate setSelected:NO];
    [sender setSelected:YES];
    app.intSearchOption2 = 3;
}


#pragma mark - search
- (IBAction)search:(id)sender {
    count = 1;
    app.IsMatch = true;

    //search with name and address(street and postal code)
    if ([txtFieldSearchKey.text isEqualToString:@""] && app.intSearchOption1 != 3) {
        app.arrSearchedDictinaryRestaurantData = [[NSMutableArray alloc]initWithArray:app.arrRegisteredDictinaryRestaurantData];
        
    }else if (app.intSearchOption1 == 1) {
        app.term = [NSString stringWithFormat:@"%@", txtFieldSearchKey.text] ;
        app.location = @"Houston";     //no means the "Houston."
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", app.term];
        app.arrSearchedDictinaryRestaurantData = [[NSMutableArray alloc]initWithArray:[app.arrRegisteredDictinaryRestaurantData filteredArrayUsingPredicate:predicate]];

        
    }else if (app.intSearchOption1==2){
        app.term = txtFieldSearchKey.text;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address CONTAINS[cd] %@",
                                  app.term];
        app.arrSearchedDictinaryRestaurantData = [[NSMutableArray alloc]initWithArray:[app.arrRegisteredDictinaryRestaurantData filteredArrayUsingPredicate:predicate]];
        
    }
   
    //filter with cuisine type
    if (![imgCheckSelectAll.image isEqual:[UIImage imageNamed:@"btn_Search_Active.png"]]) {
    NSMutableArray* tempRestaurants = [[NSMutableArray alloc]init];
    for (NSDictionary* restaurantData in app.arrSearchedDictinaryRestaurantData) {
        
        NSString* resCategories = [restaurantData objectForKey:@"categories"];
        
            
            for (int count1 = 0;app.arrCuisine.count>count1;count1++) {
                if ([[app.arrSelectedCuisine objectAtIndex:count1] isEqualToString:@"1"] && [resCategories containsString:[app.arrCuisine objectAtIndex:count1]]) {
                    [tempRestaurants addObject:restaurantData];
                    break;
                }
                
            }
        }
        app.arrSearchedDictinaryRestaurantData = [[NSMutableArray alloc]initWithArray:tempRestaurants];
    }
    
    
        NSSortDescriptor * descriptor;
        if (app.intSearchOption2==1) {
            descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            app.arrSearchedDictinaryRestaurantData = [[NSMutableArray alloc]initWithArray:[app.arrSearchedDictinaryRestaurantData sortedArrayUsingDescriptors:@[descriptor]]];
        }else if(app.intSearchOption2==2)
        {
            descriptor = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:NO];
            app.arrSearchedDictinaryRestaurantData = [[NSMutableArray alloc]initWithArray:[app.arrSearchedDictinaryRestaurantData sortedArrayUsingDescriptors:@[descriptor]]];
        }
    if (app.arrSearchedDictinaryRestaurantData.count==0) {
        UIAlertController * loginErrorAlert = [UIAlertController
                                               alertControllerWithTitle:@"No Result"
                                               message:@"there is no search result"
                                               preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:loginErrorAlert animated:YES completion:nil];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
            return;
        }];
        [loginErrorAlert addAction:ok];
        
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LocationMapOfRestaurants *LocationMapViewController = [storyboard instantiateViewControllerWithIdentifier:@"LocationMapOfRestaurants"];
    [self.navigationController pushViewController:LocationMapViewController animated:YES];
    

}



#pragma mark - select cuisine
- (IBAction)OpenFilterWithCuisine:(UIButton *)sender {
    [viewSelectCuisine setHidden:NO];
    [self.view bringSubviewToFront:viewSelectCuisine];
    //init all cuisine Image
    arrCuisine = [[NSMutableArray alloc]initWithArray: app.arrCuisine];
    arrSelectedCuisine = [[NSMutableArray alloc]initWithArray: app.arrSelectedCuisine];
    [tableCuisine reloadData];
}

//close Cuisine filter window
- (IBAction)selectFilterWindow:(UIButton *)sender {
    //add
    [viewSelectCuisine setHidden:YES];
    [self.view sendSubviewToBack:viewSelectCuisine];
    app.arrSelectedCuisine =[[NSMutableArray alloc]initWithArray: arrSelectedCuisine];
    if ([imgCheckSelectAll.image isEqual:[UIImage imageNamed:@"btn_Search_Active.png"]]) {
        lblSelectedCuisineType.text = @"All";
    }else{
    int numberOfSelectedSuisine = 0;
        for (int count1 = 0;app.arrCuisine.count>count1;count1++) {
            if ([[app.arrSelectedCuisine objectAtIndex:count1] isEqualToString:@"1"]) {
                lblSelectedCuisineType.text = [NSString stringWithFormat:@"%@...", [app.arrCuisine objectAtIndex:count1]];
                numberOfSelectedSuisine++;
                break;
            }
            
        }
        if (numberOfSelectedSuisine==0) {
            lblSelectedCuisineType.text = @"empty";
            UIAlertController * loginErrorAlert = [UIAlertController
                                                   alertControllerWithTitle:@"No Cuisine"
                                                   message:@"You have selected no cuisine type to filter."
                                                   preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:loginErrorAlert animated:YES completion:nil];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [loginErrorAlert dismissViewControllerAnimated:YES completion:nil];
                
            }];
            [loginErrorAlert addAction:ok];
        }
    }
    

}

- (IBAction)closeFilterWindow:(id)sender {
    [viewSelectCuisine setHidden:YES];
    [self.view sendSubviewToBack:viewSelectCuisine];
}


//select all cuisine type
- (IBAction)CuisineSelectAll:(UIButton *)sender {
    
    //init
    //select all cuisine Image
    
    [imgCheckSelectAll setImage:[UIImage imageNamed:@"btn_Search_Active.png"]];
    arrSelectedCuisine = [[NSMutableArray alloc]init];
    for (int index = 0; index<arrCuisine.count; index++) {
        
        [arrSelectedCuisine setObject:@"1" atIndexedSubscript:index];
        
    }
    //if index is equal arrCuisine.count then checked the "all select"
    [arrSelectedCuisine setObject:@"1" atIndexedSubscript:arrSelectedCuisine.count];
    [tableCuisine reloadData];
}
- (IBAction)clearAllCuisine:(UIButton *)sender {
    //init
    //Clear all cuisine Image
    app.isSelectedAllCuisine = false;
    [imgCheckSelectAll setImage:[UIImage imageNamed:@"unCheckCuisine.png"]];
    arrSelectedCuisine = [[NSMutableArray alloc]init];
    for (int index = 0; index<arrCuisine.count; index++) {
        
        [arrSelectedCuisine setObject:@"0" atIndexedSubscript:index];
        
    }
    //if index is equal arrCuisine.count then checked the "all select"
    [arrSelectedCuisine setObject:@"0" atIndexedSubscript:arrSelectedCuisine.count];
    [tableCuisine reloadData];

}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    static NSString *identifier = @"CuisineCell1";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        UILabel *CusisineType = (UILabel *)[cell viewWithTag:102];
        CusisineType.text = [arrCuisine objectAtIndex:indexPath.row];
        UIImageView *checkImage = (UIImageView*)[cell viewWithTag:101];
    if ([(NSString*)[arrSelectedCuisine objectAtIndex:indexPath.row] isEqualToString:@"0"]) {
        [checkImage setImage:[UIImage imageNamed:@"unCheckCuisine.png"]];
    }
    else{
        [checkImage setImage:[UIImage imageNamed:@"btn_Search_Active.png"]];
    }
    
    //if all cuisine is unchecked then all imagecheck button make check status.
    
    [imgCheckSelectAll setImage:[UIImage imageNamed:@"btn_Search_Active.png"]];
    for (int index = 0; index<arrCuisine.count; index++) {
        
        
        if ([(NSString*)[arrSelectedCuisine objectAtIndex:index] isEqualToString:@"0"]) {
            [imgCheckSelectAll setImage:[UIImage imageNamed:@"unCheckCuisine.png"]];
            
        }
    }

    return cell;
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    static NSString *identifier = @"CuisineCell1";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UIImageView *checkImage = (UIImageView*)[cell viewWithTag:101];
    if ([(NSString*)[arrSelectedCuisine objectAtIndex:indexPath.row] isEqualToString:@"0"]) {
        [imgCheckSelectAll setImage:[UIImage imageNamed:@"unCheckCuisine.png"]];
        [arrSelectedCuisine setObject:@"1" atIndexedSubscript:indexPath.row];
        [checkImage setImage:[UIImage imageNamed:@"unCheckCuisine.png"]];
        
    }
    else{
        
        [arrSelectedCuisine setObject:@"0" atIndexedSubscript:indexPath.row];
        [checkImage setImage:[UIImage imageNamed:@"btn_Search_Active.png"]];
    }
    [tableCuisine reloadData];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return arrCuisine.count;
}
#pragma mark - go slide
- (IBAction)goSlide:(UIButton *)sender {
    [self.navigationController.revealViewController rightRevealToggle:nil];
}

@end


