//
//  String+extension.swift
//  MyAMG
//
//  Created by Сергей Никитин on 15/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation

extension String {
    
    func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
        
        let disallowedCharacterSet = NSCharacterSet(charactersIn: matchCharacters).inverted
        return self.rangeOfCharacter(from: disallowedCharacterSet) == nil
    }
    
    func capitalizeName() -> String {
        return sentenceCapitalizedString(string: self)
    }
    
    func sentenceCapitalizedString(string: String) -> String {
        
        if string.isEmpty { return string }
        
        let uppercase = string.prefix(1).uppercased()
        let lowercase = string.suffix(string.count-1).lowercased()
        
        return "\(uppercase)\(lowercase)"
    }
    
    
}
