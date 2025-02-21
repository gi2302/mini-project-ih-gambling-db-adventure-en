-- Sets the current database to 'ironhack_gambling' to ensure all subsequent queries are executed within this database.
USE ironhack_gambling;

-- Question 01: Using the customer table or tab, 
-- write an SQL query that shows Title, First Name, Last Name, and Date of Birth for each customer.

SELECT 
    Title,                                     -- Retrieves the title of the customer (e.g., Mr., Ms.)
    FirstName,                                 -- Retrieves the first name of the customer
    LastName,                                  -- Retrieves the last name of the customer
    DATE(DateOfBirth) AS DateOfBirth           -- Retrieves only the date from the DateOfBirth column of the customer
FROM 
    ironhack_gambling.customer;  -- Specifies the 'customer' table from the 'ironhack_gambling' database


-- Question 02: Using the customer table or tab, 
-- write an SQL query that shows the number of customers in each customer group (Bronze, Silver & Gold).

SELECT 
    CustomerGroup AS "Customer Group",   -- Retrieves the customer group (e.g., Bronze, Silver, Gold) and renames it for clarity
    COUNT(*) AS "Number of Customers"   -- Counts the number of customers in each group and renames the output column for readability
FROM 
    ironhack_gambling.customer          -- Specifies the 'customer' table from the 'ironhack_gambling' database
GROUP BY 
    CustomerGroup;                      -- Groups the results by each unique customer group


-- Question 03: Using the customer table, write an SQL query that shows all data for customers
-- but adds the CurrencyCode of each player by joining with the account table.

SELECT 
    c.*,                  -- Selects all columns from the customer table
    a.CurrencyCode        -- Adds the CurrencyCode column from the account table
FROM 
    ironhack_gambling.customer c  -- The customer table is aliased as 'c'
JOIN 
    ironhack_gambling.account a   -- The account table is aliased as 'a'
ON 
    c.CustID = a.CustId;          -- Matches the CustID column in customer with CustId in account to join the tables


-- Question 4: Summary report showing total bet amount by product and by day, with formatted date
SELECT 
    DATE_FORMAT(b.BetDate, '%Y-%m-%d') AS Date,  -- Formats the bet date to YYYY-MM-DD
    p.Product AS Product,                        -- Extracting the product name
    SUM(b.Bet_Amt) AS TotalBetAmount             -- Calculating the total bet amount for the product on a given day
FROM 
    ironhack_gambling.betting b                  -- Betting table alias 'b'
JOIN 
    ironhack_gambling.product p                  -- Product table alias 'p'
ON 
    b.ClassId = p.CLASSID                        -- Matching the ClassId in betting with CLASSID in product
GROUP BY 
    DATE_FORMAT(b.BetDate, '%Y-%m-%d'),          -- Grouping by formatted date
    p.Product                                    -- Grouping by product name
ORDER BY 
    Date,                                        -- Sorting by date
    Product;                                     -- Sorting by product within each date


-- Question 5: Sportsbook transactions on or after 1st November, with formatted date
SELECT 
    DATE_FORMAT(b.BetDate, '%Y-%m-%d') AS Date,  -- Formats the bet date to YYYY-MM-DD
    'Sportsbook' AS Product,                     -- Labeling the product explicitly as 'Sportsbook'
    SUM(b.Bet_Amt) AS TotalBetAmount             -- Calculating total bet amount for Sportsbook transactions
FROM 
    ironhack_gambling.betting b
WHERE 
    b.ClassId IN (                               -- Filters only for Sportsbook-related ClassIds
        '1', '10', '15', '19', '2', '273', '274', '275', '3', 
        '323', '325', '36', '38', '385', '40', '42', '424', 
        '45', '46', '5', 'BETC_RET', 'BONS_SPRB', 'GWIL_SPRT'
    )
    AND b.BetDate >= '2012-11-01'                -- Filter dates on or after 1st November
GROUP BY 
    DATE_FORMAT(b.BetDate, '%Y-%m-%d'),          -- Grouping by formatted date
    Product                                      -- Grouping by product name
ORDER BY 
    Date;                                        -- Sorting by date


-- Question 08 - Part 1: Number of products per player

SELECT 
    b.AccountNo AS PlayerAccount, 
    COUNT(DISTINCT p.Product) AS NumberOfProducts
FROM 
    ironhack_gambling.betting b
JOIN 
    ironhack_gambling.product p
ON 
    b.ClassId = p.CLASSID
GROUP BY 
    b.AccountNo
HAVING 
    COUNT(DISTINCT p.Product) > 1;  -- Filter players with more than one product

-- Question 08 - Part 2: Players who play both Sportsbook and Vegas

SELECT 
    b.AccountNo AS PlayerAccount
FROM 
    ironhack_gambling.betting b
JOIN 
    ironhack_gambling.product p
ON 
    b.ClassId = p.CLASSID
WHERE 
    p.Product IN ('Sportsbook', 'Vegas')  -- Filter for Sportsbook and Vegas
GROUP BY 
    b.AccountNo
HAVING 
    COUNT(DISTINCT p.Product) = 2;  -- Ensure both products are played


-- Question 09: Players who only play one product (Sportsbook) with bet_amt > 0
SELECT 
    b.AccountNo AS PlayerAccount, -- Player's account number
    SUM(CASE WHEN p.Product = 'Sportsbook' THEN b.Bet_Amt ELSE 0 END) AS SportsbookBetTotal, -- Total bets for Sportsbook
    SUM(CASE WHEN p.Product != 'Sportsbook' THEN b.Bet_Amt ELSE 0 END) AS OtherProductsBetTotal -- Total bets for other products
FROM 
    ironhack_gambling.betting b
JOIN 
    ironhack_gambling.product p
ON 
    b.ClassId = p.CLASSID -- Join to match products with bets
GROUP BY 
    b.AccountNo -- Group by player account
HAVING 
    SportsbookBetTotal > 0 AND OtherProductsBetTotal = 0; -- Filter for players who only bet on Sportsbook


-- Question 10: Determine a player's favorite product based on the highest amount staked

WITH PlayerProductRanking AS (
    -- Create a ranking table that ranks each player's products by total bet amount
    SELECT 
        b.AccountNo AS PlayerAccount,         -- Player's account number
        p.Product AS FavoriteProduct,        -- Product with the highest bet amount
        SUM(b.Bet_Amt) AS TotalStaked,       -- Total amount staked per product
        RANK() OVER (PARTITION BY b.AccountNo ORDER BY SUM(b.Bet_Amt) DESC) AS rank
        -- RANK() assigns a rank to each product per player, with 1 being the highest-bet product
    FROM 
        ironhack_gambling.betting b          -- Betting table
    JOIN 
        ironhack_gambling.product p          -- Product table
    ON 
        b.ClassId = p.CLASSID                -- Match ClassId from betting with CLASSID in product
    GROUP BY 
        b.AccountNo, p.Product               -- Grouping by player and product
)
SELECT 
    PlayerAccount,       -- Display the player's account number
    FavoriteProduct,     -- Show the product with the highest total bet
    TotalStaked         -- Display the total bet amount for the top product
FROM 
    PlayerProductRanking
WHERE 
    rank = 1;            -- Select only the top-ranked product per player


-- Question 11: Return the top 5 students based on GPA
SELECT 
    student_name AS StudentName,  -- Retrieves the student's name
    GPA AS GradePointAverage      -- Retrieves the student's GPA
FROM 
    ironhack_gambling.student     -- Queries the 'student' table
ORDER BY 
    GPA DESC                      -- Orders students by GPA in descending order
LIMIT 5;                          -- Limits the result to the top 5 students


-- Question 12: Retrieve the number of students in each school, including schools with no students

SELECT 
    s.school_name AS SchoolName,       -- Retrieves the school's name
    COUNT(st.student_id) AS StudentCount  -- Counts the number of students in each school
FROM 
    ironhack_gambling.school s          -- Queries the 'school' table
LEFT JOIN 
    ironhack_gambling.student st        -- Left join to include schools with no students
ON 
    s.school_id = st.school_id          -- Matches students to their respective schools
GROUP BY 
    s.school_name;                      -- Groups results by school name


-- Question 13: Retrieve the top 3 GPA students from each university

WITH RankedStudents AS (
    -- Assigns a ranking to each student within their school based on GPA
    SELECT 
        st.student_name AS StudentName,  -- Retrieves the student's name
        st.GPA AS GradePointAverage,     -- Retrieves the student's GPA
        s.school_name AS SchoolName,     -- Retrieves the school name
        RANK() OVER (PARTITION BY st.school_id ORDER BY st.GPA DESC) AS rank
        -- RANK() assigns ranks within each school based on GPA (highest GPA first)
    FROM 
        ironhack_gambling.student st      -- Queries the 'student' table
    JOIN 
        ironhack_gambling.school s        -- Joins with the 'school' table
    ON 
        st.school_id = s.school_id        -- Matches students to their respective schools
)
SELECT 
    StudentName,         -- Displays the student's name
    GradePointAverage,   -- Displays the student's GPA
    SchoolName           -- Displays the school name
FROM 
    RankedStudents
WHERE 
    rank <= 3;           -- Selects only the top 3 students per school
