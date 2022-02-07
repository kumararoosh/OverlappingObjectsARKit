//
//  ContentView.swift
//  OverlappingObjectsARKit
//
//  Created by stlp on 2/6/22.
//

import SwiftUI
import ARKit
import RealityKit
import FocusEntity

struct RealityKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let view = ARView()
        // Start AR Session
        let session = view.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
    
        // Add coaching overlay
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        view.addSubview(coachingOverlay)
        
        #if DEBUG
        view.debugOptions = [.showAnchorOrigins, .showPhysics]
        #endif
        
        // Handle ARSession events via delegate
        context.coordinator.view = view
        session.delegate = context.coordinator
        
        // Handle taps
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleTap)
            )
        )
        
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        weak var view: ARView?
        var focusEntity: FocusEntity?
        var count = 0
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let view = self.view else {return}
            debugPrint("Anchors added to the scene: ", anchors)
            self.focusEntity = FocusEntity(on: view, style: .classic(color: .yellow))
            
        }
        
        @objc func handleTap() {
            guard let view = self.view else {return}
            
            // Create a new anchor to add content on
            let anchor = AnchorEntity()
            view.scene.anchors.append(anchor)
            
            // Add a Box entity with a blue material
            let box = MeshResource.generateBox(size: 0.5, cornerRadius: 0.05)
            var color: UIColor = .blue
            if (count % 2 == 0) {
                color = .blue
            } else {
                color = .green
            }
            count += 1
            
            
            let boxMaterial = SimpleMaterial(color: color, isMetallic: true)
            let diceEntity = ModelEntity(mesh: box, materials: [boxMaterial])
            diceEntity.setPosition([-0.3 - (0.1 * Float(count)), -1, -2 ], relativeTo: nil)
            
            anchor.addChild(diceEntity)
            
        }
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
}

struct ContentView: View {
    var body: some View {
        RealityKitView()
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
