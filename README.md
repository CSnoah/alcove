alcove - a small, recessed section of a room or wall that is set back further than the surrounding surface.


# Purpose

I built alcove to display images in the bottom right of the terminal. This is mainly for images that have a transparent background.

 # Setup

1. Clone the repo in an appropriate location(Recommended: ~/.local/bin/alcove)
2. Run Setup.sh with: bash setup.sh
3. Restart the terminal

# Modes

There are three modes: bg, icon, dule. All the commands apply to the mode your currently in.

- bg - sets a background image on bottom left

- icon - also sets a background image on bottom left. Since it modifies vars in the kitty config it resets the terminals zoom.

- dule - can view both bg and icon layers simultaneously

# Commands

alcove <path|file> - sets the current image

alcove on - turns image on

alcove off - turns image off

alcove set-mode - sets the current mode

alcove set-size <Width Height|value> - bg mode(`<Width> <Hight>`), icon mode(`<value>`)

alcove config - prints the config

# Inspiration

I found the most convenient location for an image to be displayed in the terminal is the bottom right corner. Text rarely ever appears there. I was searching for a quick 
way to render images specifically in that portion of the window. I also wanted a manager for displaying, swapping, and removing the image being displayed. 
Sometimes it's not very appropriate to display an image, so having a quick way to toggle the image on and off was a major motivational factor.

# What is it?

Mainly a wrapper for the image rendering portion of the kitty remote control protocol. The application leverages the functions set-window-logo(icon mode) and
set-background-image(bg mode) to actively change the image being rendered to the terminal. In bg mode the magic utility is used as a dependency for concatenating 
a full canvas transparent image with a resizable target image. The target image can be positioned anywhere, due to the power of the magic utility. 
Alcove specifically places the image on the bottom right corner of the transparent image. This was necessary for bg mode since set-background-image doesn't provide
a way for moving the image.

# Support

- The kitty terminal

# Config

- CONF_ALCOVE_CURRENT_BG_IMAGE_PATH - this variable is added out of convenience for the user. The variable  allows operations to occur without the userconstantly having
to provide the image path. The variable only applies to bg mode since icon mode relies on kitty to remember the current image, and utilzes the kitty config edit things
like the image's current size.

- CONF_ALCOVE_IMAGE_DIR - Establishes the location for the pool of images. Allows the user to enter a file name instead of a file path.
  
- CONF_ALCOVE_PROGM_DIR - Internal use for operations that require program file path. This allows you to put the program anywhere on your system.

- CONF_ALCOVE_BG_IMAGE_PATH - Used in bg mode. Stores the path to the image that the magic utility generates.

- CONF_ALCOVE_DEFAULT_MODE - Persistence of current mode.

# Issues

The socket used to communicate with the kitty remote control protocol often gets auto terminated during long terminal sessions. Use of tmux also often causes this to occur.
I have not yet found a solution for creating and binding a new socket in the current terminal process. Currently the easiest fix is to just restart the terminal. 
This is also the reason you must restart the terminal after running setup.sh.
