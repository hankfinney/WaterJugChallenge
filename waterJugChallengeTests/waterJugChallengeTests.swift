//
//  waterJugChallengeTests.swift
//  waterJugChallengeTests
//
//  Created by Henry Minden on 10/24/20.
//

import XCTest
@testable import waterJugChallenge

class waterJugChallengeTests: XCTestCase {

    var sut : WaterSolver!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        super.setUp()
        sut = WaterSolver()
        
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        sut = nil
        super.tearDown()
    }

    func testIfSolvable() throws {
        
        let solvable = try sut.checkSolvability(xSize: 5, ySize: 3, zSize: 4)
        
        XCTAssertEqual(solvable, true, "Test case is solvable")
        
    }
    
    func testInvalidInputs() throws {
       
        //we expect an error with this input
        XCTAssertThrowsError(try sut.checkSolvability(xSize: 5, ySize: 5, zSize: 1)){
            error in
            XCTAssertEqual(error as! WaterSolverError, WaterSolverError.gcdXYDoesntDivideTarget)
        }
          
    }
    
    func testInvalidInputsTwo() throws {
        
        //we expect an error with this input
        XCTAssertThrowsError(try sut.checkSolvability(xSize: 6, ySize: 10, zSize: 12)){
            error in
            XCTAssertEqual(error as! WaterSolverError, WaterSolverError.targetLargerThanLargestJug)
        }
        
    }
    
    func testSolver() throws {
     
        let solution = sut.getEfficientPourSequence(xSize: 3, ySize: 5, zSize: 4)
        
        XCTAssertEqual(solution.count , 6, "Solution for known case is wrong")
    }
    


}
