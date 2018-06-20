//
//  PhotoSorter.swift
//  PhotoSorter
//
//  Created by Andrew Lewis on 5/29/18.
//  Copyright © 2018 Andrew Lewis. All rights reserved.
//

import Foundation

class PhotoSorter{
    
    let consoleIO = ConsoleIO()
    
    func staticMode(){
        //1
        let argCount = CommandLine.argc
        //2
        let argument = CommandLine.arguments[1]
        //3
        let (option, value) = getOption(argument.substring(from:argument.index(argument.startIndex, offsetBy:1)))
        
        consoleIO.writeMessage("Argument count: \(argCount) Option: \(option) value: \(value)")
    }
    
    enum OptionType: String {
        case copyPictures = "c"
        case exit = "e"
        case unknown
        
        init(value: String) {
            switch value {
                case "c" : self = .copyPictures
                case "e" : self = .exit
                default: self = .unknown
            }
        }
    }
    
    func getOption(_ option:String)->(option:OptionType, value: String){
        return (OptionType(value: option), option)
    }
    
    func userInteraction(){
        consoleIO.writeMessage("""
            This photo sorting app was written by Andy Lewis in 2018 using Swift 4. It is free and meant for open use. WARNING: You are running this software at your own risk. Make sure to run a backup of your current system, and then disconnect the backup before running this app.

            - This app will make a copy of every image it finds and place that copy in a folder according to its creation date.

            - This app will optionally place a text file in every folder with a list of the original file locations of every image, including duplicates.
            
            """)
        
        var shouldQuit = false
        while !shouldQuit {
            consoleIO.writeMessage("""
                Type c to copy photos within User/Documents
                Type e to exit
            """)
            
            let (option, value) = getOption(consoleIO.getInput())
            
            switch option {
                case .copyPictures:
                    consoleIO.printDelimiter()
                    photoCopy()
            case .exit:
                    shouldQuit = true
                
            default:
                consoleIO.writeMessage("Uknown option \(value)", to: .error)
            }
        }
    }
    
    // copies all photos into a new, organized folder.
    func photoCopy(){
        
        let fileManager = FileManager.default
        let homeDirURL = FileManager.default.homeDirectoryForCurrentUser
        var dataPath = homeDirURL.appendingPathComponent("Pictures/Sorted Photos Folder")
        dataPath = URL(fileURLWithPath: dataPath.path)
        
        mainFolderCreation(dataPath: dataPath)
        
        // get the name of every file in the documents folder and place the url in theItems array
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        var theItems = [String]()
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        
        if let dirPath = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath)
            do {
                theItems = try FileManager.default.subpathsOfDirectory(atPath: imageURL.path)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        let documentsPath = homeDirURL.appendingPathComponent("Documents/")
        
        // copy photo and place it in the sorted photos folder
        for file in theItems {
            let fileAsNSString: NSString = file as NSString
            let pathExtension = fileAsNSString.pathExtension
            let fileName = fileAsNSString.lastPathComponent
            let newOriginPath = documentsPath.appendingPathComponent(file)
            
            if pathExtension == "png" || pathExtension == "jpeg" || pathExtension == "jpg" || pathExtension == "tiff" || pathExtension == "gif"{
                
                do{
                    // gets the creation date of the file
                    let fileAttributes = try(fileManager.attributesOfItem(atPath: newOriginPath.path))
                    let fileCreationDate = fileAttributes[FileAttributeKey.creationDate] as! Date
                    
                    // outputs the file creation date to a string
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = NSLocale.current
                    dateFormatter.dateStyle = DateFormatter.Style.medium
                    dateFormatter.dateFormat = "MMMM, yyyy"
                    let convertedDate = dateFormatter.string(from: fileCreationDate)
                    let folderDataPath = dataPath.appendingPathComponent("\(convertedDate)")
                    let fileURL = folderDataPath.appendingPathComponent("Info").appendingPathExtension("txt")
                    
                    if fileManager.fileExists(atPath: folderDataPath.path){
                        do {
                            let fileDataPath = folderDataPath.appendingPathComponent(URL(fileURLWithPath: file).lastPathComponent)
                            try fileManager.copyItem(at: newOriginPath, to: fileDataPath)
                            let fileHandle = try FileHandle(forWritingTo: fileURL)
                            fileHandle.seekToEndOfFile()
                            let writestring = "\(fileName) has a duplicate located at \(newOriginPath).\n\n"
                            fileHandle.write(writestring.data(using: String.Encoding.utf8)!)

                        }catch{
                            
                            let fileHandle = try FileHandle(forWritingTo: fileURL)
                            fileHandle.seekToEndOfFile()
                            let writestring = "\(fileName) has a duplicate located at \(newOriginPath).\n\n"
                            fileHandle.write(writestring.data(using: String.Encoding.utf8)!)
                        }
                        
                    }else{
                        
                        // create directory
                        do {
                            try FileManager.default.createDirectory(at: folderDataPath, withIntermediateDirectories: false)
                            
                        } catch let error as NSError {
                            print(error.localizedDescription);
                        }
                        
                        var writeString = ("INFO.TXT\n\n")
                        //  prepare content and write to file
                        do{
                            try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                        }catch let error as NSError{
                            print("Failed to write to URL")
                            print(error)
                        }

                        // copy image files into directory
                        do {
                            let fileDataPath = folderDataPath.appendingPathComponent(URL(fileURLWithPath: file).lastPathComponent)
                            try fileManager.copyItem(at: newOriginPath, to: fileDataPath)
                            
                            let fileHandle = try FileHandle(forWritingTo: fileURL)
                            fileHandle.seekToEndOfFile()
                            let writestring = "\(fileName) has a duplicate located at \(newOriginPath).\n\n"
                            fileHandle.write(writestring.data(using: String.Encoding.utf8)!)
                        }
                        catch let error as NSError {
                            
                            writeString = ("\(error)")
                            //  prepare content and write to file
                            do{
                                try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                            }catch let error as NSError{
                                print("Failed to write to URL")
                                print(error)
                            }
                        }
                    }

                }catch{
                    print("unable to obtain creation date for \(file).")
                }
            }
        }
    }
    
    func mainFolderCreation(dataPath: URL){
        
        let fileManager = FileManager.default
        // create directory to hold copied photos
        
        if fileManager.fileExists(atPath: dataPath.path){
            print("File already exists. Do you wish to overwrite it? Y or N")
            var userChoice = consoleIO.getInput()
            userChoice = userChoice.uppercased()
            
            if userChoice == "Y" {
                // enter code to delete the existing folder.
                do {
                    try fileManager.trashItem(at: dataPath, resultingItemURL: nil)
                    
                }catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                do {
                    try FileManager.default.createDirectory(at: dataPath, withIntermediateDirectories: true)
                    
                } catch let error as NSError {
                    print(error.localizedDescription);
                }
            }else if userChoice == "N"{
                return
            } else {
                consoleIO.writeMessage("Please enter a valid choice")
                return
            }
            
        } else {
            
            do {
                try FileManager.default.createDirectory(at: dataPath, withIntermediateDirectories: true)
                
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
    }
}
