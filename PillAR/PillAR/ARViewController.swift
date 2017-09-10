
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
    
    var worldCoord: SCNVector3 = SCNVector3()
    var apiResult: (itemName: String, instructions: String, maximum: Int) = ("", "", 0)
    
    var historyYOffset:CGFloat = 165
    
    var tapGesture = UITapGestureRecognizer()
    var panGesture = UIPanGestureRecognizer()
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
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(ARViewController.handlePanGesture(_:)))
            mainHistoryVC.topSharedView.addGestureRecognizer(panGesture)
            
            NotificationCenter.default.addObserver(forName: toggleHistoryActionNotification, object: nil, queue: nil, using: { (notification) in
                self.toggleState()
            })
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
            //sceneView.session.add(anchor: ARAnchor(transform: transform))
            worldCoord = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
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
                    self.apiResult = result
                        self.sceneView.session.add(anchor: ARAnchor(transform: transform))
                }
            })
        }
    }
    
    func createNewBubbleParentNode(_ text : String) -> SCNNode {
        // Warning: Creating 3D Text is susceptible to crashing. To reduce chances of crashing; reduce number of polygons, letters, smoothness, etc.
        
        // TEXT BILLBOARD CONSTRAINT
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // BUBBLE-TEXT
        let bubble = SCNText(string: text, extrusionDepth: CGFloat(bubbleDepth))
        var font = UIFont(name: "Arial", size: 0.15)
        font = font?.withTraits(traits: .traitBold)
        bubble.font = font
        bubble.alignmentMode = kCAAlignmentCenter
        bubble.firstMaterial?.diffuse.contents = UIColor(red: 96/255, green: 143/255, blue: 238/255, alpha: 1.0) /* #608fee */
        bubble.firstMaterial?.specular.contents = UIColor.white
        bubble.firstMaterial?.isDoubleSided = true
        // bubble.flatness // setting this too low can cause crashes.
        bubble.chamferRadius = CGFloat(bubbleDepth)
        
        // BUBBLE NODE
        let (minBound, maxBound) = bubble.boundingBox
        let bubbleNode = SCNNode(geometry: bubble)
        // Centre Node - to Centre-Bottom point
        bubbleNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, bubbleDepth/2)
        // Reduce default text size
        bubbleNode.scale = SCNVector3Make(0.15, 0.15, 0.15)
        bubbleNode.position.y += 0.20
        
        // CENTRE POINT NODE
        let sphere = SCNSphere(radius: 0.005)
        sphere.firstMaterial?.diffuse.contents = UIColor.cyan
        let sphereNode = SCNNode(geometry: sphere)
        
        // BUBBLE PARENT NODE
        let bubbleNodeParent = SCNNode()
        bubbleNodeParent.addChildNode(bubbleNode)
        bubbleNodeParent.addChildNode(sphereNode)
        bubbleNodeParent.constraints = [billboardConstraint]
        
        return bubbleNodeParent
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
    
    func handlePanGesture(_ recognizer: UIPanGestureRecognizer){
        if let mainHistoryVC = self.mainHistoryVC{
            switch recognizer.state {
            case .began:
                print("Began sliding VC")
            case .changed:
                let translation = recognizer.translation(in: view).y
                mainHistoryVC.view.center.y += translation
                recognizer.setTranslation(CGPoint.zero, in: view)
            case .ended:
                if abs(recognizer.velocity(in: view).y) > 200{
                    if recognizer.velocity(in: view).y < -200{
                        toggle(state: .Visible)
                    }else if recognizer.velocity(in: view).y > 200{
                        toggle(state: .Hidden)
                    }
                }else{
                    if mainHistoryVC.view.center.y > self.view.frame.height / 2.0{
                        toggle(state: .Hidden)
                    }else{
                        toggle(state: .Visible)
                    }
                }
            default:
                break
            }
        }
    }
    
}

enum HistoryVisible {
    case Visible
    case Hidden
}

//MARK: -  Interaction with History VC
extension ARViewController {
    
    func toggle(state: HistoryVisible){
        if state != DataManager.shared().historyState, let mainHistoryVC = self.mainHistoryVC {
            print("Animating History State Change")
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 5.0, options: .curveEaseOut, animations: {
                
                if state == .Visible{
                    mainHistoryVC.view.frame = UIScreen.main.bounds
                }else if state == .Hidden{
                    mainHistoryVC.view.frame.origin.y = self.view.frame.height - self.historyYOffset
                }
            }, completion:{ (finished) in
                NotificationCenter.default.post(name: toggleHistoryNotification, object: nil)
            })
            DataManager.shared().historyState = state
            
        }
    }
    
    func toggleState(){
        if DataManager.shared().historyState == .Visible{
            toggle(state: .Hidden)
        }else{
            toggle(state: .Visible)
        }
    }
}

extension ARViewController {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        self.sceneView.scene.rootNode.addChildNode(node)
        node.position = worldCoord
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
        titleLabel.text = apiResult.itemName.capitalized
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
        limitLabel.text = "3 pills taken / \(apiResult.maximum) limit"
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
        
        let takePillButton = UIButton(frame: CGRect(x: 64, y: 491, width: imageView.frame.width-128, height: 84))
        takePillButton.titleLabel?.textAlignment = .center
        takePillButton.titleLabel?.numberOfLines = 1
        takePillButton.titleLabel?.font = UIFont(name: "Avenir", size: 42)
        takePillButton.setTitle("MARK AS TAKEN", for: .normal)
        takePillButton.backgroundColor =  UIColor(red: 96/255, green: 143/255, blue: 238/255, alpha: 1.0) /* #608fee */
        takePillButton.setTitleColor(.white, for: .normal)
        imageView.addSubview(takePillButton)
        
        DispatchQueue.main.async {
            let texture = UIImage.imageWithView(view: imageView)
            let infoNode = SCNNode()
            let infoGeometry = SCNPlane(width: 0.13, height: 0.09)
            infoGeometry.firstMaterial?.diffuse.contents = texture
            infoNode.geometry = infoGeometry
            infoNode.position.y += 0.09
            infoNode.position.z += 0.0054
            node.addChildNode(node)
            node.addChildNode(infoNode)
            node.constraints = [billboardConstraint]
        }
    }
}

