//
//  CCBReaderDelegate.h
//  SB+SpriteKit
//
//  Created by Steffen Itterheim on 20/03/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

/** CCBSpriteKitReader informal delegate protocol */
@protocol CCBReaderDelegate <NSObject>
@optional
/** Sent only to the rootNode after a CCB was loaded. This is CCBReader doing its job. */
-(void) didLoadFromCCB;

/** Sent only to the rootNode after a CCB was loaded. Sent once for every child node in the node graph.
 Note: node will never equal 'self' because the root node will also receive the didLoadFromCCB and readerDidLoadSelf messages.  */
-(void) readerDidLoadChildNode:(SKNode*)node;

/** Sent to each node loaded from a CCB that implements this method. */
-(void) readerDidLoadSelf;
@end
