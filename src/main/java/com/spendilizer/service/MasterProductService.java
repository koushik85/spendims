package com.spendilizer.service;

import com.spendilizer.entity.MasterProduct;
import com.spendilizer.entity.Status;
import com.spendilizer.repository.MasterProductRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MasterProductService {

    private final MasterProductRepository masterProductRepository;

    public MasterProductService(MasterProductRepository masterProductRepository) {
        this.masterProductRepository = masterProductRepository;
    }

    public List<MasterProduct> getAllActiveMasterProducts() {
        return masterProductRepository.findAllByRowStatusOrderByNameAsc(Status.ACTIVE);
    }

    public MasterProduct getActiveById(Long id) {
        return masterProductRepository.findByIdAndRowStatus(id, Status.ACTIVE)
                .orElseThrow(() -> new RuntimeException("Master product not found: " + id));
    }

    public boolean hasAnyMasterProducts() {
        return masterProductRepository.count() > 0;
    }

    public MasterProduct save(MasterProduct masterProduct) {
        return masterProductRepository.save(masterProduct);
    }
}
