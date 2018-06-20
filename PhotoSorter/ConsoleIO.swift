//
//  ConsoleIO.swift
//  PhotoSorter
//
//  Created by Andrew Lewis on 5/29/18.
//  Copyright © 2018 Andrew Lewis. All rights reserved.
//

import Foundation

// this class was built using instructions from https://www.raywenderlich.com/163134/command-line-programs-macos-tutorial-2.

class ConsoleIO{

    enum OutputType{
        case error
        case standard
    }
    
    func writeMessage(_ message: String, to: OutputType = .standard){
        switch to {
        case.standard:
            print("\(message)")
        case.error:
            fputs("ERROR: \(message)\n", stderr)
        }
    }
    
    // this feels like a cheap hack, but so far, I can't find a better option in Swift
    func printDelimiter(){
            print("**********************************")
    }
    
    // this function will print possible commands to use with the application, if the user enters something in error.
    func printUsage(){
        writeMessage("This will contain information on how to use the program")
    }
    
    func getInput() -> String {
        // grab a handle to stdin
        let keyboard = FileHandle.standardInput
        
        // read data in the stream
        let inputData = keyboard.availableData
        
        // convert the data to a string
        let strData = String(data: inputData, encoding: String.Encoding.utf8)!
        
        // remove newline characters
        return strData.trimmingCharacters(in: CharacterSet.newlines)
    }

}
