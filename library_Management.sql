create database library_management;

use library_management;

create table publisher(PublisherName varchar(255) primary key,
					   PublisherAddress varchar(255),
                       PublisherPhone varchar(255));
                       
create table borrower(CardNo tinyint primary key auto_increment,
                      BorrowerName varchar(255),
                      BorrowerAddress varchar(255),
                      BorrowerPhone varchar(255));
                      
create table book(BookID tinyint primary key auto_increment,
                  Book_Title varchar(255),
                  PublisherName varchar(255),
                  foreign key (PublisherName) references Publisher(PublisherName) on update cascade on delete cascade);
                  
create table authors(AuthorID tinyint primary key auto_increment,
                     BookID tinyint,
                     AuthorName varchar(255),
                     foreign key (BookID) references book(BookID) on update cascade on delete cascade);
                     
create table library_branch(BranchID tinyint primary key auto_increment,
                            BranchName varchar(255),
                            BranchAddress varchar(255));
                            
                            
create table book_copies(CopiesID tinyint primary key auto_increment,
                         BookID tinyint,
                         BranchID tinyint,
                         No_of_Copies tinyint,
                         foreign key (BookID) references book(BookID) on update cascade on delete cascade,
                         foreign key (BranchID) references library_branch(BranchID) on update cascade on delete cascade);
                         
create table book_loans(LoansID tinyint primary key auto_increment,
                        BookID tinyint,
                        BranchID tinyint,
                        CardNo tinyint,
                        DateOut varchar(255),
                        DueDate varchar(255),
                        foreign key (BookID) references book(BookID) on update cascade on delete cascade,
                        foreign key (BranchID) references library_branch(BranchID) on update cascade on delete cascade,
                        foreign key (CardNo) references borrower(CardNo) on update cascade on delete cascade);
                        
select * from publisher;
select * from borrower;
select * from book;
select * from authors;
select * from library_branch;
select * from book_copies;
select * from book_loans; 


-- How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
				
select No_of_Copies from book
      Inner join book_copies
      using(BookID)
      Inner join library_branch
      using(BranchID)
      where Book_Title = "The Lost Tribe" and BranchName = "Sharpstown";
      
      
-- How many copies of the book titled "The Lost Tribe" are owned by each library branch?

select No_of_Copies, BranchName from book
      Inner join book_copies
      using(BookID)
      Inner join library_branch
      using(BranchID)
      where Book_Title = "The Lost Tribe";  
      
-- Retrieve the names of all borrowers who do not have any books checked out

select * from borrower
	left join book_loans
    using(CardNo)
    where DueDate is Null;
    
-- For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, 
-- retrieve the book title, the borrower's name, and the borrower's address  

select Book_Title, BorrowerName, BorrowerAddress from book
       Inner join book_loans
       using(BookID)
       Inner join borrower
       using(CardNo)
	   where BranchID = (select BranchID from library_branch
                                    where BranchName = 'Sharpstown') and DueDate = '2/3/18';
                                    
-- For each library branch, retrieve the branch name and the total number of books loaned out from that branch

select BranchName,sum(No_of_Copies) as Total_Copies from library_branch
       Inner join book_loans
       using(BranchID)
       Inner join book_copies
       using(BranchID)
       group by BranchName;
       
-- Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out

with cte_1 as (select BorrowerName, BorrowerAddress, count(*) as No_of_checkedout from borrower
       Inner join book_loans
       using(CardNo)
       group by BorrowerName, BorrowerAddress)
       
select * from cte_1
		where No_of_checkedout > 5;
        
-- For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central"

with cte_1 as (select * from authors
      where AuthorName = 'Stephen King'),
      
cte_2 as (select Book_Title, BookID from cte_1
             inner join book
             using(BookID))
             
select Book_Title, No_of_Copies from cte_2
       Inner join book_copies
       using(BookID)
       where BranchID = (select BranchID from library_branch
                                where BranchName = 'Central');
      