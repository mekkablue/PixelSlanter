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

@protocol GlyphsFilterProtocol <NSObject>
@required
- (NSUInteger)interfaceVersion;
- (NSString *)title;
- (BOOL)setup;
- (nullable NSView *)theView;
- (void)processLayer:(GSLayer *)layer withArguments:(NSDictionary<NSString *, id> *)arguments;
@optional
- (NSString *)actionName;
@end

NS_ASSUME_NONNULL_END

#endif  // __has_include

NS_ASSUME_NONNULL_BEGIN

@interface PixelSlanter : NSObject <GlyphsFilterProtocol>

// theView is the top-level XIB object — strong so it survives after NIB load.
@property (strong, nullable) IBOutlet NSView      *theView;
// angleField is a subview retained by the view hierarchy.
@property (weak,   nullable) IBOutlet NSTextField *angleField;

@end

NS_ASSUME_NONNULL_END
