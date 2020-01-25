//
//  SceneDelegate.swift
//  BeingSpotter
//
//  Created by Wladislav Cugunov on 19.01.20.
//  Copyright © 2020 Wladislav Cugunov. All rights reserved.
//

import UIKit
import SwiftUI
import AVKit
import Vision

class SceneDelegate: UIResponder, UIWindowSceneDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        
        // TODO: check here how to implement properly
        window?.inputViewController?.view.layer.addSublayer(previewLayer)
        
        previewLayer.frame = (window?.inputViewController?.view.frame)!
        
        let dataOutput = AVCaptureVideoDataOutput()
        
        dataOutput.setSampleBufferDelegate(self,
                                    queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        func captureOutput(_ output: AVCaptureOutput, didOutput
            sampleBuffer: CMSampleBuffer, from connection:
            AVCaptureConnection) {
           // print("Camera was able to capture a frame:", Date())
    
            guard let pixelBuffer: CVPixelBuffer =
                CMSampleBufferGetImageBuffer(sampleBuffer) else
                {return}
        
            guard let model = try? VNCoreMLModel(for: MobileNetV2.init().model) else {return}
            let request = VNCoreMLRequest(model: model){
                (finishedReq, err) in
                                
                guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
                guard let firstObservation = results.first else {return}
                
                print(firstObservation.identifier, firstObservation.confidence)
                
            }
            
           try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options:
                [:]).perform([request])
        }
        /**
        // Get the managed object context from the shared persistent container.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        let contentView = ContentView().environment(\.managedObjectContext, context)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
            
            let captureSession = AVCaptureSession()
            
            guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
            
            guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
            
            captureSession.addInput(input)
            captureSession.startRunning()
            
        }**/
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

