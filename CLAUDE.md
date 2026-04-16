# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
# Build (skip tests)
mvn clean package -DskipTests

# Run (embedded Tomcat, context path /spendilizer)
mvn spring-boot:run

# Compile only
mvn clean compile
```

The app is served at `http://localhost:8080/spendilizer`. MySQL must be running on `localhost:3306` with database `spendilizer_db`.

Set credentials through environment variables (not hard-coded in files):

```bash
export SPENDILIZER_DB_USERNAME=<your-db-user>
export SPENDILIZER_DB_PASSWORD=<your-db-password>
```

There are no meaningful tests — `SpendilizerApplicationTests` is a placeholder context-load test only.

## Architecture

**Stack:** Spring Boot 3.2.5 · Java 21 · Spring Security · Spring Data JPA · MySQL · JSP (JSTL) · Bootstrap 5.3

**Packaging:** WAR with embedded Tomcat. The context path `/spendilizer` is set by the WAR `finalName` in `pom.xml`, not in `application.properties`.

### Request flow

```
Browser → SecurityFilterChain → @Controller → @Service → JpaRepository → MySQL
                                     ↓
                              JSP view (WEB-INF/views/)
```

All controllers return view names resolved to `WEB-INF/views/<name>.jsp`. Static assets (CSS/JS) live under `src/main/webapp/` and are served at `/spendilizer/css/`, etc.

### Security (`config/`)

- `SecurityConfig` — defines public URLs, role-based route guards, form-login config (processes at `/perform-login`), and registers `BCryptPasswordEncoder`.
- `CustomUserDetailsService` — loads `User` by email, maps `user_roles_mapping` rows to `GrantedAuthority` with the prefix `ROLE_`.
- `CustomUserDetails` — wraps `User`; the `user` field is accessible throughout the session.
- `CustomAuthenticationSuccessHandler` — redirects all successful logins to `/spendilizer/dashboard`.
- `CustomAuthenticationFailureHandler` — redirects to `/login?error` on failed login.
- `CustomLogoutSuccessHandler` — redirects to `/login?logout` after logout.
- `AuditAccessDeniedHandler` — logs access-denied events and redirects to an error page.
- `GlobalModelAttribute` (`@ControllerAdvice`) — injects `user` (current `User` entity), `currentUri`, and `roles` into every model automatically.

### Data model

| Entity | Table | Key relationships |
|---|---|---|
| `User` | `user` | has many `UserRolesMapping`; belongs to `Enterprise` (nullable) |
| `Enterprise` | `enterprise` | owned by one `User` (owner); members are `User` rows with `enterprise_id` FK |
| `Roles` / `UserRolesMapping` | `roles` / `user_roles_mapping` | many-to-many bridge |
| `Product` | `product` | belongs to `Category`, `Supplier`, `Hsn`; has one `Stock`; has many `StockMovement` |
| `Stock` | `stock` | one-to-one with `Product`; tracks `quantity` and `minThreshold` |
| `StockMovement` | `stock_movement` | belongs to `Product`; type is `StockMovementType` enum (IN/OUT) |
| `Customer` | `customer` | scoped by `created_by`; has `displayName()` helper (company name or "First Last") |
| `SalesOrder` | `sales_order` | belongs to `Customer`; has many `OrderItem`; status: `DRAFT→CONFIRMED→SHIPPED→DELIVERED` (or `CANCELLED`) |
| `OrderItem` | `order_item` | belongs to `SalesOrder`; references `Product`; stores pre-computed `amount` |
| `Invoice` | `invoice` | optionally linked to `SalesOrder`; belongs to `Customer`; has many `InvoiceItem`; status: `DRAFT→SENT→PAID` (or `OVERDUE`/`CANCELLED`) |
| `InvoiceItem` | `invoice_item` | belongs to `Invoice`; references `Product`; stores `hsnCode`, pre-computed `amount` |

`Status` enum (`ACTIVE`/`INACTIVE`/`DELETED`) is used as a soft-delete flag on most entities (`rowStatus` column). Services use `softDelete*` methods that set `rowStatus = DELETED`; list views query only `ACTIVE`.

### Data isolation

All inventory and sales data is scoped via a `created_by` FK column. HSN is a global reference table.

**Scope rules** (implemented in `UserService.getScopeUsers(User)`):
- `INDIVIDUAL` → sees only their own data
- `ENTERPRISE_OWNER` / `ENTERPRISE_MEMBER` → sees all data created by anyone in the same enterprise

Every service read method accepts `User user` and calls `userService.getScopeUsers(user)` to get a `List<User>`, then queries with `...In(List<User>)` repository methods. Controllers resolve the current user with a private `resolveUser(CustomUserDetails)` helper that calls `userService.getUserByEmail(principal.getUsername())`.

> **DB note:** The old `UNIQUE` constraint on `category.name` must be dropped manually since `ddl-auto=update` can't remove constraints:
> ```sql
> ALTER TABLE category DROP INDEX name;
> ```

### Account types

Users have an `accountType` string field:
- `INDIVIDUAL` → role `USER`
- `ENTERPRISE_OWNER` → role `ENTERPRISE_OWNER`; `/enterprise/**` routes require this role
- `ENTERPRISE_MEMBER` → role `ENTERPRISE_MEMBER`; linked to the same `Enterprise` as their owner

`SecurityConfig` also has unused guards for `STUDENT` and `ADMIN` roles — no controllers map those routes yet.

### Order → Invoice lifecycle

Confirming a `SalesOrder` (`POST /order/{id}/confirm`) deducts stock (creates `StockMovement OUT` records) and auto-creates a `DRAFT` invoice via `InvoiceService.autoCreateFromOrder`. Cancelling a confirmed/shipped order restores stock with `StockMovement IN` reversals. Invoices are independent objects — cancelling an order does **not** auto-cancel its linked invoice.

### Stock auto-creation

`StockMovementController` creates a `Stock` record automatically on first movement if none exists (`createStockBeforeMovement`), with `minThreshold = 10`. Subsequent movements call `adjustQuantity` which throws `RuntimeException` if quantity goes negative.

### Global search

`GET /api/search?q=` (`SearchController`, `@RestController`) — navbar typeahead; returns JSON list of `{type, label, sub, url}`. Searches products, suppliers, customers, orders, invoices scoped to the current user. Requires `q` ≥ 2 chars. Note: `SecurityConfig` marks `/api/**` as `permitAll()`, but the endpoint calls `@AuthenticationPrincipal` so it effectively requires a valid session.

### Profile

`ProfileController` at `/profile` — `GET/POST /profile/edit` (name, PAN) and `GET/POST /profile/reset-password` (current + new password, min 8 chars). Uses `UserService.updateProfile` and `UserService.changePassword`.

### Document number formats

- Orders: `ORD-YYYY-NNNN` — 4-digit zero-padded sequence, year-scoped, enterprise-scoped.
- Invoices: `INV-YYYY-NNNN` — same scheme.

Both sequences are computed at save time by querying existing numbers with a `LIKE` prefix; no DB sequence is used.

### Order total computation

`SalesOrderService.recalculateTotals`:
- `subtotal` = Σ (qty × unitPrice)
- `totalDiscount` = Σ (gross × discountPct / 100)
- `totalTax` = Σ ((gross − discountAmt) × taxPct / 100)
- `totalAmount` = subtotal − totalDiscount + totalTax

### SKU generation

`GET /product/generate-sku?categoryName=&productName=` is an AJAX endpoint (`@ResponseBody`) used by `product/form.jsp` to suggest SKUs. Format: `CAT-PRD-001` (3-char prefix from each name, zero-padded sequence scoped to the user's enterprise).

### Frontend conventions

- **`ims-login.css`** — used only by `login.jsp` and `signup.jsp` (standalone pages, no sidebar).
- **`ims-shared.css`** — used by all authenticated pages. Defines CSS variables, layout, all component styles (tables, cards, forms, badges, stat cards, buttons).
- Every authenticated view includes `navbar.jsp` (via `<%@ include %>`) and `sidebar.jsp` (via `<jsp:include>`).
- The sidebar has a toggle button (hamburger in topbar) that collapses/expands via `body.sidebar-collapsed` class with `localStorage` persistence.
- `ddl-auto=update` — Hibernate auto-migrates the schema on startup.

### CSS layout conventions

- `.main-content` has asymmetric padding (`56px left / 48px right`). Section-level elements inside it carry their own `margin-left` (40px for most, 20px for `.table-card` and `.search-bar`).
- When adding new page sections, follow the existing pattern: `page-header` → optional `flash-success`/`flash-error` → content cards, each with the standard `margin-left`.
- Sidebar toggle uses `body.sidebar-collapsed` class with 0.25s ease transitions (toggled by the hamburger button in the topbar, persisted in `localStorage`).
