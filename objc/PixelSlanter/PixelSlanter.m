// PixelSlanter.m

#import "PixelSlanter.h"
#import <math.h>

static NSString * const kAngleKey     = @"com.mekkablue.PixelSlanter.angle";
static double     const kAngleDefault = 8.0;

@implementation PixelSlanter

// v2 API.
- (NSUInteger)interfaceVersion {
	return 2;
}
- (NSString *)title {
	return @"Pixel Slanter";
}

- (NSString *)actionName {
	return @"Slant";
}

// Returns the dialog view shown in the Filter sheet.
- (NSView *)view {
	return self.theView;
}

// No keyboard shortcut.
- (NSString *)keyEquivalent {
	return @"";
}

// Called once after the bundle is loaded.
// Return nil for success, or an NSError on failure.
- (nullable NSError *)setup {
	[[NSBundle bundleForClass:[self class]] loadNibNamed:@"Dialog" owner:self topLevelObjects:nil];
	double saved = [[NSUserDefaults standardUserDefaults] doubleForKey:kAngleKey];
	[self.angleField setDoubleValue:(saved != 0.0 ? saved : kAngleDefault)];
	return nil;
}

// Called for every layer when the filter runs from the Filter menu (v2 API).
- (BOOL)runFilterWithLayer:(GSLayer *)layer error:(out NSError *__autoreleasing *)error {
	double angle = self.angleField ? self.angleField.doubleValue : kAngleDefault;
	[[NSUserDefaults standardUserDefaults] setDouble:angle forKey:kAngleKey];
	if (angle == 0.0 || layer.countOfComponents == 0) {
		return YES;
	}
	double          tanAngle = tan(angle * M_PI / 180.0);
	GSFontMaster   *master   = [layer associatedFontMaster];
	CGFloat         pivot    = master ? [master slantHeightForLayer:layer] : 0.0;
	for (GSComponent *component in layer.components) {
		NSPoint pos = component.position;
		pos.x = round(pos.x + (pos.y - pivot) * tanAngle);
		component.position = pos;
	}
	return YES;
}

// Called when the filter runs via a Custom Parameter (e.g., on export).
- (void)processLayer:(GSLayer *)layer withArguments:(NSDictionary<NSString *, id> *)arguments {
	double angle;
	if (arguments[@"angle"]) {
		angle = [arguments[@"angle"] doubleValue];
	} else {
		angle = self.angleField ? self.angleField.doubleValue : kAngleDefault;
		[[NSUserDefaults standardUserDefaults] setDouble:angle forKey:kAngleKey];
	}
	if (angle == 0.0 || layer.countOfComponents == 0) {
		return;
	}
	double          tanAngle = tan(angle * M_PI / 180.0);
	GSFontMaster   *master   = [layer associatedFontMaster];
	CGFloat         pivot    = master ? [master slantHeightForLayer:layer] : 0.0;
	for (GSComponent *component in layer.components) {
		NSPoint pos = component.position;
		pos.x = round(pos.x + (pos.y - pivot) * tanAngle);
		component.position = pos;
	}
}

@end
