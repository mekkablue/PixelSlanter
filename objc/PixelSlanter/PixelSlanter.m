// PixelSlanter.m

#import "PixelSlanter.h"
#import <math.h>

static NSString * const kAngleKey     = @"com.mekkablue.PixelSlanter.angle";
static double     const kAngleDefault = 8.0;

@implementation PixelSlanter

- (instancetype)init {
	NSLog(@"[PixelSlanter] init");
	self = [super init];
	if (self) {
		// Load the dialog NIB immediately.  We use plain NSTextField (no
		// custom GlyphsCore classes), so loading here is safe.  Glyphs
		// reads _view directly from the ivar rather than through a getter,
		// so it must be set before the dialog is constructed.
		NSLog(@"[PixelSlanter] loading Dialog NIB…");
		BOOL ok = [[NSBundle bundleForClass:[self class]] loadNibNamed:@"Dialog" owner:self topLevelObjects:nil];
		NSLog(@"[PixelSlanter] NIB loaded=%d  _view=%@  angleField=%@", ok, _view, self.angleField);
	}
	return self;
}

// v1 API — return 1 to match all working Glyphs filter plugins.
- (NSUInteger)interfaceVersion {
	NSLog(@"[PixelSlanter] interfaceVersion");
	return 1;
}

- (NSString *)title {
	NSLog(@"[PixelSlanter] title");
	return @"Pixel Slanter";
}

- (NSString *)actionName {
	return @"Slant";
}

- (NSString *)keyEquivalent {
	return nil;
}

// Called before each filter run to populate the dialog with saved values.
- (nullable NSError *)setup {
	NSLog(@"[PixelSlanter] setup  angleField=%@", self.angleField);
	[super setup];
	double saved = [[NSUserDefaults standardUserDefaults] doubleForKey:kAngleKey];
	[self.angleField setDoubleValue:(saved != 0.0 ? saved : kAngleDefault)];
	// Show the initial slant preview without requiring user interaction.
	[self process:nil];
	return nil;
}

// IBAction — called by the angle field when its value changes; triggers live preview.
- (IBAction)setAngle:(id)sender {
	NSLog(@"[PixelSlanter] setAngle: %@", sender);
	[self process:nil];
}

// Core processing for the live-preview loop and dialog OK.
// _shadowLayers / _layers are set up by Glyphs before process: is called.
- (void)process:(id)sender {
	NSLog(@"[PixelSlanter] process:  shadowLayers=%lu", (unsigned long)_shadowLayers.count);
	double angle = self.angleField ? self.angleField.doubleValue : kAngleDefault;
	[[NSUserDefaults standardUserDefaults] setDouble:angle forKey:kAngleKey];
	for (NSUInteger k = 0; k < _shadowLayers.count; k++) {
		GSLayer *shadowLayer = _shadowLayers[k];
		GSLayer *layer       = _layers[k];
		[layer getCopyOfContentFromLayer:shadowLayer doSelection:_checkSelection];
		[self _slantComponents:layer angle:angle];
	}
	// If the font uses a coarse grid (e.g. pixel size > 1), migrate that value into
	// gridSubDivision so the effective grid becomes 1 unit.  This lets the slanted
	// component positions land on integer coordinates instead of snapping to the
	// coarser pixel grid.
	GSFont *font = _fontMaster.font;
	if (font && font.gridMain > 1) {
		font.gridSubDivision = font.gridMain;
	}
	[super process:nil];
}

// Called when the filter runs via a Custom Parameter (e.g., on export).
// arguments[0] is the filter name; arguments[1] is the angle value.
- (void)processLayer:(GSLayer *)layer withArguments:(NSArray *)arguments {
	NSLog(@"[PixelSlanter] processLayer:withArguments: %@", arguments);
	double angle = arguments.count > 1 ? [arguments[1] doubleValue] : kAngleDefault;
	[self _slantComponents:layer angle:angle];
}

// Returns the Custom Parameter value string used by Glyphs to reproduce the
// filter programmatically (e.g. in an Instance or export script).
// The base class's setupDialog: automatically adds "Copy Filter Parameter"
// and "Copy PreFilter Parameter" to the gear menu when this method exists.
- (NSString *)customParameterString {
	double angle = self.angleField ? self.angleField.doubleValue : kAngleDefault;
	return [NSString stringWithFormat:@"PixelSlanter;%g;", angle];
}

// Internal helper shared by all code paths.
- (void)_slantComponents:(GSLayer *)layer angle:(double)angle {
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
