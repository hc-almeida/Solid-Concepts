
/*
 Definição: O OCP - Open/closed Principle (“Aberto e fechado”) tem como objetivo trabalhar diretamente com a manutenção e evolução das classes que são abertas para extensão e fechadas para modificação.. "Você deve ser capaz de estender um comportamento de uma classe sem a necessidade de modificá-lo."
 */

import UIKit

// -- Problema: Possuímos uma classe de um jogo, cuja responsabilidade é recuperar uma lista de usuários de uma API, converte de JSON para uma classe de modelo e retorna o resultado. Agora nosso jogo ganhou uma nova expansão, além de ter usuários normais também podemos jogar como alienígenas e nossa classe UserFetcher deve ser capaz de buscar os tipos de classes.

// -- Uma alternativa seria sempre copiar todo do códido do UserFetcher para os novos tipos, no entanto, iria fechar gerar códigos repetidos e teriamos que alerar a classe.

class User: Decodable {
    var name: String?
    var character: String?
    var score: Double?
}

class Alien: Decodable {
    var name: String?
    var character: String?
    var score: Double?
}

class UserFetcher {
    func fetchUsers(completion: @escaping (Result<[User], Error>)-> Void) {
        let session = URLSession.shared
        let url = URL(string: "https://www.generic.com")!
        session.dataTask(with: url) { (data, _, error) in
            if let error = error {
                return completion(.failure(error))
            }
            
            guard let data = data else {
                return completion(.success([]))
            }
            
            let decoder = JSONDecoder()
            let decoded = try? decoder.decode([User].self, from: data)
            completion(.success(decoded ?? []))
        }
    }
}

// -- Solução: O principio de aberto e fechado se torna dificil de aplicar porque devemos trabalhar com abstração, quando encontramos uma forma de abstrair, conseguimos aplicar esse conceito com mais facilidade. Pensando nisso, nossos objetos de modelos podem conformar com o protocolo Decodable e assim não precisamos depender de um tipo específico para realizar a busca e conversão.

class Fetcher<T: Decodable> {
    func fetch(completion: @escaping (Result<[T],Error>)-> Void) {
        let session = URLSession.shared
        let url = URL(string: "https://www.exemplo.com")!
        session.dataTask(with: url) { (data, _, error) in
        if let error = error {
            return completion(.failure(error))
        }

        guard let data = data else {
            return completion(.success([]))
        }

        let decoder = JSONDecoder()
        let decoded = try? decoder.decode([T].self, from: data)
        completion(.success(decoded ?? []))
        }
    }
}

// -- Para utilizar:

typealias UserFetchers = Fetcher<User>
typealias AlienFetcher = Fetcher<Alien>
