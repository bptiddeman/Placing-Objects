/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Wrapper SceneKit node for virtual objects placed into the AR scene.
*/

import Foundation
import SceneKit
import ARKit

struct VirtualObjectDefinition: Codable, Equatable {
    let modelName: String
    let displayName: String
    let particleScaleInfo: [String: Float]
    
    lazy var thumbImage: UIImage = UIImage(named: self.modelName)!
    
    init(modelName: String, displayName: String, particleScaleInfo: [String: Float] = [:]) {
        self.modelName = modelName
        self.displayName = displayName
        self.particleScaleInfo = particleScaleInfo
    }
    
    static func ==(lhs: VirtualObjectDefinition, rhs: VirtualObjectDefinition) -> Bool {
        return lhs.modelName == rhs.modelName
            && lhs.displayName == rhs.displayName
            && lhs.particleScaleInfo == rhs.particleScaleInfo
    }
}

class VirtualObject: SCNReferenceNode, ReactsToScale {
    let definition: VirtualObjectDefinition
    
    init(definition: VirtualObjectDefinition) {
        self.definition = definition
        let url : URL
        if (definition.modelName=="BCDconv" || definition.modelName=="BCDstone" || definition.modelName=="BBC"  || definition.modelName=="BCDAxe" || definition.modelName=="MTN10179") {
          /*  let path = bundle.pathForResource("BCDconv", ofType: "obj")
            let url = NSURL(fileURLWithPath: path!)
            let asset = MDLAsset(URL: url)
            
            let scene = SCNScene(MDLAsset: asset)*/
           
            
            guard let objUrl = Bundle.main.url(forResource: "Models.scnassets/\(definition.modelName)/\(definition.modelName)", withExtension: "obj")
            else { fatalError("can't find expected virtual object bundle resources") }
            url=objUrl
        } else {
            guard let scnUrl = Bundle.main.url(forResource: "Models.scnassets/\(definition.modelName)/\(definition.modelName)", withExtension: "scn")
            else { fatalError("can't find expected virtual object bundle resources") }
            url = scnUrl
        }
        super.init(url: url)!
        if (definition.modelName=="BCDconv" || definition.modelName=="BCDstone") {
            self.scale.x=0.1
            self.scale.y=0.1
            self.scale.z=0.1
        }
        else if (definition.modelName=="BBC") {
            self.scale.x=0.01
            self.scale.y=0.01
            self.scale.z=0.01
        } else if (definition.modelName=="BCDAxe") {
            self.scale.x=0.001
            self.scale.y=0.001
            self.scale.z=0.001
        } else if (definition.modelName=="MTN10179") {
            self.scale.x=0.001
            self.scale.y=0.001
            self.scale.z=0.001
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Use average of recent virtual object distances to avoid rapid changes in object scale.
    var recentVirtualObjectDistances = [Float]()
    
    func reactToScale() {
        for (nodeName, particleSize) in definition.particleScaleInfo {
            guard let node = self.childNode(withName: nodeName, recursively: true), let particleSystem = node.particleSystems?.first
                else { continue }
            particleSystem.reset()
            particleSystem.particleSize = CGFloat(scale.x * particleSize)
        }
    }
}

extension VirtualObject {
	
	static func isNodePartOfVirtualObject(_ node: SCNNode) -> VirtualObject? {
		if let virtualObjectRoot = node as? VirtualObject {
			return virtualObjectRoot
		}
		
		if node.parent != nil {
			return isNodePartOfVirtualObject(node.parent!)
		}
		
		return nil
	}
    
}

// MARK: - Protocols for Virtual Objects

protocol ReactsToScale {
	func reactToScale()
}

extension SCNNode {
	
	func reactsToScale() -> ReactsToScale? {
		if let canReact = self as? ReactsToScale {
			return canReact
		}
		
		if parent != nil {
			return parent!.reactsToScale()
		}
		
		return nil
	}
}
