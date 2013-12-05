#import <CoreLocation/CoreLocation.h>
#import "UIAlertView+PebCiti.h"
#import "PCStationList.h"
#import "PCStation.h"
#import "PebCiti.h"

@interface PCStationList ()
@property (nonatomic, strong, readwrite) NSArray *stations;
@property (nonatomic, strong) NSMutableData *data;
@end

@implementation PCStationList

- (instancetype)init
{
    if (self = [super init]) {
        self.data = [[NSMutableData alloc] init];
        [self requestStationList];
    }
    return self;
}
- (void)requestStationList
{
    NSURL *URL = [NSURL URLWithString:@"https://api.jcdecaux.com/vls/v1/stations?contract=Lyon&apiKey=51c05c8d85aa71cfea75406761eef6b7f4a488c7"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection start];
}
- (PCStation *)closestStationWithAvailableBike
{
    CLLocation *userLocation = PebCiti.sharedInstance.locationManager.location;
    if (!userLocation) {
        return nil;
    }
    [self sortStationsByDistance];
    NSPredicate *availableBikesPredicate = [NSPredicate predicateWithFormat:@"bikesAvailable > 0"];
    return [self.stations filteredArrayUsingPredicate:availableBikesPredicate][0];
}

- (PCStation *)closestStationWithOpenDock
{
    CLLocation *userLocation = PebCiti.sharedInstance.locationManager.location;
    if (!userLocation) {
        return nil;
    }
    [self sortStationsByDistance];
    NSPredicate *openDocksPredicate = [NSPredicate predicateWithFormat:@"docksAvailable > 0"];
    return [self.stations filteredArrayUsingPredicate:openDocksPredicate][0];
}
#pragma mark - <NSURLConnectionDelegate>
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIAlertView displayAlertViewWithTitle:@"" message:@"A problem occurred downloading the station list from JCDecaux"];
}
#pragma mark - <NSURLConnectionDataDelegate>
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *e = nil;
    NSArray *json = [NSJSONSerialization JSONObjectWithData:self.data options: NSJSONReadingMutableContainers error: &e];
    NSArray *stationInfos = json;
    if (!stationInfos) {
        [UIAlertView displayAlertViewWithTitle:@"" message:@"A problem occurred downloading the station list from JCDecaux"];
    } else {
        NSMutableArray *stations = [@[] mutableCopy];
        PCStation *station;
        for (NSDictionary *stationInfo in stationInfos) {
            station = [[PCStation alloc] initWithID:stationInfo[@"number"]];
            station.name = stationInfo[@"name"];
            station.bikesAvailable = [stationInfo[@"available_bikes"] integerValue];
            station.docksAvailable = [stationInfo[@"available_bike_stands"] integerValue];
            station.location = [[CLLocation alloc] initWithLatitude:[stationInfo[@"position"][@"lat"]  floatValue] longitude:[stationInfo[@"position"][@"lng"] floatValue]];
            [stations addObject:station];
        }
        self.stations = stations;
        [self sortStationsByDistance];
        
        [self.delegate stationListWasUpdated:self];
        self.data = [[NSMutableData alloc] init];
        [self performSelector:@selector(requestStationList) withObject:nil afterDelay:30];
    }
}
#pragma mark - Private
- (void)sortStationsByDistance
{
    if (PebCiti.sharedInstance.locationManager.location) {
        self.stations = [self.stations sortedArrayUsingComparator:^NSComparisonResult(PCStation *station1, PCStation *station2) {
            CLLocation *userLocation = PebCiti.sharedInstance.locationManager.location;
            CLLocationDistance station1Distance = [userLocation distanceFromLocation:station1.location];
            CLLocationDistance station2Distance = [userLocation distanceFromLocation:station2.location];
            if (station1Distance < station2Distance) {
                return NSOrderedAscending;
            } else if (station1Distance > station2Distance) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
    }
}
@end
