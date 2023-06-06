//
//  WelcomeVC.swift
//  ChatGPT Ultivic
//  Created by SHIVAM GAIND on 02/05/23.
//

import UIKit

class WelcomeVC: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var btnNext: Gradientbutton!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var collectionViewlay: UIView!
    
    // MARK: - Variables
    var currentSelectedIndex = 0
    var currentPage = 0
    // custom data Array
    var arrImage    = ["Frame","Vector1","Group1"]
    var arrFrameName = [Constant.Examples,Constant.Capabilities,Constant.Limitations]
    var arrDis1     = [Constant.Explainquantum ,Constant.Rememberwhatuser,Constant.Rememberwhatuser]
    var arrDis2     = [Constant.Gotanycreativeideas,Constant.Allowsusertoprovide,Constant.Allowsusertoprovide]
    var arrDis3     = [Constant.HowdoImake,Constant.Trainedtodeclineinappropriate,Constant.Trainedtodeclineinappropriate]
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        collectionview.delegate      = self
        collectionview.dataSource    = self
        btnNext.layer.cornerRadius   = 16
        btnNext.layer.masksToBounds  = true
        pageController.currentPage   = 0
        pageController.numberOfPages = arrDis1.count
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Button Action
    @IBAction func btnNext(_ sender: UIButton) {
        collectionview.isPagingEnabled = false
        let cellIndexPath = IndexPath.init(item: currentSelectedIndex + 1, section: 0)
        
        if currentSelectedIndex == 0 || currentSelectedIndex == 1 {
            collectionview.scrollToItem(at: cellIndexPath, at: .centeredHorizontally, animated: true)
            currentSelectedIndex = currentSelectedIndex + 1
            collectionview.isPagingEnabled = true
            pageController.currentPage = currentSelectedIndex
        } else {
            collectionview.isPagingEnabled = true
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
 }
// MARK: - Collectionview Delegate and DataSource
extension WelcomeVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrDis1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "welComeCollectionViewCell", for: indexPath) as! welComeCollectionViewCell
        cell.frameing.image    = UIImage(named: arrImage[indexPath.row])
        cell.lblframe.text     = arrFrameName[indexPath.row]
        cell.lblFirstDis.text  = arrDis1[indexPath.row]
        cell.lblSecondDis.text = arrDis2[indexPath.row]
        cell.lblthirdDis.text  = arrDis3[indexPath.row]
        cell.firstView.layer.cornerRadius  = 17
        cell.secondView.layer.cornerRadius = 17
        cell.thridView.layer.cornerRadius  = 17
        cell.firstView.layer.shadowRadius  = 4
        cell.firstView.layer.shadowColor   = CGColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        return cell
    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        pageController.currentPage = indexPath.row
//    }
//
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right:20)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        currentSelectedIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let size = CGSize(width: collectionViewlay.frame.size.width, height: collectionViewlay.frame.size.height)
        return size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageController.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        
        currentSelectedIndex = Int(scrollView.contentOffset.x / collectionViewlay.frame.size.width)
        pageController.currentPage = currentSelectedIndex
        
    }
}

