package com.spendilizer.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "group_expense")
public class GroupExpense {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "split_group_id", nullable = false)
    private SplitGroup splitGroup;

    @Column(nullable = false, length = 200)
    private String description;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "paid_by_member_id", nullable = false)
    private GroupMember paidBy;

    @Enumerated(EnumType.STRING)
    @Column(name = "split_type", nullable = false)
    private SplitType splitType = SplitType.EQUAL;

    @Column(name = "expense_date", nullable = false)
    private LocalDate expenseDate;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "expense", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<ExpenseSplit> splits = new ArrayList<>();

    public GroupExpense() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public SplitGroup getSplitGroup() { return splitGroup; }
    public void setSplitGroup(SplitGroup splitGroup) { this.splitGroup = splitGroup; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public GroupMember getPaidBy() { return paidBy; }
    public void setPaidBy(GroupMember paidBy) { this.paidBy = paidBy; }

    public SplitType getSplitType() { return splitType; }
    public void setSplitType(SplitType splitType) { this.splitType = splitType; }

    public LocalDate getExpenseDate() { return expenseDate; }
    public void setExpenseDate(LocalDate expenseDate) { this.expenseDate = expenseDate; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<ExpenseSplit> getSplits() { return splits; }
    public void setSplits(List<ExpenseSplit> splits) { this.splits = splits; }
}
