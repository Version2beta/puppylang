# puppylang

Puppy is a concatentative programming language created by Will Byrd (@webyrd) and Rob Martin (@version2beta) while sitting around a coffee shop one night looking for a good concatenative programming language to use for teaching concatenative programming languages, like you do.

## Example code

```
( This is a simplified version of the card game War written in Puppy. )

( Simple version of War: )
(   Two values on top of the stack represent dealt cards for the left and the   )
(   right players. Figure out which is bigger, and send the cards to that       )
(   player. In case of a tie, play again to determine the winner.               )

( Puppy is an unimplemented point-free, concatentative, stack-based language    )
( with quotations.                                                              )

( Puppy standard vocabulary:              )
( --------------------------------------- )
(   + - / * ^ %                           )
(   < > =                                 )
(   not                                   )
(   drop, dup, swap, rot, -rot, over      )
(   depth                                 )
(   quote - copy stack to a quote         )
(   [ quote ], [ quote ] call             )
(   bool [ then-quote ] [ else-quote ] if )
(   [ quote ] bool cond                   )
(   bool [ quote ] while                  ) ( repeats quote until false )
(   bool [ quote ] until                  ) ( repeats quote until true )
(   pid                                   )
(   pid send                              )
(   pid receive                           )
(   throw                                 )

( Some stack effects for reference:       )
( --------------------------------------- )
(   rot ( x y z -- y z x )                )
(   -rot ( x y z -- z x y )               )
(   over ( x y -- x y x )                 )
(   quote ( x.. -- x.. [ x.. ] )          )
(   send  ( [ word ] pid -- )             )

: empty
  depth [ drop ] while ;
: 2dup
  over over ;
: winner
  2dup < [ drop drop "left" ] [ > [ "right" ] [ "tie" ] if ] if ;
: tied?
  dup "tie" = ;
: war
  quote -rot winner tied? [ drop call ] [ swap send empty ] if ;

--------------
Demonstration:
--------------

Start :                                          3 4 war
war : quote  :                                   3 4 [ 3 4 ]
war : -rot   :                                   [ 3 4 ] 3 4
war : winner : 2dup :                            [ 3 4 ] 3 4 3 4
war : winner : < :                               [ 3 4 ] 3 4 t
war : winner : [ drop drop "left" ] [ ... ] if : [ 3 4 ] "left"
war : tied?  : dup "tie" = :                     [ 3 4 ] "left" f
war : [ ... ] [ swap send empty ] if :

Start :                                          4 3 war
war : quote  :                                   4 3 [ 4 3 ]
war : -rot   :                                   [ 4 3 ] 4 3
war : winner : 2dup :                            [ 4 3 ] 4 3 4 3
war : winner : < :                               [ 4 3 ] 4 3 f
war : winner : [ ... ] [ > ] if :                [ 4 3 ] t
war : winner : [ "right " ] [ ] if :             [ 4 3 ] "right"
war : tied?  : dup "tie" = :                     [ 4 3 ] "right" f
war : [ ... ] [ swap send empty ] if :

Start :                                          4 4 war
war : quote  :                                   4 4 [ 4 4 ]
war : -rot   :                                   [ 4 4 ] 4 4
war : winner : 2dup :                            [ 4 4 ] 4 4 4 4
war : winner : < :                               [ 4 4 ] 4 4 f
war : winner : [ ... ] [ > ] if :                [ 4 4 ] f
war : winner : [ ... ] [ "tie" ] if :            [ 4 4 ] "tie"
war : tied?  : dup "tie" = :                     [ 4 4 ] "tie" t
war : [ drop call ] [ ... ] if :                 4 4

Start :                                          4 4 2 1 war
war : quote  :                                   4 4 2 1 [ 4 4 2 1 ]
war : -rot   :                                   4 4 [ 4 4 2 1 ] 2 1
war : winner : 2dup :                            4 4 [ 4 4 2 1 ] 2 1 2 1
war : winner : < :                               4 4 [ 4 4 2 1 ] 2 1 f
war : winner : [ ... ] [ > ] if :                4 4 [ 4 4 2 1 ] t
war : winner : [ ... ] [ "tie" ] if :            4 4 [ 4 4 2 1 ] "right"
war : tied?  : dup "tie" = :                     4 4 [ 4 4 2 1 ] "right" f
war : [ ... ] [ swap send empty ] if :
```
