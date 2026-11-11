# Noteman
An all-in-one command line notes manager made for college students writing their notes in LaTeX

## Features
- Edit/read/create/delete notes without the friction of command line navigation
- Automatically detect notes based on subject without having to specify the chapter
- Interactive navigation using tree
- Customizable templates on a per-subject basis

## Installation
### Dependencies
- ```latexmk``` for compiling latex
- ```tree``` for displaying notes
- Any text editor (default: vim)
- Any pdf viewer (default: zathura)
- Any LaTeX program (default: pdfTeX)

### Manual
```bash
mkdir -p ~/.local/bin
curl -o ~/.local/bin/noteman https://raw.githubusercontent.com/NURBLuigi/noteman/noteman.sh
chmod +x ~/.local/bin/ytsurf
```

## Usage
### Upon installation
Simply run
```bash
noteman
```
and all of the necessary configuration files will be generated in ```~/.config/noteman/```

It is recommended to go on and edit the configuration file to your likings especially if you do not want your note stored in your home directory or you use a text editor/pdf viewer other than vim or zathura.

**Default configuration:**
```bash
# ~/.config/noteman/noteman.conf

# Directory for notes to be stored in
root_dir=~/Notes

# Your text editor of choice
editor=vim

# Your pdf viewer of choice
reader=zathura

# LaTeX program to be used for initial compliation (pdfTeX, XeLaTeX, LuaTeX, etc.)
latex_program=pdf
```

### Basic usage
For optimal organization, all notes follow the template:
```bash
├── SUBJECT
│   ├── CHAPTER
│   │   ├── NOTES
│   │   │   └── NOTES.tex
```

Here is the screen for general usage:
```bash
Usage:
noteman <mode> -s <subject> -c <chapter> (only required for make mode) -n <note>
_________________________________________________________________
  [mode]   | [flag] |              [function]
   edit    |   -e   | opens the .tex file in specified editor
   read    |   -r   | opens the .pdf in specified pdf reader
   make    |   -m   | makes a new brand new notespace
  delete   |   -d   | removes the specified subject/chapter/note 
   list    |   -l   | lists the directory tree
interactive|   -li  | list mode but with edit/read/make options
_________________________________________________________________
```
**Examples:**
```noteman -rs PHYS -n Entropy``` will open up the notes titled "Entropy" under the subject "PHYS" in your pdf viewer

```noteman -es HIST -n Industrialization``` will edit the notes titled "Industrialization" under the subject "HIST" in your text editor

```noteman -ds MATH -n Optimization``` will prompt the user y/n if they would like to delete the notes titled "Optimization" under the subject "MATH"

```noteman -ms ELEN -c ch6 -n Impedance_Matching``` will create a new notespace titled "Impedance_Matching" under subject ELEN and chapter "ch6", creating all necessary parent directories in the process

```noteman -li``` will list all of your notes in interactive mode

***In interactive mode:***
All commands follow the format ```cmd arg1 arg2 arg3```, or you may optionally type ```up``` to move up a directory.

- Commands are the same as the ones from above just not as a flag (ex. read, write, make, list, delete)
- Your arguments depend on the directory that you are in just like in normal command like navigation.
  - ex. If you are inside a subject directory and in make mode, you must type ```make [chapter] [note]``` to create a new notespace
  - If you are in any other mode, then ```[command] [subject] [note]``` or ```[command] [note]``` if you are inside of a subject directory will suffice since notes are automatically detected regardless of chapter

## Templates and Customization
One of the other features is the option to load in custom LaTeX templates on a per-subject basis whenever you create a new notespace. All templates are stored in 
```.config/noteman/templates/```. 

### Changing the default template
If you want to change the default template, navigate to ```.config/noteman/templates/.default/``` and edit ```template.tex```.

### Creating a subject-exclusive template
To create a subject exclusive template follow these steps:

1. Create a new directory in ```.config/noteman/templates/``` that shares the same name as the directory for that subject in your notes
  - ex. ```.../templates/PHYS```
2. Inside of your new directory, create a new file called ```template.tex``` and add whatever you want to include in your template.
3. If your template requires any custom .sty files, create another directory called ```style_files``` and place any of the .sty files your template requires. If the script detects anything inside of that directory, then it will automatically create symbolic links to every .sty file it found, meaning that including the full path in your \usepackage statement is unnecessary.
