# Noteman
An lightweight command line notes manager made for college students writing their notes in LaTeX

## Features
- Edit/read/create/delete notespaces without the friction of command line navigation
- Automatically detect notes based on subject without having to specify the chapter
- Interactive navigation using tree
- Customizable templates on a per-subject basis
- Sync across multiple devices under your own private GitHub repository

## Installation
### Dependencies
- ```latexmk``` for compiling TeX
- ```tree``` for displaying notes
- ```git``` for accessing remote repositories
- Any text editor (default: vim)
- Any pdf viewer (default: zathura)
- Any LaTeX program (default: pdfTeX)

### Manual
```bash
mkdir -p ~/.local/bin
curl -o ~/.local/bin/noteman https://raw.githubusercontent.com/NURBLuigi/noteman/noteman.sh
chmod +x ~/.local/bin/noteman
```

## Usage
### Upon installation
Simply run
```bash
noteman
```
and all necessary configuration variables will be generated in ```~/.config/noteman.conf```

It is recommended to go on and edit the configuration file to your likings especially if you do not want your notes stored in your home directory or you use a text editor/pdf viewer other than vim or zathura.

**Default configuration:**
```bash
# ~/.config/noteman.conf

# Directory for notes to be stored in
root_dir=~/.noteman/Notes

# Your text editor of choice
editor=vim

# Your pdf viewer of choice
reader=zathura

# LaTeX program to be used for initial compliation (pdfTeX, XeLaTeX, LuaTeX, etc.)
latex_program=pdf
```

### Basic usage
For optimal organization, all notes follow the template:
```
├── SUBJECT
│   ├── CHAPTER
│   │   ├── NOTES
│   │   │   └── NOTES.tex
```

Here is the screen for general usage:
```
Usage:
noteman <mode> -s <subject> -c <chapter> (only required for make mode) -n <note> -M <commit message> (only for pushing notes to your github repo)
╭───────────┬────────┬─────────────────────────────────────────────────────────────────────╮
│  [mode]   │ [flag] │                             [function]                              │
├───────────┼────────┼─────────────────────────────────────────────────────────────────────┤
│   edit    │   -e   │               opens the .tex file in specified editor               │
│   read    │   -r   │               opens the .pdf in specified pdf reader                │
│   make    │   -m   │                   makes a new brand new notespace                   │
│  delete   │   -d   │             removes the specified subject/chapter/note              │
│   list    │   -l   │                      lists the directory tree                       │
│interactive│   -li  │              list mode but with edit/read/make options              │
│   push    │   -p   │            pushes notes to a specified github repository            │
│   sync    │   -S   │          pulls files from your speficied github repository          │
│  revert   │   -R   │      reverts to the last commit from your connected repository      │
│  update   │   -u   │              updates the script to the latest version               │
╰───────────┴────────┴─────────────────────────────────────────────────────────────────────╯
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
One of the other features is the option to load in custom LaTeX templates on a per-subject basis whenever you create a new notespace. All templates are stored in the root directory designated in ```noteman.conf``` under
```.templates/```. 

### Changing the default template
If you want to change the default template, navigate to ```.templates/.default/``` and edit ```template.tex```.

### Creating a subject-exclusive template
To create a subject exclusive template follow these steps:

1. Create a new directory in ```.templates/``` that shares the same name as the directory for that subject in your notes
  - ex. ```.templates/PHYS```
2. Inside of your new directory, create a new file called ```template.tex``` and add whatever you want to include in your template.
3. If your template requires any custom .sty files, create another directory called ```style_files``` and place any of the .sty files your template requires. If the script detects anything inside of that directory, then it will automatically create symbolic links to every .sty file it found, meaning that including the full path in your \usepackage statement is unnecessary.

## Syncing Across Multiple Devices with GitHub
### Generating an ssh key
To sync across multiple devices or store backups of your notes on a private GitHub repository, you must first generate your own ssh authentication key and configure git to access your private repos from the command line. If you have done this already, you may skip to the next section. If you haven't yet, then follow these steps:

1. Configure git by adding your GitHub username and email:
  ```bash
    git config --global user.name "[Your Username]"
    git config --global user.email "[Your Email]"
  ```

2. Run ```ssh-keygen -t ed25519 -C "email@example.com"``` where ```email@example.com``` is the email address connected to your GitHub account. Follow the prompts it gives you. Password is only optional.

3. Start your ssh agent:
  ```bash
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_xxxxxxx
  ```
  - Replace ```xxxxxxx``` with the sequence of numbers and letters that your ssh key stored in ```~/.ssh/``` uses (the one without the .pub extension).

4. Open GitHub in your browser and navigate to Settings/SSH and GPG keys

5. Click "New ssh key", name it, and paste the contents of ```~/.ssh/id_xxxxxxx.pub``` in the large text box. Make sure that the key type is "Authentication Key" and not "Signing Key".

6. Click "Add SSH key" and you should now be able to access your private repositories from the command line.

### Pushing Notes onto your Private Repository
If you already have a Notes directory, you may convert it to a git repository and push it to your own private repo:

1. Create a new private GitHub repository

2. Run ```noteman -p```

3. You will be asked for the link to your repository. Please enter the **SSH** link and not the **HTTPS** link. _eg. git@github.com:Tux/Notes.git_

Now whenever you run ```noteman -p```, all of your notes will be pushed onto your private repository. One of the many benefits of this is the access to backups. For instance, if you accidentally delete all of your notes from a specific subject or make a change that you did not intend, simply run ```noteman -R``` and your notes will be restored to the previous commit.

> [!NOTE]
> You may optionally auto-push your notes to the repo whenever you close your editor by adding ```gh_autopush=1```
> to ```~/.config/noteman.conf```.

### Syncing Notes with Another Device
Another benefit of storing your notes on a private repository is the ability to edit notes across multiple devices:

1. Follow the same steps listed in [generating an ssh key](#Generating-an-ssh-key) to give your new device remote access to your private GitHub repositories.

2. Run ```noteman``` and you will be asked if you want to clone from an existing repository. Choose 'Y'.

3. You may then enter the link to your private repository. Like in the last section, make sure you use the **SSH** link for remote access.

4. All of the notes from your private repository should now be cloned over to your root notes directory.

Now whenever you run ```noteman -S```, your notes will be synced with your private repository.

## Updating
To update to the latest version of the script, run:
```bash
sudo noteman -u
```
