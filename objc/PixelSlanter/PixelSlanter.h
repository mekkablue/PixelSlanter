// PixelSlanter.h

#import <Cocoa/Cocoa.h>

#if __has_include(<GlyphsCore/GlyphsFilterProtocol.h>)
#  import <GlyphsCore/GlyphsFilterProtocol.h>
#  import <GlyphsCore/GSLayer.h>
#  import <GlyphsCore/GSComponent.h>
#  import <GlyphsCore/GSFontMaster.h>
#else
//  Minimal stubs for compiling without GlyphsCore SDK headers.
//  The real implementations are provided by the Glyphs runtime at load time.
//  We do NOT stub @protocol GlyphsFilterProtocol to avoid a runtime protocol
//  conflict: Glyphs uses respondsToSelector: for method discovery, not conformsToProtocol:.

@class GSComponent;

NS_ASSUME_NONNULL_BEGIN

@interface GSFontMaster : NSObject
- (CGFloat)slantHeightForLayer:(nullable id)layer;
@end

@interface GSLayer : NSObject
@property (nonatomic, readonly) GSFontMaster           *master;
@property (nonatomic, readonly) NSArray<GSComponent *> *components;
@end

@interface GSComponent : NSObject
@property (nonatomic) NSPoint position;
@end

NS_ASSUME_NONNULL_END

#endif  // __has_include

NS_ASSUME_NONNULL_BEGIN

// Declare as plain NSObject — no formal protocol conformance.
// Glyphs discovers filter methods via respondsToSelector:, not conformsToProtocol:.
// Declaring <GlyphsFilterProtocol> would embed a stub protocol object that conflicts
// with the real one in GlyphsCore, causing "Problem with Plugin."
@interface PixelSlanter : NSObject

// theView is the top-level XIB object — strong so it survives after NIB load.
@property (strong, nullable) IBOutlet NSView      *theView;
// angleField is a subview retained by the view hierarchy.
@property (weak,   nullable) IBOutlet NSTextField *angleField;

@end

NS_ASSUME_NONNULL_END
