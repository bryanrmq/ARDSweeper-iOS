//
//  config.swift
//  ARDSweeper-iOS
//
//  Created by Bryan Reymonenq on 23/06/2015.
//  Copyright (c) 2015 Fliizweb.fr. All rights reserved.
//

import Foundation


let HOST            = "172.31.1.197"
let PORT            = "3000"

/**
    URLS
*/
let ROOT_URL        = "http://" + HOST + ":" + PORT
let URL_LOGIN       = ROOT_URL + "/user/login"
let URL_LOGIN_TOKEN = URL_LOGIN + "/"
let URL_REGISTER    = ROOT_URL + "/user/register"
let URL_GET_USER    = ROOT_URL + "/user/"
let URL_GAME_SOCKET = "http://" + HOST + ":" 


/**
    USER CONFIG
*/
let USERNAME_SIZE = 4
let PASSWORD_SIZE = 4

let TOKEN_KEY = "user.token"
let USERNAME_KEY = "user.username"

/**
    GAME CONFIG
*/
let BOX_SIZE = 100