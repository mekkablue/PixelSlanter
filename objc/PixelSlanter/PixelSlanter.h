// PixelSlanter.h

#import <Cocoa/Cocoa.h>
#import <GlyphsCore/GlyphsFilterProtocol.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSComponent.h>
#import <GlyphsCore/GSFontMaster.h>

NS_ASSUME_NONNULL_BEGIN

@interface PixelSlanter : NSObject <GlyphsFilterProtocol>

// Connected in Dialog.xib; custom class GSSteppingTextField set there.
@property (weak) IBOutlet NSView       *theView;
@property (weak) IBOutlet NSTextField  *angleField;

@end

NS_ASSUME_NONNULL_END
