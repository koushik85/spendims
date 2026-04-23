package com.spendilizer.service;

import com.spendilizer.entity.Category;
import com.spendilizer.entity.Status;
import com.spendilizer.entity.User;
import com.spendilizer.repository.CategoryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    // ── Read (global — visible to all users) ────────────────────────

    public List<Category> getAllActiveCategory(User user) {
        return categoryRepository.findAllByRowStatus(Status.ACTIVE);
    }

    public List<Category> getActiveCategories(User user) {
        return getAllActiveCategory(user);
    }

    public List<Category> getAllActiveCategory() {
        return categoryRepository.findAllByRowStatus(Status.ACTIVE);
    }

    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    // ── Admin CRUD (SUPER_ADMIN only) ────────────────────────────────

    public Category adminCreateCategory(Category category, User admin) {
        if (categoryRepository.existsByNameIgnoreCaseAndRowStatus(category.getName(), Status.ACTIVE)) {
            throw new IllegalArgumentException(
                    "A category named \"" + category.getName() + "\" already exists.");
        }
        category.setCreatedBy(admin);
        return categoryRepository.save(category);
    }

    public Optional<Category> getCategoryById(Long id) {
        return categoryRepository.findById(id);
    }

    public Category adminUpdateCategory(Long id, Category updatedCategory) {
        Category existing = getCategoryById(id)
                .orElseThrow(() -> new RuntimeException("Category not found: " + id));
        if (categoryRepository.existsByNameIgnoreCaseAndRowStatusAndIdNot(
                updatedCategory.getName(), Status.ACTIVE, id)) {
            throw new IllegalArgumentException(
                    "A category named \"" + updatedCategory.getName() + "\" already exists.");
        }
        existing.setName(updatedCategory.getName());
        existing.setDescription(updatedCategory.getDescription());
        existing.setRowStatus(updatedCategory.getRowStatus());
        return categoryRepository.save(existing);
    }

    public void adminSoftDeleteCategory(Long id) {
        Category existing = getCategoryById(id)
                .orElseThrow(() -> new RuntimeException("Category not found: " + id));
        existing.setRowStatus(Status.DELETED);
        categoryRepository.save(existing);
    }

    // ── Legacy scoped methods (kept for backward compatibility) ──────

    public Category createCategory(Category category, User user) {
        return adminCreateCategory(category, user);
    }

    public Optional<Category> getCategoryById(Long id, User user) {
        return getCategoryById(id);
    }

    public Category updateCategory(Long id, Category updatedCategory, User user) {
        return adminUpdateCategory(id, updatedCategory);
    }

    public void softDeleteCategory(Long id, User user) {
        adminSoftDeleteCategory(id);
    }
}
