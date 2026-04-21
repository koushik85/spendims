package com.spendilizer.dto;

import java.math.BigDecimal;

public class MemberBalanceDto {
    private Long memberId;
    private String memberName;
    private BigDecimal totalPaid;
    private BigDecimal totalOwed;
    private BigDecimal netBalance; // positive = others owe them; negative = they owe others

    public MemberBalanceDto(Long memberId, String memberName,
                            BigDecimal totalPaid, BigDecimal totalOwed) {
        this.memberId = memberId;
        this.memberName = memberName;
        this.totalPaid = totalPaid;
        this.totalOwed = totalOwed;
        this.netBalance = totalPaid.subtract(totalOwed);
    }

    public Long getMemberId() { return memberId; }
    public String getMemberName() { return memberName; }
    public BigDecimal getTotalPaid() { return totalPaid; }
    public BigDecimal getTotalOwed() { return totalOwed; }
    public BigDecimal getNetBalance() { return netBalance; }
}
