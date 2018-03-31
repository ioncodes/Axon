//
//  main.swift
//  Axon
//
//  Created by Luca Marcelli on 30.03.18.
//  Copyright © 2018 Luca Marcelli. All rights reserved.
//

import Foundation

let methodRegex = "([\\+\\-]) \\(([\\w ]+)\\)([\\w]+)[:;]([\\w\\(\\) \\:\\*]+)?;?"

func matches(for regex: String, in text: String) -> [NSTextCheckingResult] {
    let re = try? NSRegularExpression(pattern: regex, options: NSRegularExpression.Options.caseInsensitive)
    let matches = re?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
    return matches!
}

let path = CommandLine.arguments[1]
let outName = CommandLine.arguments[2]

let fileManager = FileManager.default
let enumerator = fileManager.enumerator(atPath: path)

var headerFiles: [String] = []

while let element = enumerator?.nextObject() as? String {
    if element.hasSuffix("h") {
        print(String(format: "Found file '%@'", element))
        headerFiles.append(path + "/" + element)
    }
}

print(String(format: "Found %i files", headerFiles.count))

var methods: [String: [Method]] = [:]

for headerFile in headerFiles {
    let headerName = URL(fileURLWithPath: headerFile).lastPathComponent
    methods[headerName] = []
    let contentFromFile = try String(contentsOfFile: headerFile, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
    for match in matches(for: methodRegex, in: contentFromFile) {
        let methodType = (contentFromFile as NSString).substring(with: match.range(at: 1))
        let returnType = (contentFromFile as NSString).substring(with: match.range(at: 2))
        let methodName = (contentFromFile as NSString).substring(with: match.range(at: 3))
        var methodArgs: String = ""
        if(match.range(at: 4).location != NSNotFound) {
            methodArgs = (contentFromFile as NSString).substring(with: match.range(at: 4))
        }
        print(String(format: "Found method in %@:\n* Name: %@\n* Type: %@\n* Return: %@\n* Args: %@", headerFile, methodName, methodType, returnType, methodArgs))
        let method = Method(name: methodName, type: methodType, returnType: returnType, args: methodArgs.contains(" ")
            ? methodArgs.components(separatedBy: " ")
            : methodArgs.isEmpty
            ? []
            : [methodArgs])
        methods[headerName]?.append(method)
    }
}

print("Writing data")
let data = try JSONEncoder().encode(methods)
try data.write(to: URL(fileURLWithPath: outName))

print("Done")
