#import <PebbleKit/PebbleKit.h>
#import "PCHomeViewController.h"
#import "PCPebbleCentral.h"
#import "PCPebbleManager.h"
#import "PebCiti.h"

@interface PCHomeViewController ()
@property (nonatomic, weak, readwrite) UILabel *connectedPebbleLabel;
@property (nonatomic, weak, readwrite) UIButton *connectToPebbleButton;
@property (nonatomic, weak, readwrite) UITextField *messageTextField;
@property (nonatomic, weak, readwrite) UIButton *sendToPebbleButton;
@property (nonatomic, weak, readwrite) UIActivityIndicatorView *activityIndicator;
@end

@implementation PCHomeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"PebCiti";
        [self setupConnectedPebbleLabel];
        [self setupConnectToPebbleButton];
        [self setupMessageTextField];
        [self setupSendToPebbleButton];
        [self setupActivityIndicator];

        PebCiti.sharedInstance.pebbleManager.delegate = self;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    PBWatch *connectedWatch = PCPebbleCentral.defaultCentral.lastConnectedWatch;
    self.connectedPebbleLabel.text = connectedWatch.isConnected ? connectedWatch.name : @"";
}

#pragma mark - <PCPebbleManagerDelegate>

- (void)pebbleManagerConnectedToWatch:(PBWatch *)watch
{
    self.connectedPebbleLabel.text = watch.name;
    [self.activityIndicator stopAnimating];
}

- (void)pebbleManagerFailedToConnectToWatch:(PBWatch *)watch
{
    [self.activityIndicator stopAnimating];
    self.connectedPebbleLabel.text = @"";
    NSString *message = watch ? @"Pebble doesn't support app messages." : @"No connected Pebble recognized.";
    [self displayAlertViewWithTitle:@"Cannot Connect to Pebble" message:message];
}

- (void)pebbleManagerSentMessageWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
    NSString *message = error ? error.localizedDescription : @"Message sent to Pebble successfully.";
    [self displayAlertViewWithTitle:@"" message:message];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Private

- (void)setupConnectedPebbleLabel
{
    UILabel *connectedPebbleLabelStaticLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0, 160.0f, 50.0f)];
    connectedPebbleLabelStaticLabel.text = @"Connected Pebble: ";
    [self.view addSubview:connectedPebbleLabelStaticLabel];

    UILabel *connectedPebbleLabel = [[UILabel alloc] initWithFrame:CGRectMake(170.0f, 0, 140.0f, 50.0f)];
    connectedPebbleLabel.textAlignment = NSTextAlignmentRight;
    PBWatch *watch = PebCiti.sharedInstance.pebbleManager.connectedWatch;
    connectedPebbleLabel.text = watch ? watch.name : @"";
    [self.view addSubview:connectedPebbleLabel];
    self.connectedPebbleLabel = connectedPebbleLabel;
}

- (void)setupConnectToPebbleButton
{
    UIButton *connectToPebbleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 40.0f, 320.0f, 50.0f)];
    [connectToPebbleButton setTitle:@"Connect to Pebble" forState:UIControlStateNormal];
    [connectToPebbleButton setTitleColor:self.buttonTitleColor forState:UIControlStateNormal];
    [connectToPebbleButton setTitleColor:self.buttonTitleHighlightedColor forState:UIControlStateHighlighted];
    [connectToPebbleButton addTarget:self action:@selector(connectToPebbleButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connectToPebbleButton];
    self.connectToPebbleButton = connectToPebbleButton;
}

- (void)setupMessageTextField
{
    UITextField *messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(25.0f, 130.0f, 270.0f, 40.0f)];
    messageTextField.delegate = self;
    messageTextField.returnKeyType = UIReturnKeyDone;
    messageTextField.text = @"";
    messageTextField.borderStyle = UITextBorderStyleRoundedRect;
    messageTextField.textAlignment = NSTextAlignmentCenter;
    messageTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:messageTextField];
    self.messageTextField = messageTextField;
}

- (void)setupSendToPebbleButton
{
    UIButton *sendToPebbleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 175.0f, 320.0f, 50.0f)];
    [sendToPebbleButton setTitle:@"Send Message to Pebble" forState:UIControlStateNormal];
    [sendToPebbleButton setTitleColor:self.buttonTitleColor forState:UIControlStateNormal];
    [sendToPebbleButton setTitleColor:self.buttonTitleHighlightedColor forState:UIControlStateHighlighted];
    [sendToPebbleButton addTarget:self action:@selector(sendToPebbleButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendToPebbleButton];
    self.sendToPebbleButton = sendToPebbleButton;
}

- (void)setupActivityIndicator
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    activityIndicator.color = [UIColor blackColor];
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    self.activityIndicator = activityIndicator;
}

- (void)connectToPebbleButtonWasTapped
{
    [self.activityIndicator startAnimating];
    [PebCiti.sharedInstance.pebbleManager connectToPebble];
}

- (void)sendToPebbleButtonWasTapped
{
    [self.activityIndicator startAnimating];
    [PebCiti.sharedInstance.pebbleManager sendMessageToPebble:self.messageTextField.text];
}

- (void)displayAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Dismiss"
                      otherButtonTitles:nil] show];
}

- (UIColor *)buttonTitleColor
{
    if ([self.view respondsToSelector:@selector(tintColor)]) {
        return self.view.tintColor;
    } else {
        return [UIColor blueColor];
    }
}

- (UIColor *)buttonTitleHighlightedColor
{
    return [[self buttonTitleColor] colorWithAlphaComponent:0.5f];
}

@end
