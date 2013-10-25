#import <CoreLocation/CoreLocation.h>
#import "UIAlertView+PebCiti.h"
#import "PCStationList.h"
#import "PCStation.h"
#import "PebCiti.h"

@interface PCStationList ()
@property (nonatomic, strong) NSArray *stations;
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

- (PCStation *)closestStation
{
    CLLocation *userLocation = PebCiti.sharedInstance.locationManager.location;
    if (!userLocation) {
        return nil;
    }

    PCStation *closestStation = nil;
    CGFloat smallestDistance = CGFLOAT_MAX;
    for (PCStation *station in self.stations) {
        if ([userLocation distanceFromLocation:station.location] < smallestDistance) {
            closestStation = station;
        }
    }
    return closestStation;
}

#pragma mark - <NSURLConnectionDelegate>

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIAlertView displayAlertViewWithTitle:@"" message:@"A problem occurred downloading the station list from citibikenyc.com"];
}

#pragma mark - <NSURLConnectionDataDelegate>

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
    NSArray *stationInfos = json[@"stationBeanList"];

    if (!stationInfos) {
        [UIAlertView displayAlertViewWithTitle:@"" message:@"A problem occurred downloading the station list from citibikenyc.com"];
    }

    NSMutableArray *stations = [@[] mutableCopy];
    for (NSDictionary *stationInfo in stationInfos) {
        PCStation *station = [[PCStation alloc] init];
        station.name = stationInfo[@"stationName"];
        station.docksAvailable = [stationInfo[@"availableDocks"] integerValue];
        station.location = [[CLLocation alloc] initWithLatitude:[stationInfo[@"latitude"] floatValue] longitude:[stationInfo[@"longitude"] floatValue]];
        [stations addObject:station];
    }
    self.stations = stations;

    [self.delegate stationListWasUpdated:self];
}

#pragma mark - Object Subscripting

- (NSUInteger)count
{
    return self.stations.count;
}

- (PCStation *)objectAtIndexedSubscript:(NSUInteger)index
{
    return [self.stations objectAtIndexedSubscript:index];
}

#pragma mark - Private

- (void)requestStationList
{
    NSURL *URL = [NSURL URLWithString:@"http://citibikenyc.com/stations/json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection start];
}

@end