//
//  Load SD Model.swift
//  PromptToImage
//
//  Created by hany on 05/12/22.
//

import Foundation
import CoreML
import AppKit


// MARK: Create Pipeline

func createStableDiffusionPipeline(computeUnits:MLComputeUnits, url:URL) {
    DispatchQueue.main.async {
        // show wait window
        (wins["main"] as! SDMainWindowController).waitProgr.startAnimation(nil)
        (wins["main"] as! SDMainWindowController).waitLabel.stringValue = "Loading Model"
        (wins["main"] as! SDMainWindowController).waitInfoLabel.stringValue = currentModelName()
        (wins["main"] as! SDMainWindowController).window?.beginSheet((wins["main"] as! SDMainWindowController).waitWin)
    }
    
    // DispatchQueue.global().sync {
    var url = url
    if !FileManager.default.fileExists(atPath: url.absoluteURL.path(percentEncoded: false) ) {
        print("Error: model directory not found at \(url.absoluteURL.path(percentEncoded: false))")
        modelResourcesURL = defaultModelResourcesURL
        url = defaultModelResourcesURL
    }
    
    sdPipeline?.unloadResources()
    sdPipeline = nil
    
    // create Stable Diffusion pipeline from CoreML resources
    print("creating Stable Diffusion pipeline...")
    print("Model: \(url.lastPathComponent)")
    print("Model dir path: \(url.path(percentEncoded: false))")
    
    do {
        let config = MLModelConfiguration()
        config.computeUnits = computeUnits
        sdPipeline = try StableDiffusionPipeline(resourcesAt: url,
                                                 configuration:config)
        try sdPipeline?.loadResources()
    } catch {
        print("Unable to create Stable Diffusion pipeline")
        sdPipeline = nil
    }
    
    // close wait window
    DispatchQueue.main.async {
        (wins["main"] as! SDMainWindowController).window?.endSheet((wins["main"] as! SDMainWindowController).waitWin)
        (wins["main"] as! SDMainWindowController).enableImg2Img()
        
        // set resolution
        if let shape = (sdPipeline?.unet.models[0].loadedModel?.modelDescription.inputDescriptionsByName["sample"] as? MLFeatureDescription)?.multiArrayConstraint?.shape {
            modelWidth = Double(truncating: shape[3]) * 8
            modelHeight = Double(truncating: shape[2]) * 8
            print("Current resolution: \(String(Int(modelWidth)))x\(String(Int(modelHeight)))")
        } else {
            modelWidth = 512
            modelHeight = 512
        }
        
        if let name = (sdPipeline?.unet.models[0].loadedModel?.modelDescription.metadata[MLModelMetadataKey(rawValue: "MLModelVersionStringKey")]) {
            print("Created pipeline for model: \(name)")
        }
    }
    //}
    
}




// MARK: Reload Model

func loadSDModel() {
    DispatchQueue.global().async {
        createStableDiffusionPipeline(computeUnits: currentComputeUnits, url:modelResourcesURL)
        if sdPipeline == nil {
            // error
            print("error creating pipeline")
            DispatchQueue.main.async {
                displayErrorAlert(txt: "Unable to create Stable Diffusion pipeline using model at url \(modelResourcesURL)\n\nClick the button below to dismiss this alert and restore default model")
                // restore default model and compute units
                createStableDiffusionPipeline(computeUnits: defaultComputeUnits,
                                              url: defaultModelResourcesURL)
                modelResourcesURL = defaultModelResourcesURL
                // set user defaults
                UserDefaults.standard.set(modelResourcesURL, forKey: "modelResourcesURL")
            }
        } else {
            // save to user defaults
            UserDefaults.standard.set(modelResourcesURL, forKey: "modelResourcesURL")
        }
    }
}

