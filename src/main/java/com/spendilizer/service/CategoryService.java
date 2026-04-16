package com.spendilizer.service;

import com.spendilizer.entity.Category;
import com.spendilizer.entity.Status;
import com.spendilizer.entity.User;
import com.spendilizer.repository.CategoryRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CategoryService {

    private final CategoryRepository categoryRepository;
    private final UserService userService;

    public CategoryService(CategoryRepository categoryRepository, UserService userService) {
        this.categoryRepository = categoryRepository;
        this.userService = userService;
    }

    public Category createCategory(Category category, User user) {
        List<User> scopeUsers = userService.getScopeUsers(user);
        if (categoryRepository.existsByNameIgnoreCaseAndCreatedByInAndRowStatus(
                category.getName(), scopeUsers, Status.ACTIVE)) {
            throw new IllegalArgumentException(
                    "A category named \"" + category.getName() + "\" already exists in your workspace.");
        }
        category.setCreatedBy(user);
        return categoryRepository.save(category);
    }

    public List<Category> getAllActiveCategory(User user) {
        return categoryRepository.findAllByRowStatusAndCreatedByIn(Status.ACTIVE, userService.getScopeUsers(user));
    }

    public List<Category> getActiveCategories(User user) {
        return getAllActiveCategory(user);
    }

    public Optional<Category> getCategoryById(Long id, User user) {
        return categoryRepository.findByIdAndCreatedByIn(id, userService.getScopeUsers(user));
    }

    public Category updateCategory(Long id, Category updatedCategory, User user) {
        Category existing = getCategoryById(id, user)
                .orElseThrow(() -> new RuntimeException("Category not found: " + id));
        List<User> scopeUsers = userService.getScopeUsers(user);
        if (categoryRepository.existsByNameIgnoreCaseAndCreatedByInAndRowStatusAndIdNot(
                updatedCategory.getName(), scopeUsers, Status.ACTIVE, id)) {
            throw new IllegalArgumentException(
                    "A category named \"" + updatedCategory.getName() + "\" already exists in your workspace.");
        }
        existing.setName(updatedCategory.getName());
        existing.setDescription(updatedCategory.getDescription());
        existing.setRowStatus(updatedCategory.getRowStatus());
        return categoryRepository.save(existing);
    }

    public void softDeleteCategory(Long id, User user) {
        Category existing = getCategoryById(id, user)
                .orElseThrow(() -> new RuntimeException("Category not found: " + id));
        existing.setRowStatus(Status.DELETED);
        categoryRepository.save(existing);
    }
}
