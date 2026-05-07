package com.spendilizer.service;

import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import com.spendilizer.entity.Invoice;
import com.spendilizer.entity.InvoiceItem;
import com.spendilizer.entity.OrderPaymentMode;
import com.spendilizer.entity.User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;

@Service
public class InvoicePdfService {

    private final InvoiceService invoiceService;

    public InvoicePdfService(InvoiceService invoiceService) {
        this.invoiceService = invoiceService;
    }

    @Transactional(readOnly = true)
    public byte[] generateInvoicePdf(Long invoiceId, User user) {
        Invoice invoice = invoiceService.getById(invoiceId, user)
                .orElseThrow(() -> new RuntimeException("Invoice not found: " + invoiceId));

        String html = buildHtml(invoice);
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            PdfRendererBuilder builder = new PdfRendererBuilder();
            builder.useFastMode();
            builder.withHtmlContent(html, null);
            builder.toStream(outputStream);
            builder.run();
            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate invoice PDF.", e);
        }
    }

    private String buildHtml(Invoice invoice) {
        StringBuilder rows = new StringBuilder();
        int index = 1;
        for (InvoiceItem item : invoice.getItems()) {
            rows.append("<tr>")
                    .append("<td>").append(index++).append("</td>")
                    .append("<td>").append(escape(getProductName(item))).append("</td>")
                    .append("<td>").append(escape(defaultText(item.getHsnCode()))).append("</td>")
                    .append("<td class='num'>").append(item.getQuantity()).append("</td>")
                    .append("<td class='num'>").append(formatMoney(item.getUnitPrice())).append("</td>")
                    .append("<td class='num'>").append(formatPercent(item.getDiscountPercent())).append("</td>")
                    .append("<td class='num'>").append(formatPercent(item.getTaxPercent())).append("</td>")
                    .append("<td class='num amount'>").append(formatMoney(item.getAmount())).append("</td>")
                    .append("</tr>");
        }

        String sellerName = "Seller";
        if (invoice.getCreatedBy() != null && invoice.getCreatedBy().getUserBasicDetails() != null) {
            sellerName = (defaultText(invoice.getCreatedBy().getUserBasicDetails().getUserFirstName())
                    + " " + defaultText(invoice.getCreatedBy().getUserBasicDetails().getUserLastName())).trim();
        }

        return "<!DOCTYPE html>"
            + "<html xmlns='http://www.w3.org/1999/xhtml'><head><meta charset='UTF-8' /><style>"
                + "body{font-family:Arial,sans-serif;color:#1e293b;font-size:12px;margin:0;padding:28px;}"
                + ".header{display:flex;justify-content:space-between;align-items:flex-start;border-bottom:2px solid #0f172a;padding-bottom:14px;margin-bottom:18px;}"
                + ".title{font-size:28px;font-weight:800;letter-spacing:0.5px;color:#0f172a;}"
                + ".seller{line-height:1.45;color:#334155;}"
                + ".meta{text-align:right;line-height:1.55;color:#334155;}"
                + ".meta .number{font-size:16px;font-weight:700;color:#0f172a;}"
                + ".section{display:flex;gap:14px;margin-bottom:14px;}"
                + ".box{flex:1;background:#f8fafc;border:1px solid #dbe4ee;border-radius:6px;padding:10px 12px;}"
                + ".box .label{text-transform:uppercase;letter-spacing:0.5px;font-size:10px;font-weight:700;color:#64748b;margin-bottom:4px;}"
                + ".box .name{font-size:13px;font-weight:700;color:#0f172a;}"
                + "table{width:100%;border-collapse:collapse;margin-top:10px;}"
                + "th{background:#0f172a;color:#ffffff;text-transform:uppercase;letter-spacing:0.4px;font-size:10px;padding:8px 7px;}"
                + "td{border-bottom:1px solid #e2e8f0;padding:8px 7px;vertical-align:top;color:#334155;}"
                + "tr:nth-child(even) td{background:#f8fafc;}"
                + ".num{text-align:right;}"
                + ".amount{font-weight:700;color:#0f172a;}"
                + ".totals{width:300px;margin-left:auto;margin-top:12px;border-top:1px solid #cbd5e1;padding-top:8px;}"
                + ".tot{display:flex;justify-content:space-between;padding:3px 0;color:#334155;}"
                + ".tot.grand{font-size:14px;font-weight:800;color:#0f172a;border-top:2px solid #0f172a;margin-top:6px;padding-top:8px;}"
                + ".footer{margin-top:20px;border-top:1px solid #e2e8f0;padding-top:10px;color:#475569;line-height:1.5;}"
                + "</style></head><body>"
                + "<div class='header'>"
                + "<div><div class='title'>INVOICE</div><div class='seller'><strong>" + escape(sellerName) + "</strong><br/>"
                + escape(invoice.getCreatedBy() != null ? defaultText(invoice.getCreatedBy().getUserEmail()) : "")
                + "</div></div>"
                + "<div class='meta'>"
                + "<div class='number'>" + escape(defaultText(invoice.getInvoiceNumber())) + "</div>"
                + "<div>Invoice Date: <strong>" + escape(invoice.getInvoiceDateFormatted()) + "</strong></div>"
                + "<div>Due Date: <strong>" + escape(invoice.getDueDateFormatted()) + "</strong></div>"
                + "<div>Payment Mode: <strong>" + escape(formatPaymentMode(invoice.getPaymentMode())) + "</strong></div>"
                + "<div>Status: <strong>" + escape(invoice.getStatus() != null ? invoice.getStatus().name() : "DRAFT") + "</strong></div>"
                + "</div></div>"
                + "<div class='section'>"
                + "<div class='box'><div class='label'>Bill To</div>"
                + "<div class='name'>" + escape(invoice.getCustomer() != null ? defaultText(invoice.getCustomer().getDisplayName()) : "") + "</div>"
                + "<div>" + escape(invoice.getCustomer() != null ? defaultText(invoice.getCustomer().getEmail()) : "") + "</div>"
                + "<div>" + escape(invoice.getCustomer() != null ? defaultText(invoice.getCustomer().getPhone()) : "") + "</div>"
                + "<div style='white-space:pre-wrap;'>" + escape(defaultText(invoice.getBillingAddress())) + "</div>"
                + "</div>"
                + "<div class='box'><div class='label'>Additional Info</div>"
                + "<div>GSTIN: " + escape(defaultText(invoice.getCustomerGstin())) + "</div>"
                + "<div>Linked Order: " + escape(invoice.getSalesOrder() != null ? defaultText(invoice.getSalesOrder().getOrderNumber()) : "-") + "</div>"
                + "<div style='white-space:pre-wrap;'>Ship To: " + escape(defaultText(invoice.getShippingAddress())) + "</div>"
                + "</div></div>"
                + "<table><thead><tr>"
                + "<th style='width:28px;'>#</th><th>Description</th><th>HSN</th><th style='width:48px;'>Qty</th>"
                + "<th style='width:88px;'>Unit Price</th><th style='width:58px;'>Disc%</th><th style='width:58px;'>Tax%</th><th style='width:100px;'>Amount</th>"
                + "</tr></thead><tbody>" + rows + "</tbody></table>"
                + "<div class='totals'>"
                + "<div class='tot'><span>Subtotal</span><span>" + formatMoney(invoice.getSubtotal()) + "</span></div>"
                + "<div class='tot'><span>Discount</span><span>-" + formatMoney(invoice.getTotalDiscount()) + "</span></div>"
                + "<div class='tot'><span>Tax (GST)</span><span>+" + formatMoney(invoice.getTotalTax()) + "</span></div>"
                + "<div class='tot grand'><span>Total</span><span>" + formatMoney(invoice.getTotalAmount()) + "</span></div>"
                + "</div>"
                + "<div class='footer'>"
                + "<div><strong>Terms:</strong> " + escape(defaultText(invoice.getTermsAndConditions())) + "</div>"
                + "<div><strong>Notes:</strong> " + escape(defaultText(invoice.getNotes())) + "</div>"
                + "</div>"
                + "</body></html>";
    }

    private String getProductName(InvoiceItem item) {
        if (item.getProduct() != null && item.getProduct().getName() != null && !item.getProduct().getName().isBlank()) {
            return item.getProduct().getName();
        }
        return defaultText(item.getDescription());
    }

    private String formatMoney(BigDecimal value) {
        BigDecimal safe = value != null ? value : BigDecimal.ZERO;
        return "INR " + safe.setScale(2, RoundingMode.HALF_UP).toPlainString();
    }

    private String formatPercent(BigDecimal value) {
        BigDecimal safe = value != null ? value : BigDecimal.ZERO;
        return safe.stripTrailingZeros().toPlainString() + "%";
    }

    private String defaultText(String value) {
        return value == null || value.isBlank() ? "-" : value;
    }

    private String formatPaymentMode(OrderPaymentMode mode) {
        if (mode == null) return "Not specified";
        String[] words = mode.name().toLowerCase().split("_");
        StringBuilder label = new StringBuilder();
        for (String word : words) {
            if (word.isEmpty()) continue;
            if (label.length() > 0) label.append(' ');
            label.append(Character.toUpperCase(word.charAt(0))).append(word.substring(1));
        }
        return label.toString();
    }

    private String escape(String text) {
        if (text == null) return "";
        return text
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
