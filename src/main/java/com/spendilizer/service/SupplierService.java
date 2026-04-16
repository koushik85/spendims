package com.spendilizer.service;

import com.spendilizer.entity.Status;
import com.spendilizer.entity.Supplier;
import com.spendilizer.entity.User;
import com.spendilizer.repository.SupplierRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class SupplierService {

    private final SupplierRepository supplierRepository;
    private final UserService userService;

    public SupplierService(SupplierRepository supplierRepository, UserService userService) {
        this.supplierRepository = supplierRepository;
        this.userService = userService;
    }

    public Supplier createSupplier(Supplier supplier, User user) {
        supplier.setCreatedBy(user);
        return supplierRepository.save(supplier);
    }

    public List<Supplier> getAllActiveSuppliers(User user) {
        return supplierRepository.findAllByRowStatusAndCreatedByIn(Status.ACTIVE, userService.getScopeUsers(user));
    }

    public Optional<Supplier> getSupplierById(Long id, User user) {
        return supplierRepository.findByIdAndCreatedByIn(id, userService.getScopeUsers(user));
    }

    public Supplier updateSupplier(Long id, Supplier updatedSupplier, User user) {
        Supplier existing = getSupplierById(id, user)
                .orElseThrow(() -> new RuntimeException("Supplier not found: " + id));
        existing.setName(updatedSupplier.getName());
        existing.setEmail(updatedSupplier.getEmail());
        existing.setPhone(updatedSupplier.getPhone());
        existing.setAddress(updatedSupplier.getAddress());
        existing.setRowStatus(updatedSupplier.getRowStatus());
        return supplierRepository.save(existing);
    }

    public void softDeleteSupplier(Long id, User user) {
        Supplier existing = getSupplierById(id, user)
                .orElseThrow(() -> new RuntimeException("Supplier not found: " + id));
        existing.setRowStatus(Status.DELETED);
        supplierRepository.save(existing);
    }
}
