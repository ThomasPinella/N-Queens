Thomas Pinella
CSC 173 Fall 2015
12.2.2015

The nqueens.rkt file contains the implementation of two algorithms: backtracking and min conflicts. Both make use of the basic print/formatting functions called print_board, which prints the n x n board with empty squares expressed as 0's and queens expressed as 1's. And they both make use of make_board which creates the previously described board. Since both use these two basic functions, I'll describe them first.

(make_board i V board):

Base case is reached when the variable i is greather than or euqal to the length of vector V, which is the one dimensional numerical represenation of the solution. Before we reach the base case, we are doing three things: 1) creating a new vector filled with 0's for each column, 2) finding the queen in that column and making it a 1, and 3) recursing, incrementing i by 1. One important thing to note here is that because we are creating the vectors of the 2-dimensional board in this order, we are creating rows at a time, not columns. Therefore, the correspondance between the vector solution and the board representation is not that each index of the vector is a column, but that each index is a row, and the number is the row # the queen is placed on.

(print board i board)

This takes the 2-dimensional vector returned by the aforementioned function and iterates through it using tail recursion. Each time, calling display and new line. Fairly straightforward.

Backtracking

The backtracking algorithm is composed of four main functions: good_pos?, place_queen, place_queens, and, of course, nq-bt.

I'm not going to go into too much detail of how each function works because that can be found by simply reading the comments. I'll give a quick summary on the purpose of the functions here, however.

The good_pos? function is fundamental; it is called for each row on every column and returns true if a position is good (aka there are no conflicts with other queens) and false if otherwise. It does this by using the vector representation. It loops through all the indices to the left of the current index (or column) being tested and if the vector's value at some index is equal to the value at the tested index, then there's a conflict. And if the absolute value of the tested index minus the index equals the absolute value of the tested row minus the value of the vector value at the index location, then there's a conflict.

The place_queen function checks each row of a certain column looking for a place to put the queen. The first location that returns a value of true from the good_pos? function is the location the queen is placed in.

The place_queens function iterates through the indices, or columns, of the vector and calls place_queen for each one.

Finally, the nq-bt function calls place_queens so that it can get the solution vector and number of steps required. It then puts this list into a local variable. We then check bool to see if the user wants to see the 0/1 representation of the board. If they do (that is, bool is true), then we call print_board, passing make_board as a parameter into it). Otherwise, we just print the solution vector and number of steps.

Min Conflicts

The min conflicts algorithm that I'm using is composed of 7 functions: num_conflicts, get_min_conflict, move_queens_one, good?, init, rand_pos, and, of course, nq-mc. Again, I will not go into too much detail here, as details can be found and understood by reading the comments in the code.

The num_conflicts function finds the number of conflicts for a particular square in a particular column. It does this by using a method similar to the one described for the good_pos? function used in backtracking, only this time we need to check everything, not just the columns to the left. We then use the get_min_conflict function to find the row # of a particular column that has the least number of conflicts. We simply keep track of the minimum number and check it for each row # as we loop (or tail recurse, in this case) through all the squares of a certain column. Fairly straightforward.

Finally, move_queens_one puts it all together. If you read the code/comments, you'll notice that I only return a solution when the number of iterations modulo n squared is equal to zero and then I verify using the good? function that the board is indeed a valid solution. The reason for this is because checking if the board is a valid solution every iteration is very computationally taxing. Therefore, I only check it when I reach my max number of iterations, namely n squared. If it's a solution, great, and I return it. Otherwise, I reinitialize the board and try again. This can be seen in the second part of the conditional statement. If the number of iterations is greather than or equal to n squared, we reset. The rest of the move_queens_one function selects a random column and, if the queen in that column is experiencing more than 0 conflicts, it finds the min conflict and moves the queen there. Then recurses.

The good? function, as I mentioned before, just verifies that the vector solution is indeed valid. It does this by calling num_conflicts on each queen and making sure it returns 0 each time.

The init function uses a greedy approach to initialize the board. It goes through, from i = 0 to the end and places the queen in the min conflicted square for each one.

The nq-mc function puts it all together in a similar fashion the nc-bt function did. That is, I call print_board and make_vector if bool is true, otherwise just return the solution vector and number of steps.

Extra stuff

I tried a variety of things to speed up min conflicts, many of which I found didn't actually help. One thing I tried was finding the most conflicted queen with each iteration and instead of being random about which column to pick, go to that most conflicted queen and move it. I found that I fell into local mins quite often, however. Therefore, I made it so that half the time I would move the most conflicted queen and the other half of the time I would simply choose a random column. This solved the local minimum problem and worked. Only thing was that it was actually slower than my original method. Reason being that it is computationally expensive to be finding the most conflicted queen with every iteration. But, I saved this method of doing it and can be tested by calling the function nq-mc-maxi. It makes use of the function max_conflicted_col to find the most conflicted queen each time.

Another thing I tried doing was a dynamic programming approach. After moving a queen, I would put the number of conflicts for that queen into a vector. Then, I would choose columns based off the vector. I wouldn't move queens that had a zero. This failed because the vector wasn't always accurate. When you move a queen in column x, it may cause a new conflict in column y that goes unaccounted for. And if column y had zero conflicts prior to this move, now it has one, but that change goes unrecorded in the vector. Therefore this method was no good.

















