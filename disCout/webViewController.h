

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface webViewController : UIViewController
@property (nonatomic, retain) WKWebView *webView;
@property (nonatomic, retain) NSURL *url;


@end
