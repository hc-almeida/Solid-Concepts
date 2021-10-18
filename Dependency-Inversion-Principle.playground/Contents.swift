/*
 Príncipio de Inversão de Dependencia (DIP - Dependency Inversion Principle):
    Módulos de alto nível não devem depender de módulos de baixo nível. Ambos devem depender de abstrações.
 */

import UIKit

/*
 Problema: Supondo que tenha que consumir uma API e mostrar os resultados, ao fazer da forma abaixo,
    o código se torna fragil, pois se mudar algo na camada de network irá afetar diretamente a
    view controller, ou seja, o módulo de alto nível pode sofrer algum impacto, pois ele depende de uma classe concreta e não uma abstração.
 */

// Estrutura que é usada por uma viewController

struct Product {
    let name: String
    let cost: Int
    let image: UIImage
}

// Camada de network

final class Network {
    private let urlSession = URLSession(configuration: .default)

    func getProducts(for userId: String, completion: @escaping ([Product]) -> Void) {
        guard let url = URL(string: "baseURL/products/user/\(userId)") else {
            completion([])
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        urlSession.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completion([Product(name: "Just an example", cost: 1000, image: UIImage())])
            }
        }
    }
}

// ViewController que usa a camada de network

final class ExampleScreenViewController: UIViewController {
    private let network: Network
    private var products: [Product]
    private let userId: String = "user-id"
    required init?(coder: NSCoder) {
        fatalError()
    }
    init(network: Network, products: [Product]) {
        self.network = network
        self.products = products
        super.init(nibName: nil, bundle: nil)
    }
    override func loadView() {
        view = UIView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getProducts()
    }
    private func getProducts() {
        network.getProducts(for: userId) { [weak self] products in
            self?.products = products
        }
    }
}

// -----------------

// -- Solução: Criar abstrações através de protocolos para tornar o código mais fácil de dar manutenção, desacoplado e escalavel.

protocol ProductProtocol {
    var name: String { get }
    var cost: Int { get }
    var image: UIImage { get }
}

protocol NetworkProtocol {
    func getProducts(for userId: String, completion: @escaping ([ProductProtocol]) -> Void)
}

struct Product2: ProductProtocol {
    let name: String
    let cost: Int
    let image: UIImage
}


final class Network2: NetworkProtocol {
    private let urlSession2 = URLSession(configuration: .default)

    func getProducts(for userId: String, completion: @escaping ([ProductProtocol]) -> Void) {
        guard let url = URL(string: "baseURL/products/user/\(userId)") else {
            completion([])
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        urlSession2.dataTask(with: request) { data, response, error in
            completion([Product2(name: "Just an example", cost: 1000, image: UIImage())])
        }
    }
}

final class ExampleScreenViewController2: UIViewController {
    private let network: NetworkProtocol // Abstraction dependency
    private var products: [ProductProtocol] // Abstraction dependency
    private let userId: String = "user-id"

    required init?(coder: NSCoder) {
        fatalError()
    }

    init(network: NetworkProtocol, products: [ProductProtocol]) { // Abstraction dependency
        self.network = network
        self.products = products
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        view = UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getProducts()
    }

    private func getProducts() {
        network.getProducts(for: userId) { [weak self] products in
            self?.products = products
        }
    }
}

/*
 Pontos chaves do DIP:
    - Módulos de alto nível não devem depender de módulos de baixo nível. Ambos devem depender de abstrações.
    - Abstrações não devem depender de detalhes. Os detalhes devem depender de abstrações.
    - Este princípio é resultado principalmente pela falta dos dois princípios (OCP e LSP).
    - Um código mal projetado é rígido, frágil, imóvel e acoplado.
    - Se não respeitarmos o DIP ao desenvolver um software, este software pode se tornar um software mal projetado.
 
 As vantagens de respeitar este princípio são:
    - Softwares bem projetados.
    - Facilidades na substituição de peças de software (classes, estruturas, módulos) quando eles estão em conformidade com os protocolos.
    - Quando é respeitado o DIP conseguimos melhorar testabilidade do nosso código, principalmente pois agora não dependemos de
      implementações concretas que podem possuir muitas dependências que acabam atrapalhando na hora de criar testes de unidades.
 */

