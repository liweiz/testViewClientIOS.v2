// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

func s(t: Bool) -> Int? {
    if t {
        return nil
    } else {
        return 0
    }
}

let x = s(false)

func ss() -> Bool {
    let y = s(true)
    if y == 0 {
        return true
    } else {
        return false
    }
}

ss()