-- PostgreSQL
-- Assignment 4: database schema
-- Tables and relationships only. No triggers, views, functions or test data.

create table customer (
    customer_id bigint generated always as identity primary key,
    customer_name varchar(255) not null,
    customer_address text,
    customer_phone varchar(50),
    customer_email varchar(255)
);

create table product (
    product_id bigint generated always as identity primary key,
    product_name varchar(255) not null,
    article varchar(100) not null unique
);

create table customer_order (
    customer_order_id bigint generated always as identity primary key,
    customer_id bigint not null,
    order_date date not null,
    order_status varchar(50) not null,

    constraint fk_customer_order_customer
        foreign key (customer_id)
        references customer(customer_id)
        on update cascade
        on delete restrict
);

create table material (
    material_id bigint generated always as identity primary key,
    material_name varchar(255) not null,
    unit varchar(50) not null,
    material_price numeric(12, 2) not null check (material_price >= 0)
);

create table technological_operation (
    operation_id bigint generated always as identity primary key,
    operation_name varchar(255) not null,
    operation_cost numeric(12, 2) not null check (operation_cost >= 0)
);

create table specification (
    specification_id bigint generated always as identity primary key,
    product_id bigint not null,
    specification_name varchar(255) not null,

    constraint fk_specification_product
        foreign key (product_id)
        references product(product_id)
        on update cascade
        on delete restrict,

    constraint uq_specification_product_name
        unique (product_id, specification_name)
);

create table specification_material (
    specification_id bigint not null,
    material_id bigint not null,
    material_quantity numeric(12, 3) not null check (material_quantity > 0),

    constraint pk_specification_material
        primary key (specification_id, material_id),

    constraint fk_specification_material_specification
        foreign key (specification_id)
        references specification(specification_id)
        on update cascade
        on delete cascade,

    constraint fk_specification_material_material
        foreign key (material_id)
        references material(material_id)
        on update cascade
        on delete restrict
);

create table specification_operation (
    specification_id bigint not null,
    operation_id bigint not null,
    operation_quantity numeric(12, 3) not null check (operation_quantity > 0),

    constraint pk_specification_operation
        primary key (specification_id, operation_id),

    constraint fk_specification_operation_specification
        foreign key (specification_id)
        references specification(specification_id)
        on update cascade
        on delete cascade,

    constraint fk_specification_operation_operation
        foreign key (operation_id)
        references technological_operation(operation_id)
        on update cascade
        on delete restrict
);

create table product_price (
    product_price_id bigint generated always as identity primary key,
    product_id bigint not null,
    price_value numeric(12, 2) not null check (price_value >= 0),
    valid_from date not null,

    constraint fk_product_price_product
        foreign key (product_id)
        references product(product_id)
        on update cascade
        on delete cascade,

    constraint uq_product_price_product_date
        unique (product_id, valid_from)
);



create table order_item (
    customer_order_id bigint not null,
    product_id bigint not null,
    quantity integer not null check (quantity > 0),
    item_price numeric(12, 2) not null check (item_price >= 0),

    constraint pk_order_item
        primary key (customer_order_id, product_id),

    constraint fk_order_item_customer_order
        foreign key (customer_order_id)
        references customer_order(customer_order_id)
        on update cascade
        on delete cascade,

    constraint fk_order_item_product
        foreign key (product_id)
        references product(product_id)
        on update cascade
        on delete restrict
);

create table production_order (
    production_order_id bigint generated always as identity primary key,
    product_id bigint not null,
    specification_id bigint not null,
    production_order_date date not null,
    production_quantity integer not null check (production_quantity > 0),
    production_status varchar(50) not null,

    constraint fk_production_order_product
        foreign key (product_id)
        references product(product_id)
        on update cascade
        on delete restrict,

    constraint fk_production_order_specification
        foreign key (specification_id)
        references specification(specification_id)
        on update cascade
        on delete restrict
);
