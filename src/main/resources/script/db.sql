-- =============================================================================
-- Spendilizer DB — Full Schema Creation Script
-- Database: spendilizer_db
-- Run once on a fresh MySQL instance. Tables are created in dependency order.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS spendilizer_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE spendilizer_db;

-- =============================================================================
-- 1. USERS
-- =============================================================================

CREATE TABLE IF NOT EXISTS users (
    user_id                     BIGINT          NOT NULL AUTO_INCREMENT,
    user_unique_id              VARCHAR(255)    NOT NULL,
    customer_id                 BIGINT          NOT NULL,
    user_email                  VARCHAR(255),
    user_password               VARCHAR(255),
    user_creation_date_time     DATETIME(6),
    user_modification_date_time DATETIME(6),
    user_last_login             DATETIME(6),
    user_status                 VARCHAR(20),    -- UserStatusEnum: NEW, ACTIVE, PENDING, DELETED
    user_role                   VARCHAR(20),    -- RolesEnum: USER, PREMIUM_USER
    PRIMARY KEY (user_id),
    UNIQUE KEY uq_users_unique_id   (user_unique_id),
    UNIQUE KEY uq_users_customer_id (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 2. USER_BASIC_DETAILS
-- =============================================================================

CREATE TABLE IF NOT EXISTS user_basic_details (
    user_basic_id       BIGINT          NOT NULL AUTO_INCREMENT,
    customer_id         BIGINT,
    user_first_name     VARCHAR(255),
    user_last_name      VARCHAR(255),
    user_phone_number   VARCHAR(255),
    user_gender         VARCHAR(255),
    user_dob            DATE,
    user_image          VARCHAR(255),
    pan                 VARCHAR(10),
    PRIMARY KEY (user_basic_id),
    CONSTRAINT fk_ubd_customer FOREIGN KEY (customer_id)
        REFERENCES users (customer_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 3. ROLES
-- =============================================================================

CREATE TABLE IF NOT EXISTS roles (
    role_id     INT             NOT NULL AUTO_INCREMENT,
    role_name   VARCHAR(50),
    PRIMARY KEY (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 4. USER_ROLES_MAPPING
-- =============================================================================

CREATE TABLE IF NOT EXISTS user_roles_mapping (
    user_role_id    INT     NOT NULL AUTO_INCREMENT,
    user_id         BIGINT,
    role_id         INT,
    PRIMARY KEY (user_role_id),
    CONSTRAINT fk_urm_user FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_urm_role FOREIGN KEY (role_id)
        REFERENCES roles (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 5. ENTERPRISE
-- =============================================================================

CREATE TABLE IF NOT EXISTS enterprise (
    enterprise_id   INT             NOT NULL AUTO_INCREMENT,
    enterprise_name VARCHAR(100)    NOT NULL,
    owner_user_id   BIGINT,
    approval_status VARCHAR(20)     NOT NULL DEFAULT 'PENDING',  -- ApprovalStatus
    PRIMARY KEY (enterprise_id),
    CONSTRAINT fk_enterprise_owner FOREIGN KEY (owner_user_id)
        REFERENCES users (user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 6. HSN_MASTER
-- =============================================================================

CREATE TABLE IF NOT EXISTS hsn_master (
    id          BIGINT          NOT NULL AUTO_INCREMENT,
    hsn_code    VARCHAR(255),
    description VARCHAR(255),
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 7. CATEGORY
-- =============================================================================

CREATE TABLE IF NOT EXISTS category (
    id          BIGINT          NOT NULL AUTO_INCREMENT,
    name        VARCHAR(255)    NOT NULL,
    description VARCHAR(255),
    row_status  VARCHAR(20)     NOT NULL DEFAULT 'ACTIVE',
    created_by  BIGINT,
    created_at  DATETIME(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_category_user FOREIGN KEY (created_by)
        REFERENCES users (user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 8. SUPPLIER
-- =============================================================================

CREATE TABLE IF NOT EXISTS supplier (
    id          BIGINT          NOT NULL AUTO_INCREMENT,
    name        VARCHAR(255)    NOT NULL,
    email       VARCHAR(255),
    phone       VARCHAR(255),
    address     VARCHAR(255),
    row_status  VARCHAR(20)     NOT NULL DEFAULT 'ACTIVE',
    created_by  BIGINT,
    created_at  DATETIME(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_supplier_user FOREIGN KEY (created_by)
        REFERENCES users (user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 9. PRODUCT
-- =============================================================================

CREATE TABLE IF NOT EXISTS product (
    id          BIGINT              NOT NULL AUTO_INCREMENT,
    name        VARCHAR(255)        NOT NULL,
    sku         VARCHAR(255)        NOT NULL,
    cost_price  DECIMAL(10,2)       NOT NULL DEFAULT 0.00,
    selling_price DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
    mrp         DECIMAL(10,2)       NOT NULL DEFAULT 0.00,
    description TEXT,
    category_id BIGINT              NOT NULL,
    supplier_id BIGINT              NOT NULL,
    row_status  VARCHAR(20)         NOT NULL DEFAULT 'ACTIVE',
    created_at  DATETIME(6),
    hsn_id      BIGINT              NOT NULL,
    created_by  BIGINT,
    PRIMARY KEY (id),
    UNIQUE KEY uq_product_sku (sku),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id)
        REFERENCES category (id),
    CONSTRAINT fk_product_supplier FOREIGN KEY (supplier_id)
        REFERENCES supplier (id),
    CONSTRAINT fk_product_hsn FOREIGN KEY (hsn_id)
        REFERENCES hsn_master (id),
    CONSTRAINT fk_product_user FOREIGN KEY (created_by)
        REFERENCES users (user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 10. STOCK
-- =============================================================================

CREATE TABLE IF NOT EXISTS stock (
    id              BIGINT  NOT NULL AUTO_INCREMENT,
    product_id      BIGINT  NOT NULL,
    quantity        INT     NOT NULL DEFAULT 0,
    min_threshold   INT     NOT NULL DEFAULT 10,
    row_status      VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    updated_at      DATETIME(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_stock_product (product_id),
    CONSTRAINT fk_stock_product FOREIGN KEY (product_id)
        REFERENCES product (id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 11. STOCK_MOVEMENT
-- =============================================================================

CREATE TABLE IF NOT EXISTS stock_movement (
    id          BIGINT          NOT NULL AUTO_INCREMENT,
    product_id  BIGINT          NOT NULL,
    type        VARCHAR(20)     NOT NULL,   -- StockMovementType: IN, OUT
    quantity    INT             NOT NULL,
    note        VARCHAR(255),
    row_status  VARCHAR(20)     NOT NULL DEFAULT 'ACTIVE',
    moved_at    DATETIME(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_sm_product FOREIGN KEY (product_id)
        REFERENCES product (id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 12. MASTER_PRODUCT
-- =============================================================================

CREATE TABLE IF NOT EXISTS master_product (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    name            VARCHAR(255)    NOT NULL,
    sku             VARCHAR(255)    NOT NULL,
    category_name   VARCHAR(255)    NOT NULL,
    supplier_name   VARCHAR(255)    NOT NULL,
    hsn_code        VARCHAR(255)    NOT NULL,
    description     TEXT,
    row_status      VARCHAR(20)     NOT NULL DEFAULT 'ACTIVE',
    created_at      DATETIME(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_mp_sku (sku)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 13. MASTER_PRODUCT_REQUEST
-- =============================================================================

CREATE TABLE IF NOT EXISTS master_product_request (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    requested_by    BIGINT          NOT NULL,
    name            VARCHAR(255)    NOT NULL,
    sku             VARCHAR(255)    NOT NULL,
    category_name   VARCHAR(255)    NOT NULL,
    supplier_name   VARCHAR(255)    NOT NULL,
    hsn_code        VARCHAR(255)    NOT NULL,
    description     TEXT,
    request_status  VARCHAR(20)     NOT NULL DEFAULT 'PENDING',
    requested_at    DATETIME(6),
    review_note     TEXT,
    reviewed_at     DATETIME(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_mpr_sku (sku),
    CONSTRAINT fk_mpr_user FOREIGN KEY (requested_by)
        REFERENCES users (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 14. CUSTOMER
-- =============================================================================

CREATE TABLE IF NOT EXISTS customer (
    id                  BIGINT          NOT NULL AUTO_INCREMENT,
    first_name          VARCHAR(255)    NOT NULL,
    last_name           VARCHAR(255),
    company_name        VARCHAR(255),
    email               VARCHAR(255)    NOT NULL,
    phone               VARCHAR(255),
    billing_address     TEXT,
    shipping_address    TEXT,
    gstin               VARCHAR(15),
    pan                 VARCHAR(10),
    notes               TEXT,
    row_status          VARCHAR(20)     NOT NULL DEFAULT 'ACTIVE',
    created_by          BIGINT,
    created_at          DATETIME(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_customer_user FOREIGN KEY (created_by)
        REFERENCES users (user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 15. SALES_ORDER
-- =============================================================================

CREATE TABLE IF NOT EXISTS sales_order (
    id                      BIGINT          NOT NULL AUTO_INCREMENT,
    order_number            VARCHAR(255)    NOT NULL,
    customer_id             BIGINT          NOT NULL,
    order_date              DATE            NOT NULL,
    expected_delivery_date  DATE,
    payment_mode            VARCHAR(20)     NOT NULL DEFAULT 'CASH',
    status                  VARCHAR(20)     NOT NULL DEFAULT 'DRAFT',
    billing_address         TEXT,
    shipping_address        TEXT,
    notes                   TEXT,
    subtotal                DECIMAL(15,2)   DEFAULT 0.00,
    total_discount          DECIMAL(15,2)   DEFAULT 0.00,
    total_tax               DECIMAL(15,2)   DEFAULT 0.00,
    total_amount            DECIMAL(15,2)   DEFAULT 0.00,
    created_by              BIGINT,
    created_at              DATETIME(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_so_order_number (order_number),
    CONSTRAINT fk_so_customer FOREIGN KEY (customer_id)
        REFERENCES customer (id),
    CONSTRAINT fk_so_user FOREIGN KEY (created_by)
        REFERENCES users (user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 16. ORDER_ITEM
-- =============================================================================

CREATE TABLE IF NOT EXISTS order_item (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    sales_order_id  BIGINT          NOT NULL,
    product_id      BIGINT,
    description     TEXT,
    quantity        INT             NOT NULL DEFAULT 1,
    unit_price      DECIMAL(15,2)   NOT NULL DEFAULT 0.00,
    discount_percent DECIMAL(5,2)   DEFAULT 0.00,
    tax_percent     DECIMAL(5,2)    DEFAULT 18.00,
    amount          DECIMAL(15,2)   DEFAULT 0.00,
    PRIMARY KEY (id),
    CONSTRAINT fk_oi_order FOREIGN KEY (sales_order_id)
        REFERENCES sales_order (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_oi_product FOREIGN KEY (product_id)
        REFERENCES product (id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 17. INVOICE
-- =============================================================================

CREATE TABLE IF NOT EXISTS invoice (
    id                  BIGINT          NOT NULL AUTO_INCREMENT,
    invoice_number      VARCHAR(255)    NOT NULL,
    sales_order_id      BIGINT,
    customer_id         BIGINT          NOT NULL,
    invoice_date        DATE            NOT NULL,
    due_date            DATE,
    status              VARCHAR(20)     NOT NULL DEFAULT 'DRAFT',
    payment_mode        VARCHAR(20)     NOT NULL DEFAULT 'CASH',
    billing_address     TEXT,
    shipping_address    TEXT,
    customer_gstin      VARCHAR(15),
    notes               TEXT,
    terms_and_conditions TEXT,
    subtotal            DECIMAL(15,2)   DEFAULT 0.00,
    total_discount      DECIMAL(15,2)   DEFAULT 0.00,
    total_tax           DECIMAL(15,2)   DEFAULT 0.00,
    total_amount        DECIMAL(15,2)   DEFAULT 0.00,
    created_by          BIGINT,
    created_at          DATETIME(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_invoice_number (invoice_number),
    CONSTRAINT fk_inv_order FOREIGN KEY (sales_order_id)
        REFERENCES sales_order (id)
        ON DELETE SET NULL,
    CONSTRAINT fk_inv_customer FOREIGN KEY (customer_id)
        REFERENCES customer (id),
    CONSTRAINT fk_inv_user FOREIGN KEY (created_by)
        REFERENCES users (user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 18. INVOICE_ITEM
-- =============================================================================

CREATE TABLE IF NOT EXISTS invoice_item (
    id               BIGINT          NOT NULL AUTO_INCREMENT,
    invoice_id       BIGINT          NOT NULL,
    product_id       BIGINT,
    description      TEXT            NOT NULL,
    hsn_code         VARCHAR(20),
    quantity         INT             NOT NULL DEFAULT 1,
    unit_price       DECIMAL(15,2)   NOT NULL DEFAULT 0.00,
    discount_percent DECIMAL(5,2)    DEFAULT 0.00,
    tax_percent      DECIMAL(5,2)    DEFAULT 18.00,
    amount           DECIMAL(15,2)   DEFAULT 0.00,
    PRIMARY KEY (id),
    CONSTRAINT fk_ii_invoice FOREIGN KEY (invoice_id)
        REFERENCES invoice (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ii_product FOREIGN KEY (product_id)
        REFERENCES product (id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 19. SPLIT_GROUP
-- =============================================================================

CREATE TABLE IF NOT EXISTS split_group (
    id          BIGINT          NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100)    NOT NULL,
    description TEXT,
    event_date  DATE,
    status      VARCHAR(10)     NOT NULL DEFAULT 'ACTIVE',
    created_by  BIGINT          NOT NULL,
    created_at  DATETIME(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_sg_user FOREIGN KEY (created_by)
        REFERENCES users (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 20. GROUP_MEMBER
-- =============================================================================

CREATE TABLE IF NOT EXISTS group_member (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    split_group_id  BIGINT          NOT NULL,
    name            VARCHAR(80)     NOT NULL,
    email           VARCHAR(100),
    linked_user_id  BIGINT,
    PRIMARY KEY (id),
    CONSTRAINT fk_gm_group FOREIGN KEY (split_group_id)
        REFERENCES split_group (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_gm_user FOREIGN KEY (linked_user_id)
        REFERENCES users (user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 21. GROUP_EXPENSE
-- =============================================================================

CREATE TABLE IF NOT EXISTS group_expense (
    id                  BIGINT          NOT NULL AUTO_INCREMENT,
    split_group_id      BIGINT          NOT NULL,
    description         VARCHAR(200)    NOT NULL,
    amount              DECIMAL(15,2)   NOT NULL,
    paid_by_member_id   BIGINT          NOT NULL,
    split_type          VARCHAR(20)     NOT NULL DEFAULT 'EQUAL',
    expense_date        DATE            NOT NULL,
    created_at          DATETIME(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_ge_group FOREIGN KEY (split_group_id)
        REFERENCES split_group (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ge_member FOREIGN KEY (paid_by_member_id)
        REFERENCES group_member (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 22. EXPENSE_SPLIT
-- =============================================================================

CREATE TABLE IF NOT EXISTS expense_split (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    expense_id      BIGINT          NOT NULL,
    member_id       BIGINT          NOT NULL,
    share_amount    DECIMAL(15,2)   NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_es_expense FOREIGN KEY (expense_id)
        REFERENCES group_expense (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_es_member FOREIGN KEY (member_id)
        REFERENCES group_member (id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 23. SUBSCRIPTION
-- =============================================================================

CREATE TABLE IF NOT EXISTS subscription (
    id                  BIGINT          NOT NULL AUTO_INCREMENT,
    name                VARCHAR(100)    NOT NULL,
    provider            VARCHAR(100),
    amount              DECIMAL(12,2)   NOT NULL,
    billing_cycle       VARCHAR(20)     NOT NULL DEFAULT 'MONTHLY',
    start_date          DATE            NOT NULL,
    next_billing_date   DATE            NOT NULL,
    category            VARCHAR(30)     NOT NULL DEFAULT 'OTHER',
    status              VARCHAR(20)     NOT NULL DEFAULT 'ACTIVE',
    notes               TEXT,
    created_by          BIGINT          NOT NULL,
    created_at          DATETIME(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_sub_user FOREIGN KEY (created_by)
        REFERENCES users (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- 24. SUBSCRIPTION_NOTIFICATION
-- =============================================================================

CREATE TABLE IF NOT EXISTS subscription_notification (
    id                  BIGINT      NOT NULL AUTO_INCREMENT,
    user_id             BIGINT      NOT NULL,
    subscription_id     BIGINT      NOT NULL,
    days_until_due      INT         NOT NULL,
    notified_date       DATE        NOT NULL,
    state               VARCHAR(10) NOT NULL DEFAULT 'NEW',
    PRIMARY KEY (id),
    UNIQUE KEY uq_sn_sub_date (subscription_id, notified_date),
    CONSTRAINT fk_sn_user FOREIGN KEY (user_id)
        REFERENCES users (user_id),
    CONSTRAINT fk_sn_sub FOREIGN KEY (subscription_id)
        REFERENCES subscription (id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
