#import <Foundation/Foundation.h>
#import <PebbleKit/PebbleKit.h>

@protocol PCPebbleManagerDelegate;

@interface PCPebbleManager : NSObject <PBPebbleCentralDelegate>

@property (nonatomic, weak) id<PCPebbleManagerDelegate> delegate;
@property (nonatomic, getter = isSendingMessagesToPebble) BOOL sendMessagesToPebble;
@property (nonatomic, getter = isVibratingPebble) BOOL vibratePebble;
@property (nonatomic, strong, readonly) PBWatch *watch;

- (void)sendMessageToPebble:(NSString *)message;
- (void)changeFocusTo:(NSString *)focus;

@end

@protocol PCPebbleManagerDelegate
- (void)pebbleManagerConnectedToWatch:(PCPebbleManager *)pebbleManager;
- (void)pebbleManagerFailedToConnectToWatch:(PCPebbleManager *)pebbleManager;
- (void)pebbleManager:(PCPebbleManager *)pebbleManager receivedError:(NSError *)error;
- (void)pebbleManagerDisconnectedFromWatch:(PCPebbleManager *)pebbleManager;
@end
