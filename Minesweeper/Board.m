//
//  Board.m
//  Minesweeper
//
//  Created by Deshmukh,Richa on 10/27/15.
//  Copyright (c) 2015 Richa. All rights reserved.
//

#import "Board.h"

@interface Board()

@property(nonatomic, strong, readwrite) NSMutableArray *boardSquares; //Array of type square
@property (nonatomic) NSInteger boardSize;

@end

@implementation Board

/*
 * Initialze board
 */
-(instancetype) initWithBoardSize : (NSInteger) boardSize
{
    self = [super init];
    if(self)
    {
        _boardSquares = [NSMutableArray array];
        _boardSize = boardSize;
        [self initializeBoard];
    }
    return self;
}

-(void) initializeBoard
{
    for(int i = 0; i < self.boardSize; i++)
    {
        for(int j = 0; j < self.boardSize; j++)
        {
            Square *square = [[Square alloc] init];
            square.row = i;
            square.column = j;
            square.squareStatus = ClosedSquare;
            [self.boardSquares addObject:square];
        }
    }
}

/*
 * Create a board with number of mines
 */
-(void) createBoardWithMineCount:(NSInteger)mineCount
{
    [self placeRandomMines:mineCount];
    for(Square *square in self.boardSquares){
         NSInteger valCount = 0;
        
        if(!square.minePresent){
            NSInteger row = square.row;
            NSInteger col = square.column;
            
            if(row > 0){
                Square *sq = [self squareAtRow:row - 1 andColumn:col];
                if(sq.minePresent)
                {
                    valCount++;
                }
            }
            
            if(row < (self.boardSize - 1)){
                Square *sq = [self squareAtRow:row + 1 andColumn:col];
                if(sq.minePresent)
                {
                    valCount++;
                }
            }
            if(col > 0){
                Square *sq = [self squareAtRow:row andColumn:col - 1];
                if(sq.minePresent)
                {
                    valCount++;
                }
            }
            
            if(col < (self.boardSize - 1)){
                Square *sq = [self squareAtRow:row andColumn:col + 1];
                if(sq.minePresent)
                {
                    valCount++;
                }
            }
            
            if(row < (self.boardSize - 1) && col < (self.boardSize - 1)){
                Square *sq = [self squareAtRow:row + 1 andColumn:col + 1];
                if(sq.minePresent)
                {
                    valCount++;
                }
            }
            
            if(row > 0 && col < (self.boardSize - 1)){
                Square *sq = [self squareAtRow:row - 1 andColumn:col + 1];
                if(sq.minePresent)
                {
                    valCount++;
                }
            }
            
            if(row < (self.boardSize - 1) && col > 0){
                Square *sq = [self squareAtRow:row + 1 andColumn:col - 1];
                if(sq.minePresent)
                {
                    valCount++;
                }
            }
            
            if(row > 0 && col > 0){
                Square *sq = [self squareAtRow:row - 1 andColumn:col - 1];
                if(sq.minePresent)
                {
                    valCount++;
                }
            }
        }
        square.value = valCount;
        square.squareStatus = ClosedSquare;
    }
}

/*
 * Place mines in random squares
 */
-(void) placeRandomMines:(NSInteger)mineCount
{
    NSInteger i = 0;
    while(i < mineCount)
    {
        //TODO should this be boardsize - 1?
        int randomRow = arc4random_uniform((int)self.boardSize);
        int randomCol = arc4random_uniform((int)self.boardSize);
        
        Square *square = [self squareAtRow:randomRow andColumn:randomCol];
        if(!square.minePresent)
        {
            square.minePresent = YES;
            square.value = INT_MAX;
            i++;
        }
    }
}

/*
 * Returns square at specified row and column
 */
-(Square *) squareAtRow: (NSInteger) row andColumn : (NSInteger) column
{
    for(int i = 0; i < self.boardSquares.count; i++)
    {
        Square *square = [self.boardSquares objectAtIndex:i];
        if(square.row == row && square.column == column)
        {
            return square;
        }
    }
    return nil;
}


@end
