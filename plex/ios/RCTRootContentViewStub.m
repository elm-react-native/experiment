#undef RCT_REMOVE_LEGACY_ARCH
#import <React/RCTComponent.h>
#import <React/RCTRootContentView.h>

@implementation RCTRootContentView

- (instancetype)initWithFrame:(CGRect)frame
                       bridge:(RCTBridge *)bridge
                     reactTag:(NSNumber *)reactTag
              sizeFlexibility:(RCTRootViewSizeFlexibility)sizeFlexibility
{
  if ((self = [super initWithFrame:frame])) {
    _bridge = bridge;
    ((id<RCTComponent>)self).reactTag = reactTag;
    _sizeFlexibility = sizeFlexibility;
  }
  return self;
}

- (void)invalidate
{
}

- (CGSize)availableSize
{
  return self.bounds.size;
}

- (void)updateAvailableSize
{
}

@end
