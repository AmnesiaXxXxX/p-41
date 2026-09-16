CREATE TABLE customer (
    customer_id bigint generated always as identity primary key,
    customer_first_name VARCHAR(50) NOT NULL,
    customer_second_name VARCHAR(50) NOT NULL,
    customer_surname VARCHAR(50) NOT NULL,
    customer_email VARCHAR(50),
    customer_phone VARCHAR(50),
    customer_address VARCHAR(50)
);

CREATE TABLE product (
    product_id bigint generated always as identity primary key,
    product_name varchar(255) not null,
    article VARCHAR(10) CHECK (length(article) = 10) NOT NULL UNIQUE
);

CREATE TABLE customer_order (
    customer_order_id bigint generated always as identity primary key,
    customer_id bigint not null,
    order_status VARCHAR(50) not null,
    order_date TIMESTAMP not null,

    CONSTRAINT fk_custom_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE material (
    material_id bigint generated always as identity primary key,
    material_name VARCHAR(255) not null,
    unit VARCHAR(50) NOT NULL,
    material_price NUMERIC(12, 2) not null check (material_price >= 0)
);

CREATE TABLE technological_operation (
    operation_id bigint generated always as identity primary key,
    operation_name VARCHAR(255) not null,
    operation_cost NUMERIC(12, 2) not null check (operation_cost >= 0)
);

CREATE TABLE specification (
    specification_id bigint generated always as identity primary key,
    product_id BIGINT NOT NULL,
    specification_name VARCHAR(255) NOT NULL,

    CONSTRAINT fk_specification_product
        FOREIGN KEY (product_id)
        REFERENCES product(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_specification_product_name
        UNIQUE (product_id, specification_name)
);
-- Простыми словами: она хранит, какие технологические операции нужны для конкретной спецификации и в каком количестве.
CREATE TABLE specification_operation (
    specification_id BIGINT NOT NULL,
    operation_id BIGINT NOT NULL,
    operation_quantity  NUMERIC(12, 2) NOT NULL CHECK (operation_quantity >= 0),

    CONSTRAINT pk_specification_operation
        PRIMARY KEY (specification_id, operation_id),
    
    CONSTRAINT fk_specification_operation_specification
        FOREIGN KEY (specification_id)
        REFERENCES specification(specification_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_specification_operation_operation
        Foreign Key (operation_id)
        REFERENCES technological_operation(operation_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE product_price (
    product_price_id bigint generated always as identity primary key,
    product_id BIGINT NOT NULL,
    price_value numeric(12, 2) not null check (price_value >= 0),
    valid_from DATE NOT NULL,

    CONSTRAINT fk_product_price_product
        Foreign Key (product_id)
        REFERENCES product(product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT uq_product_price_product_date
        UNIQUE (product_id, valid_from)
);

CREATE TABLE order_item (
    customer_order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    item_price NUMERIC(12,2) NOT NULL CHECK (item_price >= 0),

    CONSTRAINT pk_order_item
        PRIMARY KEY (customer_order_id, product_id),
    
    CONSTRAINT fk_order_item_customer_order
        Foreign Key (customer_order_id)
        REFERENCES customer_order(customer_order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_order_item_product
        Foreign Key (product_id)
        REFERENCES product(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE production_order (
    production_order_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id BIGINT NOT NULL,
    specification_id BIGINT NOT NULL,
    production_order_date DATE NOT NULL,
    production_quantity INTEGER NOT NULL check (production_quantity > 0),
    production_status VARCHAR(50) NOT NULL,

    CONSTRAINT fk_production_order_product
        foreign key (product_id)
        references product(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_production_order_specification
        FOREIGN KEY (specification_id)
        REFERENCES specification(specification_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
