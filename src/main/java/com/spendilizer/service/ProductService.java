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
import org.springframework.dao.DataIntegrityViolationException;
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
        Supplier selectedSupplier = resolveSelectedSupplier(pricingInput.getSupplier(), scopeUsers);
        Category category = resolveOrCreateCategory(master.getCategoryName(), user);
        Hsn hsn = resolveOrCreateHsn(master.getHsnCode());

        Product product = new Product();
        product.setName(master.getName());
        product.setDescription(master.getDescription());
        product.setCategory(category);
        product.setSupplier(selectedSupplier);
        product.setHsn(hsn);
        product.setCostPrice(defaultMoney(pricingInput.getCostPrice()));
        product.setSellingPrice(defaultMoney(pricingInput.getSellingPrice()));
        product.setMrp(defaultMoney(pricingInput.getMrp()));
        product.setCreatedBy(user);
        product.setRowStatus(Status.ACTIVE);

        for (int attempt = 0; attempt < 3; attempt++) {
            product.setSku(generateSku(master.getCategoryName(), master.getName(), user));
            try {
                return productRepository.save(product);
            } catch (DataIntegrityViolationException ex) {
                if (productRepository.existsBySkuIgnoreCase(product.getSku())) {
                    continue;
                }
                throw ex;
            }
        }
        throw new IllegalArgumentException("Unable to generate a unique SKU for this product. Please try again.");
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
        existing.setCostPrice(defaultMoney(updatedProduct.getCostPrice()));
        existing.setSellingPrice(defaultMoney(updatedProduct.getSellingPrice()));
        existing.setMrp(defaultMoney(updatedProduct.getMrp()));
        existing.setDescription(updatedProduct.getDescription());
        existing.setSupplier(updatedProduct.getSupplier());
        return productRepository.save(existing);
    }

    public void softDeleteProduct(Long id, User user) {
        Product existing = getProductById(id, user)
                .orElseThrow(() -> new RuntimeException("Product not found: " + id));
        existing.setRowStatus(Status.DELETED);
        productRepository.save(existing);
    }

    public String generateSku(String categoryName, String productName, User user) {
        String customerId = resolveCustomerId(user);
        String catPrefix  = buildPrefix(categoryName);
        String prodPrefix = buildPrefix(productName);
        String skuPrefix  = customerId + "-" + catPrefix + "-";
        List<String> existingSkus = productRepository.findSkusByPrefix(skuPrefix, userService.getScopeUsers(user));

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
        return skuPrefix + prodPrefix + "-" + String.format("%03d", nextNumber);
    }

    /**
     * Returns the customer ID to embed in SKUs.
     * Enterprise members use the owner's customer ID so all products in the
     * same enterprise share a consistent prefix.
     * Back-fills a customer ID for legacy users who registered before this
     * feature was added.
     */
    private String resolveCustomerId(User user) {
        return user.getCustomerId() != null ? user.getCustomerId().toString() : "";
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

    private Category resolveOrCreateCategory(String name, User user) {
        String normalizedName = name == null ? "" : name.trim();
        if (normalizedName.isEmpty()) {
            throw new IllegalArgumentException("Master product category is missing. Please update the master product.");
        }

        Optional<Category> existingOpt = categoryRepository.findFirstByNameIgnoreCase(normalizedName);
        if (existingOpt.isPresent()) {
            Category existing = existingOpt.get();
            boolean dirty = false;

            if (existing.getRowStatus() != Status.ACTIVE) {
                existing.setRowStatus(Status.ACTIVE);
                dirty = true;
            }
            if (existing.getDescription() == null || existing.getDescription().isBlank()) {
                existing.setDescription("Auto-created from master product catalog.");
                dirty = true;
            }
            if (existing.getCreatedBy() == null) {
                existing.setCreatedBy(user);
                dirty = true;
            }

            return dirty ? categoryRepository.save(existing) : existing;
        }

        Category category = new Category();
        category.setName(normalizedName);
        category.setDescription("Auto-created from master product catalog.");
        category.setCreatedBy(user);
        category.setRowStatus(Status.ACTIVE);

        try {
            return categoryRepository.save(category);
        } catch (DataIntegrityViolationException ex) {
            // Handle a race where another request inserted the same category name.
            return categoryRepository.findFirstByNameIgnoreCase(normalizedName)
                    .orElseThrow(() -> ex);
        }
    }

    private Supplier resolveSelectedSupplier(Supplier selectedSupplier,
                                             List<User> scopeUsers) {
        Long selectedSupplierId = selectedSupplier != null ? selectedSupplier.getId() : null;
        if (selectedSupplierId == null || selectedSupplierId <= 0) {
            throw new IllegalArgumentException("Please select a supplier before creating a product from the master list.");
        }

        return supplierRepository.findByIdAndCreatedByIn(selectedSupplierId, scopeUsers)
                .orElseThrow(() -> new IllegalArgumentException("Selected supplier is invalid. Please choose a valid supplier."));
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
