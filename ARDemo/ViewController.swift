import UIKit
import SceneKit
import ARKit
import AVFoundation


class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var playerNode: SKVideoNode!
    var player: AVPlayer!
    var justGainedFocus: Bool = true
    var justLostFocus: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        let scene = SCNScene(named: "ar.scnassets/ar.scn")!
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let conf = ARImageTrackingConfiguration()
        guard let arImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Targets", bundle: nil) else { return }
        conf.trackingImages = arImages
        conf.frameSemantics.insert(.personSegmentationWithDepth)
        sceneView.session.run(conf)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARImageAnchor else { return }
        if ((anchor as? ARImageAnchor)?.referenceImage) == nil {
            return
        }
        
        guard let container = sceneView.scene.rootNode.childNode(withName: "container", recursively: false) else { return }
        
        container.removeFromParentNode()
        node.addChildNode(container)
        container.isHidden = false
        
        guard let videoURL = Bundle.main.url(forResource: "kda", withExtension: ".mp4") else { return }
        player = AVPlayer(url: videoURL)
        player.volume = 0
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
        
        // todo: get size from the video file?
        let videoScene = SKScene(size: CGSize(width: 628, height: 878))
        playerNode = SKVideoNode(avPlayer: player)
        playerNode.position = CGPoint(x: videoScene.size.width/2, y: videoScene.size.height/2)
        playerNode.size = videoScene.size
        playerNode.yScale = -1
        playerNode.play()
        videoScene.addChild(playerNode)
        
        guard let video = container.childNode(withName: "video", recursively: true) else { return }
        video.geometry?.firstMaterial?.diffuse.contents = videoScene
        video.position = node.position
    }
    
    var fadeInTimer: Timer?
    var fadeOutTimer: Timer?
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = (anchor as? ARImageAnchor) else { return }
        if imageAnchor.isTracked {
            playerNode.play()
            if justGainedFocus {
                fadeOutTimer?.invalidate()
                fadeInTimer = player.fadeVolume(from: player.volume, to: 1, duration: 0.5)
                justGainedFocus = false
                justLostFocus = true
                sceneView.scene.rootNode.fadeAlpha(from: 0, to: 1, duration: 0.5)
            }
        } else {
            if justLostFocus {
                fadeInTimer?.invalidate()
                fadeOutTimer = player.fadeVolume(from: player.volume, to: 0, duration: 0.5) { self.playerNode.pause() }
                justLostFocus = false
                justGainedFocus = true
            }
        }
    }
}
