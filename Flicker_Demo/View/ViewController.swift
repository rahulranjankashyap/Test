//
//  ViewController.swift
//  Flicker_Demo
//
//  Created by Apple on 6/19/18.
//  Copyright © 2018 Uber. All rights reserved.
//

import UIKit

let numberOfCellsPerRow: CGFloat = 3

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBarPhoto: UISearchBar!
    var searchActive : Bool = false
    @IBOutlet weak var collectionViewPhoto: UICollectionView!
    let reuseIdentifier = "cell"
    let footerViewReuseIdentifier = "RefreshFooterView"
    var strSearchText = "kittens"
    var pageCount = 1
    var items = [[String:Any]]()
    var footerView:CustomFooterView?
    var isLoading:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        registerNib()
        hitPhotoAPI()
    }
    
    func registerNib(){
        collectionViewPhoto.register(UINib(nibName: "CustomFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerViewReuseIdentifier)
    }
    
    func initialSetUp(){
        searchBarPhoto.delegate = self
       
        if let flowLayout = collectionViewPhoto?.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let cellWidth = (view.frame.width - max(0, numberOfCellsPerRow - 1)*horizontalSpacing)/numberOfCellsPerRow
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        }
    }
}

//MARK:
//MARK: -API
extension ViewController {
    
    func hitPhotoAPI(_ pageCount: Int = 1){
      
        if(HelperViewModel.sharedInstanceHelper.isInternetAvailable()){
            
            WebServiceHelper.sharedInstanceAPI.load(strSearchText, page: String(format:"%d",pageCount))
            { (result : [String : Any]) in
                
                if(self.isLoading){
                    for item in PhotoDetailsResponse.sharedInstance.photosArray{
                        self.items.append(item)
                    }
                    self.isLoading = false
                    self.footerView?.stopAnimate()
                }else{
                     self.items = PhotoDetailsResponse.sharedInstance.photosArray
                }
                DispatchQueue.main.async {
                    self.collectionViewPhoto.reloadData()
                }
                
            }
        }else{
            let alert = UIAlertController(title: "Network Error", message: "Please connect Internet Connection", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! FlickerCollectionViewCell
        
        let urlString = "http://farm\(items[indexPath.row]["farm"] ?? "").static.flickr.com/\(items[indexPath.row]["server"] ?? "")/\(items[indexPath.row]["id"] ?? "")_\(items[indexPath.row]["secret"] ?? "").jpg"
        
        cell.imageURL = URL(string: urlString)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//
//
//        targetContentOffset.pointee = scrollView.contentOffset
//        let pageWidth:Float = Float(self.view.bounds.width)
//        let minSpace:Float = 10.0
//
//        var cellToSwipe:Double = Double(Float((scrollView.contentOffset.x))/Float((pageWidth+minSpace))) + Double(0.5)
//
//        if cellToSwipe < 0 {
//            cellToSwipe = 0
//        } else if cellToSwipe >= Double(self.items.count) {
//
//            cellToSwipe = Double(self.items.count) - Double(1)
//        }
//
//        let indexPath:IndexPath = IndexPath(row: Int(cellToSwipe), section:0)
//        self.collectionViewPhoto.scrollToItem(at:indexPath, at: UICollectionViewScrollPosition.left, animated: true)
//
//
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isLoading {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewReuseIdentifier, for: indexPath) as! CustomFooterView
            self.footerView = aFooterView
            self.footerView?.backgroundColor = UIColor.clear
            return aFooterView
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewReuseIdentifier, for: indexPath)
            return headerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            self.footerView?.prepareInitialAnimation()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            self.footerView?.stopAnimate()
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold   = 0.0 ;
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold);
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(fabs(triggerThreshold),1.0);
        self.footerView?.setTransform(inTransform: CGAffineTransform.identity, scaleFactor: CGFloat(pullRatio))
        if pullRatio >= 1 {
            self.footerView?.animateFinal()
        }
        print("pullRation:\(pullRatio)")
    }
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        let pullHeight  = fabs(diffHeight - frameHeight);
        let doubleStr = String(format: "%.2f", pullHeight)
        let dLati = (doubleStr as NSString).doubleValue

        if dLati == 0.0
        {
            if (self.footerView?.isAnimatingFinal)! {
                print("load more trigger")
                self.isLoading = true
                self.footerView?.startAnimate()
                
                pageCount += 1
                hitPhotoAPI(pageCount)
                
            }
        }
    }
 
    
}

extension ViewController: UISearchBarDelegate
{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
        strSearchText = "kittens"
        WebServiceHelper.sharedInstanceAPI.load(strSearchText, page: String(format:"%d",pageCount))
        { (result : [String : Any]) in
            
            self.items = PhotoDetailsResponse.sharedInstance.photosArray
            DispatchQueue.main.async {
                self.collectionViewPhoto.reloadData()
                
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchText.count > 0)
        {
            WebServiceHelper.sharedInstanceAPI.load(searchText, page: String(format:"%d",pageCount))
            { (result : [String : Any]) in
                
                self.items = PhotoDetailsResponse.sharedInstance.photosArray
                DispatchQueue.main.async {
                    self.collectionViewPhoto.reloadData()
                    
                }
            }
            
            
        }
    }
}


