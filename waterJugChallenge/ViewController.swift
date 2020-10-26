//
//  ViewController.swift
//  waterJugChallenge
//
//  Created by Henry Minden on 10/24/20.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource {

    //storyboard outlets
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var solveButton: UIButton!
    
    @IBOutlet var waterJugX: WaterJug!
    @IBOutlet var waterJugY: WaterJug!
    
    @IBOutlet var fillXFaucet: WaterFaucet!
    @IBOutlet var fillYFaucet: WaterFaucet!
    @IBOutlet var xToYFaucet: WaterFaucet!
    @IBOutlet var yToXFaucet: WaterFaucet!
    @IBOutlet var drainXFaucet: WaterFaucet!
    @IBOutlet var drainYFaucet: WaterFaucet!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeight: NSLayoutConstraint!
    
    //var tableViewCollapsedHeight : CGFloat = 0
    var isTableCollapsed : Bool = true
    
    //initialize array to store the solution steps
    var solutionStepData : [(Int,String)] = []
    
    //initialize values for picker view
    let pickerValues = Array(1...10000)
    
    //initialize solver instance
    let waterSolver = WaterSolver()
    
    //initialize jug sizes and target size
    var xSize : Int = 1
    var ySize : Int = 1
    var zSize : Int = 1
    
    //enables solve button
    var solvable : Bool = false
    
    //used to skip solution
    var skipMode : Bool = false
    var solving : Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        solveButton.layer.cornerRadius = 18
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 18

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //need to configure subviews after container view bounds are established
        waterJugX.configureView()
        waterJugY.configureView()
        
        //configure particle effects
        fillXFaucet.configureView(type: WaterFaucetType.topDown)
        fillYFaucet.configureView(type: WaterFaucetType.topDown)
        
        xToYFaucet.configureView(type: WaterFaucetType.leftToRight)
        yToXFaucet.configureView(type: WaterFaucetType.rightToLeft)
        
        drainXFaucet.configureView(type: WaterFaucetType.topDown)
        drainYFaucet.configureView(type: WaterFaucetType.topDown)
        
        fillXFaucet.clipsToBounds = true
        fillYFaucet.clipsToBounds = true
        xToYFaucet.clipsToBounds = true
        yToXFaucet.clipsToBounds = true
        drainXFaucet.clipsToBounds = true
        drainYFaucet.clipsToBounds = true
        
        //set the tableView to collapsed height
        tableViewHeight.constant = 44
        view.needsUpdateConstraints()
        view.layoutIfNeeded()
     
    }
    
    func checkSolvability(xSize: Int, ySize: Int, zSize: Int) {
        
        do {
            solvable = try waterSolver.checkSolvability(xSize: xSize, ySize: ySize, zSize: zSize)
            
            updateSolveButton(title: "Solve")
            
        } catch WaterSolverError.targetLargerThanLargestJug {
            solvable = false
            updateSolveButton(title: "Z larger than largest jug")
        } catch WaterSolverError.gcdXYDoesntDivideTarget {
            solvable = false
            updateSolveButton(title: "Unsolvable with current inputs")
        } catch {
            solvable = false
            updateSolveButton(title: "Unknown error")
        }
        
    }
    
    func updateSolveButton(title: String) {
        
        solveButton.setTitle(title, for: UIControl.State.normal)
        
        if solvable {
            solveButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            solveButton.backgroundColor = UIColor(red: 84.0/255.0, green: 199.0/255.0, blue: 252.0/255.0, alpha: 1.0)
        } else {
            solveButton.setTitleColor(UIColor.red, for: UIControl.State.normal)
            solveButton.backgroundColor = UIColor.white
        }
    }
    
    func refreshParametersAndCheckSolvability() {
        
        //reset jug sizes and target size
        xSize = pickerValues[pickerView.selectedRow(inComponent: 0)]
        ySize = pickerValues[pickerView.selectedRow(inComponent: 1)]
        zSize = pickerValues[pickerView.selectedRow(inComponent: 2)]
        
        checkSolvability(xSize: xSize, ySize: ySize, zSize: zSize)
        
        waterJugX.reconfigureJugWithNewParameters(newSize: xSize, newCounterpartSize: ySize, newTargetSize: zSize)
        waterJugY.reconfigureJugWithNewParameters(newSize: ySize, newCounterpartSize: xSize, newTargetSize: zSize)
        
        //clear out previous state of water jugs
        if waterJugX.waterLevel > 0 ||  waterJugY.waterLevel > 0{
            waterJugX.setJugWaterLevel(toLevel: 0, animated: false, completion: {})
            waterJugY.setJugWaterLevel(toLevel: 0, animated: false, completion: {})
        }
        
        //re-enable the button in case it is disabled from solve completion
        solveButton.isUserInteractionEnabled = true
     
    }

    @IBAction func solveTouched(_ sender: Any) {
        
        if solving && !skipMode {
            skipMode = true
        } else {
            
            if solvable {
            
                //clear out table
                solutionStepData = []
                tableView.reloadData()
                
                //clear out previous state of water jugs
                if waterJugX.waterLevel > 0 ||  waterJugY.waterLevel > 0{
                    waterJugX.setJugWaterLevel(toLevel: 0, animated: false, completion: {})
                    waterJugY.setJugWaterLevel(toLevel: 0, animated: false, completion: {})
                }
            
                //disable the picker view and solve button while solving
                pickerView.isUserInteractionEnabled = false
                solving = true
                
                let solution = waterSolver.getEfficientPourSequence(xSize: xSize, ySize: ySize, zSize: zSize)
                
                let solutionStepsRemaining = solution.count
                
                solveButton.backgroundColor = UIColor.white
                solveButton.setTitleColor(UIColor(red: 84.0/255.0, green: 199.0/255.0, blue: 252.0/255.0, alpha: 1.0), for: UIControl.State.normal)
                
                
                //this gets called recursively until all solution steps are completed
                doSolutionStep(solution: solution, stepsRemaining: solutionStepsRemaining)
                
            }
        }
        
        
        
    }
    
    func skipToFinalStep(solution: [(pourOp: PourOperationType, sourceLevel: Int, destLevel: Int, isXSource: Bool)]){
        
        solutionStepData = []
        var solutionStepIndex = 0
        
        for solutionStep in solution {
                
            var lastSolutionStep : (pourOp: PourOperationType, sourceLevel: Int, destLevel: Int, isXSource: Bool)?
            if solutionStepIndex > 0 {
                lastSolutionStep = solution[solutionStepIndex - 1]
            } else {
                //put a dummy zero value here in the case we are on the first step, since the last fill values will always be zero in that case
                lastSolutionStep = (PourOperationType.EmptyDestination, 0,0,false)
            }
            
            switch solutionStep.pourOp {
            case PourOperationType.FillSource:
                if solutionStep.isXSource {
                    
                    //add solution step to table view
                    solutionStepData.append((solutionStepIndex + 1,"Fill X to \(solutionStep.sourceLevel), Y still \(lastSolutionStep!.destLevel)"))
                    
                } else {
                    //add solution step to table view
                    solutionStepData.append((solutionStepIndex + 1,"Fill Y to \(solutionStep.sourceLevel), X still \(lastSolutionStep!.destLevel)"))
                    
                }
                break
            case PourOperationType.PourFromSourceToDestination:
                if solutionStep.isXSource {
            
                    //add solution step to table view
                    solutionStepData.append((solutionStepIndex + 1, "Pour X to Y, X now \(solutionStep.sourceLevel), Y now \(solutionStep.destLevel) "))
                } else {
                    //add solution step to table view
    
                    solutionStepData.append((solutionStepIndex + 1, "Pour Y to X, Y now \(solutionStep.sourceLevel), X now \(solutionStep.destLevel) "))
                }
                break
            case PourOperationType.EmptyDestination:
                if solutionStep.isXSource {
                    //add solution step to table view
                    solutionStepData.append((solutionStepIndex + 1,"Drain Y to \(solutionStep.destLevel), X still \(lastSolutionStep!.sourceLevel)"))
                } else {
                    //add solution step to table view
                    solutionStepData.append((solutionStepIndex + 1,"Drain X to \(solutionStep.destLevel), Y still \(lastSolutionStep!.sourceLevel)"))
                }
                break
            
            
            }
            solutionStepIndex += 1
        }
        
    }
    
    
    func doSolutionStep(solution: [(pourOp: PourOperationType, sourceLevel: Int, destLevel: Int, isXSource: Bool)], stepsRemaining: Int)  {
        
        //base case
        if stepsRemaining == 0 || skipMode {
            
            if skipMode {
                skipToFinalStep(solution: solution)
                tableView.reloadData()
                scrollToBottom()
            }
            
            //set to final level
            let finalStep = solution[solution.count - 1]
            if finalStep.isXSource {
                waterJugX.setJugWaterLevel(toLevel: finalStep.sourceLevel, animated: false) {}
                waterJugY.setJugWaterLevel(toLevel: finalStep.destLevel, animated: false) {}
            } else {
                waterJugY.setJugWaterLevel(toLevel: finalStep.sourceLevel, animated: false) {}
                waterJugX.setJugWaterLevel(toLevel: finalStep.destLevel, animated: false) {}
            }
            
            //re-enable the picker
            pickerView.isUserInteractionEnabled = true
            //disable the solve to avoid hitting twice to skip
            solveButton.isUserInteractionEnabled = false
            solveButton.setTitle("Solved in \(solution.count) steps", for: UIControl.State.normal)
            
            //make sure we don't skip next solver run
            solving = false
            skipMode = false
            return
        }
        
        if !skipMode {
            solveButton.setTitle("Skip \(stepsRemaining) steps", for: UIControl.State.normal)
        }
        
        
        
        let solutionStepIndex = solution.count - stepsRemaining
        let solutionStep = solution[solutionStepIndex]
        
        
        var lastSolutionStep : (pourOp: PourOperationType, sourceLevel: Int, destLevel: Int, isXSource: Bool)?
        if solutionStepIndex > 0 {
            lastSolutionStep = solution[solutionStepIndex - 1]
        } else {
            //put a dummy zero value here in the case we are on the first step, since the last fill values will always be zero in that case 
            lastSolutionStep = (PourOperationType.EmptyDestination, 0,0,false)
        }
  
        
        switch solutionStep.pourOp {
        case PourOperationType.FillSource:
            if solutionStep.isXSource {
                
                
                //add solution step to table view
                solutionStepData.append((solutionStepIndex + 1,"Fill X to \(solutionStep.sourceLevel), Y still \(lastSolutionStep!.destLevel)"))
                
                
                //fill x to sourceLevel
                fillXFaucet.turnOnFaucet()
                
                tableView.reloadData()
                
                waterJugX.setJugWaterLevel(toLevel: solutionStep.sourceLevel, animated: !skipMode) {
                    self.fillXFaucet.turnOffFaucet()
                    self.scrollToBottom()
                    //recursive step
                    self.doSolutionStep(solution: solution, stepsRemaining: stepsRemaining - 1)
                }
                
            } else {
                
                
                //add solution step to table view
                solutionStepData.append((solutionStepIndex + 1,"Fill Y to \(solutionStep.sourceLevel), X still \(lastSolutionStep!.destLevel)"))
                
                //fill y to sourceLevel
                fillYFaucet.turnOnFaucet()
                
                tableView.reloadData()
                
                waterJugY.setJugWaterLevel(toLevel: solutionStep.sourceLevel, animated: !skipMode) {
                    self.fillYFaucet.turnOffFaucet()
                    self.scrollToBottom()
                    //recursive step
                    self.doSolutionStep(solution: solution, stepsRemaining: stepsRemaining - 1)
                }
                
                
            }
            
            break
        case PourOperationType.PourFromSourceToDestination:
            if solutionStep.isXSource {
                
                
                //add solution step to table view
                solutionStepData.append((solutionStepIndex + 1, "Pour X to Y, X now \(solutionStep.sourceLevel), Y now \(solutionStep.destLevel) "))
                
                //set x to source level
                xToYFaucet.turnOnFaucet()
                
                tableView.reloadData()
                
                waterJugX.setJugWaterLevel(toLevel: solutionStep.sourceLevel, animated: !skipMode) {
                    
                    self.xToYFaucet.turnOffFaucet()
                    self.scrollToBottom()
                    
                    //both of these functions will execute at the same time so we only call recursive step after one completes
                    self.doSolutionStep(solution: solution, stepsRemaining: stepsRemaining - 1)
                }
                //set y to dest level
                waterJugY.setJugWaterLevel(toLevel: solutionStep.destLevel, animated: !skipMode) {
                    
                }
                
            } else {
                
                
                //add solution step to table view
                solutionStepData.append((solutionStepIndex + 1, "Pour Y to X, Y now \(solutionStep.sourceLevel), X now \(solutionStep.destLevel) "))
                
                //set y to source level
                yToXFaucet.turnOnFaucet()
                
                tableView.reloadData()
                
                waterJugY.setJugWaterLevel(toLevel: solutionStep.sourceLevel, animated: !skipMode) {
                    
                    self.yToXFaucet.turnOffFaucet()
                    self.scrollToBottom()
                    
                    //both of these functions will execute at the same time so we only call recursive step after one completes
                    self.doSolutionStep(solution: solution, stepsRemaining: stepsRemaining - 1)
                }
                //set  x to dest level
                waterJugX.setJugWaterLevel(toLevel: solutionStep.destLevel, animated: !skipMode) {
                    
                }
                
            }
            break
        case PourOperationType.EmptyDestination:
            if solutionStep.isXSource {
                
                
                //add solution step to table view
                solutionStepData.append((solutionStepIndex + 1,"Drain Y to \(solutionStep.destLevel), X still \(lastSolutionStep!.sourceLevel)"))
                tableView.reloadData()
                
                //set y to dest level
                drainYFaucet.turnOnFaucet()
                
                waterJugY.setJugWaterLevel(toLevel: solutionStep.destLevel, animated: !skipMode) {
                    self.drainYFaucet.turnOffFaucet()
                    self.scrollToBottom()
                    
                    //recursive step
                    self.doSolutionStep(solution: solution, stepsRemaining: stepsRemaining - 1)
                    
                }
                
                
            } else {
                
                
                //add solution step to table view
                solutionStepData.append((solutionStepIndex + 1,"Drain X to \(solutionStep.destLevel), Y still \(lastSolutionStep!.sourceLevel)"))
                
                //set x to dest level
                drainXFaucet.turnOnFaucet()
                
                tableView.reloadData()
                
                waterJugX.setJugWaterLevel(toLevel: solutionStep.destLevel, animated: !skipMode) {
                    self.drainXFaucet.turnOffFaucet()
                    self.scrollToBottom()
                    
                    //recursive step
                    self.doSolutionStep(solution: solution, stepsRemaining: stepsRemaining - 1)
                    
                }
                
                
            }
            break
  
        }
        
      
        
    }
    
    //======================================
    //===  picker view delegate methods ====
    //======================================
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        refreshParametersAndCheckSolvability()
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        var pickerLabel = view as? UILabel;

        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.textColor = UIColor(red: 84.0/255.0, green: 199.0/255.0, blue: 252.0/255.0, alpha: 1.0)
            pickerLabel?.font = UIFont(name: "HiraginoSans-W6", size: 22)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }

        pickerLabel?.text = String(pickerValues[row])
        
        refreshParametersAndCheckSolvability()
        
        return pickerLabel!
    }
    
    //======================================
    //===  table view delegate methods =====
    //======================================

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "solutionStepCell", for: indexPath) as! SolutionStepTableViewCell
        let solutionStep = solutionStepData[indexPath.row]
        
        cell.solutionStepNumber.text = String(solutionStep.0)
        cell.solutionStepText.text = solutionStep.1
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solutionStepData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func scrollToBottom() {
        //this scrolls the table view to the last row
        let indexPath = IndexPath(row: solutionStepData.count-1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //expand the table if it is collapsed and collapse it if expanded
        if isTableCollapsed {
            
            tableViewHeight.constant = 440
            view.setNeedsUpdateConstraints()
            
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            } completion: { (Bool) in
                self.isTableCollapsed = false
            }

        } else {
            
            tableViewHeight.constant = 44
            view.setNeedsUpdateConstraints()
            
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            } completion: { (Bool) in
                self.isTableCollapsed = true
            }
            
        }
        
    }
    
}

