package com.spendilizer.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Entity
@Table(name = "stock_movement")
public class StockMovement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StockMovementType type;

    @Column(nullable = false)
    private Integer quantity;

    private String note;

    @Enumerated(EnumType.STRING)
    @Column(name = "row_status", nullable = false)
    private Status rowStatus = Status.ACTIVE;

    @CreationTimestamp
    @Column(name = "moved_at", updatable = false)
    private LocalDateTime movedAt;

    public StockMovement () {}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public StockMovementType getType() {
        return type;
    }

    public void setType(StockMovementType type) {
        this.type = type;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Status getRowStatus() {
        return rowStatus;
    }

    public void setRowStatus(Status rowStatus) {
        this.rowStatus = rowStatus;
    }

    public LocalDateTime getMovedAt() {
        return movedAt;
    }

    public void setMovedAt(LocalDateTime movedAt) {
        this.movedAt = movedAt;
    }

    public String getMovedAtFormatted() {
        if (movedAt == null) return "—";
        return movedAt.format(DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm"));
    }
}
