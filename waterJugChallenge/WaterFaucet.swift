//
//  WaterFaucet.swift
//  waterJugChallenge
//
//  Created by Henry Minden on 10/25/20.
//

import UIKit
import QuartzCore

enum WaterFaucetType : Int {
    case topDown = 0
    case leftToRight
    case rightToLeft
}

class WaterFaucet: UIView {

    var particleEmitter : CAEmitterLayer?
    
    func configureView(type: WaterFaucetType) {
        
        //add particle effect
        let particleLayer = CAEmitterLayer()
        
        particleLayer.emitterShape = CAEmitterLayerEmitterShape.line;
        particleLayer.emitterZPosition = 10
        particleLayer.renderMode = CAEmitterLayerRenderMode.additive
        
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage.init(named: "dropletSmall")?.cgImage
        emitterCell.scale = 0.1
        emitterCell.scaleRange = 0.4
 
        emitterCell.scaleRange = 0.2
        emitterCell.lifetime = 2.0
        emitterCell.birthRate = 1000
        emitterCell.emissionRange = CGFloat.pi / 12
        
        switch type {
        
        case WaterFaucetType.topDown:
            
            emitterCell.velocity = -100
            emitterCell.velocityRange = 50
            emitterCell.yAcceleration = 250
            
            particleLayer.emitterCells = [emitterCell]
            
            particleEmitter = particleLayer
            particleEmitter!.birthRate = 0.0
            particleEmitter!.emitterPosition = CGPoint(x: self.bounds.size.width / 2, y: 0)
            particleEmitter!.emitterSize = CGSize(width: self.bounds.size.width, height: 0)
            break
        
        case WaterFaucetType.leftToRight:
        
            emitterCell.velocity = 100
            emitterCell.velocityRange = 50
            emitterCell.yAcceleration = -250
 
            particleLayer.emitterCells = [emitterCell]
            
            particleEmitter = particleLayer
            particleEmitter!.birthRate = 0.0
            particleEmitter!.emitterPosition = CGPoint(x: self.bounds.size.height / 2, y: 0)
            particleEmitter!.emitterSize = CGSize(width: self.bounds.size.height, height: 0)
            
            //rotate the stream for horizontal flow
            particleEmitter!.setAffineTransform(CGAffineTransform(rotationAngle: .pi / 2))
        
            break
            
        case WaterFaucetType.rightToLeft:
        
            emitterCell.velocity = 100
            emitterCell.velocityRange = 50
            emitterCell.yAcceleration = -250
        
            particleLayer.emitterCells = [emitterCell]
            
            particleEmitter = particleLayer
            
            //add the effect turned off
            particleEmitter!.birthRate = 0.0
            particleEmitter!.emitterPosition = CGPoint(x: -self.bounds.size.height / 2, y: self.bounds.size.height / 2)
            particleEmitter!.emitterSize = CGSize(width: self.bounds.size.height, height: 0)
            
            //rotate the stream for horizontal flow
            particleEmitter!.setAffineTransform(CGAffineTransform(rotationAngle: -.pi / 2 ))
        
            break
   
        }
        
        self.layer.addSublayer(particleEmitter!)
        
    }
    
    func turnOnFaucet(){
       
        self.particleEmitter!.birthRate = 1.0
    }
    
    func turnOffFaucet(){
        
        self.particleEmitter!.birthRate = 0.0
        
    }
    

}
