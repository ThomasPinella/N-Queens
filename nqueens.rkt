(#%require (only racket/base random)) ;Need to require this so we can use the random function
(#%require (only racket/base time)) ;Need to require this so we can use time functions to measure time

;Backtracking method

;Determines whether or not a certain square in a column has conflicts or not
(define (good_pos? index cur_index x V)
	(cond 
		(
			(>= index cur_index) ;Base case: when index exceeds our current index, that means there is no conflict for cur_index
			#t
		)
		(
			(or (equal? (vector-ref V index) x) (equal? (abs (- x (vector-ref V index))) (abs (- cur_index index))))
			#f ;If either row violation or diaganol violation, then we return a false -- the tested square is not good
		)
		(else
			(good_pos? (+ index 1) cur_index x V) ;Recursive step -- we increment the index by one and continue to test
		)
	)
)

;If a square has no conflicts, then we place a queen
(define (place_queen i x V)
	(cond
		(
			(>= x (vector-length V)) ;If there is no good row to place a queen for a particular column, we denote that with a -1
			(- 0 1)

		)
		(
			(good_pos? 0 i x V) ;If a square has no conflicts, then we place the queen there
			x
		)
		(else
			(place_queen i (+ x 1) V) ;Our recursive step -- we continue to increment the row till we either find a place for the queen or not
		)
	)
)

;Recurses through all the columns, calling place_queen for each column
(define (place_queens i x V num_steps)
	(cond
		(
			(>= i (vector-length V)) ;Base case: when we reach the end, we return a list containing 1) the vector representation and 2) the number of steps
			(list V num_steps)
		)
		(else
			(and 
				(vector-set! V i (place_queen i x V)) ;This is where we actually place the queen
				(cond
					(
						(and (equal? (vector-ref V i) (- 0 1)) (not (equal? i 0))) ;If we need to backtrack, then we call place_queens again, but subtract 1 from i
						(place_queens (- i 1) (+ 1 (vector-ref V (- i 1))) V (+ 1 num_steps))
					)
					(
						(and (equal? (vector-ref V i) (- 0 1)) (equal? i 0)) ;This only happens in board sizes of 4 or less, when there is no solution
						"No solution :("
					)
					(else
						(place_queens (+ i 1) 0 V (+ 1 num_steps)) ;If we were able to place a queen successfully, we continue to the next column
					)
				)
			)
		)
	)
)

;This function creates the 0/1 representation of the board.
(define (make_board i V board)
	(cond
		(
			(>= i (vector-length V)) ;When we reach the end, we return the board
			board
		)
		(else
			(and
				(and
					(vector-set! board i (make-vector (vector-length V) 0)) ;For each column, we make a new vector of rows
					(vector-set! (vector-ref board i) (vector-ref V i) 1) ;Here, we specify which row has the queen
				)
				(make_board (+ i 1) V board) ;Recursive step here, increment i by 1
			)
		)	
	)
)

;Prints the board
(define (print_board i board)
	(cond
		(
			(>= i (vector-length board)) ;Base case: simply return a newline when we reach the end
			(newline)
		)
		(else
			(and (and (display (vector-ref board i)) (newline)) (print_board (+ 1 i) board))
		)
	)
)

;Main backtracking function
(define (nq-bt bool n)
	(let
	 	(
	 		(r (place_queens 0 0 (make-vector n (- 0 1)) 0)) ;Define a local variable r which contains the solution vector and number of steps
	 	)
	 	(cond ;If bool is true, then we print out the 0/1 representation of the board in addition to the solution vector and number of steps
	 		(
	 			bool
	 			(and
	 				(print_board 0 (make_board 0 (car r) (make-vector n 0)))
					(and (and (and (display (car r)) (newline) (display (cadr r)))) (newline))
 				)
	 		)
	 		(else ;If bool is false, then only print out the solution vector and number of steps
				(and (and (and (display (car r)) (newline) (display (cadr r)))) (newline))
	 		)
	 	)
	)
)


;(nq-bt #t 22)


;Min Conflicts ---------------------------------------------------------------------------------------------------------

;For a particular square, this function returns the number of conflicts it has
(define (num_conflicts index cur_index x num V)
	(cond
		(
			(>= index (vector-length V)) ;When we get to the end of the board, we are done and return the number
			(- num 1) ;Subtract one because we don't want to include the conflict with itself
		)
		(
			(or (equal? (vector-ref V index) x) (equal? (abs (- x (vector-ref V index))) (abs (- cur_index index))))
			(num_conflicts (+ 1 index) cur_index x (+ 1 num) V) ;The conditional checks both rows and diaganol conflicts
		)
		(else
			(num_conflicts (+ 1 index) cur_index x num V) ;If no conflict, we recurse as usual, but don't increment num
		)
	)
)

;(display (num_conflicts 0 0 5 0 #(5 6 7 8 45)))

;Returns the row of a certain column with the least number of conflicts
(define (get_min_conflict i x mini p V)
	(cond
		(
			(>= x (vector-length V)) ;Once we've exhausted all the squares in a column, we return p -- the row # with least conflicts
			p
		)
		(else
			(let
				(
					(c (num_conflicts 0 i x 0 V)) ;Local variable c has the number of conflicts at a particular square
				)
				(cond
					(
						(<= c mini) ;If this is a new min number, we save the position
						(get_min_conflict i (+ 1 x) c x V)
					)
					(else
						(get_min_conflict i (+ 1 x) mini p V) ;Otherwise, we recurse and keep our old min value
					)
				)
			)
		)
	)
)

;The workhorse -- chooses columns randomly and moves queens
(define (move_queens_one i steps V res iter t n)
	(cond
		(
			(and (= 0 (modulo iter (* n n))) (good? 0 V)) ;Checks the whole board every time we reach the limit iteratino # of n squared
			(list V steps) ;Returns both the solution vector and the # of steps
		)
		(
			(>= iter (* n n)) ;Limit of n squared iterations to avoid local mins
			(move_queens_one i (+ steps n) (init 0 (make-vector (vector-length V) 0)) (+ 1 res) 0 (+ 1 t) n) ;Start over with init'd board
		)
		(else
			(and
				(set! i (random (vector-length V))) ;We choose a random column...
				(cond
					(
						(equal? 0 (num_conflicts 0 i (vector-ref V i) 0 V)) ;... and if it has no conflicts, we don't move it
						(move_queens_one i steps V res (+ 1 iter) (+ 1 t) n) ;then recurse, of course
					)
					(else
						(and
							(vector-set! V i (get_min_conflict i 0 (vector-length V) 0 V)) ;... but if it does have conflicts, we choose the min conflict in the column
							(move_queens_one i (+ 1 steps) V res (+ 1 iter) (+ 1 t) n) ;and then we recurse
						)
					)
				)
			)
		)
	)
)

;Verifies if the board satisfies the conditions of the problem
(define (good? i V)
	(cond
		(
			(>= i (vector-length V)) ;if we get to the end of the board with no breaks, it is a good board
			#t
		)
		(
			(not (equal? 0 (num_conflicts 0 i (vector-ref V i) 0 V))) ;If we have any conflicts, then the board isn't good
			#f
		)
		(else
			(good? (+ 1 i) V) ;Recurse
		)
	)
)

;Depracated function that uses the max_conflicted_col function
;It finds the column with the most conflicts and then fixes it
;This however, is significantly slower than the other completely random way of doing it
(define (move_queens i steps V res iter n)
	(let
		(
			(maxi (max_conflicted_col 0 0 0 V)) ;Find the most conflicted queen 
		)
		(cond
			(
				;(equal? 0 (cadr maxi))
				(and (= 0 (modulo iter (* n n))) (good? 0 V)) ;Same logic here as before in move_queens_one...

				(list V steps)
			)
			(
				(>= iter (* n n)) ;See above
				(move_queens i (+ steps n) (init 0 (make-vector (vector-length V) 0)) (+ 1 res) 0 n)
			)
			(else
				(and
					(cond
						(
							(= 0 (random 2)) ;50-50 chance of using the most conflicted queen in order that we don't fall into local min
							(set! i (random (vector-length V))) ;Here we use a completely random column
						)
						(else
							(set! i (car maxi)) ;Here we use the most conflicted queen column
						)
					)
					(cond
						(
							(equal? 0 (num_conflicts 0 i (vector-ref V i) 0 V)) ;Same logic here as in move_queens_one. See above
							(move_queens i steps V res (+ 1 iter) n)
						)
						(else
							(and
								(vector-set! V i (get_min_conflict i 0 (vector-length V) 0 V)) ;See above
								(move_queens i (+ 1 steps) V res (+ 1 iter) n)
							)
						)
					)
				)
			)
		)
	)
)

;Used in depracated function move_queens. Finds the most conflicted queen
(define (max_conflicted_col i col_index maxi_num V)
	(cond
		(
			(>= i (vector-length V)) ;If at end, then we return the max
			(list col_index maxi_num) ;We return the index and the number of conflicts it has in a list
		)
		(
			(>= maxi_num (num_conflicts 0 i (vector-ref V i) 0 V)) ;Here we check to see if the current location is bigger (has more conflicts) than our current maximum
			(max_conflicted_col (+ 1 i) col_index maxi_num V) ;Keep what we've got here
		)
		(else
			(max_conflicted_col (+ 1 i) i (vector-ref V i) V) ;Replace it here
		)
	)
)

;Initializes the board with a greedy approach
(define (init i V)
	(cond
		(
			(>= i (vector-length V)) ;At end, return the vector
			V
		)
		(else
			(and
				(vector-set! V i (get_min_conflict i 0 (vector-length V) 0 V)) ;Place queen in the least conflicted column
				(init (+ 1 i) V)
			)
		)
	)
)

;Puts queens in random positions on the board
(define (rand_pos i V)
	(cond
		(
			(>= i (vector-length V)) ;At end, return vector
			V
		)
		(else
			(and
				(vector-set! V i (random (vector-length V))) ;Places the queen in a random row for each column
				(rand_pos (+ 1 i) V)
			)
		)
	)
)

;Min Conflicts Algorithm function that uses the depracated method of finding the maximum conflicted queen. Rather slowish.
(define (nq-mc-maxi bool n)
	(let
	 	(
	 		(r (move_queens 0 0 (init 0 (rand_pos 0 (make-vector n 0))) 0 0 n))
	 	)
	 	(cond
	 		(
	 			bool
	 			(and
	 				(print_board 0 (make_board 0 (car r) (make-vector n 0)))
					(and (and (and (display (car r)) (newline) (display (cadr r)))) (newline))
 				)
	 		)
	 		(else
				(and (and (and (display (car r)) (newline) (display (cadr r)))) (newline))
	 		)
	 	)
	)
)

;The Minimum Conflicts Algorithm
(define (nq-mc bool n)
	(let
	 	(
	 		(r (move_queens_one 0 0 (init 0 (rand_pos 0 (make-vector n 0))) 0 0 0 n)) ;Local variable r contains the solution vector and # of steps
	 	)
	 	(cond
	 		(
	 			bool
	 			(and
	 				(print_board 0 (make_board 0 (car r) (make-vector n 0))) ;For the 0/1 representation of the board
					(and (and (and (display (car r)) (newline) (display (cadr r)))) (newline))
 				)
	 		)
	 		(else
				(and (and (and (display (car r)) (newline) (display (cadr r)))) (newline))
	 		)
	 	)
	)
)

(nq-mc #f 100)



























