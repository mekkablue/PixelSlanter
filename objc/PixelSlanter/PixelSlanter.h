// PixelSlanter.h

#import <Cocoa/Cocoa.h>
#import <GlyphsCore/GSFilterPlugin.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSComponent.h>
#import <GlyphsCore/GSFontMaster.h>
#import <GlyphsCore/GSProxyShapes.h>

NS_ASSUME_NONNULL_BEGIN

// Subclass GSFilterPlugin so Glyphs recognises this bundle as a filter plugin.
// The runtime class (GSFilterPlugin) is provided by GlyphsCore, which is
// already loaded by Glyphs before any plugin bundles.  We link with
// -undefined dynamic_lookup so the linker does not require the framework at
// build time.
@interface PixelSlanter : GSFilterPlugin

// Top-level view loaded from Dialog.xib (connected as IBOutlet "theView").
@property (strong, nullable) IBOutlet NSView      *theView;
// Angle input field inside the dialog view.
@property (weak,   nullable) IBOutlet NSTextField *angleField;

@end

NS_ASSUME_NONNULL_END
