// PixelSlanter.m

#import "PixelSlanter.h"
#import <math.h>

static NSString * const kAngleKey     = @"com.mekkablue.PixelSlanter.angle";
static double     const kAngleDefault = 8.0;

@implementation PixelSlanter

- (NSUInteger)interfaceVersion {
	return 1;
}

- (NSString *)title {
	return @"Pixel Slanter";
}

- (NSString *)actionName {
	return @"Slant";
}

// Called once after the bundle is loaded.
- (BOOL)setup {
	[[NSBundle bundleForClass:[self class]] loadNibNamed:@"Dialog" owner:self topLevelObjects:nil];
	double saved = [[NSUserDefaults standardUserDefaults] doubleForKey:kAngleKey];
	[self.angleField setDoubleValue:(saved != 0.0 ? saved : kAngleDefault)];
	return YES;
}

// Called for every layer the filter is applied to.
- (void)processLayer:(GSLayer *)layer withArguments:(NSDictionary<NSString *, id> *)arguments {
	double angle;
	if (arguments[@"angle"]) {
		// Invoked via Custom Parameter — use the value from the parameter dict.
		angle = [arguments[@"angle"] doubleValue];
	} else {
		// Invoked from the dialog — read from the UI field and persist.
		angle = self.angleField.doubleValue;
		[[NSUserDefaults standardUserDefaults] setDouble:angle forKey:kAngleKey];
	}

	if (angle == 0.0 || layer.components.count == 0) {
		return;
	}

	double  tanAngle = tan(angle * M_PI / 180.0);
	CGFloat pivot    = [layer.master slantHeightForLayer:layer];

	for (GSComponent *component in layer.components) {
		NSPoint pos = component.position;
		pos.x = round(pos.x + (pos.y - pivot) * tanAngle);
		component.position = pos;
	}
}

@end
