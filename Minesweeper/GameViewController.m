//
//  GameViewController.m
//  Minesweeper
//
//  Created by Deshmukh,Richa on 10/25/15.
//  Copyright (c) 2015 Richa. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GameViewController.h"
#import "BoardCellCollectionViewCell.h"
#import "Board.h"

@interface GameViewController()

@property (weak, nonatomic) IBOutlet UICollectionView *boardView;

@property (nonatomic) NSInteger count;
@property (nonatomic, strong) Board *board;

@property(nonatomic) GameStatus gameStatus;
@property(nonatomic) NSInteger mineCount;
@property(nonatomic) NSInteger squaresCount;
@property (weak, nonatomic) IBOutlet UILabel *minesLeftLabel;

@end

@implementation GameViewController

#define kboardSize 8
#define kmineCount 10

-(void) viewDidLoad
{
    self.count = 0;
    
    UINib *cellNib = [UINib nibWithNibName:@"CollectionViewCell" bundle:nil];
    [self.boardView registerNib:cellNib forCellWithReuseIdentifier:@"BoardCell"];
    [self setupLongPressGesture];
    
    [self startNewGame];
}

-(void) startNewGame
{
    self.board = [[Board alloc] initWithBoardSize:kboardSize];
    [self.board createBoardWithMineCount:kmineCount];
    self.mineCount = 0;
    self.squaresCount = 0;
    self.gameStatus = GamePlaying;
    [self updateMinesLeftLabelWithValue:kmineCount];
}


-(void) setupLongPressGesture
{
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.boardView addGestureRecognizer:lpgr];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded || self.gameStatus != GamePlaying || self.mineCount >= kmineCount) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.boardView];
    
    NSIndexPath *indexPath = [self.boardView indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        
        Square *square = [self.board squareAtRow:indexPath.section andColumn:indexPath.row];
        if(square.squareStatus == ClosedSquare)
        {
            square.squareStatus = FlaggedSquare;
            self.mineCount++;
            self.squaresCount++;
            [self.boardView reloadItemsAtIndexPaths:@[indexPath]];
            [self updateMinesLeftLabelWithValue:(kmineCount - self.mineCount)];
        }
    }
}

-(void) updateMinesLeftLabelWithValue: (NSInteger) value
{
    self.minesLeftLabel.text = [NSString stringWithFormat:@"%ld", value];
}

#pragma mark - UICollectionView Datasource

/*
 * Returns number of sections
 */
-(NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return kboardSize;
}

/*
 * Returns number of rows
 */
-(NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return kboardSize;
}

/*
 * Returns cell in board
 */
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Square *square = [self.board squareAtRow:indexPath.section andColumn:indexPath.row];
    
    static NSString *cellIdentifier = @"BoardCell";

    BoardCellCollectionViewCell *cell = (BoardCellCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [self showCell:square atCell:cell];
    [self showSquareValue:square atCell:cell];

    return cell;
}

-(void) validateGameWin
{
    if([self isGameWon]){
        self.gameStatus = GameWon;
        [self showGameWinAlert];
    }
}

-(void) closedSquareSelected : (Square *) square
{
    square.squareStatus = OpenedSquare;
    if(square.minePresent){
        self.gameStatus = GameLost;
        [self showGameLossAlert];
    }
    self.squaresCount++;
}

-(void) flaggedSquareSelected: (Square *) square
{
    square.squareStatus = ClosedSquare;
    self.mineCount--;
    [self updateMinesLeftLabelWithValue:kmineCount - self.mineCount];
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    Square *square = [self.board squareAtRow:indexPath.section andColumn:indexPath.row];
    
    if(self.gameStatus != GamePlaying || square.squareStatus == OpenedSquare){
        return;
    }
    
    if(square.squareStatus == ClosedSquare){
        [self closedSquareSelected:square];
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    
    else if(square.squareStatus == FlaggedSquare){
        [self flaggedSquareSelected:square];
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    
    if(square.value == 0 && square.minePresent == NO){
        [self rippleEffect: square];
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    
    [self validateGameWin];
}

-(void) updateAfterRippleEffectSquare: (Square *) sq{
    if(sq.squareStatus == ClosedSquare && sq.minePresent == NO){
        sq.squareStatus = OpenedSquare;
        self.squaresCount++;
        if(sq.value == 0){
            [self rippleEffect: sq];
        }
    }
}

-(void) rippleEffect: (Square *) square{
    NSInteger row = square.row;
    NSInteger col = square.column;
    
    if(row > 0){
        Square *sq = [self.board squareAtRow:row - 1 andColumn:col];
        [self updateAfterRippleEffectSquare:sq];
        [self.boardView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:col inSection:row-1]]];
    }
    
    if(row < (kboardSize - 1)){
        Square *sq = [self.board squareAtRow:row + 1 andColumn:col];
        [self updateAfterRippleEffectSquare:sq];
        [self.boardView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:col inSection:row+1]]];
    }
    if(col > 0){
        Square *sq = [self.board squareAtRow:row andColumn:col - 1];
        [self updateAfterRippleEffectSquare:sq];
        [self.boardView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:col-1 inSection:row]]];
    }
    
    if(col < (kboardSize - 1)){
        Square *sq = [self.board squareAtRow:row andColumn:col + 1];
        [self updateAfterRippleEffectSquare:sq];
        [self.boardView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:col+1 inSection:row]]];
    }
    
    if(row < (kboardSize - 1) && col < (kboardSize - 1)){
        Square *sq = [self.board squareAtRow:row + 1 andColumn:col + 1];
        [self updateAfterRippleEffectSquare:sq];
        [self.boardView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:col+1 inSection:row+1]]];
    }
    
    if(row > 0 && col < (kboardSize - 1)){
        Square *sq = [self.board squareAtRow:row - 1 andColumn:col + 1];
        [self updateAfterRippleEffectSquare:sq];
        [self.boardView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:col+1 inSection:row-1]]];
    }
    
    if(row < (kboardSize - 1) && col > 0){
        Square *sq = [self.board squareAtRow:row + 1 andColumn:col - 1];
        [self updateAfterRippleEffectSquare:sq];
        [self.boardView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:col-1 inSection:row+1]]];
    }
    
    if(row > 0 && col > 0){
        Square *sq = [self.board squareAtRow:row - 1 andColumn:col - 1];
        [self updateAfterRippleEffectSquare:sq];
        [self.boardView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:col-1 inSection:row-1]]];
    }
}


/*
 * Displays value of cell
 */
-(void) showSquareValue : (Square *) square atCell : (BoardCellCollectionViewCell *) cell{
    
    if(square.squareStatus == OpenedSquare){
        if(square.minePresent){
            UIImage *image = [[UIImage imageNamed:@"mine"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.imageView.hidden = NO;
             cell.imageView.tintColor = [UIColor brownColor];
            cell.label.hidden = YES;
            cell.imageView.image = image;
           
        }else{
            cell.imageView.hidden = YES;
            cell.label.hidden = NO;
            cell.label.text = [NSString stringWithFormat:@"%ld", square.value];
        }
    }
    if(square.squareStatus == FlaggedSquare){
        UIImage *image = [[UIImage imageNamed:@"flag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.hidden = NO;
        cell.imageView.tintColor = [UIColor orangeColor];
        cell.label.hidden = YES;
        cell.imageView.image = image;
    }
    
    if(square.squareStatus == ClosedSquare){
        cell.label.hidden = YES;
        cell.imageView.hidden = YES;
    }
}

/*
 * Adds styles to the cells
 */
-(void) showCell : (Square *) square atCell : (BoardCellCollectionViewCell *) cell{
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderWidth=1.0f;
    cell.layer.borderColor=[UIColor brownColor].CGColor;
    cell.label.textColor = [UIColor blackColor];
}

/*
 * Returns size of cell
 */
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = self.boardView.frame.size.height/kboardSize;
    CGFloat width = self.boardView.frame.size.width/kboardSize;
    CGSize size = CGSizeMake(width, height);
    
    return size;
}


-(UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0f;
}

- (IBAction)newGameButtonTapped:(id)sender {
    [self startNewGame];
    [self.boardView reloadData];
}

- (IBAction)cheatButtonTapped:(id)sender {
    for(Square *square in self.board.boardSquares){
        if(square.minePresent){
            square.squareStatus = OpenedSquare;
            self.squaresCount++;
        }
    }
    [self updateMinesLeftLabelWithValue:0];
    [self.boardView reloadData];
}

-(BOOL) isGameWon{
    return (self.squaresCount == kboardSize * kboardSize);
}

- (IBAction)validateButtonTapped:(id)sender {
    if(self.gameStatus == GameLost){
        [self showGameLossAlert];
    }
    else if (self.gameStatus == GameWon){
        [self showGameWinAlert];
    }else{
        [self showGamePlayingAlert];
    }
}

-(void) showGameWinAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Won"
                                                    message:@"Congrtas!! You won"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void) showGameLossAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Lost"
                                                    message:@"Sorry!! You Lost. Start a new game"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void) showGamePlayingAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Keep Playing"
                                                    message:@"You havent completed the game yet"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
