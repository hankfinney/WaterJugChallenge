//
//  WaterSolver.swift
//  waterJugChallenge
//
//  Created by Henry Minden on 10/24/20.
//

import Foundation

enum WaterSolverError : Error {
    case targetLargerThanLargestJug
    case gcdXYDoesntDivideTarget
}

enum PourOperationType : Int {
    case FillSource = 0
    case PourFromSourceToDestination
    case EmptyDestination
}

class WaterSolver {
    
    func getEfficientPourSequence(xSize: Int, ySize: Int, zSize: Int) -> [(pourOp: PourOperationType, sourceLevel: Int, destLevel: Int, isXSource: Bool)] {
        
        
        //Get pouring sequence with X Jug as source and Y Jug as destination, then vice versa, and return the sequence with the least steps
        let xy = getPouringSequence(fromSize: xSize, toSize: ySize, targetSize: zSize, xSource: true)
        let yx = getPouringSequence(fromSize: ySize, toSize: xSize, targetSize: zSize, xSource: false)
        
        if xy.count > yx.count {
            return yx
        } else {
            //if pouring sequence are equal length we will return xy although either would be valid 
            return xy
        }
        
    }
    
    func checkSolvability(xSize: Int, ySize: Int, zSize: Int) throws -> Bool {
        
        let maxPouringJug = max(xSize, ySize)
        
        //If the target amount z is greater than the largest jug we can't solve this problem
        if zSize > maxPouringJug {
            throw WaterSolverError.targetLargerThanLargestJug
        }
        
        //If the greatest common denominator of Jug X and Jug Y doesn't divide amount Z we can't solve this problem according to Bezout's lemma
        let gcdXY = findGreatestCommonDenominator(a: xSize, b: ySize)
        if zSize % gcdXY != 0 {
            throw WaterSolverError.gcdXYDoesntDivideTarget
        }
        
        return true
        
    }
    
    func findGreatestCommonDenominator(a: Int, b: Int) -> Int {
        
        //use Euclid's algorithm to find gcd recursively
        
        if b == 0 {
            //base case
            return a;
        }
        //recursive step
        return findGreatestCommonDenominator(a: b, b: a % b)
        
    }
    
    func getPouringSequence(fromSize: Int, toSize: Int, targetSize: Int, xSource: Bool) -> [(pourOp: PourOperationType, sourceLevel: Int, destLevel: Int, isXSource: Bool)] {
        
        //Initialize result sequence array
        var result : [(pourOp: PourOperationType, sourceLevel: Int, destLevel: Int, isXSource: Bool)] = []
        
        //Initialize current levels of water in source(from) and destination(to) jugs
        var from = fromSize //fill the source container
        var to = 0
        
        //Initialize steps required
        var step = 1 //first step is filling source
        
        //Push operation details to result sequence
        result.append((pourOp: PourOperationType.FillSource,sourceLevel: from, destLevel: to, isXSource: xSource))
        
        //While loop should cycle until one jug contains target amount
        while from != targetSize && to != targetSize {
            
            //The max amount of water that can be poured is either the source size or free space in the destination, whichever is smaller
            let temp = min( from, toSize - to)
            
            //pour destination to source
            to += temp
            from -= temp
            
            //Increment step counter
            step += 1
            
            //Push operation details to result sequence
            result.append((pourOp: PourOperationType.PourFromSourceToDestination, sourceLevel: from, destLevel: to, isXSource: xSource))
            
            //Break while loop if we hit our target amount
            if from == targetSize || to == targetSize {
                break
            }
            
            //If the source jug is empty, fill it
            if from == 0 {
                from = fromSize
                
                //increment step
                step += 1
                
                //Push operation details to result sequence
                result.append((pourOp: PourOperationType.FillSource, sourceLevel: from, destLevel: to, isXSource: xSource))
            }
            
            //If destination jug is full, empty it
            if to == toSize {
                to = 0
                
                //increment step
                step += 1
                
                //Push operation details to result sequence
                result.append((pourOp: PourOperationType.EmptyDestination, sourceLevel: from, destLevel: to, isXSource: xSource))
            }
        }
        
        //target acheived return number of steps
        return result
        
    }
    
    
    
}
