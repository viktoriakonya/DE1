
-- Drop schema if exists
DROP SCHEMA IF EXISTS e_commerce;

-- Create schema
CREATE SCHEMA e_commerce;

-- Switch to schema
USE e_commerce;

-- Enable local infile
-- SET GLOBAL local_infile = true;
-- SHOW GLOBAL VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE "secure_file_priv";

-- Change default timeout
SHOW SESSION VARIABLES LIKE '%wait_timeout%'; 
SET @@GLOBAL.wait_timeout=300;


-- Table creation 

-- 1. Create placeholder for customers dataset

DROP TABLE IF EXISTS olist_customers_dataset;
CREATE TABLE olist_customers_dataset 
(	customer_id	VARCHAR(32) NOT NULL,
	customer_unique_id VARCHAR(32) NOT NULL,
	customer_zip_code_prefix INTEGER,	
	customer_city VARCHAR(50),
	customer_state VARCHAR(2),
    PRIMARY KEY(customer_id));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv'
INTO TABLE olist_customers_dataset
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(	customer_id, 
	customer_unique_id, 
	@customer_zip_code_prefix, 
	@customer_city, 
	@customer_state)
SET 
	customer_zip_code_prefix = nullif(@customer_zip_code_prefix, ''),
	customer_city = nullif(@customer_city, ''),
	customer_state = nullif(@customer_state, '');
    
    
-- 2. Create placeholder for geolocation dataset (no key)

DROP TABLE IF EXISTS olist_geolocation_dataset;
    CREATE TABLE olist_geolocation_dataset 
(	geolocation_zip_code_prefix	NUMERIC,
	geolocation_lat	DECIMAL(20,14),
	geolocation_lng	DECIMAL(20,14),
    geolocation_city VARCHAR(50),	
    geolocation_state VARCHAR(2));


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_geolocation_dataset.csv'
INTO TABLE olist_geolocation_dataset
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(	@geolocation_zip_code_prefix, 
	@geolocation_lat, 
    @geolocation_lng,
	@geolocation_city, 
	@geolocation_state)
SET 
	geolocation_zip_code_prefix = nullif(@geolocation_zip_code_prefix, ''),
	geolocation_lat = nullif(@geolocation_lat, ''),
	geolocation_lng = nullif(@geolocation_lng, ''),
	geolocation_city = nullif(@geolocation_city, ''),
	geolocation_state = nullif(@geolocation_state, '');


-- 3. Create placeholder for order items dataset

DROP TABLE IF EXISTS olist_order_items_dataset;
    CREATE TABLE olist_order_items_dataset 
(	order_id  VARCHAR(32),	
	order_item_id INTEGER,	
	product_id	VARCHAR(32),
	seller_id   VARCHAR(32),
	shipping_limit_date	DATETIME,
	price DECIMAL(9, 2),
	freight_value DECIMAL(9, 2),
    PRIMARY KEY (order_id, order_item_id, product_id, seller_id));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
INTO TABLE olist_order_items_dataset
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(	order_id,
	order_item_id,	
	product_id,
	seller_id,
	@shipping_limit_date,
	@price,
	@freight_value
    )
SET 
	shipping_limit_date = nullif(@shipping_limit_date, ''),
	price = nullif(@price, ''),
	freight_value = nullif(@freight_value, '');


-- 4. Create placeholder for order payments dataset

DROP TABLE IF EXISTS olist_order_payments_dataset;
    CREATE TABLE olist_order_payments_dataset 
(	order_id  VARCHAR(32),	
	payment_sequential INTEGER,	
	payment_type VARCHAR(20),
	payment_installments  INTEGER,
	payment_value DECIMAL(9, 2)
    -- PRIMARY KEY (order_id)
    );

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv'
INTO TABLE olist_order_payments_dataset
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(	order_id,	
	@payment_sequential,	
	@payment_type,
	@payment_installments,
	@payment_value
    )
SET 
	payment_sequential = nullif(@payment_sequential, ''),
	payment_type = nullif(@payment_type, ''),
	payment_installments = nullif(@payment_installments, ''),
  	payment_value = nullif(@payment_value, '');

-- 5. Create placeholder for order reviews dataset (/"-t át kellett írni)

DROP TABLE IF EXISTS olist_order_reviews_dataset;
    CREATE TABLE olist_order_reviews_dataset 
(	review_id VARCHAR(32),
	order_id VARCHAR(32),
	review_score INTEGER,
	review_comment_title TEXT,	
	review_comment_message	TEXT,
	review_creation_date DATETIME,	
	review_answer_timestamp DATETIME,
    PRIMARY KEY (review_id, order_id)
    );

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(	review_id,
	order_id,
	review_score,
	review_comment_title,	
	review_comment_message,
	review_creation_date,	
	review_answer_timestamp
    )
SET 
	review_score = nullif(@review_score, ''),
	review_comment_title = nullif(@review_comment_title, ''),
	review_comment_message = nullif(@review_comment_message, ''),
  	review_creation_date = nullif(@review_creation_date, ''),
   	review_answer_timestamp = nullif(@review_answer_timestamp, '')
    ;

-- 6. Create placeholder for orders dataset
SHOW SESSION VARIABLES LIKE '%wait_timeout%'; 
SET @@GLOBAL.wait_timeout=300;

DROP TABLE IF EXISTS olist_orders_dataset;
    CREATE TABLE olist_orders_dataset 
(	order_id VARCHAR(32),
    customer_id	 VARCHAR(32),
    order_status  VARCHAR(15),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    PRIMARY KEY (order_id, customer_id)
    );
    
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv'
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(	order_id,
    customer_id,
    @order_status,
    @order_purchase_timestamp,
    @order_approved_at,
    @order_delivered_carrier_date,
    @order_delivered_customer_date,
    @order_estimated_delivery_date
    )
SET 
	order_status = nullif(@order_status, ''),
	order_purchase_timestamp = nullif(@order_purchase_timestamp, ''),
	order_approved_at = nullif(@order_approved_at, ''),
  	order_delivered_carrier_date = nullif(@order_delivered_carrier_date, ''),
   	order_delivered_customer_date = nullif(@order_delivered_customer_date, ''),
	order_estimated_delivery_date = nullif(@order_estimated_delivery_date, '')
    ;
    
    
-- 7. Create placeholder for products dataset

DROP TABLE IF EXISTS olist_products_dataset;
    CREATE TABLE olist_products_dataset 
(	product_id VARCHAR(32),
    product_category_name VARCHAR(50),
    product_name_lenght  INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER,
    PRIMARY KEY (product_id)
    );
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv'
INTO TABLE olist_products_dataset
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(	product_id,
    @product_category_name,
    @product_name_lenght,
    @product_description_lenght,
    @product_photos_qty,
    @product_weight_g,
    @product_length_cm,
    @product_height_cm,
    @product_width_cm
    )
SET 
	product_category_name = nullif(@product_category_name, ''),
	product_name_lenght = nullif(@product_name_lenght, ''),
	product_description_lenght = nullif(@product_description_lenght, ''),
  	product_photos_qty = nullif(@product_photos_qty, ''),
   	product_weight_g = nullif(@product_weight_g, ''),
	product_length_cm = nullif(@product_length_cm, ''),
	product_height_cm = nullif(@product_height_cm, ''),
	product_width_cm = nullif(@product_width_cm, '')
    ;

  -- 8. Create placeholder for sellers dataset

DROP TABLE IF EXISTS olist_sellers_dataset;
    CREATE TABLE olist_sellers_dataset 
(	seller_id VARCHAR(32),
    seller_zip_code_prefix INTEGER,
    seller_city  VARCHAR(50),
    seller_state VARCHAR(2),
    PRIMARY KEY (seller_id)
    );

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv'
INTO TABLE olist_sellers_dataset
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(	seller_id,
    @seller_zip_code_prefix,
    @seller_city,
    @seller_state
    )
SET 
	seller_zip_code_prefix = nullif(@seller_zip_code_prefix, ''),
	seller_city = nullif(@seller_city, ''),
	seller_state = nullif(@seller_state, '')
    ;

 -- 9. Create placeholder for product category translation dataset

DROP TABLE IF EXISTS product_category_name_translation;
    CREATE TABLE product_category_name_translation 
(	product_category_name VARCHAR(50),
    product_category_name_english VARCHAR(50)
    );

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(	@product_category_name,
    @product_category_name_english
    )
SET 
	product_category_name = nullif(@product_category_name, ''),
	product_category_name_english = nullif(@product_category_name_english, '')
    ;






