# tent-puzzle-elixir
This was my homework to solve the Tent puzzle with the fastest solution.
Here are two tests
A puzzle and its solution.
      1  0  2  0  2       1  0  2  0  2
   1  -  *  -  -  -    1  -  *  E  -  -
   1  -  -  -  -  -    1  -  -  -  -  N
   0  -  -  *  -  *    0  -  -  *  -  *
   3  -  -  -  -  -    3  N  -  S  -  N
   0  *  -  -  -  *    0  *  -  -  -  *
  
  iex> Nhf1.satrak {[1, 1, 0, 3, 0], [1, 0, 2, 0, 2], [{1, 2}, {3, 3}, {3, 5}, {5, 1}, {5, 5}]}
  [[:e, :s, :n, :n, :n]]
  
Another puzzle with solution.
     -1 -2 -2  0 -2       -1 -2 -2  0 -2       -1 -2 -2  0 -2       -1 -2 -2  0 -2
  -1  -  *  -  -  -    -1  W  *  -  -  -    -1  -  *  -  -  -	 -1  -  *  E  -  -
  -1  -  -  -  -  -    -1  -  -  -  -  N    -1  -  S  -  -  N	 -1  -  -  -  -  N
  -1  -  -  *  -  *    -1  -  -  *  -  *    -1  -  -  *  -  *	 -1  -  -  *  -  *
   3  -  -  -  -  -     3  N  -  S  -  N     3  N  -  S  -  N	  3  N  -  S  -  N
   0  *  -  -  -  *     0  *  -  -  -  *     0  *  -  -  -  *	  0  *  -  -  -  *
  
  iex> Nhf1.satrak {[-1, -1, -1, 3, 0], [-1, -2, -2, 0, -2], [{1, 2}, {3, 3}, {3, 5}, {5, 1}, {5, 5}]}
  [[:w, :s, :n, :n, :n], [:s, :s, :n, :n, :n], [:e, :s, :n, :n, :n]]
