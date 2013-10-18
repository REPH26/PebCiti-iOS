#import <CoreLocation/CoreLocation.h>
#import "PCPebbleManager.h"
#import "PebCiti.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PebCitiSpec)

describe(@"PebCiti", ^{
    __block PebCiti *pebCiti;

    beforeEach(^{
        pebCiti = PebCiti.sharedInstance;
    });

    it(@"should behave like a singleton", ^{
        pebCiti should be_same_instance_as(PebCiti.sharedInstance);
    });

    describe(@"-pebbleManager", ^{
        it(@"should be a PCPebbleManager", ^{
            pebCiti.pebbleManager should be_instance_of([PCPebbleManager class]);
        });

        it(@"should always return the same manager", ^{
            pebCiti.pebbleManager should be_same_instance_as(pebCiti.pebbleManager);
        });
    });

    describe(@"-locationManager", ^{
        it(@"should be a CLLocationManager", ^{
            pebCiti.locationManager should be_instance_of([CLLocationManager class]);
        });

        it(@"should always return the same manager", ^{
            pebCiti.locationManager should be_same_instance_as(pebCiti.locationManager);
        });
    });
});

SPEC_END
