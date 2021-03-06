//
//  MyPageViewController.swift
//  Plot
//
//  Created by joe on 2017. 8. 1..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit
import Firebase

class MyPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /*******************************************/
    // MARK: -  Outlet                         //
    /*******************************************/
    
    @IBAction func clickedLogout(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "loginFlag")
            presentLoginVC()
            //TODO: 항상 home이 가장 첫번째로 뜨게 하는 방법?
        }catch{
            
        }
    }
    @IBOutlet weak var posterCollectionView: UICollectionView!
    
    
    @IBOutlet weak var tagCollectionView: UICollectionView!
    
    
    var sizingCell: TagCustomCell?
    
    var liketag = [Tag]()
    
    
    //보영
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    var userID:String?
    var userLikeCount:Int = 0
    var userLikeDataList:[String:[String:Any]] = [:]
    var likeGenre:[String] = ["전시","설치"]
    
    /*******************************************/
    // MARK: -  Life Cycle                     //
    /*******************************************/
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentLoginVC()
        
        for name in likeGenre {
            let tag = Tag()
            tag.name = name
            self.liketag.append(tag)
        }
        
        self.posterCollectionView.register(UINib(nibName: "RankingCustomCell", bundle: nil), forCellWithReuseIdentifier: "RankingCustomCell")
        
        self.tagCollectionView.register(UINib(nibName: "TagCustomCell", bundle: nil), forCellWithReuseIdentifier: "TagCustomCell")
        
        self.tagCollectionView.register(UINib(nibName: "CollectionViewHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader")
        
        self.posterCollectionView.delegate = self
        self.posterCollectionView.dataSource = self
        self.tagCollectionView.dataSource = self
        self.tagCollectionView.delegate = self
        
        let cellNib = UINib(nibName: "TagCustomCell", bundle: nil)
        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! TagCustomCell?
        
        //보영
        var userData:UserData?{
            didSet{
                guard let realUserData = userData else {return}
                self.userNameLabel.text = realUserData.name
                self.emailLabel.text = realUserData.email
                
                guard let url = URL(string: realUserData.profileImgURL) else {return}
                
                do{
                    let realData = try Data(contentsOf: url)
                    self.profileImageView.image = UIImage(data: realData)
                }catch{
                    
                }
                
            }
        }
        
        guard let realCurrnetUser = Auth.auth().currentUser else {return}
        let currentUserID:String = realCurrnetUser.uid
        DataCenter.sharedData.requestUserData(id: currentUserID) { (data) in
            userData = data
        }
        
        
        //좋아요한 전시 어레이 출력
        var userLikeList:[String : [String : Any]]? {
            didSet{
                self.likeCountLabel.text = "\(userLikeList!.count)"
            }
        }
        
        DataCenter.sharedData.requestFavoriteExhibitionIDsOfUser(id: Auth.auth().currentUser?.uid) { (int) in
            userLikeList = int
            self.userLikeCount = (userLikeList?.count)!
            self.userLikeDataList = int
            
            self.posterCollectionView.reloadData()
        
        }
        
        
        //코멘트 갯수
        var userCommentList:[String : [String : Any]]? {
            didSet{
                self.commentCountLabel.text = "\(userCommentList!.count)"
            }
        }
        
        DataCenter.sharedData.requestCommentedExhibitionIDsOfUser(id: Auth.auth().currentUser?.uid) { (int) in
            userCommentList = int
        }
        
        //좋아요한 장르 어레이
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*******************************************/
    // MARK: -  CollectionView                 //
    /*******************************************/
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if collectionView == posterCollectionView {
            return 1
        }
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == posterCollectionView {
            return self.userLikeCount
        } else {
            return self.likeGenre.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == posterCollectionView {
            return CGSize(width: 150, height: 150 * 4/3)
        } else {
            self.configureCell(self.sizingCell!, forIndexPath: indexPath)
            return self.sizingCell!.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let mappedID = self.userLikeDataList.map({ (dic:(key: String, value: [String : Any])) -> Int in
            let exhibitionID:Int = dic.value[Constants.likes_ExhibitionID] as! Int
            return exhibitionID
        })
        
        if collectionView == posterCollectionView {
            let cell:RankingCustomCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankingCustomCell", for: indexPath) as! RankingCustomCell

            var exhibitionData:ExhibitionData? {
                didSet{
                    
                    guard let realExhibitionData = exhibitionData else {
                        print("리얼데이터가 없습니다")
                        return
                    }
                    guard let url = URL(string: realExhibitionData.imgURL[0].posterURL) else {return}
                    
                    do{
                        let realData = try Data(contentsOf: url)
                        cell.posterImage.image = UIImage(data: realData)
                    }catch{
                        
                    }
                }
            }
            
            DataCenter.sharedData.requestExhibitionData(id: mappedID[indexPath.item], completion: { (data) in
                exhibitionData = data
            })
            
            cell.rankImage.isHidden = true
            return cell
            
        } else {
            let cell:TagCustomCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCustomCell", for: indexPath) as! TagCustomCell
            
            print("인덱스패스로우:\(indexPath.row)")
            print("여기는 태그셀")
            self.configureCell(cell, forIndexPath: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header:CollectionViewHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionViewHeader", for: indexPath) as! CollectionViewHeader
        //        if collectionView == posterCollectionView {
        //            header.headerName.text! = "좋아요 목록"
        header.headerName.text! = "선호하는 장르"
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView == posterCollectionView {
            return CGSize.init(width: 0, height: 0)
        }
        return CGSize.init(width: collectionView.frame.size.width, height: 30)
    }
    
    func configureCell(_ cell: TagCustomCell, forIndexPath indexPath: IndexPath) {
        
        let tag = liketag[indexPath.row]
        cell.tagName.text = tag.name
        cell.tagName.textColor = tag.selected ? UIColor(red: 31/255, green: 208/255, blue: 255/255, alpha: 1) : UIColor(red: 31/255, green: 208/255, blue: 255/255, alpha: 1)
        cell.backgroundColor = tag.selected ? UIColor(red: 1, green: 1, blue: 1, alpha: 1) : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if collectionView == tagCollectionView {
            liketag[indexPath.row].selected = !liketag[indexPath.row].selected
        }
        self.tagCollectionView.reloadData()
    }
    
    
    
    /*******************************************/
    // MARK: -  Func                           //
    /*******************************************/
    
    func presentLoginVC(){
        if Auth.auth().currentUser == nil {
            let loginVC:LoginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            present(loginVC, animated: true, completion: nil)
        }else{
            print(Auth.auth().currentUser?.email)
        }
    }
    
}
