DROP DATABASE IF EXISTS LibraryDB;

CREATE DATABASE LibraryDB;

USE LibraryDB;

DROP TABLE IF EXISTS tbl_publisher;
DROP TABLE IF EXISTS tbl_book;
DROP TABLE IF EXISTS tbl_book_authors;
DROP TABLE IF EXISTS tbl_library_branch;
DROP TABLE IF EXISTS tbl_book_copies;
DROP TABLE IF EXISTS tbl_borrower;
DROP TABLE IF EXISTS tbl_book_loans;

-- 1. Publisher table
CREATE TABLE tbl_publisher (
    publisher_PublisherName VARCHAR(255) PRIMARY KEY,
    publisher_PublisherAddress TEXT,
    publisher_PublisherPhone VARCHAR(15)
);

-- 2. Book table
CREATE TABLE tbl_book (
    book_BookID INT PRIMARY KEY AUTO_INCREMENT,
    book_Title VARCHAR(255),
    book_PublisherName VARCHAR(255),
    FOREIGN KEY (book_PublisherName) REFERENCES tbl_publisher(publisher_PublisherName)
);

-- 3. Book Authors table
CREATE TABLE tbl_book_authors (
    book_authors_AuthorID INT PRIMARY KEY AUTO_INCREMENT,
    book_authors_BookID INT,
    book_authors_AuthorName VARCHAR(255),
    FOREIGN KEY (book_authors_BookID) REFERENCES tbl_book(book_BookID)
);

-- 4. Library Branch table
CREATE TABLE tbl_library_branch (
    library_branch_BranchID INT PRIMARY KEY AUTO_INCREMENT,
    library_branch_BranchName VARCHAR(255),
    library_branch_BranchAddress TEXT
);

-- 5. Book Copies table
CREATE TABLE tbl_book_copies (
    book_copies_CopiesID INT PRIMARY KEY AUTO_INCREMENT,
    book_copies_BookID INT,
    book_copies_BranchID INT,
    book_copies_No_Of_Copies INT,
    FOREIGN KEY (book_copies_BookID) REFERENCES tbl_book(book_BookID),
    FOREIGN KEY (book_copies_BranchID) REFERENCES tbl_library_branch(library_branch_BranchID)
);

-- 6. Borrower table
CREATE TABLE tbl_borrower (
    borrower_CardNo INT PRIMARY KEY,
    borrower_BorrowerName VARCHAR(255),
    borrower_BorrowerAddress TEXT,
    borrower_BorrowerPhone VARCHAR(15)
);

-- 7. Book Loans table
CREATE TABLE tbl_book_loans (
    book_loans_LoansID INT PRIMARY KEY AUTO_INCREMENT,
    book_loans_BookID INT,
    book_loans_BranchID INT,
    book_loans_CardNo INT,
    book_loans_DateOut DATE,
    book_loans_DueDate DATE,
    FOREIGN KEY (book_loans_BookID) REFERENCES tbl_book(book_BookID),
    FOREIGN KEY (book_loans_BranchID) REFERENCES tbl_library_branch(library_branch_BranchID),
    FOREIGN KEY (book_loans_CardNo) REFERENCES tbl_borrower(borrower_CardNo)
);

SELECT * FROM tbl_publisher;
SELECT * FROM tbl_book;
SELECT * FROM tbl_book_authors;
SELECT * FROM tbl_library_branch;
SELECT * FROM tbl_book_copies;
SELECT * FROM tbl_borrower;
SELECT * FROM tbl_book_loans;

-- 1.	How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
SELECT
    T1.book_copies_No_Of_Copies
FROM
    tbl_book_copies AS T1
JOIN
    tbl_book AS T2 ON T1.book_copies_CopiesID = T2.book_BookID
JOIN
    tbl_library_branch AS T3 ON T1.book_copies_BranchID = T3.library_branch_BranchID
WHERE
    T2.book_Title LIKE 'The Lost Tribe' AND T3.library_branch_BranchName LIKE 'Sharpstown';

-- 2.	How many copies of the book titled "The Lost Tribe" are owned by each library branch?
SELECT
    T3.library_branch_BranchName,
    SUM(T1.book_copies_No_Of_Copies) AS Total_Copies
FROM
    tbl_book_copies AS T1
JOIN
    tbl_book AS T2 ON T1.book_copies_CopiesID = T2.book_BookID
JOIN
    tbl_library_branch AS T3 ON T1.book_copies_BranchID = T3.library_branch_BranchID
WHERE
    T2.book_Title LIKE 'The Lost Tribe'
GROUP BY
    T3.library_branch_BranchName;

-- 3.	Retrieve the names of all borrowers who do not have any books checked out.
SELECT
    T1.borrower_BorrowerName
FROM
    tbl_borrower AS T1
LEFT JOIN
    tbl_book_loans AS T2 ON T1.borrower_CardNo = T2.book_loans_CardNo
WHERE
    T2.book_loans_CardNo IS NULL;

-- 4.	For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 
SELECT
    T1.book_Title,
    T3.borrower_BorrowerName,
    T3.borrower_BorrowerAddress
FROM tbl_book AS T1
JOIN tbl_book_loans AS T2 ON T1.book_BookID = T2.book_loans_BookID
JOIN tbl_borrower AS T3 ON T2.book_loans_CardNo = T3.borrower_CardNo
JOIN tbl_library_branch AS T4 ON T2.book_loans_BranchID = T4.library_branch_BranchID
WHERE
    T4.library_branch_BranchName = 'Sharpstown'
    AND T2.book_loans_BookID IS NOT NULL
    AND DATE(T2.book_loans_DueDate) = '2018-02-03';

-- 5.	For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
SELECT
    T1.library_branch_BranchName,
    COUNT(T2.book_loans_LoansID) AS Total_Books_Loaned
FROM
    tbl_library_branch AS T1
JOIN
    tbl_book_loans AS T2 ON T1.library_branch_BranchID = T2.book_loans_BranchID
GROUP BY
    T1.library_branch_BranchName;


-- 6.	Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
SELECT
    T1.borrower_BorrowerName,
    T1.borrower_BorrowerAddress,
    COUNT(T2.book_loans_LoansID) AS Number_of_Books_Checked_Out
FROM tbl_borrower AS T1
JOIN tbl_book_loans AS T2 ON T1.borrower_CardNo = T2.book_loans_CardNo
GROUP BY T1.borrower_CardNo
HAVING COUNT(T2.book_loans_LoansID) > 5;


-- 7.	For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
SELECT
    T1.book_Title,
    T3.book_copies_No_Of_Copies
FROM tbl_book AS T1
JOIN tbl_book_authors AS T2 ON T1.book_BookID = T2.book_authors_AuthorID
JOIN tbl_book_copies AS T3 ON T1.book_BookID = T3.book_copies_CopiesID
JOIN tbl_library_branch AS T4 ON T3.book_copies_BranchID = T4.library_branch_BranchID
WHERE
    T2.book_authors_AuthorName LIKE 'Stephen King' AND T4.library_branch_BranchName LIKE 'Central';
    

