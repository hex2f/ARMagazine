import Foundation
import SceneKit
import AVFoundation

extension AVPlayer {
    func fadeVolume(from: Float, to: Float, duration: Float, completion: (() -> Void)? = nil) -> Timer? {
        volume = from
        guard from != to else { return nil }
        let interval: Float = 0.1
        let range = to-from
        let step = (range*interval)/duration
        
        func reachedTarget() -> Bool {
            guard volume >= 0, volume <= 1 else {
                volume = to
                return true
            }
            
            if to > from {
                return volume >= to
            }
            return volume <= to
        }
        
        return Timer.scheduledTimer(withTimeInterval: Double(interval), repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if !reachedTarget() {
                    self.volume += step
                } else {
                    timer.invalidate()
                    completion?()
                }
            }
        })
    }
}

extension SCNNode {
    func fadeAlpha(from: CGFloat, to: CGFloat, duration: CGFloat, completion: (() -> Void)? = nil) -> Timer? {
        opacity = from
        
        guard from != to else { return nil }
        let interval: CGFloat = 0.05
        let range = to-from
        let step = (range*interval)/duration
        
        func reachedTarget() -> Bool {
            guard opacity >= 0, opacity <= 1 else {
                opacity = to
                return true
            }
            
            if to > from {
                return opacity >= to
            }
            return opacity <= to
        }
        
        return Timer.scheduledTimer(withTimeInterval: Double(interval), repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if !reachedTarget() {
                    self.opacity += step
                } else {
                    timer.invalidate()
                    completion?()
                }
            }
        })
    }
}
