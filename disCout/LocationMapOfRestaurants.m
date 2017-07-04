
#import "SWRevealViewController.h"
#import "LocationMapOfRestaurants.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "restaurantListViewcontroller.h"
#import "RestaurantInfoViewController.h"
#import "actvatedRestaurantListViewController.h"
#import "AppDelegate.h"
#import "Annotation.h"

@interface LocationMapOfRestaurants ()<MKMapViewDelegate> {
    NSMutableArray *arrRestaurantData;
    float preValue;
    UIViewController *previousController;
}
#define METERS_PER_MILE 1609.344

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISlider *slideControlDistance;
@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,strong) NSMutableArray *annotations;
@property BOOL mapDidLoadForFirstTime;
@property (nonatomic,retain) AppDelegate *app;
@property (strong, nonatomic) IBOutlet UILabel *searchRadius;
@end

@implementation LocationMapOfRestaurants

@synthesize mapView;

- (void)viewDidLoad{

}

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *MyPin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"current"];
    UIButton *advertButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    MyPin.rightCalloutAccessoryView = advertButton;
    MyPin.draggable = YES;
    MyPin.animatesDrop=TRUE;
    MyPin.canShowCallout = YES;
    MyPin.highlighted = NO;
    return MyPin;
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
}
- (IBAction)goSideMenu:(UIButton *)sender {
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    [self.navigationController.revealViewController rightRevealToggle:nil];
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{

}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    self.app.selectedResNumberFromResList = [(Annotation*)[view annotation] number];
    self.app.dicRestaurantData = [[NSDictionary alloc]initWithDictionary:[arrRestaurantData objectAtIndex:self.app.selectedResNumberFromResList] copyItems:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RestaurantInfoViewController *restaurantInfoViewController = [storyboard instantiateViewControllerWithIdentifier:@"RestaurantInfoViewController"];
    [self.navigationController pushViewController:restaurantInfoViewController animated:YES];
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay

{
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:(MKCircle *)overlay] ;
    circleView.fillColor = [UIColor colorWithRed:242.0f/255.0f green:101.0f/255.0f blue:34.0f/255.0f alpha:0.2];
    return circleView;
}


- (IBAction)ExchangeMapList:(UIButton *)sender {
    // pop back to previous controller
    NSArray *myControllers = self.navigationController.viewControllers;
    int previous = (int)myControllers.count - 2;
    previousController = [myControllers objectAtIndex:previous];
    if ([previousController isKindOfClass:[actvatedRestaurantListViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if([previousController isKindOfClass:[restaurantListViewcontroller class]]){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        restaurantListViewcontroller *RestaurantListViewcontroller = [storyboard instantiateViewControllerWithIdentifier:@"restaurantListViewcontroller"];
        [self.navigationController pushViewController:RestaurantListViewcontroller animated:YES];
    }
}

- (IBAction)GoBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)ChangeDistanceSearch:(UISlider *)sender {
    
    [self.searchRadius setFrame:CGRectMake(self.searchRadius.frame.origin.x - sender.frame.size.width/100.0f, self.searchRadius.frame.origin.x, self.searchRadius.frame.size.width, self.searchRadius.frame.size.height)];
    preValue = sender.value;
    if ((int)(sender.value) % 5 == 0) {
        [mapView removeOverlay:[[mapView overlays] firstObject]];
        float lati = [[(NSDictionary*)[arrRestaurantData firstObject] objectForKey:@"latitude"] floatValue];
        float longgi = [[(NSDictionary*)[arrRestaurantData firstObject] objectForKey:@"longitude"] floatValue];
        CLLocationCoordinate2D circleMiddlePoint = CLLocationCoordinate2DMake(lati, longgi);
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:circleMiddlePoint radius:sender.value*300];
        [mapView addOverlay: circle];
    }

}
- (void)viewWillAppear:(BOOL)animated{
    _app = [UIApplication sharedApplication].delegate;
    arrRestaurantData = [[NSMutableArray alloc]init];
    // pop back to previous controller
    NSArray *myControllers = self.navigationController.viewControllers;
    int previous = (int)myControllers.count - 2;
    previousController = [myControllers objectAtIndex:previous];
    if ([previousController isKindOfClass:[actvatedRestaurantListViewController class]]) {
        arrRestaurantData = self.app.arrRegisteredDictinaryRestaurantData;
    }else{
        arrRestaurantData = self.app.arrSearchedDictinaryRestaurantData;
    }

    
    MKCoordinateRegion Bridge = { {0.0, 0.0} , {0.0, 0.0} };
    
    [mapView setDelegate:self];
    [mapView removeAnnotations:mapView.annotations];

    
    for (int count = 0; arrRestaurantData.count>count ; count++) {
        float lati = [[(NSDictionary*)[arrRestaurantData objectAtIndex:count] objectForKey:@"latitude"] floatValue];
        float longgi = [[(NSDictionary*)[arrRestaurantData objectAtIndex:count] objectForKey:@"longitude"] floatValue];
        Bridge.center.latitude = lati;
        Bridge.center.longitude = longgi;
        Bridge.span.longitudeDelta = 0.01f;
        Bridge.span.latitudeDelta = 0.01f;
        Annotation *ann = [[Annotation alloc] init];
        NSDictionary *dicRestaurantData = (NSDictionary*)[arrRestaurantData objectAtIndex:count];
        ann.title = [dicRestaurantData objectForKey:@"name"];
        ann.subtitle = [dicRestaurantData objectForKey:@"display_phone"];
        ann.subtitle = (NSString*)[dicRestaurantData objectForKey:@"address"];;
        ann.url = [dicRestaurantData objectForKey:@"mobile_url"];
        ann.number = count;
        [ann setValue:ann.url forKey:@"url"];
        ann.coordinate = Bridge.center;
        [mapView addAnnotation:ann];
        
    }
    float lati = [[(NSDictionary*)[arrRestaurantData firstObject] objectForKey:@"latitude"] floatValue];
    float longgi = [[(NSDictionary*)[arrRestaurantData firstObject] objectForKey:@"longitude"] floatValue];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(lati, longgi), 500, 500);
    [self.mapView setRegion:region animated:YES];

}

@end
