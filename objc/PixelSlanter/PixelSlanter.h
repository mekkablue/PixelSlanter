// PixelSlanter.h

#import <Cocoa/Cocoa.h>

// Glyphs 4 moved the plug-in base classes out of GlyphsCore and into the
// GlyphsApp framework, so GSFilterPlugin has to come from <GlyphsApp/…>.
// The object model (GSFont, GSLayer, GSComponent, …) stays in GlyphsCore.
// Compare GlyphsSDK, branch Glyphs4:
// Xcode Templates/Glyphs Dev/Glyphs Filter Plugin.xctemplate
#import <GlyphsApp/GSFilterPlugin.h>
#import <GlyphsCore/GlyphsCore.h>
#import <GlyphsCore/GSComponent.h>
#import <GlyphsCore/GSFont.h>
#import <GlyphsCore/GSFontMaster.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSPath.h>
#import <GlyphsCore/GSNode.h>
#import <GlyphsCore/GSProxyShapes.h>

NS_ASSUME_NONNULL_BEGIN

// Subclass GSFilterPlugin so Glyphs recognises this bundle as a filter plugin.
@interface PixelSlanter : GSFilterPlugin

// Angle input field inside the dialog view (connected in Dialog.xib).
// The top-level view of the XIB connects to the _view outlet, which this class
// owns itself; see -view in PixelSlanter.m.
@property (weak, nullable) IBOutlet NSTextField *angleField;

@end

NS_ASSUME_NONNULL_END
