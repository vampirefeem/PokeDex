//
//  MainVC.swift
//  PokeDex
//
//  Created by Patcharapon Joksamut on 1/31/2560 BE.
//  Copyright © 2560 Patcharapon Joksamut. All rights reserved.
//

import UIKit
import AVFoundation

class MainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate{

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pokemons = [Pokemon]()
    var filteredPoken = [Pokemon]()
    var searchMode = false
    var musicPlater: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        initAudio()
        
        parsePokemonCSV()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            
            searchMode = false
            collectionView.reloadData()
            view.endEditing(true)
            
        } else {
            
            searchMode = true
            
            let lower = searchBar.text!.lowercased()
            filteredPoken = pokemons.filter({$0.name.range(of: lower) != nil})
            collectionView.reloadData()
            
        }
        
    }
    
    func initAudio() {
        
        let path = Bundle.main.path(forResource: "bgMusic", ofType: "mp3")
        
        do {
            
            musicPlater = try AVAudioPlayer(contentsOf: URL(string: path!)!)
            musicPlater.prepareToPlay()
            musicPlater.numberOfLoops = -1
            musicPlater.play()
            
        } catch let err as NSError{
            
            print(err.description)
            
        }
        
    }
    
    func parsePokemonCSV() {
        
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")
        
        do {
            let csv = try CSV(contentsOfURL: path!)
            let rows = csv.rows
            
            for row in rows {
                
                let pokeID = Int(row["id"]!)!
                let name = row["identifier"]!
                
                let poke = Pokemon(name: name, id: pokeID)
                
                self.pokemons.append(poke)
            }
            
            
        } catch let err as NSError {
            
            print(err.description)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell{
            
            let pokemon:Pokemon!
            
            if searchMode {
                
                pokemon = filteredPoken[indexPath.row]
                
            } else {
                
                pokemon = pokemons[indexPath.row]
                
            }
            
            cell.updateCell(pokemon)
            
            return cell
            
        } else {
            
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var poke: Pokemon!
        
        if searchMode {
            
            poke = filteredPoken[indexPath.row]
            
        } else {
            
            poke = pokemons[indexPath.row]
            
        }
        
        performSegue(withIdentifier: "PokemonDetailVC", sender: poke)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PokemonDetailVC" {
            if let DetailVC = segue.destination as? DetailVC {
                if let poke = sender as? Pokemon {
                    DetailVC.pokemon = poke
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if searchMode {
            
            return filteredPoken.count
            
        } else {
            return pokemons.count
            
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 105, height: 105)
    }

    @IBAction func musicButtonPressed(_ sender: UIButton) {
        
        if musicPlater.isPlaying {
            
            musicPlater.pause()
            sender.alpha = 0.2
            
        } else {
            
            musicPlater.play()
            sender.alpha = 1.0
        }
        
    }
}

