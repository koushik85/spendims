package com.spendilizer.service;

import com.spendilizer.entity.Customer;
import com.spendilizer.entity.Status;
import com.spendilizer.entity.User;
import com.spendilizer.repository.CustomerRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CustomerService {

    private final CustomerRepository customerRepository;
    private final UserService userService;

    public CustomerService(CustomerRepository customerRepository, UserService userService) {
        this.customerRepository = customerRepository;
        this.userService = userService;
    }

    public Customer createCustomer(Customer customer, User user) {
        List<User> scope = userService.getScopeUsers(user);
        if (customerRepository.existsByEmailAndCreatedByInAndRowStatus(
                customer.getEmail(), scope, Status.ACTIVE)) {
            throw new IllegalArgumentException(
                    "A customer with email \"" + customer.getEmail() + "\" already exists.");
        }
        customer.setCreatedBy(user);
        customer.setRowStatus(Status.ACTIVE);
        return customerRepository.save(customer);
    }

    public List<Customer> getAllActive(User user) {
        return customerRepository.findAllByRowStatusAndCreatedByIn(
                Status.ACTIVE, userService.getScopeUsers(user));
    }

    public Optional<Customer> getById(Long id, User user) {
        return customerRepository.findByIdAndCreatedByIn(id, userService.getScopeUsers(user));
    }

    public Customer updateCustomer(Long id, Customer updated, User user) {
        Customer existing = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Customer not found: " + id));
        List<User> scope = userService.getScopeUsers(user);
        if (customerRepository.existsByEmailAndCreatedByInAndRowStatusAndIdNot(
                updated.getEmail(), scope, Status.ACTIVE, id)) {
            throw new IllegalArgumentException(
                    "A customer with email \"" + updated.getEmail() + "\" already exists.");
        }
        existing.setFirstName(updated.getFirstName());
        existing.setLastName(updated.getLastName());
        existing.setCompanyName(updated.getCompanyName());
        existing.setEmail(updated.getEmail());
        existing.setPhone(updated.getPhone());
        existing.setBillingAddress(updated.getBillingAddress());
        existing.setShippingAddress(updated.getShippingAddress());
        existing.setGstin(updated.getGstin());
        existing.setPan(updated.getPan());
        existing.setNotes(updated.getNotes());
        existing.setRowStatus(updated.getRowStatus());
        return customerRepository.save(existing);
    }

    public void softDeleteCustomer(Long id, User user) {
        Customer existing = getById(id, user)
                .orElseThrow(() -> new RuntimeException("Customer not found: " + id));
        existing.setRowStatus(Status.DELETED);
        customerRepository.save(existing);
    }

    public long countActive(User user) {
        return getAllActive(user).size();
    }
}
