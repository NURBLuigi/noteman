#!/bin/bash
# Noteman: a notes management tool for college students taking notes using LaTeX

# Set up default configuration and template files for first-time users
make_config() {
  echo "No configuration file detected"
  echo "Creating default configuration..."

  curdir=$(pwd)
  mkdir -p ~/.config/noteman/templates/.default/style_files/
  cd ~/.config/noteman/
  touch noteman.conf

  echo "Storing default configuration in noteman.conf"
  echo "# Directory for notes to be stored in" >>noteman.conf
  echo "root_dir=~/Notes" >>noteman.conf
  echo "# Your text editor of choice" >>noteman.conf
  echo "editor=vim" >>noteman.conf
  echo "# Your pdf viewer of choice" >>noteman.conf
  echo "reader=zathura" >>noteman.conf
  echo "# LaTeX program to be used for initial compliation (pdfTeX, XeLaTeX, LuaTeX, etc.)" >>noteman.conf
  echo "latex_program=pdf" >>noteman.conf
  cd $curdir
}

make_template() {
  echo "No default template detected"
  echo "Creating default template file..."

  curdir=$(pwd)
  mkdir -p ~/.config/noteman/templates/.default/style_files/
  cd ~/.config/noteman/templates/.default
  touch template.tex

  echo "% Default notes template" >>template.tex
  echo "\documentclass[12pt]{article}" >>template.tex
  echo "\usepackage[margin=1in]{geometry}" >>template.tex
  echo "\usepackage{times}" >>template.tex
  echo "\usepackage{setspace}" >>template.tex
  echo "\usepackage{blindtext}" >>template.tex
  echo "" >>template.tex
  echo "\title{Default Notes Template}" >>template.tex
  echo "\author{Name\\\\ Subject}" >>template.tex
  echo "" >>template.tex
  echo "\begin{document}" >>template.tex
  echo "  \maketitle" >>template.tex
  echo "\end{document}" >>template.tex
  cd $curdir
}

if [ ! -e ~/.config/noteman/ ]; then
  make_config
  make_template
fi

# Load in configuration file
source ~/.config/noteman/noteman.conf

# Flag variables
edit_mode='false'
read_mode='false'
make_mode='false'
list_mode='false'
delete_mode='false'
interactive='false'
subject=''
note=''
chapter='' # Make mode only

# Usage to be printed in case of errors
print_usage() {
  printf "Usage:\n"
  printf "noteman <mode> -s <subject> -c <chapter> (only required for make mode) -n <note>\n"
  printf "_________________________________________________________________\n"
  printf "  [mode]   | [flag] |              [function]\n"
  printf "   edit    |   -e   | opens the .tex file in specified editor\n"
  printf "   read    |   -r   | opens the .pdf in specified pdf reader\n"
  printf "   make    |   -m   | makes a new brand new notespace\n"
  printf "  delete   |   -d   | removes the specified subject/chapter/note \n"
  printf "   list    |   -l   | lists the directory tree\n"
  printf "interactive|   -li  | list mode but with edit/read/make options\n"
  printf "_________________________________________________________________\n"
}

# Delete a subject/chapter/notespace
delete() {
  echo "The following directory be deleted:"
  echo "$1"
  read -p "This data cannot be recovered. Are you sure you want to continue? [y/n]: " option
  if [ $option = 'y' ]; then
    rm -rf $1
  fi
}

# Render a specific directory using tree
list_notes() {
  if [ ! -e $root_dir/$1/$2/$3 ]; then
    # Only show .tex and .md files
    echo "Error: No notespace named '$1/$2/$3'"
    exit 1
  fi

  # Print tree
  tree -P "*.tex|*.md" $root_dir/$1/$2/$3

  # Interactive mode interface
  if [ "$interactive" = 'true' ]; then
    read -p "What would you like to do <type up to move up a directory>: " opt arg1 arg2 arg3
    case "${opt:0:1}" in
    e)
      edit_mode='true'
      list_mode='false'
      ;;
    r)
      read_mode='true'
      list_mode='false'
      ;;
    m)
      make_mode='true'
      list_mode='false'
      ;;
    d)
      delete_mode='true'
      list_mode='false'
      ;;
    u)
      if [ $note ]; then
        note=''
      elif [ $chapter ]; then
        chapter=''
      elif [ $subject ]; then
        subject=''
      fi
      clear
      list_notes $subject $chapter $note
      ;;
    esac
    if [ "$make_mode" = 'true' ] || [ "$list_mode" = 'true' ]; then
      if [ -z $subject ]; then
        subject=$arg1
        chapter=$arg2
        note=$arg3
      elif [ -z $chapter ]; then
        chapter=$arg1
        note=$arg2
      else
        note=$arg1
      fi
    else
      if [ -z $arg2 ]; then
        note=$arg1
      elif [ $arg3 ]; then
        subject=$arg1
        chapter=$arg2
        note=$arg3
      else
        subject=$arg1
        note=$arg2
      fi
      search_dir $subject $note
    fi

    if [ "$list_mode" = 'true' ]; then
      clear
      list_notes $subject $chapter $note
    fi
  else # Interactive mode not set-- exit script
    exit 1
  fi
}

# Search a directory for instances of a notespace
search_dir() {
  curdir=$(pwd)
  cd "$root_dir/$1"
  for dir in *; do
    if [ -e "$dir/$2" ]; then
      chapter="$dir"
    fi
  done
  cd $curdir
}

# Copy templates over to the directory of your choosing

# Print the status of the script based on the mode declared
print_mode() {
  if [ ! "$1" = 'true' ]; then
    printf "Finding notespace '$4' in "
    if [ "$2" = 'true' ]; then
      printf "edit mode...\n"
    fi
    if [ "$3" = 'true' ]; then
      printf "read mode...\n"
    fi
  else
    echo "Creating new notespace '$4'..."
  fi
}

# Check if multiple modes are set and conflict with each other
check_conflicting_modes() {
  declare -i num_true=0 # Must be declared as an integer
  Modes=("$edit_mode" "$read_mode" "$make_mode" "$delete_mode" "$list_mode")

  # Loop through each mode
  for i in ${Modes[@]}; do
    if [ "$i" = 'true' ]; then
      num_true=$((num_true + 1))
    fi
  done

  # If the number of true instances is greater than one, exit the script
  if [[ $num_true > 1 ]]; then
    echo "Error: Conflicting modes (only one must be set!)"
    print_usage
    exit 1
  elif [[ $num_true == 0 ]]; then
    print_usage
    exit 1
  fi
}

# Procecss user flags
while getopts 'ermlids:n:c:' flag; do
  case "${flag}" in
  e) edit_mode='true' ;;
  r) read_mode='true' ;;
  m) make_mode='true' ;;
  l) list_mode='true' ;;
  d) delete_mode='true' ;;
  i) interactive='true' ;;
  s) subject="${OPTARG}" ;;
  n) note="${OPTARG}" ;;
  c) chapter="${OPTARG}" ;;
  *)
    print_usage
    exit 1
    ;;
  esac
done

# Make sure that only one mode is set
check_conflicting_modes

# Go through each directory and find the matching notespace
if [ $note ]; then
  search_dir $subject $note
fi

# Print the list if list mode is set to true
if [ "$list_mode" = 'true' ]; then
  list_notes $subject $chapter $note
fi

# Delete file if delete mode is set to true
if [ "$delete_mode" = 'true' ]; then
  delete "$root_dir/$subject/$chapter/$note"
  exit 1
fi

# Catch any syntax errors in calling the script
if [ -z $subject ]; then
  print_usage
  exit 1
fi

if [ -z $note ]; then
  print_usage
  exit 1
fi

# Otherwise, display the mode set by the user
print_mode $make_mode $edit_mode $read_mode $note

# If edit mode is on, use your editor, otherwise use your reader
if [ ! "$make_mode" = 'true' ]; then
  if [ -z $chapter ]; then
    echo "Error: Notespace '$note' does not exist!"
    exit 1
  fi

  notepath="$root_dir/$subject/$chapter/$note"
  echo "Notespace '$note' found in path $notepath"

  # Edit mode set -- open in specified text editor
  if [ "$edit_mode" = 'true' ]; then
    $editor "$notepath/$note.tex"
    exit 1
  fi

  # Read mode set -- open in specified pdf viewer
  if [ "$read_mode" = 'true' ]; then
    $reader "$notepath/$note.pdf" &
    exit 1
  fi
else
  # Avoid overwriting existing notes
  if [ -e "$root_dir/$subject/$chapter/$note" ]; then
    echo "Error: Notespace '$note' already exists!"
    exit 1
  fi

  # Create the new notespace
  echo "Creating notespace '$note'"
  mkdir -p $root_dir/$subject/$chapter/$note/
  notepath="$root_dir/$subject/$chapter/$note/"

  # Copy the template into your notes file -- if the user specified one in the .conf folder,
  # use that one
  if [ -e ~/.config/noteman/templates/"$subject" ]; then
    template_dir=$subject
    echo "Using user-defined template for $subject"
  else
    template_dir=".default"
    echo "Using default template"
    if [ ! -e ~/.config/noteman/templates/$template_dir/template.tex ]; then
      make_template
    fi
  fi
  cat ~/.config/noteman/templates/$template_dir/template.tex >>"$notepath/$note.tex"

  # Make a symbolic link to any style files included in the template
  curdir=$(pwd)
  cd ~/.config/noteman/templates/$template_dir
  if [ -e "style_files" ]; then
    cd "style_files"
    for i in *.sty; do
      ln -s ~/.config/noteman/templates/$template_dir/style_files/$i $notepath/$i
    done
  fi
  cd $curdir

  # Make the pdf rendered notes file with latexmk
  echo "Compiling pdf..."
  cd $notepath
  latexmk -$latex_program "$note.tex"
  cd $curdir

  # Open the newly created file in the specified editor
  $editor "$notepath/$note.tex"
fi
