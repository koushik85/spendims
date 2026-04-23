package com.spendilizer.service;

import com.spendilizer.entity.ApprovalStatus;
import com.spendilizer.entity.MasterProduct;
import com.spendilizer.entity.MasterProductRequest;
import com.spendilizer.entity.Status;
import com.spendilizer.entity.User;
import com.spendilizer.repository.MasterProductRepository;
import com.spendilizer.repository.MasterProductRequestRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class MasterProductService {

    private final MasterProductRepository masterProductRepository;
    private final MasterProductRequestRepository requestRepository;

    public MasterProductService(MasterProductRepository masterProductRepository,
                                MasterProductRequestRepository requestRepository) {
        this.masterProductRepository = masterProductRepository;
        this.requestRepository = requestRepository;
    }

    public List<MasterProduct> getAllActiveMasterProducts() {
        return masterProductRepository.findAllByRowStatusOrderByNameAsc(Status.ACTIVE);
    }

    public List<MasterProduct> getAllMasterProducts() {
        return masterProductRepository.findAll();
    }

    public MasterProduct getActiveById(Long id) {
        return masterProductRepository.findByIdAndRowStatus(id, Status.ACTIVE)
                .orElseThrow(() -> new RuntimeException("Master product not found: " + id));
    }

    public MasterProduct getById(Long id) {
        return masterProductRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Master product not found: " + id));
    }

    public boolean hasAnyMasterProducts() {
        return masterProductRepository.count() > 0;
    }

    public MasterProduct save(MasterProduct masterProduct) {
        masterProduct.setName(normalizeRequired(masterProduct.getName(), "Product name"));
        masterProduct.setCategoryName(normalizeRequired(masterProduct.getCategoryName(), "Category"));
        masterProduct.setHsnCode(normalizeRequired(masterProduct.getHsnCode(), "HSN Code"));
        masterProduct.setSku(ensureTechnicalSku(masterProduct.getSku(), "MST"));
        masterProduct.setSupplierName(normalizeOptional(masterProduct.getSupplierName(), "USER_DEFINED"));
        return masterProductRepository.save(masterProduct);
    }

    @Transactional
    public void softDelete(Long id) {
        MasterProduct mp = getById(id);
        mp.setRowStatus(Status.INACTIVE);
        masterProductRepository.save(mp);
    }

    // ── Request flow ────────────────────────────────────────────────

    public MasterProductRequest submitRequest(MasterProductRequest request, User requestedBy) {
        String name = normalizeRequired(request.getName(), "Product name");
        String categoryName = normalizeRequired(request.getCategoryName(), "Category");
        String hsnCode = normalizeRequired(request.getHsnCode(), "HSN Code");

        request.setName(name);
        request.setCategoryName(categoryName);
        request.setHsnCode(hsnCode);
        request.setSku(ensureTechnicalSku(request.getSku(), "REQ"));
        request.setSupplierName(normalizeOptional(request.getSupplierName(), "USER_DEFINED"));

        if (masterProductRepository.existsByNameIgnoreCaseAndCategoryNameIgnoreCaseAndRowStatus(name, categoryName, Status.ACTIVE)) {
            throw new IllegalArgumentException("A master product named \"" + name + "\" in category \"" + categoryName + "\" already exists.");
        }

        if (requestRepository.existsByNameIgnoreCaseAndCategoryNameIgnoreCaseAndRequestStatus(name, categoryName, ApprovalStatus.PENDING)) {
            throw new IllegalArgumentException("A pending request for \"" + name + "\" in category \"" + categoryName + "\" already exists.");
        }

        request.setRequestedBy(requestedBy);
        request.setRequestStatus(ApprovalStatus.PENDING);
        return requestRepository.save(request);
    }

    private String normalizeRequired(String value, String fieldName) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(fieldName + " is required.");
        }
        return value.trim();
    }

    private String normalizeOptional(String value, String defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        return value.trim();
    }

    private String ensureTechnicalSku(String currentValue, String prefix) {
        if (currentValue != null && !currentValue.trim().isEmpty()) {
            return currentValue.trim();
        }
        String generated;
        do {
            generated = prefix + "-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        } while (masterProductRepository.existsBySkuIgnoreCase(generated));
        return generated;
    }

    public List<MasterProductRequest> getPendingRequests() {
        return requestRepository.findAllByRequestStatusOrderByRequestedAtDesc(ApprovalStatus.PENDING);
    }

    public List<MasterProductRequest> getAllRequests() {
        return requestRepository.findAll();
    }

    public List<MasterProductRequest> getRequestsByUser(User user) {
        return requestRepository.findAllByRequestedByOrderByRequestedAtDesc(user);
    }

    @Transactional
    public void approveRequest(Long requestId) {
        MasterProductRequest req = requestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found: " + requestId));
        req.setRequestStatus(ApprovalStatus.APPROVED);
        req.setReviewedAt(LocalDateTime.now());
        requestRepository.save(req);

        MasterProduct mp = new MasterProduct();
        mp.setName(req.getName());
        mp.setSku(ensureTechnicalSku(req.getSku(), "MST"));
        mp.setCategoryName(req.getCategoryName());
        mp.setSupplierName("USER_DEFINED");
        mp.setHsnCode(req.getHsnCode());
        mp.setDescription(req.getDescription());
        mp.setRowStatus(Status.ACTIVE);
        masterProductRepository.save(mp);
    }

    @Transactional
    public void rejectRequest(Long requestId, String reviewNote) {
        MasterProductRequest req = requestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found: " + requestId));
        req.setRequestStatus(ApprovalStatus.REJECTED);
        req.setReviewNote(reviewNote);
        req.setReviewedAt(LocalDateTime.now());
        requestRepository.save(req);
    }
}
