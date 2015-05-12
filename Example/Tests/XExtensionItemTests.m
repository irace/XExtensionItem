@import MobileCoreServices;
@import UIKit;
@import XCTest;
#import "CustomParameters.h"
#import "XExtensionItem.h"

@interface XExtensionItemTests : XCTestCase
@end

@implementation XExtensionItemTests

- (void)testItemSourceThrowsIfPlaceholderIsNil {
    XCTAssertThrows([[XExtensionItemSource alloc] initWithPlaceholderItem:nil typeIdentifier:nil itemBlock:nil]);
}

- (void)testAttributedTitle {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithText:@""];
    itemSource.title = @"Foo";
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqualObjects(itemSource.title, xExtensionItem.title);
}

- (void)testAttributedContentText {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithText:@""];
    itemSource.attributedContentText = [[NSAttributedString alloc] initWithString:@"Foo" attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:20] }];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqual(itemSource.attributedContentText.hash, xExtensionItem.attributedContentText.hash);
}

- (void)testAttachments {
    NSURL *URL = [NSURL URLWithString:@"http://apple.com"];
    
    NSArray *additionalAttachments = @[
        [[NSItemProvider alloc] initWithItem:[NSURL URLWithString:@"http://apple.com"] typeIdentifier:(__bridge NSString *)kUTTypeURL],
        [[NSItemProvider alloc] initWithItem:@"Apple’s website" typeIdentifier:(__bridge NSString *)kUTTypeText]
    ];
    
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithURL:URL];
    itemSource.additionalAttachments = additionalAttachments;
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqual(xExtensionItem.attachments.count, 3);
}

- (void)testTags {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithText:@""];
    itemSource.tags = @[@"foo", @"bar", @"baz"];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqualObjects(itemSource.tags, xExtensionItem.tags);
}

- (void)testSourceURL {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithText:@""];
    itemSource.sourceURL = [NSURL URLWithString:@"http://tumblr.com"];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqualObjects(itemSource.sourceURL, xExtensionItem.sourceURL);
}

- (void)testReferrer {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithText:@""];

    itemSource.referrer = [[XExtensionItemReferrer alloc] initWithAppName:@"Tumblr"
                                                               appStoreID:@"12345"
                                                             googlePlayID:@"54321"
                                                                   webURL:[NSURL URLWithString:@"http://bryan.io/a94kan4"]
                                                                iOSAppURL:[NSURL URLWithString:@"tumblr://a94kan4"]
                                                            androidAppURL:[NSURL URLWithString:@"tumblr://a94kan4"]];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqualObjects(itemSource.referrer, xExtensionItem.referrer);
}

- (void)testReferrerFromBundle {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithText:@""];
    itemSource.referrer = [[XExtensionItemReferrer alloc] initWithAppNameFromBundle:[NSBundle bundleForClass:[self class]]
                                                                         appStoreID:@"12345"
                                                                       googlePlayID:@"54321"
                                                                             webURL:[NSURL URLWithString:@"http://bryan.io/a94kan4"]
                                                                          iOSAppURL:[NSURL URLWithString:@"tumblr://a94kan4"]
                                                                      androidAppURL:[NSURL URLWithString:@"tumblr://a94kan4"]];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqualObjects(itemSource.referrer, xExtensionItem.referrer);
}

- (void)testUserInfo {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithText:@""];
    itemSource.sourceURL = [NSURL URLWithString:@"http://tumblr.com"];
    itemSource.userInfo = @{ @"foo": @"bar" };
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    // Output params user info dictionary should be a superset of input params user info dictionary
    
    [itemSource.userInfo enumerateKeysAndObjectsUsingBlock:^(id inputKey, id inputValue, BOOL *stop) {
        XCTAssertEqualObjects(xExtensionItem.userInfo[inputKey], inputValue);
    }];
}

- (void)testAddEntriesToUserInfo {
    CustomParameters *inputCustomParameters = [[CustomParameters alloc] init];
    inputCustomParameters.customParameter = @"Value";

    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithText:@""];
    [itemSource addCustomParameters:inputCustomParameters];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    CustomParameters *outputCustomParameters = [[CustomParameters alloc] initWithDictionary:xExtensionItem.userInfo];
    
    XCTAssertEqualObjects(inputCustomParameters, outputCustomParameters);
}

- (void)testTypeSafety {
    /*
     Try to break things by intentionally using the wrong types for these keys, then calling methods that would only
     exist on the correct object types
     */
    
    NSExtensionItem *item = [[NSExtensionItem alloc] init];
    item.userInfo = @{
        @"x-extension-item": @[],
    };
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:item];
    XCTAssertNoThrow([xExtensionItem.sourceURL absoluteString]);
    
    item = [[NSExtensionItem alloc] init];
    item.userInfo = @{
        @"x-extension-item": @{
            @"source-url": @"",
            @"tags": @{},
            @"referrer-name": @[],
            @"referrer-app-store-id": @[],
            @"referrer-google-play-id": @[],
            @"referrer-web-url": @[],
            @"referrer-ios-app-url": @[],
            @"referrer-android-app-url": @[]
        }
    };
    
    xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:item];
    XCTAssertNoThrow([xExtensionItem.sourceURL absoluteString]);
    XCTAssertNoThrow(xExtensionItem.tags.count);
    XCTAssertNoThrow([xExtensionItem.referrer.appName stringByAppendingString:@""]);
    XCTAssertNoThrow([xExtensionItem.referrer.appStoreID stringByAppendingString:@""]);
    XCTAssertNoThrow([xExtensionItem.referrer.googlePlayID stringByAppendingString:@""]);
    XCTAssertNoThrow([xExtensionItem.referrer.webURL absoluteString]);
    XCTAssertNoThrow([xExtensionItem.referrer.iOSAppURL absoluteString]);
    XCTAssertNoThrow([xExtensionItem.referrer.androidAppURL absoluteString]);
}

- (void)testAdditionalAttachmentsForActivityTypeClearedByPassingNil {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithText:@""];
    [itemSource setAdditionalAttachments:@[@"String"] forActivityType:UIActivityTypeMail];
    [itemSource setAdditionalAttachments:nil forActivityType:UIActivityTypeMail];
  
    XExtensionItem *extensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    XCTAssertEqual(extensionItem.attachments.count, 1);
}

- (void)testRegisteringSubjectReturnsRegisteredSubjectForMailActivity {
    NSString *subject = @"Subject";
    
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithText:@""];
    itemSource.title = subject;
    
    XCTAssertEqualObjects(subject, [itemSource activityViewController:nil subjectForActivityType:UIActivityTypeMail]);
}

- (void)testRegisteringThumbnailProvidingBlockReturnsThumbnailForTwitterActivity {
    UIImage *image = [[UIImage alloc] initWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithText:@""];
    itemSource.thumbnailProvider = ^(CGSize suggestedSize, NSString *activityType) {
        return image;
    };
    
    XCTAssertEqualObjects(image, [itemSource activityViewController:nil thumbnailImageForActivityType:UIActivityTypePostToTwitter suggestedSize:CGSizeZero]);
}

- (void)testDataTypeIdentifierPassedToInitializerIsReturnedByActivityItemSourceDelegateMethods {
    NSString *dataTypeIdentifier = (NSString *)kUTTypeVideo;
    
    XExtensionItemSource *source = [[XExtensionItemSource alloc] initWithPlaceholderItem:[[NSData alloc] init]
                                                                          typeIdentifier:dataTypeIdentifier
                                                                               itemBlock:nil];
    
    XCTAssertEqualObjects(dataTypeIdentifier, [source activityViewController:nil dataTypeIdentifierForActivityType:nil]);
}

- (void)testTextReturnedForSystemActivityThatCantProcessExtensionItemInput {
    NSString *text = @"Foo";
    
    XExtensionItemSource *source = [[XExtensionItemSource alloc] initWithText:text];
    source.additionalAttachments = @[[[NSItemProvider alloc] initWithItem:@"Bar" typeIdentifier:(NSString *)kUTTypeText]];
    
    XCTAssertEqualObjects(text, [source activityViewController:nil itemForActivityType:UIActivityTypeMail]);
}

- (void)testExtensionItemReturnedForSystemActivityThatCanProcessExtensionItemInput {
    NSArray *attachments = @[[[NSItemProvider alloc] initWithItem:@"Bar" typeIdentifier:(NSString *)kUTTypeText]];
    
    XExtensionItemSource *source = [[XExtensionItemSource alloc] initWithText:@""];
    source.additionalAttachments = attachments;
    
    NSExtensionItem *expected = [[NSExtensionItem alloc] init];
    expected.attachments = attachments;
    
    id actual = [source activityViewController:nil itemForActivityType:UIActivityTypePostToTwitter];
    
    XCTAssertTrue([actual isKindOfClass:[NSExtensionItem class]]);
}

- (void)testExtensionItemReturnedForNonSystemExtension {
    NSArray *attachments = @[[[NSItemProvider alloc] initWithItem:@"Bar" typeIdentifier:(NSString *)kUTTypeText]];
    
    XExtensionItemSource *source = [[XExtensionItemSource alloc] initWithText:@""];
    source.additionalAttachments = attachments;
    
    NSExtensionItem *expected = [[NSExtensionItem alloc] init];
    expected.attachments = attachments;
    
    NSExtensionItem *actual = [source activityViewController:nil itemForActivityType:@"com.irace.me.SomeExtension"];
    
    XCTAssertTrue([actual isKindOfClass:[NSExtensionItem class]]);
}

@end