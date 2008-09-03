#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>
#import <Nu/Nu.h>

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */
@interface NuMarkdown : NSObject {}
+ (id) convert:(id) text;
@end

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    NSAutoreleasePool *pool;
    NSMutableDictionary *props;
	
    pool = [[NSAutoreleasePool alloc] init];
    // Before proceeding make sure the user didn't cancel the request
	NSString *input = [[NSString alloc]initWithContentsOfURL:(NSURL *)url encoding:NSUTF8StringEncoding error:noErr];
    id parser = [Nu parser];
	id script = [parser parse:@"(load \"markdown\")"];
	[parser eval:script];
	
	Class NuMarkdown = NSClassFromString(@"NuMarkdown");
	NSString *html = [NuMarkdown convert:input];
	
	props=[[[NSMutableDictionary alloc] init] autorelease];
	[props setObject:@"UTF-8" forKey:(NSString *)kQLPreviewPropertyTextEncodingNameKey];
	[props setObject:@"text/html" forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
	
	NSLog(@"%@", html);
	QLPreviewRequestSetDataRepresentation(preview,(CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding],kUTTypeHTML,(CFDictionaryRef)props);

    [pool release];
    return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}