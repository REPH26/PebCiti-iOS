#import <CoreLocation/CoreLocation.h>
#import "PCPebbleManager.h"
#import "PebCiti.h"

@interface PebCiti ()
@property (nonatomic, strong, readwrite) PCPebbleManager *pebbleManager;
@property (nonatomic, strong, readwrite) CLLocationManager *locationManager;
@end

static PebCiti *_sharedPebCiti;

@implementation PebCiti

+ (PebCiti *)sharedInstance
{
    if (!_sharedPebCiti) {
        _sharedPebCiti = [[PebCiti alloc] init];
    }
    return _sharedPebCiti;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pebbleManager = [[PCPebbleManager alloc] init];
        self.locationManager = [[CLLocationManager alloc] init];
    }
    return  self;
}

@end
