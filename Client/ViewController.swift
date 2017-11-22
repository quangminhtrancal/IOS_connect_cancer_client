//
//  ViewController.swift
//  Client
//
//  Created by Minh on 2017-10-14.
//  Copyright © 2017 Minh. All rights reserved.
//

import UIKit
import SocketIO

class ViewController: UIViewController {
    
    @IBOutlet weak var tbsupport: UIButton!
    
    @IBOutlet weak var support: UIButton!
    
    @IBOutlet weak var btnsend: UIButton!
    
    @IBOutlet weak var tbvmessage: UITableView!
    var arrdata:Array<String>=[]
    @IBOutlet weak var txtout: UITextField!
    
    @IBOutlet weak var txtremind: UITextField!
    @IBOutlet weak var txtin: UITextField!
  
    //let socket = SocketIOClient(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
    let socket = SocketIOClient(socketURL: URL(string: "http://\(ip):3000")!, config: [.log(true), .compress])

    var token1: String = ""
    var socketid: String = ""
    var webdata: [String:String]=["token":"","socket_id":""]
    var token2: String = ""
    var socketid2: String = ""
    var chat_id: String = ""
    var message: [String:String]=["token":"","message":"","type":"2","chat_id":"","user1":"","user2":""]
    var checker: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // CONNECT to HOST
        txtremind.text="No connection"

        tbvmessage.delegate=self
        tbvmessage.dataSource=self
        socket.on("Data") { (data, ack) in
            print(data)
            //self.txtout.text=data[0] as! String
            let s:String=data[0] as! String
            self.arrdata.append(s)
            self.tbvmessage.reloadData()
        }
        socket.on("Token") { (data, ack) in
            let arr = data as? [[String: Any]]
            self.token1=arr![0]["token"] as! String
            self.socketid=arr![0]["socket_id"] as! String
            let s:String="Token \(self.token1) has socketid \(self.socketid)"
            self.arrdata.append(s)
            self.tbvmessage.reloadData()
        }
        socket.on("queue"){(data, acl) in
            let s1:String=data[0] as! String
            if (s1==self.token1){
                let s:String="Please wait! We are looking for an interlocutor for you!"
                self.arrdata.append(s)
                self.tbvmessage.reloadData()
            }
        }
        socket.on("chat created"){(data, acl) in
            let arr = data as? [[String: Any]]
            let t1=arr![0]["token"] as! String
            let t2=arr![0]["chat_id"] as! String

            if (self.token1==t1){
                self.token2=t2
                self.txtremind.text="My self \(self.token1) chat \(self.token2)"
                
            }
            else{
                self.token2=t1
                self.token1=t2
                
            }
            self.arrdata=[]
            self.tbvmessage.reloadData()
        }
        socket.on("chatid"){(data, acl) in
            let arr = data as? [[String: Any]]
            self.chat_id=arr![0]["chat_id"] as! String
            self.txtremind.text="My self \(self.token1) chat \(self.token2) with id \(self.chat_id)"
        }
        socket.on("updatechat_m"){(data, acl) in
            print("Minh message \(data)")
            if (self.checker==false) {
                self.arrdata=[]
                self.checker=true
            }
            let arr = data as? [[String: Any]]
            let u1=arr![0]["user"] as! String
            let m1=arr![0]["message"] as! String
            

            //print("Minh array\(arr?[0]["message"])")
           // let t1=arr![0]["messages"] as? String
            
            var s:String = ""
            if (u1==self.token1) {
                s="ME:\(u1):\(m1)_____________________________"
            }
            else{
                s="\(u1):\(m1)"
            }
            self.arrdata.append(s)
            self.tbvmessage.reloadData()
        }
        socket.on("chat updated"){(data, acl) in
            
            
            print("This is the data Minh \(data)")
            self.socket.emit("needupdate", with: [self.chat_id])
        }
        socket.on("end_updatechat_m"){(data, acl) in
            self.checker=false
            self.tbvmessage.reloadData()
        }
        socket.on("done_insert"){(data, acl) in
  
            self.message["token"]=self.token1
            self.message["message"]=self.txtin.text
            self.message["chat_id"]=self.chat_id
            self.message["user1"]=self.token1
            self.message["user2"]=self.token2
            
            self.socket.emit("send_message2_m", with:[self.message])
        }
    }
    

    @IBAction func Connect(_ sender: Any) {
        socket.connect()
        if (socket.status==SocketIOClientStatus.connected){

            socket.emit("want_be_supported_m", with: [socket.sid!])
            txtremind.text=(" The socket \(socket.sid) connect to server")
            tbsupport.isEnabled=true
            support.isEnabled=true
        }

        
    }
    
    
    @IBAction func To_be_support(_ sender: Any) {
     
        webdata["token"]=token1
        webdata["socket_id"]=socketid
        
        socket.emit("to_be_supported", with: [webdata])
        btnsend.isEnabled=true
        support.isEnabled=false
        tbsupport.isEnabled=false
    }
    
    @IBAction func support(_ sender: Any) {
        webdata["token"]=token1
        webdata["socket_id"]=socketid
        
        socket.emit("to_support", with: [webdata])
        btnsend.isEnabled=true
        support.isEnabled=false
        tbsupport.isEnabled=false
    }
    
    @IBAction func Send(_ sender: Any) {
        message["token"]=self.token1
        message["message"]=txtin.text
        message["chat_id"]=self.chat_id
        message["user1"]=self.token1
        message["user2"]=self.token2

        socket.emit("send_message_m", with:[message])
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cleartable(_ sender: Any) {
        self.arrdata=[]
        self.tbvmessage.reloadData()
    }
    
}
extension ViewController: UITableViewDelegate,UITableViewDataSource
{

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return arrdata.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell=tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.textAlignment = .right
    cell.textLabel?.text=arrdata[indexPath.row]
    return cell
}

}
