// PixelSlanter.h

#import <Cocoa/Cocoa.h>
#import <GlyphsCore/GSFilterPlugin.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSComponent.h>
#import <GlyphsCore/GSDialogController.h>
#import <GlyphsCore/GSFont.h>
#import <GlyphsCore/GSFontMaster.h>
#import <GlyphsCore/GSProxyShapes.h>

NS_ASSUME_NONNULL_BEGIN

// Subclass GSFilterPlugin so Glyphs recognises this bundle as a filter plugin.
// The runtime class (GSFilterPlugin) is provided by GlyphsCore, which is
// already loaded by Glyphs before any plugin bundles.  We link with
// -undefined dynamic_lookup so the linker does not require the framework at
// build time.
@interface PixelSlanter : GSFilterPlugin

// Angle input field inside the dialog view (connected in Dialog.xib).
// The top-level view connects to the inherited 'view' property from GSFilterPlugin.
@property (weak, nullable) IBOutlet NSTextField *angleField;

@end

NS_ASSUME_NONNULL_END
