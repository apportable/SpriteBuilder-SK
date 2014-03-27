/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCBAnimationManager.h"
#import "CCBSequence.h"
#import "CCBSequenceProperty.h"
#import "CCBReader.h"
#import "CCBKeyframe.h"
#import <objc/runtime.h>

#import "CCBReader.h"
#import "CCBReader_Private.h"

static NSInteger ccbAnimationManagerID = 0;

@implementation CCBAnimationManager

@synthesize sequences;
@synthesize autoPlaySequenceId;
@synthesize rootNode;
@synthesize rootContainerSize;
@synthesize owner;
@synthesize delegate;
@synthesize lastCompletedSequenceName;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    animationManagerId = ccbAnimationManagerID;
    ccbAnimationManagerID++;
    
    sequences = [[NSMutableArray alloc] init];
    nodeSequences = [[NSMutableDictionary alloc] init];
    baseValues = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (CGSize) containerSize:(CCNode*)node
{
    if (node) return node.contentSize;
    else return rootContainerSize;
}

- (void) addNode:(CCNode*)node andSequences:(NSDictionary*)seq
{
    NSValue* nodePtr = [NSValue valueWithPointer:(__bridge const void *)(node)];
    [nodeSequences setObject:seq forKey:nodePtr];
}

- (void) moveAnimationsFromNode:(CCNode*)fromNode toNode:(CCNode*)toNode
{
    NSValue* fromNodePtr = [NSValue valueWithPointer:(__bridge const void *)(fromNode)];
    NSValue* toNodePtr = [NSValue valueWithPointer:(__bridge const void *)(toNode)];
    
    // Move base values
    id baseValue = [baseValues objectForKey:fromNodePtr];
    if (baseValue)
    {
        [baseValues setObject:baseValue forKey:toNodePtr];
        [baseValues removeObjectForKey:fromNodePtr];
    }
    
    // Move keyframes
    NSDictionary* seqs = [nodeSequences objectForKey:fromNodePtr];
    if (seqs)
    {
        [nodeSequences setObject:seqs forKey:toNodePtr];
        [nodeSequences removeObjectForKey:fromNodePtr];
    }
}

- (void) setBaseValue:(id)value forNode:(CCNode*)node propertyName:(NSString*)propName
{
    NSValue* nodePtr = [NSValue valueWithPointer:(__bridge const void *)(node)];
    
    NSMutableDictionary* props = [baseValues objectForKey:nodePtr];
    if (!props)
    {
        props = [NSMutableDictionary dictionary];
        [baseValues setObject:props forKey:nodePtr];
    }
    
    [props setObject:value forKey:propName];
}

- (id) baseValueForNode:(CCNode*) node propertyName:(NSString*) propName
{
    NSValue* nodePtr = [NSValue valueWithPointer:(__bridge const void *)(node)];
    
    NSMutableDictionary* props = [baseValues objectForKey:nodePtr];
    return [props objectForKey:propName];
}

- (int) sequenceIdForSequenceNamed:(NSString*)name
{
    for (CCBSequence* seq in sequences)
    {
        if ([seq.name isEqualToString:name])
        {
            return seq.sequenceId;
        }
    }
    return -1;
}

- (CCBSequence*) sequenceFromSequenceId:(int)seqId
{
    for (CCBSequence* seq in sequences)
    {
        if (seq.sequenceId == seqId) return seq;
    }
    return NULL;
}

- (CCActionInterval*) actionFromKeyframe0:(CCBKeyframe*)kf0 andKeyframe1:(CCBKeyframe*)kf1 propertyName:(NSString*)name node:(CCNode*)node
{
	[NSException raise:NSInternalInconsistencyException format:@"CCBAnimationManager: use corresponding method in CCBSpriteKitAnimationManager instead"];
    return NULL;
}

- (void) setAnimatedProperty:(NSString*)name forNode:(CCNode*)node toValue:(id)value tweenDuration:(float) tweenDuration
{
    if (tweenDuration > 0)
    {
        // Create a fake keyframe to generate the action from
        CCBKeyframe* kf1 = [[CCBKeyframe alloc] init];
        kf1.value = value;
        kf1.time = tweenDuration;
        kf1.easingType = kCCBKeyframeEasingLinear;
        
        // Animate
        CCActionInterval* tweenAction = [self actionFromKeyframe0:NULL andKeyframe1:kf1 propertyName:name node:node];
        [node runAction:tweenAction];
    }
    else
    {
        // Just set the value
    
        if ([name isEqualToString:@"position"])
        {
            // Get position type
            //int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];
            
            // Get relative position
            float x = [[value objectAtIndex:0] floatValue];
            float y = [[value objectAtIndex:1] floatValue];
#ifdef __CC_PLATFORM_IOS
            [node setValue:[NSValue valueWithCGPoint:ccp(x,y)] forKey:name];
#elif defined (__CC_PLATFORM_MAC)
            [node setValue:[NSValue valueWithPoint:ccp(x,y)] forKey:name];
#endif
            
            //[node setRelativePosition:ccp(x,y) type:type parentSize:[self containerSize:node.parent] propertyName:name];
        }
        else if ([name isEqualToString:@"scale"])
        {
            // Get scale type
            //int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];
            
            // Get relative scale
            float x = [[value objectAtIndex:0] floatValue];
            float y = [[value objectAtIndex:1] floatValue];
            
            [node setValue:[NSNumber numberWithFloat:x] forKey:[name stringByAppendingString:@"X"]];
            [node setValue:[NSNumber numberWithFloat:y] forKey:[name stringByAppendingString:@"Y"]];
            
            //[node setRelativeScaleX:x Y:y type:type propertyName:name];
        }
        else if ([name isEqualToString:@"skew"])
        {
            node.skewX = [[value objectAtIndex:0] floatValue];
            node.skewY = [[value objectAtIndex:1] floatValue];
        }
        else
        {
            [node setValue:value forKey:name];
        }
    }  
}

- (void) setFirstFrameForNode:(CCNode*)node sequenceProperty:(CCBSequenceProperty*)seqProp tweenDuration:(float)tweenDuration
{
    NSArray* keyframes = [seqProp keyframes];
    
    if (keyframes.count == 0)
    {
        // Use base value (no animation)
        id baseValue = [self baseValueForNode:node propertyName:seqProp.name];
        NSAssert1(baseValue, @"No baseValue found for property (%@)", seqProp.name);
        [self setAnimatedProperty:seqProp.name forNode:node toValue:baseValue tweenDuration:tweenDuration];
    }
    else
    {
        // Use first keyframe
        CCBKeyframe* keyframe = [keyframes objectAtIndex:0];
        [self setAnimatedProperty:seqProp.name forNode:node toValue:keyframe.value tweenDuration:tweenDuration];
    }
}

- (CCActionInterval*) easeAction:(CCActionInterval*) action easingType:(int)easingType easingOpt:(float) easingOpt
{
	[NSException raise:NSInternalInconsistencyException format:@"CCBAnimationManager: use corresponding method in CCBSpriteKitAnimationManager instead"];
	return nil;
}

- (void) removeActionsByTag:(NSInteger)tag fromNode:(CCNode*)node
{
    CCActionManager* am = [[CCDirector sharedDirector] actionManager];
    
    while ([am getActionByTag:(int)tag target:node])
    {
        [am removeActionByTag:(int)tag target:node];
    }
}

- (void) runActionsForNode:(CCNode*)node sequenceProperty:(CCBSequenceProperty*)seqProp tweenDuration:(float)tweenDuration
{
    NSArray* keyframes = [seqProp keyframes];
    int numKeyframes = (int)keyframes.count;
    
    if (numKeyframes > 1)
    {
        // Make an animation!
        NSMutableArray* actions = [NSMutableArray array];
            
        CCBKeyframe* keyframeFirst = [keyframes objectAtIndex:0];
        float timeFirst = keyframeFirst.time + tweenDuration;
        
        if (timeFirst > 0)
        {
            [actions addObject:[CCActionDelay actionWithDuration:timeFirst]];
        }
        
        for (int i = 0; i < numKeyframes - 1; i++)
        {
            CCBKeyframe* kf0 = [keyframes objectAtIndex:i];
            CCBKeyframe* kf1 = [keyframes objectAtIndex:i+1];
            
            CCActionInterval* action = [self actionFromKeyframe0:kf0 andKeyframe1:kf1 propertyName:seqProp.name node:node];
            if (action)
            {
                // Apply easing
                action = [self easeAction:action easingType:kf0.easingType easingOpt:kf0.easingOpt];
                
                [actions addObject:action];
            }
        }
        
        CCActionSequence* seq = [CCActionSequence actionWithArray:actions];
        seq.tag = (int)animationManagerId;
        [node runAction:seq];
    }
}

- (id) actionForCallbackChannel:(CCBSequenceProperty*) channel
{
    float lastKeyframeTime = 0;
    
    NSMutableArray* actions = [NSMutableArray array];
    
    for (CCBKeyframe* keyframe in channel.keyframes)
    {
        float timeSinceLastKeyframe = keyframe.time - lastKeyframeTime;
        lastKeyframeTime = keyframe.time;
        if (timeSinceLastKeyframe > 0)
        {
            [actions addObject:[CCActionDelay actionWithDuration:timeSinceLastKeyframe]];
        }
        
        NSString* selectorName = [keyframe.value objectAtIndex:0];
        int selectorTarget = [[keyframe.value objectAtIndex:1] intValue];
        
        // Callback through obj-c
        id target = NULL;
        if (selectorTarget == kCCBTargetTypeDocumentRoot) target = self.rootNode;
        else if (selectorTarget == kCCBTargetTypeOwner) target = owner;
        
        SEL selector = NSSelectorFromString(selectorName);
        
        if (target && selector)
        {
            [actions addObject:[CCActionCallFunc actionWithTarget:target selector:selector]];
        }
    }
    
    if (!actions.count) return NULL;
    
    return [CCActionSequence actionWithArray:actions];
}

- (id) actionForSoundChannel:(CCBSequenceProperty*) channel
{
	[NSException raise:NSInternalInconsistencyException format:@"Sprite Kit reader does not support sound channel actions yet"];
	return nil;
	/*
    float lastKeyframeTime = 0;
    
    NSMutableArray* actions = [NSMutableArray array];
    
    for (CCBKeyframe* keyframe in channel.keyframes)
    {
        float timeSinceLastKeyframe = keyframe.time - lastKeyframeTime;
        lastKeyframeTime = keyframe.time;
        if (timeSinceLastKeyframe > 0)
        {
            [actions addObject:[CCActionDelay actionWithDuration:timeSinceLastKeyframe]];
        }
        
        NSString* soundFile = [keyframe.value objectAtIndex:0];
        float pitch = [[keyframe.value objectAtIndex:1] floatValue];
        float pan = [[keyframe.value objectAtIndex:2] floatValue];
        float gain = [[keyframe.value objectAtIndex:3] floatValue];
        
        [actions addObject:[CCBSoundEffect actionWithSoundFile:soundFile pitch:pitch pan:pan gain:gain]];
    }
    
    if (!actions.count) return NULL;
    
    return [CCActionSequence actionWithArray:actions];
	*/
}

- (void) runAnimationsForSequenceId:(int)seqId tweenDuration:(float) tweenDuration
{
    NSAssert(seqId != -1, @"Sequence id %d couldn't be found",seqId);
    
    // Stop actions associated with this animation manager
    [self removeActionsByTag:animationManagerId fromNode:rootNode];
    
    for (NSValue* nodePtr in nodeSequences)
    {
        CCNode* node = [nodePtr pointerValue];
        
        // Stop actions associated with this animation manager
        [self removeActionsByTag:animationManagerId fromNode:node];
        
        NSDictionary* seqs = [nodeSequences objectForKey:nodePtr];
        NSDictionary* seqNodeProps = [seqs objectForKey:[NSNumber numberWithInt:seqId]];
        
        NSMutableSet* seqNodePropNames = [NSMutableSet set];
        
        // Reset nodes that have sequence node properties, and run actions on them
        for (NSString* propName in seqNodeProps)
        {
            CCBSequenceProperty* seqProp = [seqNodeProps objectForKey:propName];
            [seqNodePropNames addObject:propName];
            
            [self setFirstFrameForNode:node sequenceProperty:seqProp tweenDuration:tweenDuration];
            [self runActionsForNode:node sequenceProperty:seqProp tweenDuration:tweenDuration];
        }
        
        // Reset the nodes that may have been changed by other timelines
        NSDictionary* nodeBaseValues = [baseValues objectForKey:nodePtr];
        for (NSString* propName in nodeBaseValues)
        {
            if (![seqNodePropNames containsObject:propName])
            {
                id value = [nodeBaseValues objectForKey:propName];
                
                if (value)
                {
                    [self setAnimatedProperty:propName forNode:node toValue:value tweenDuration:tweenDuration];
                }
            }
        }
    }
    
    // Make callback at end of sequence
    CCBSequence* seq = [self sequenceFromSequenceId:seqId];
    CCAction* completeAction = [CCActionSequence actionOne:[CCActionDelay actionWithDuration:seq.duration+tweenDuration] two:[CCActionCallFunc actionWithTarget:self selector:@selector(sequenceCompleted)]];
    completeAction.tag = (int)animationManagerId;
    [rootNode runAction:completeAction];
    
    // Playback callbacks and sounds
    if (seq.callbackChannel)
    {
        // Build sound actions for channel
        CCAction* action = [self actionForCallbackChannel:seq.callbackChannel];
        if (action)
        {
            action.tag = (int)animationManagerId;
            [self.rootNode runAction:action];
        }
    }
    
    if (seq.soundChannel)
    {
		[NSException raise:NSInternalInconsistencyException format:@"Sprite Kit reader does not support sound channels yet"];
		
		/*
        // Build sound actions for channel
        CCAction* action = [self actionForSoundChannel:seq.soundChannel];
        if (action)
        {
            action.tag = (int)animationManagerId;
            [self.rootNode runAction:action];
        }
		 */
    }
    
    // Set the running scene
    runningSequence = [self sequenceFromSequenceId:seqId];
}

- (void) runAnimationsForSequenceNamed:(NSString*)name tweenDuration:(float)tweenDuration
{
    int seqId = [self sequenceIdForSequenceNamed:name];
    [self runAnimationsForSequenceId:seqId tweenDuration:tweenDuration];
}

- (void) runAnimationsForSequenceNamed:(NSString*)name
{
    [self runAnimationsForSequenceNamed:name tweenDuration:0];
}

- (void) sequenceCompleted
{
    // Save last completed sequence
    if (lastCompletedSequenceName != runningSequence.name)
    {
        lastCompletedSequenceName = [runningSequence.name copy];
    }
    
    // Play next sequence
    int nextSeqId = runningSequence.chainedSequenceId;
    runningSequence = NULL;
    
    // Callbacks
    [delegate completedAnimationSequenceNamed:lastCompletedSequenceName];
    if (block) block(self);
    
    // Run next sequence if callbacks did not start a new sequence
    if (runningSequence == NULL && nextSeqId != -1)
    {
        [self runAnimationsForSequenceId:nextSeqId tweenDuration:0];
    }
}

- (NSString*) runningSequenceName
{
    return runningSequence.name;
}

-(void) setCompletedAnimationCallbackBlock:(void(^)(id sender))b
{
    block = [b copy];
}

/*
- (void) setCallFunc:(CCCallBlockN *)callFunc forJSCallbackNamed:(NSString *)callbackNamed
{
    [keyframeCallFuncs setObject:callFunc forKey:callbackNamed];
}
 */

- (void) dealloc
{
    self.rootNode = NULL;
}

- (void) debug
{
    //NSLog(@"baseValues: %@", baseValues);
    //NSLog(@"nodeSequences: %@", nodeSequences);
}

@end
