// PixelSlanter.m

#import "PixelSlanter.h"
#import <GlyphsApp/GSCallbackHandler.h>
#import <math.h>

static NSString * const kAngleKey     = @"com.mekkablue.PixelSlanter.angle";
static double     const kAngleDefault = 8.0;

@implementation PixelSlanter {
	// In Glyphs 3, GSFilterPlugin owned the _view ivar. In Glyphs 4 the
	// subclass owns it and loads the dialog NIB lazily from the -view getter,
	// so the ivar is declared here and Dialog.xib connects its top-level view
	// to the _view outlet.
	NSView *_view;
}

// Dialog view — loads the NIB the first time Glyphs asks for it.
- (NSView *)view {
	if (!_view) {
		[[NSBundle bundleForClass:[self class]] loadNibNamed:@"Dialog" owner:self topLevelObjects:nil];
	}
	return _view;
}

// v1 API — return 1 to match all working Glyphs filter plugins.
- (NSUInteger)interfaceVersion {
	return 1;
}

- (NSString *)title {
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
	[super setup];
	double saved = [[NSUserDefaults standardUserDefaults] doubleForKey:kAngleKey];
	[self.angleField setDoubleValue:(saved != 0.0 ? saved : kAngleDefault)];
	// Show the initial slant preview without requiring user interaction.
	[self process:nil];
	return nil;
}

// IBAction — called by the angle field when its value changes; triggers live preview.
- (IBAction)setAngle:(id)sender {
	[self process:nil];
}

// Core processing for the live-preview loop and dialog OK.
// _shadowLayers / _layers are set up by Glyphs before process: is called.
- (void)process:(id)sender {
	double angle = self.angleField ? self.angleField.doubleValue : kAngleDefault;
	[[NSUserDefaults standardUserDefaults] setDouble:angle forKey:kAngleKey];
	for (NSUInteger k = 0; k < _shadowLayers.count; k++) {
		GSLayer *shadowLayer = _shadowLayers[k];
		GSLayer *layer       = _layers[k];

		// Restore the untouched shapes from the shadow layer, then re-apply the
		// filter, so the preview is non-destructive. This follows the Glyphs 4
		// filter template instead of -getCopyOfContentFromLayer:doSelection:.
		layer.shapes = [[NSMutableArray alloc] initWithArray:shadowLayer.shapes copyItems:YES];
		layer.selection = [NSMutableOrderedSet new];
		if (_checkSelection && shadowLayer.selection.count > 0) {
			for (NSUInteger i = 0; i < shadowLayer.shapes.count; i++) {
				GSPath *shadowPath = (GSPath *)[shadowLayer objectInShapesAtIndex:i];
				if (![shadowPath isKindOfClass:[GSPath class]]) {
					continue;
				}
				GSPath *layerPath = (GSPath *)[layer objectInShapesAtIndex:i];
				for (NSUInteger j = 0; j < shadowPath.nodes.count; j++) {
					GSNode *shadowNode = [shadowPath nodeAtIndex:j];
					if ([shadowLayer.selection containsObject:shadowNode]) {
						[layer addSelection:[layerPath nodeAtIndex:j]];
					}
				}
			}
		}

		[self _slantComponents:layer angle:angle];
		[layer clearSelection];
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
