//
//  Board.h
//  Minesweeper
//
//  Created by Deshmukh,Richa on 10/27/15.
//  Copyright (c) 2015 Richa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Square.h"

@interface Board : NSObject

@property(nonatomic, strong, readonly) NSMutableArray *boardSquares; //Array of type square

/*
 * Initialze board
 */
-(instancetype) initWithBoardSize : (NSInteger) boardSize;

/*
 * Create a board with number of mines
 */
-(void) createBoardWithMineCount: (NSInteger) mineCount;

/*
 * Returns square at specified row and column
 */
-(Square *) squareAtRow: (NSInteger) row andColumn : (NSInteger) column;

@end
