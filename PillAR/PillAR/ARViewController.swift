
//  ViewController.swift
//  CoreML in ARKit
//
//  Created by Hanley Weng on 14/7/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SceneKit.ModelIO
import Vision
import Photos

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    var mainHistoryVC: MainHistoryViewController?
    // SCENE
    @IBOutlet var sceneView: ARSCNView!
    let bubbleDepth : Float = 0.01 // the 'depth' of 3D text
    var latestPrediction : String = "" // a variable containing the latest CoreML prediction
    
    var historyState:HistoryVisible = .Hidden
    var historyYOffset:CGFloat = 170
    
    var tapGesture = UITapGestureRecognizer()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognize:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        if let mainHistoryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainHistoryVC") as? MainHistoryViewController{
            self.mainHistoryVC = mainHistoryVC
            mainHistoryVC.view.frame = UIScreen.main.bounds
            mainHistoryVC.view.frame.origin.y = self.view.frame.height - historyYOffset
            self.addChildViewController(mainHistoryVC)
            self.view.addSubview(mainHistoryVC.view)
            mainHistoryVC.didMove(toParentViewController: self)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        // Enable plane detection
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    func cropImage(image:UIImage, toRect rect:CGRect) -> UIImage{
        let imageRef:CGImage = image.cgImage!.cropping(to: rect)!
        let croppedImage:UIImage = UIImage(cgImage:imageRef)
        return croppedImage
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            // Do any desired updates to SceneKit here.
        }
    }
    
    // MARK: - Status Bar: Hide
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - Interaction
    func convertCItoUIImage(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        return UIImage(cgImage: cgImage)
    }
    
    var fetchingResults = false
    
    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) {
        
        print("Screen Hit")
        
        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        
        let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(screenCentre, types: [.featurePoint]) // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
        
        if let closestResult = arHitTestResults.first {
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
            if pixbuff == nil { return }
            let ciImage = CIImage(cvPixelBuffer: pixbuff!)
            var image = convertCItoUIImage(cmage: ciImage)
            image = image.crop(to: CGSize(width: image.size.width, height: image.size.width))
            image = image.zoom(to: 4.0) ?? image
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { success, error in
                if success {
                    print("Saved successfully")
                    // Saved successfully!
                }
                else if let error = error {
                    // Save photo failed with error
                }
                else {
                    // Save photo failed with no error
                }
            })

            print("Sending Image")
            if fetchingResults == true{
                return
            }else{
                fetchingResults = true
                activityIndicator.startAnimating()
            }
            GoogleAPIManager.shared().identifyDrug(image: image, completionHandler: { (result) in
                self.fetchingResults = false
                self.activityIndicator.stopAnimating()
                if let result = result {
                    
                    let billboardConstraint = SCNBillboardConstraint()
                    billboardConstraint.freeAxes = SCNBillboardAxis.Y
                    
                    let textNode : SCNNode = SCNNode()
                    self.sceneView.scene.rootNode.addChildNode(textNode)
                    textNode.position = worldCoord
                    let node = SCNNode()
                    let plaque = SCNBox(width: 0.14, height: 0.1, length: 0.01, chamferRadius: 0.005)
                    plaque.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.6)
                    node.geometry = plaque
                    node.position.y += 0.09
                    
                    //Set up card view
                    let imageView = UIView(frame: CGRect(x: 0, y: 0, width: 800, height: 600))
                    imageView.backgroundColor = .clear
                    imageView.alpha = 1.0
                    let titleLabel = UILabel(frame: CGRect(x: 64, y: 64, width: imageView.frame.width-224, height: 84))
                    titleLabel.textAlignment = .left
                    titleLabel.numberOfLines = 1
                    titleLabel.font = UIFont(name: "Avenir", size: 84)
                    titleLabel.text = result.itemName.capitalized
                    titleLabel.backgroundColor = .clear
                    imageView.addSubview(titleLabel)
                    
                    let circleLabel = UILabel(frame: CGRect(x: imageView.frame.width - 144, y: 48, width: 96, height: 96))
                    circleLabel.layer.cornerRadius = 48
                    circleLabel.clipsToBounds = true
                    circleLabel.backgroundColor = .red
                    imageView.addSubview(circleLabel)
                    
                    let lastTakenLabel = UILabel(frame: CGRect(x: 64, y: 180, width: imageView.frame.width-128, height: 42))
                    lastTakenLabel.textAlignment = .left
                    lastTakenLabel.numberOfLines = 1
                    lastTakenLabel.font = UIFont(name: "Avenir-HeavyOblique", size: 42)
                    lastTakenLabel.text = "Last taken XX hours ago"
                    lastTakenLabel.backgroundColor = .clear
                    imageView.addSubview(lastTakenLabel)
                    
                    let limitLabel = UILabel(frame: CGRect(x: 64, y: 286, width: imageView.frame.width-128, height: 63))
                    limitLabel.textAlignment = .center
                    limitLabel.numberOfLines = 1
                    limitLabel.font = UIFont(name: "Avenir", size: 63)
                    limitLabel.text = "X pills taken / \(result.maximum) limit"
                    limitLabel.backgroundColor = .clear
                    imageView.addSubview(limitLabel)
                    
                    let refillLabel = UILabel(frame: CGRect(x: 64, y: 365, width: imageView.frame.width-128, height: 42))
                    refillLabel.textAlignment = .center
                    refillLabel.numberOfLines = 1
                    refillLabel.font = UIFont(name: "Avenir", size: 42)
                    refillLabel.text = "REFILL SOON"
                    refillLabel.backgroundColor = .clear
                    refillLabel.textColor = .red
                    imageView.addSubview(refillLabel)
                    
//                    let takePillButton = UIButton(frame: CGRect(x: 64, y: 491, width: imageView.frame.width-128, height: 84))
//                    takePillButton.titleLabel?.textAlignment = .center
//                    takePillButton.titleLabel?.numberOfLines = 1
//                    takePillButton.titleLabel?.font = UIFont(name: "Avenir", size: 42)
//                    takePillButton.setTitle("MARK AS TAKEN", for: .normal)
//                    takePillButton.backgroundColor =  UIColor(red: 96/255, green: 143/255, blue: 238/255, alpha: 1.0) /* #608fee */
//                    takePillButton.setTitleColor(.white, for: .normal)
//                    imageView.addSubview(takePillButton)
                    
                    let buttonNode = self.createButton(size: CGSize(width: imageView.frame.width - 128, height: 84))

                    let texture = UIImage.imageWithView(view: imageView)
                    
                    let infoNode = SCNNode()
                    let infoGeometry = SCNPlane(width: 0.13, height: 0.09)
                    infoGeometry.firstMaterial?.diffuse.contents = texture
                    infoNode.geometry = infoGeometry
                    infoNode.position.y += 0.09
                    infoNode.position.z += 0.0055
                    
                    textNode.addChildNode(node)
                    textNode.addChildNode(infoNode)
                    
                    infoNode.addChildNode(buttonNode)
                    buttonNode.position = infoNode.position
                    buttonNode.position.y -= (0.125)
                    textNode.constraints = [billboardConstraint]
                }
            })
        }
    }
    
    func createButton(size: CGSize) -> SCNNode {
        let buttonNode = SCNNode()
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        buttonView.backgroundColor = UIColor(red: 96/255, green: 143/255, blue: 238/255, alpha: 1.0) /* #608fee */
        let buttonLabel = UILabel(frame: CGRect(x: 0, y: 0, width: buttonView.frame.width, height: buttonView.frame.height))
        buttonLabel.backgroundColor = .clear
        buttonLabel.textColor = .white
        buttonLabel.text = "MARK AS TAKEN"
        buttonLabel.font = UIFont(name: "Avenir", size: 42)
        buttonLabel.textAlignment = .center
        buttonView.addSubview(buttonLabel)
        buttonNode.geometry = SCNBox(width: size.width / 6000, height: size.height / 6000, length: 0.002, chamferRadius: 0.0)
        //buttonNode.geometry = SCNPlane(width: size.width / 6000, height: size.height / 6000)
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = UIImage.imageWithView(view: buttonView)
        let blueMaterial = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor(red: 96/255, green: 143/255, blue: 238/255, alpha: 1.0) /* #608fee */
        buttonNode.geometry?.materials = [textMaterial, blueMaterial, blueMaterial, blueMaterial, blueMaterial, blueMaterial]
        //buttonNode.position.y
        //buttonNode.position.x
        return buttonNode
    }
}


extension ARViewController: UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGesture{
            if let mainHistoryVC = self.mainHistoryVC{
                return  mainHistoryVC.view.frame.contains(gestureRecognizer.location(in: self.view)) == false
            }
        }
        return true
    }
    
}

enum HistoryVisible {
    case Visible
    case Hidden
}

//MARK: -  Interaction with History VC
extension ARViewController {
    
    func toggle(state: HistoryVisible){
        if state != self.historyState {
            print("Animating History State Change")
            
            
        }
    }
    
    
}

