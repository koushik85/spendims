package com.spendilizer.service;

import com.spendilizer.entity.Category;
import com.spendilizer.entity.Hsn;
import com.spendilizer.entity.MasterProduct;
import com.spendilizer.entity.Product;
import com.spendilizer.entity.Status;
import com.spendilizer.entity.Supplier;
import com.spendilizer.entity.User;
import com.spendilizer.repository.CategoryRepository;
import com.spendilizer.repository.HsnRepository;
import com.spendilizer.repository.ProductRepository;
import com.spendilizer.repository.SupplierRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final SupplierRepository supplierRepository;
    private final HsnRepository hsnRepository;
    private final MasterProductService masterProductService;
    private final UserService userService;

    public ProductService(ProductRepository productRepository,
                          CategoryRepository categoryRepository,
                          SupplierRepository supplierRepository,
                          HsnRepository hsnRepository,
                          MasterProductService masterProductService,
                          UserService userService) {
        this.productRepository = productRepository;
        this.categoryRepository = categoryRepository;
        this.supplierRepository = supplierRepository;
        this.hsnRepository = hsnRepository;
        this.masterProductService = masterProductService;
        this.userService = userService;
    }

    public Product createProduct(Product product, User user) {
        product.setCostPrice(defaultMoney(product.getCostPrice()));
        product.setSellingPrice(defaultMoney(product.getSellingPrice()));
        product.setMrp(defaultMoney(product.getMrp()));
        product.setCreatedBy(user);
        return productRepository.save(product);
    }

    public Product createProductFromMaster(Long masterProductId, Product pricingInput, User user) {
        MasterProduct master = masterProductService.getActiveById(masterProductId);
        List<User> scopeUsers = userService.getScopeUsers(user);

        Product product = new Product();
        product.setName(master.getName());
        product.setSku(generateSku(master.getCategoryName(), master.getName(), user));
        product.setDescription(master.getDescription());
        product.setCategory(resolveOrCreateCategory(master.getCategoryName(), user, scopeUsers));
        product.setSupplier(resolveSupplierForMaster(pricingInput.getSupplier(), master.getSupplierName(), user, scopeUsers));
        product.setHsn(resolveOrCreateHsn(master.getHsnCode()));
        product.setCostPrice(defaultMoney(pricingInput.getCostPrice()));
        product.setSellingPrice(defaultMoney(pricingInput.getSellingPrice()));
        product.setMrp(defaultMoney(pricingInput.getMrp()));
        product.setCreatedBy(user);
        product.setRowStatus(Status.ACTIVE);
        return productRepository.save(product);
    }

    public List<Product> getAllProducts(User user) {
        return productRepository.findAllByCreatedByIn(userService.getScopeUsers(user));
    }

    public List<Product> getAllActiveProducts(User user) {
        return productRepository.findAllByRowStatusAndCreatedByIn(Status.ACTIVE, userService.getScopeUsers(user));
    }

    public Optional<Product> getProductById(Long id, User user) {
        return productRepository.findByIdAndCreatedByIn(id, userService.getScopeUsers(user));
    }

    public Product updateProduct(Long id, Product updatedProduct, User user) {
        Product existing = getProductById(id, user)
                .orElseThrow(() -> new RuntimeException("Product not found: " + id));
        existing.setName(updatedProduct.getName());
        existing.setSku(updatedProduct.getSku());
        existing.setCostPrice(defaultMoney(updatedProduct.getCostPrice()));
        existing.setSellingPrice(defaultMoney(updatedProduct.getSellingPrice()));
        existing.setMrp(defaultMoney(updatedProduct.getMrp()));
        existing.setDescription(updatedProduct.getDescription());
        existing.setCategory(updatedProduct.getCategory());
        existing.setSupplier(updatedProduct.getSupplier());
        existing.setRowStatus(updatedProduct.getRowStatus());
        return productRepository.save(existing);
    }

    public void softDeleteProduct(Long id, User user) {
        Product existing = getProductById(id, user)
                .orElseThrow(() -> new RuntimeException("Product not found: " + id));
        existing.setRowStatus(Status.DELETED);
        productRepository.save(existing);
    }

    public String generateSku(String categoryName, String productName, User user) {
        String catPrefix  = buildPrefix(categoryName);
        String prodPrefix = buildPrefix(productName);
        List<String> existingSkus = productRepository.findSkusByPrefix(catPrefix + "-", userService.getScopeUsers(user));

        int nextNumber = 1;
        if (!existingSkus.isEmpty()) {
            int max = existingSkus.stream()
                    .mapToInt(sku -> {
                        try { return Integer.parseInt(sku.substring(sku.lastIndexOf("-") + 1)); }
                        catch (NumberFormatException e) { return 0; }
                    })
                    .max().orElse(0);
            nextNumber = max + 1;
        }
        return catPrefix + "-" + prodPrefix + "-" + String.format("%03d", nextNumber);
    }

    private String buildPrefix(String input) {
        if (input == null || input.trim().isEmpty()) return "UNK";
        String[] words = input.trim().toUpperCase().split("\\s+");
        StringBuilder prefix = new StringBuilder();
        for (String word : words) {
            if (prefix.length() >= 3) break;
            int charsNeeded = 3 - prefix.length();
            prefix.append(word, 0, Math.min(charsNeeded, word.length()));
        }
        while (prefix.length() < 3) prefix.append("X");
        return prefix.toString();
    }

    private Category resolveOrCreateCategory(String name, User user, List<User> scopeUsers) {
        return categoryRepository.findFirstByNameIgnoreCaseAndCreatedByInAndRowStatus(name, scopeUsers, Status.ACTIVE)
                .orElseGet(() -> {
                    Category category = new Category();
                    category.setName(name);
                    category.setDescription("Auto-created from master product catalog.");
                    category.setCreatedBy(user);
                    category.setRowStatus(Status.ACTIVE);
                    return categoryRepository.save(category);
                });
    }

    private Supplier resolveOrCreateSupplier(String name, User user, List<User> scopeUsers) {
        return supplierRepository.findFirstByNameIgnoreCaseAndCreatedByInAndRowStatus(name, scopeUsers, Status.ACTIVE)
                .orElseGet(() -> {
                    Supplier supplier = new Supplier();
                    supplier.setName(name);
                    supplier.setCreatedBy(user);
                    supplier.setRowStatus(Status.ACTIVE);
                    return supplierRepository.save(supplier);
                });
    }

    private Supplier resolveSupplierForMaster(Supplier selectedSupplier,
                                              String masterSupplierName,
                                              User user,
                                              List<User> scopeUsers) {
        Long selectedSupplierId = selectedSupplier != null ? selectedSupplier.getId() : null;
        if (selectedSupplierId != null && selectedSupplierId > 0) {
            return supplierRepository.findByIdAndCreatedByIn(selectedSupplierId, scopeUsers)
                    .orElseThrow(() -> new RuntimeException("Selected supplier not found: " + selectedSupplierId));
        }
        return resolveOrCreateSupplier(masterSupplierName, user, scopeUsers);
    }

    private Hsn resolveOrCreateHsn(String hsnCode) {
        return hsnRepository.findFirstByHsnCodeIgnoreCase(hsnCode)
                .orElseGet(() -> {
                    Hsn hsn = new Hsn();
                    hsn.setHsnCode(hsnCode);
                    hsn.setDescription("Auto-created from master product catalog.");
                    return hsnRepository.save(hsn);
                });
    }

    private BigDecimal defaultMoney(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }
}
