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
            guard let view = self.view, let focusEntity = self.focusEntity else {return}
            
            // Create a new anchor to add content on
            let anchor = AnchorEntity()
            view.scene.anchors.append(anchor)
            
            // Add a Box entity with alternating blue and green material
            let box = MeshResource.generateBox(size: 0.5, cornerRadius: 0.05)
            let redBoxMaterial = SimpleMaterial(color: .red, isMetallic: false)
            let yellowBoxMaterial = SimpleMaterial(color: .yellow, isMetallic: false)

            let redBoxEntity = ModelEntity(mesh: box, materials: [redBoxMaterial])
            let yellowBoxEntity = ModelEntity(mesh: box, materials: [yellowBoxMaterial])

            
            redBoxEntity.position = focusEntity.position
            yellowBoxEntity.position = focusEntity.position
            count += 1
            debugPrint("number of boxes added", count * 2)
            anchor.addChild(yellowBoxEntity)
            anchor.addChild(redBoxEntity)

            
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
