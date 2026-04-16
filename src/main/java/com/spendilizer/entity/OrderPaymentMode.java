package com.spendilizer.entity;

public enum OrderPaymentMode {
    CASH,
    CARD,
    UPI,
    NET_BANKING,
    BANK_TRANSFER,
    CREDIT,
    CHEQUE;

    public String getLabel() {
        String[] words = this.name().toLowerCase().split("_");
        StringBuilder label = new StringBuilder();
        for (String word : words) {
            if (word.isEmpty()) {
                continue;
            }
            if (label.length() > 0) {
                label.append(' ');
            }
            label.append(Character.toUpperCase(word.charAt(0))).append(word.substring(1));
        }
        return label.toString();
    }
}