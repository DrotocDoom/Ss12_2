CREATE TABLE products (
                          product_id SERIAL PRIMARY KEY,
                          name VARCHAR(50),
                          stock INT
);

CREATE TABLE sales (
                       sale_id SERIAL PRIMARY KEY,
                       product_id INT REFERENCES products(product_id),
                       quantity INT
);

CREATE OR REPLACE FUNCTION check_stock_before_sale()
RETURNS TRIGGER AS $$
DECLARE current_stock INT;
BEGIN
    SELECT stock INTO current_stock FROM products WHERE product_id = NEW.product_id;
    IF current_stock IS NULL THEN
        RAISE EXCEPTION 'Product with ID % does not exist.', NEW.product_id;
    ELSIF current_stock < NEW.quantity THEN
        RAISE EXCEPTION 'Not enough stock for product ID %. Available: %, Requested: %', NEW.product_id, current_stock, NEW.quantity;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_sale_insert
BEFORE INSERT ON sales
FOR EACH ROW
EXECUTE FUNCTION check_stock_before_sale();

INSERT INTO products (name, stock) VALUES ('Product A', 50);
INSERT INTO sales(product_id, quantity) VALUES (1, 20); -- This will succeed
INSERT INTO sales(product_id, quantity) VALUES (1, 90); -- This will fail

SELECT * FROM products;
SELECT * FROM sales;