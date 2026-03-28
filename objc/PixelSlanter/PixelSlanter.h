// PixelSlanter.h

#import <Cocoa/Cocoa.h>

#if __has_include(<GlyphsCore/GlyphsFilterProtocol.h>)
#  import <GlyphsCore/GlyphsFilterProtocol.h>
#  import <GlyphsCore/GSLayer.h>
#  import <GlyphsCore/GSComponent.h>
#  import <GlyphsCore/GSFontMaster.h>
#else
//  Minimal stubs for compiling without GlyphsCore SDK headers installed.
//  The real implementations are provided by the Glyphs runtime at load time.

@class GSComponent;

@interface GSFontMaster : NSObject
- (CGFloat)slantHeightForLayer:(id)layer;
@end

@interface GSLayer : NSObject
@property (nonatomic, readonly) GSFontMaster               *master;
@property (nonatomic, readonly) NSArray<GSComponent *>     *components;
@end

@interface GSComponent : NSObject
@property (nonatomic) NSPoint position;
@end

@protocol GlyphsFilterProtocol <NSObject>
@required
- (NSUInteger)interfaceVersion;
- (NSString *)title;
- (BOOL)setup;
- (NSView *)theView;
- (void)processLayer:(GSLayer *)layer options:(NSDictionary<NSString *, id> *)options;
@optional
- (NSString *)actionName;
@end

#endif  // __has_include

NS_ASSUME_NONNULL_BEGIN

@interface PixelSlanter : NSObject <GlyphsFilterProtocol>

// Both outlets are connected in Dialog.xib.
// angleField has custom class GSSteppingTextField set in the XIB.
@property (weak) IBOutlet NSView      *theView;
@property (weak) IBOutlet NSTextField *angleField;

@end

NS_ASSUME_NONNULL_END
