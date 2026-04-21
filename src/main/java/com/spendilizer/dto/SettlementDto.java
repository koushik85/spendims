package com.spendilizer.dto;

import java.math.BigDecimal;

public class SettlementDto {
    private String from;   // who pays
    private String to;     // who receives
    private BigDecimal amount;

    public SettlementDto(String from, String to, BigDecimal amount) {
        this.from = from;
        this.to = to;
        this.amount = amount;
    }

    public String getFrom() { return from; }
    public String getTo() { return to; }
    public BigDecimal getAmount() { return amount; }
}
