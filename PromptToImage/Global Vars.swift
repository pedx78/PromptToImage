//
//  Global Vars.swift
//  PromptToImage
//
//  Created by Hany El Imam on 05/12/22.
//

import Foundation
import CoreML
import AppKit

// built-in stable diffusion model resources URL/name 
let defaultModelResourcesURL : URL = Bundle.main.resourceURL!
let defaultModelName = "Stable Diffusion 2.1 SPLIT EINSUM"

// current model resources URL
var modelResourcesURL : URL = Bundle.main.resourceURL!

// file format
let savefileFormat : NSBitmapImageRep.FileType = .png

// model image size
var modelWidth : Double = 512
var modelHeight: Double = 512

// sd pipeline
var sdPipeline : StableDiffusionPipeline? = nil

// sd compute units
let defaultComputeUnits : MLComputeUnits = .cpuAndGPU
var currentComputeUnits : MLComputeUnits = .cpuAndGPU

// upscaler
let defaultUpscaleModelPath = Bundle.main.path(forResource: "realesrgan512", ofType: "mlmodelc")
let defaultUpscalerComputeUnits : MLComputeUnits = .cpuAndGPU
