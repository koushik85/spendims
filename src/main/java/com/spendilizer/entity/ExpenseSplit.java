package com.spendilizer.entity;

import jakarta.persistence.*;

import java.math.BigDecimal;

@Entity
@Table(name = "expense_split")
public class ExpenseSplit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "expense_id", nullable = false)
    private GroupExpense expense;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "member_id", nullable = false)
    private GroupMember member;

    @Column(name = "share_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal shareAmount;

    public ExpenseSplit() {}

    public ExpenseSplit(GroupExpense expense, GroupMember member, BigDecimal shareAmount) {
        this.expense = expense;
        this.member = member;
        this.shareAmount = shareAmount;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public GroupExpense getExpense() { return expense; }
    public void setExpense(GroupExpense expense) { this.expense = expense; }

    public GroupMember getMember() { return member; }
    public void setMember(GroupMember member) { this.member = member; }

    public BigDecimal getShareAmount() { return shareAmount; }
    public void setShareAmount(BigDecimal shareAmount) { this.shareAmount = shareAmount; }
}
