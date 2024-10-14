// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProductMarketplace {

    // Struct definition: Product
    struct Product {
        uint256 id;
        string name;
        uint256 price;
        address payable seller;
        bool isSold;
    }

    // State variables
    mapping(uint256 => Product) public products;
    uint256 public nextProductId;

    // Events
    event ProductAdded(uint256 productId, string name, uint256 price, address indexed seller);
    event ProductPurchased(uint256 productId, address indexed buyer);
    event ProductPriceUpdated(uint256 productId, uint256 newPrice);
    event ProductSoldStatusChanged(uint256 productId, bool isSold);
    event FundsWithdrawn(address indexed seller, uint256 amount);
    event ProductsFetched(Product[] products);

    // Modifier to check valid product
    modifier validProduct(uint256 productId) {
        require(productId < nextProductId, "Product does not exist");
        _;
    }

    // External function to add a product (state-changing)
    function addProduct(string memory _name, uint256 _price) external {
        require(_price > 0, "Price must be greater than zero");

        Product memory newProduct = Product({
            id: nextProductId,
            name: _name,
            price: _price,
            seller: payable(msg.sender),
            isSold: false
        });

        products[nextProductId] = newProduct;
        emit ProductAdded(nextProductId, _name, _price, msg.sender);
        nextProductId++;
    }

    // Public function to purchase a product (requires payment, state-changing)
    function purchaseProduct(uint256 productId) public payable validProduct(productId) {
        Product storage product = products[productId];
        require(!product.isSold, "Product already sold");
        require(msg.value >= product.price, "Insufficient payment");

        product.isSold = true;
        product.seller.transfer(msg.value);

        emit ProductPurchased(productId, msg.sender);
        emit ProductSoldStatusChanged(productId, true);
    }

    // Public function to update product price (state-changing)
    function updateProductPrice(uint256 productId, uint256 _newPrice) public validProduct(productId) {
        Product storage product = products[productId];
        require(msg.sender == product.seller, "Only seller can update price");
        require(!product.isSold, "Cannot update sold product");

        product.price = _newPrice;
        emit ProductPriceUpdated(productId, _newPrice);
    }

    // Public function to withdraw funds (state-changing)
    function withdrawFunds() public {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(msg.sender).transfer(balance);
        emit FundsWithdrawn(msg.sender, balance);
    }

    function getAllProducts() public {
        Product[] memory allProducts = new Product[](nextProductId);
    
        for (uint256 i = 0; i < nextProductId; i++) {
            allProducts[i] = products[i];
        }

        emit ProductsFetched(allProducts);
    }

    function fetchAllProducts() external view returns (Product[] memory) {
    Product[] memory allProducts = new Product[](nextProductId);
    
    for (uint256 i = 0; i < nextProductId; i++) {
        allProducts[i] = products[i];
    }

    return allProducts; // Return the products to the caller

}
}
