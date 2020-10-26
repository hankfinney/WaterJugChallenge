//
//  WaterJug.swift
//  waterJugChallenge
//
//  Created by Henry Minden on 10/25/20.
//

import UIKit

class WaterJug: UIView {

    var size : Int = 1
    var counterpartSize : Int = 1 //we need to know the other jug size to calculate scale factor
    var targetSize : Int = 1
    var scaleFactor : Float = 1.0 //if this is the smaller jug we will scale it proportionally to its counter part (=size/counterpartSize)
    var waterLevel : Int = 0 //initialize the water level
    
    var maxJugSizeContainer : UIView?
    var targetLine : UIView?
    var waterLevelView : UIView?
    
    
    
    var isAnimating = false
    
    func configureView() {
        
        //initialize main container layer radius
        let path = UIBezierPath(roundedRect:self.bounds, byRoundingCorners:[.bottomLeft, .bottomRight ], cornerRadii: CGSize(width: 18, height: 18))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
        
        
        //initialize max jug size container
        maxJugSizeContainer = UIView.init(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        maxJugSizeContainer?.backgroundColor = UIColor.lightGray
        maxJugSizeContainer?.clipsToBounds = true //maintain rounded corners at bottom
        self.addSubview(maxJugSizeContainer!)
        
        
        //initialize water level
        waterLevelView = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 0))
        waterLevelView?.clipsToBounds = true //maintain rounded corners at bottom
        self.addSubview(waterLevelView!)
        
        //initialize gradient view for water level
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor.init(red: 0/255, green: 87/255, blue: 255/255, alpha: 1).cgColor,
                                UIColor.init(red: 84/255, green: 199/255, blue: 252/255, alpha: 1).cgColor]
        waterLevelView?.layer.insertSublayer(gradientLayer, at: 0)
        
        //initialize target line
        targetLine = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 1))
        targetLine?.backgroundColor = UIColor.red
        targetLine?.clipsToBounds = true //maintain rounded corners at bottom
        self.addSubview(targetLine!)
    }
    
    
    func reconfigureJugWithNewParameters(newSize: Int, newCounterpartSize: Int, newTargetSize: Int) {
        
        size = newSize
        counterpartSize = newCounterpartSize
        targetSize = newTargetSize
        
        var targetRatio : Float = 0
        
        if size < counterpartSize  {
            //if this jug is smaller than counter part we will scale it proportionally
            scaleFactor = Float(size) / Float(counterpartSize)
            
            //in this case we will base the target height off the counterpart size
            targetRatio = Float(targetSize) / Float(counterpartSize)
            
        } else {
            scaleFactor = 1.0
            
            //in this case we'll base the target height off our size
            targetRatio = Float(targetSize) / Float(size)
        }
        
        let newHeight = self.frame.size.height * CGFloat(scaleFactor)
        let currentHeight = self.frame.size.height
        let currentWidth = self.frame.size.width
        
        maxJugSizeContainer?.frame = CGRect(x: 0, y: currentHeight - newHeight, width: currentWidth, height: newHeight)
        
        let newTargetHeight = self.frame.size.height * CGFloat(targetRatio)
        
        targetLine?.frame = CGRect(x: 0, y: currentHeight - newTargetHeight, width: currentWidth, height: 1)
 
        
    }
    
    func setJugWaterLevel(toLevel: Int, animated: Bool, completion: @escaping () -> Void) {
        
        waterLevel = toLevel
        
        var waterLevelRatio : Float = 0
        
        if scaleFactor < 1.0 {
            //if this jug is smaller than its counterpart base the water level on the counterpart
            waterLevelRatio = Float(toLevel) / Float(counterpartSize)
        } else {
            //this jug is the larger one use it to determine water level ratio
            waterLevelRatio = Float(toLevel) / Float(size)
        }
        
        let currentHeight = self.frame.size.height
        let currentWidth = self.frame.size.width
        let newWaterLevelHeight = self.frame.size.height * CGFloat(waterLevelRatio)
        
        if animated {
            UIView.animate(withDuration: 1.0) {
                self.waterLevelView?.frame = CGRect(x: 0, y: currentHeight - newWaterLevelHeight, width: currentWidth, height: newWaterLevelHeight)
            } completion: { (Bool) in
                completion()
            }
        } else {
            self.waterLevelView?.frame = CGRect(x: 0, y: currentHeight - newWaterLevelHeight, width: currentWidth, height: newWaterLevelHeight)
            
            //need this completion to continue execution in skip mode
            completion()
        }
        
        

    }

}
