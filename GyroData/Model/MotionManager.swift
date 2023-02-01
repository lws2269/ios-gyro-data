//
//  File.swift
//  GyroData
//
//  Created by stone, LJ on 2023/01/31.
//

import Foundation
import CoreMotion

class MotionManager {
    var manager = CMMotionManager()
    var timer: Timer?
    var second: Double = 0.0
    
    var interval: Double = 0.0
    
    func start(type: MotionType, completion: @escaping (Coordinate) -> Void) {
        second = 0
        switch type {
        case .acc:
            accelerometerMode(completion: completion)
        case .gyro:
            gyroMode(completion: completion)
        }
    }
    
    func confgiureTimeInterval(interval: Double) {
        self.interval = interval
    }
    
    func stop() {
        timer?.invalidate()
        manager.stopGyroUpdates()
        manager.stopAccelerometerUpdates()
    }
    
    func accelerometerMode(completion: @escaping (Coordinate) -> Void) {
        manager.accelerometerUpdateInterval = interval
        manager.startAccelerometerUpdates()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            if floor(self.second) == 60.0 {
                self.stop()
            }
            self.second += 0.1
            guard let data = self.manager.accelerometerData else { return }
            completion(self.convert(measureData: data))
        })
    }
    
    func gyroMode(completion: @escaping (Coordinate) -> Void) {
        manager.gyroUpdateInterval = interval
        manager.startGyroUpdates()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            if floor(self.second) == 60.0 {
                self.stop()
            }
            self.second += 0.1
            guard let data = self.manager.gyroData else { return }
            completion(self.convert(measureData: data))
        })
    }
    
    func convert(measureData: MeasureData) -> Coordinate {
        var (x,y,z) = (0.0, 0.0, 0.0)
        
        if let data = measureData as? CMAccelerometerData {
            x = data.acceleration.x
            y = data.acceleration.y
            z = data.acceleration.z
        } else if let data = measureData as? CMGyroData {
            x = data.rotationRate.x
            y = data.rotationRate.y
            z = data.rotationRate.z
        }
        
        return Coordinate(x: x.decimalPlace(3), y: y.decimalPlace(3), z: z.decimalPlace(3))
    }
    
}
