//
//  GreenCoverNode.m
//  thisarrow
//
//  Created by iMac206 on 17/1/3.
//  Copyright © 2017年 jamstudio. All rights reserved.
//

#import "GreenCoverNode.h"

@implementation GreenCoverNode

+(instancetype)defaultNode
{
    GreenCoverNode* nod=[GreenCoverNode spriteNodeWithImageNamed:@"greenCover"];
    nod.xScale=0;
    nod.yScale=nod.xScale;
    [nod runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction scaleTo:1 duration:0.25],[SKAction repeatActionForever:[SKAction sequence:[NSArray arrayWithObjects:[SKAction waitForDuration:0.1],[SKAction performSelector:@selector(addMovingTrack) onTarget:nod], nil]]],nil]] completion:^{
        
    }];
    return nod;
}

-(void)actionWithHero:(SKNode *)hero
{
    self.position=hero.position;
}

-(void)addMovingTrack
{
    ZZSpriteNode* cir=[ZZSpriteNode spriteNodeWithImageNamed:@"greenCircle"];
    [self.parent addChild:cir];
    cir.xScale=0.99;
    cir.yScale=cir.xScale;
    cir.zPosition=Background_Z_Position;
    cir.position=self.position;
    [cir runAction:[SKAction group:[NSArray arrayWithObjects:[SKAction scaleTo:1.5 duration:1],[SKAction fadeAlphaTo:0 duration:1],nil]] completion:^{
        [cir removeFromParent];
    }];
}

-(BOOL)intersectsNode:(SKNode *)node
{
    CGPoint p0=self.position;
    CGPoint p1=node.position;
    CGFloat dx=p0.x-p1.x;
    CGFloat dy=p0.y-p1.y;
    CGFloat distance=sqrtf(dx*dx+dy*dy);
    BOOL inter=distance<self.frame.size.width/2+node.frame.size.width/2;
    return inter;
}

@end
