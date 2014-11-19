class board
  board_array: []
  
  # generate a 2D array with all the cell's values set to 0
  constructor: (@width, @height) ->
    for y in [0..@height]
      @board_array[y]=[] 
      for x in [0..@width]
        @board_array[y][x]=0
		
  # Get the value at cell (x, y)
  getEntry: (x,y)->
      @board_array[y][x]
	  
  # Set the value at cell (x, y) to type
  setEntry: (x,y, type)->
      @board_array[y][x]=type
  
  #Printing the current board and score to browser
  printboard: (score) ->
    html = '<table>'
    for y in [0..@height-1]
      html += '<tr>'
      for x in [0..@width-1]
        if @board_array[y][x]==0
          html += '<td class="empty"></td>'
        else if @board_array[y][x]==1
          html += '<td class="pellet"></td>'
        else if @board_array[y][x]==2
          html += '<td class="snake_body"></td>'
        else
          html += '<td class="snake_head"></td>'
      html += '</tr>'
    html += '</table>'
    document.getElementById('board').innerHTML=html
    document.getElementById('score_holder').innerHTML=score


class snake 
  direction: 1 #1 = left, 2 = right, 3 = top, 4 = bottom
  board_width: 20
  board_height: 20
  #a list of dictionaries that holds the positions of the snake. first element being the head
  snake_list: [] 
  empty_list: []
  is_gameover: 0
  score: 0
  
  # Generate a new head according to the current direction
  # Check whether the head hit the wall or its body
  # call game over or update accordingly
  move: ->
    head =  @snake_list[0]
    if @direction==1
      head = {'x':head.x-1, 'y':head.y}
    else if @direction==2
      head = {'x':head.x+1, 'y':head.y}
    else if @direction==3
      head = {'x':head.x, 'y':head.y-1}
    else
      head = {'x':head.x, 'y':head.y+1}

    if head.x < 0 or head.x >=@board_width or head.y < 0 or head.y >=@board.height 
      @is_gameover = 1
    else if @board.getEntry(head.x, head.y) == 2
      @is_gameover = 1
 
    
    if @is_gameover is 1
      @gameover()

    else
      @update(head)

  #Displays the game over message
  gameover: ->
    #display the game over message
    document.getElementById('gameover').style.visibility='visible'

  # update the snake's body, empty cells and the board
  update: (head)->
    last = @snake_list[@snake_list.length-1]

    # add the new head to the front of the snake_list and take off the tail
    for i in [0..@snake_list.length-1]
      tmp = @snake_list[i]
      @snake_list[i] = head
      head = tmp

    if @board.getEntry(@snake_list[0].x, @snake_list[0].y)!=1
       #add the tail and add it to empty list 
       @empty_list.push({'x':last.x, 'y':last.y})
    else
       # when eating a pellet, increment score, add tail and generate next pellet
       @score += 100
       @snake_list.push({'x':last.x, 'y':last.y})
       @next_pellet()

    #remove head from empty_list
    remove = 0
    for i in [0..@empty_list.length-1]
      if @empty_list[i].x == @snake_list[0].x && @empty_list[i].y == @snake_list[0].y
        remove = i

    @empty_list.splice(remove, 1)

    #redraw the board
    for s in @snake_list
      @board.setEntry(s.x,s.y,2)
    for s in @empty_list
      @board.setEntry(s.x,s.y,0)

    @board.printboard(@score)

  constructor: (@init_x, @init_y, @speed) ->
    #reset the game 
    @reset(@init_x, @init_y, @speed)

  reset: (init_x, init_y, speed) ->
    #initialize the board
    @board = new board @board_width, @board_height
    @board.setEntry(@init_x, @init_y, 2);

    #initialize the lists
    @snake_list = []
    @empty_list = []

    #initialize the score
    @score = 0
    
    #initialize the free list and empty_list
    for x in [0..@board_width-1]
      for y in [0..@board_height-1]
        if x==@init_x && y==@init_y
          @snake_list.push({'x':@init_x, 'y':@init_y})
        else
          @empty_list.push({'x':x, 'y':y})
    
    @is_gameover = 0
    document.getElementById('gameover').style.visibility='hidden'

    #randomly generate the next pellet
    @next_pellet()

    #print the snake board
    @board.printboard(@score)
  
  # generate a random pellet from the empty cells in the table
  next_pellet:->
    random = Math.floor(Math.random()*@empty_list.length-1)
    pos = @empty_list.splice(random, 1)
    @board.setEntry(pos[0].x, pos[0].y, 1)

  # change the current direction according to the key press
  # if the body's length is 2 or more, ignore change to opposite direction
  changeDirection: (keyCode)->
    if keyCode is 13
      if @is_gameover is 1
        @reset(@init_x, @init_y, @speed)
    if keyCode is 37
      if @snake_list.length > 1 && @direction == 2
        @direction = 2
      else
        @direction = 1
    else if keyCode is 39
      if @snake_list.length > 1 && @direction == 1
        @direction = 1
      else
        @direction = 2
    else if keyCode is 38
      if @snake_list.length > 1 && @direction == 4
        @direction = 4
      else
        @direction = 3
    else if keyCode is 40
      if @snake_list.length > 1 && @direction == 3
        @direction = 3
      else
        @direction = 4

# start off the game and listen for key presses
game = new snake 10,10,10
setInterval (-> game.move()), 100

$(document).keydown( (e) ->
  game.changeDirection(e.which)
) 
    
