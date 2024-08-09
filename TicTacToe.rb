require 'tk'

class TicTacToe
  def initialize
    @root = TkRoot.new
    @root.title = "Tic Tac Toe"
    @current_resolution = "400x400"
    @root.geometry(@current_resolution)

    @board = Array.new(3) { Array.new(3, "") }
    @current_player = "X"

    create_interface
  end

  # Create the main interface with Play, Options, Help, and Exit buttons
  def create_interface
    clear_previous_menu

    @main_frame = TkFrame.new(@root) {
      pack "side" => "top", "fill" => "both", "expand" => true
    }

    title_label = TkLabel.new(@main_frame) {
      text "Tic Tac Toe"
      font TkFont.new('times 20 bold')
      pack "side" => "top", "pady" => 20
    }

    play_button = TkButton.new(@main_frame) {
      text "Play"
      font TkFont.new('times 16 bold')
      pack "side" => "top", "padx" => 20, "pady" => 10
    }
    play_button.command { show_game_modes }

    options_button = TkButton.new(@main_frame) {
      text "Options"
      font TkFont.new('times 16 bold')
      pack "side" => "top", "padx" => 20, "pady" => 10
    }
    options_button.command { show_options }

    help_button = TkButton.new(@main_frame) {
      text "Help"
      font TkFont.new('times 16 bold')
      pack "side" => "top", "padx" => 20, "pady" => 10
    }
    help_button.command { show_help }

    exit_button = TkButton.new(@main_frame) {
      text "Exit"
      font TkFont.new('times 16 bold')
      pack "side" => "top", "padx" => 20, "pady" => 10
    }
    exit_button.command { exit_game }
  end

  # Clear any previous menu frames to prevent duplication
  def clear_previous_menu
    @main_frame.pack_forget if @main_frame
    @mode_frame.pack_forget if @mode_frame
    @ai_frame.pack_forget if @ai_frame
    @board_frame.pack_forget if @board_frame
  end

  # Show game modes: Local Multiplayer or Player vs AI
  def show_game_modes
    clear_previous_menu

    @mode_frame = TkFrame.new(@root) {
      pack "side" => "top", "fill" => "both", "expand" => true
    }

    local_button = TkButton.new(@mode_frame) {
      text "Local Multiplayer"
      font TkFont.new('times 16 bold')
      pack "side" => "top", "padx" => 20, "pady" => 10
    }
    local_button.command { start_game("local") }

    ai_button = TkButton.new(@mode_frame) {
      text "Player vs AI"
      font TkFont.new('times 16 bold')
      pack "side" => "top", "padx" => 20, "pady" => 10
    }
    ai_button.command { show_ai_difficulties }

    back_button = TkButton.new(@mode_frame) {
      text "Back"
      font TkFont.new('times 16 bold')
      pack "side" => "top", "padx" => 20, "pady" => 10
    }
    back_button.command { back_to_main_menu }
  end

  # Show AI difficulty levels
  def show_ai_difficulties
    @mode_frame.pack_forget

    @ai_frame = TkFrame.new(@root) {
      pack "side" => "top", "fill" => "both", "expand" => true
    }

    easy_button = TkButton.new(@ai_frame) {
      text "Easy"
      font TkFont.new('times 16 bold')
      pack "side" => "top", "padx" => 20, "pady" => 10
    }
    easy_button.command { start_game("ai_easy") }

    medium_button = TkButton.new(@ai_frame) {
      text "Medium"
      font TkFont.new('times 16 bold')
      pack "side" => "top", "padx" => 20, "pady" => 10
    }
    medium_button.command { start_game("ai_medium") }

    hard_button = TkButton.new(@ai_frame) {
      text "Hard"
      font TkFont.new('times 16 bold')
      pack "side" => "top", "padx" => 20, "pady" => 10
    }
    hard_button.command { start_game("ai_hard") }

    back_button = TkButton.new(@ai_frame) {
      text "Back"
      font TkFont.new('times 16 bold')
      pack "side" => "top", "padx" => 20, "pady" => 10
    }
    back_button.command { show_game_modes }
  end

  # Start the Tic Tac Toe game based on selected mode
  def start_game(mode)
    clear_previous_menu
    create_board(mode)
    bind_escape_key

    # Determine if AI should start first
    if mode.start_with?("ai") && rand < 0.5
      @current_player = "O"
      ai_move(mode)
      @current_player = "X"
    end
  end

  # Create the game board
  def create_board(mode)
    @board_frame = TkFrame.new(@root) {
      pack "side" => "top"
    }

    3.times do |row|
      3.times do |col|
        button = TkButton.new(@board_frame) {
          text ""
          font TkFont.new('times 14 bold')
        }
        button.grid "row" => row, "column" => col
        button.command { click_button(row, col, mode) }
        @board[row][col] = button
      end
    end
    scale_buttons_to_resolution
  end

  # Scale buttons based on the current resolution
  def scale_buttons_to_resolution
    return unless @board_frame # Only scale if the board_frame exists

    button_width, button_height = calculate_button_size
    TkWinfo.children(@board_frame).each do |widget|
      widget.configure("width" => button_width, "height" => button_height)
    end
  end

  # Calculate button size based on resolution
  def calculate_button_size
    case @current_resolution
    when "400x400"
      [10, 5]
    when "500x500"
      [15, 8]
    when "700x700"
      [20, 10]
    else
      [10, 5]
    end
  end

  # Handle button clicks during the game
  def click_button(row, col, mode)
    if @board[row][col].cget("text") == ""
      @board[row][col].configure("text" => @current_player, "fg" => @current_player == "X" ? "red" : "blue")
      check_win(mode)
      switch_player unless mode.start_with?("ai") && @current_player == "O"
      ai_move(mode) if mode.start_with?("ai") && @current_player == "O"
    end
  rescue => e
    Tk.messageBox('type' => 'ok', 'icon' => 'error', 'title' => 'Error', 'message' => "An error occurred: #{e.message}")
  end

  # AI makes a move based on difficulty level
  def ai_move(mode)
    empty_cells = @board.flatten.select { |button| button.cget("text") == "" }
    move = empty_cells.sample

    if mode == "ai_easy"
      move.configure("text" => "O", "fg" => "blue")
    elsif mode == "ai_medium"
      block_move = find_blocking_move
      move = block_move if block_move
      move.configure("text" => "O", "fg" => "blue")
    elsif mode == "ai_hard"
      move = find_best_move if respond_to?(:find_best_move)
      move.configure("text" => "O", "fg" => "blue")
    end
    check_win(mode)
    switch_player
  end

  # Find blocking move (for medium AI)
  def find_blocking_move
    # Check for winning moves
    winning_move = @board.flatten.find { |button| can_win_with_move?(button, "X") }
    return winning_move if winning_move
  
    # Check for blocking moves
    blocking_move = @board.flatten.find { |button| can_win_with_move?(button, "O") }
    return blocking_move if blocking_move
  
     # If no winning or blocking moves are found, return a random empty button
    empty_buttons = @board.flatten.select { |button| button.nil? || button == "" }
    return empty_buttons.sample if empty_buttons.any?
  end

  # Check if a move can lead to a win (for AI)
  def can_win_with_move?(button, player)
    original_text = button.cget("text")
    button.configure("text" => player)
    win = winning_combination?
    button.configure("text" => original_text)
    win
  end

  # Check if there's a winner
  def check_win(mode)
    if winning_combination?
      Tk.messageBox('type' => 'ok', 'icon' => 'info', 'title' => 'Game Over', 'message' => "#{@current_player} wins!")
      reset_game
    elsif board_full?
      Tk.messageBox('type' => 'ok', 'icon' => 'info', 'title' => 'Game Over', 'message' => "It's a draw!")
      reset_game
    end
  end

  # Check winning combinations
  def winning_combination?
    (0..2).any? { |i| @board[i][0].cget("text") == @board[i][1].cget("text") && @board[i][1].cget("text") == @board[i][2].cget("text") && @board[i][0].cget("text") != "" } ||
    (0..2).any? { |i| @board[0][i].cget("text") == @board[1][i].cget("text") && @board[1][i].cget("text") == @board[2][i].cget("text") && @board[0][i].cget("text") != "" } ||
    (@board[0][0].cget("text") == @board[1][1].cget("text") && @board[1][1].cget("text") == @board[2][2].cget("text") && @board[0][0].cget("text") != "") ||
    (@board[0][2].cget("text") == @board[1][1].cget("text") && @board[1][1].cget("text") == @board[2][0].cget("text") && @board[0][2].cget("text") != "")
  end

  # Check if the board is full
  def board_full?
    @board.all? { |row| row.all? { |button| button.cget("text") != "" } }
  end

  # Reset the game after a win or draw
  def reset_game
    @board_frame.pack_forget # Hide the board
    create_interface # Show the main interface again
  end

  # Switch the current player
  def switch_player
    @current_player = (@current_player == "X") ? "O" : "X"
  end

  # Bind the Escape key to show a confirmation dialog
  def bind_escape_key
    @root.bind("Escape") {
      if Tk.messageBox('type' => 'yesno', 'icon' => 'question', 'title' => 'Exit Game', 'message' => 'Do you want to go back to the main menu?') == 'yes'
        reset_game
      end
    }
  end

  # Show options menu to change resolution
  def show_options
    options_window = TkToplevel.new(@root) {
      title "Options"
      geometry "200x150"
    }

    TkLabel.new(options_window) {
      text "Choose Resolution:"
      pack "side" => "top", "pady" => 10
    }

    resolution_var = TkVariable.new
    resolutions = { "400x400" => "400x400", "500x500" => "500x500", "700x700" => "700x700" }

    TkOptionMenubutton.new(options_window, resolution_var, *resolutions.keys) {
      pack "side" => "top", "pady" => 10
    }

    apply_button = TkButton.new(options_window) {
      text "Apply"
      pack "side" => "top", "padx" => 20, "pady" => 10
    }
    apply_button.command {
      @current_resolution = resolutions[resolution_var.value]
      @root.geometry(@current_resolution)
      scale_buttons_to_resolution
      options_window.destroy
    }
  end

  # Show help information
  def show_help
    help_window = TkToplevel.new(@root) {
      title "Help"
      geometry "300x300"
    }

    TkLabel.new(help_window) {
      text "You probably already know how to play the game..."
      pack "side" => "top", "pady" => 20
    }

    TkLabel.new(help_window) {
      text "Authors:"
      font TkFont.new('times 14 bold')
      pack "side" => "top", "pady" => 10
    }

    TkLabel.new(help_window) {
      text "James\nCarl\nArmand\nJian Carlo"
      pack "side" => "top", "pady" => 5
    }

    close_button = TkButton.new(help_window) {
      text "Close"
      pack "side" => "top", "pady" => 10
    }
    close_button.command { help_window.destroy }
  end

  # Go back to the main menu
  def back_to_main_menu
    clear_previous_menu
    create_interface
  end

  # Exit the game
  def exit_game
    @root.destroy
  end

  # Run the game
  def run
    Tk.mainloop
  end
end

game = TicTacToe.new
game.run
