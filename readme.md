22nd July 2020

Initialization of hangman readme.

Currently in planning stage.

___
22nd July 2020 cont

- Pseudocode complete
- Successfully generating a word between 5 and 12 characters from the string file and transforming it into a blank string in the test code
- Nothing committed to main file yet
- Tomorrow will continue on piecing together bits from the pseudocode in the test code file

___
23rd July

Okay so I'll be taking my time with this one. I will be making this alongside reading and learning from Practical Object-Oriented Design by Sandi Metz, and applying concepts I learn along the way.

Of course I'll not be as good as the examples in the book in terms of avoiding dependency, but I can set myself these 3 rules to follow:

- Ensure methods only have 1 purpose
- Ensure classes only have 1 purpose
- Ensure no method is more than 10 lines long

If I can abide by those 3 rules and successfully implement concepts from POODR along the way, it's a success and a step forward in my programming

Fleshed out the UI today. Will read more POODR and implement where I can.

___
25th July

I haven't been doing nothing!

I've been reading POODR and implementing lessons learned from that to the test code as well as I can for now, and I've been looking up how to make UMLs.

The test code is coming along nicely. So far no methods longer than 10 lines, I have established an implied game loop through the use of methods calling each other appropriately, when the user presses a key it instantly responds instead of having to 'enter' via the use of require 'io/console'. Small steps forward, both in learning techniques and writing cleaner code.

When the game is playable without the save/load functions, I'll call that version one. I'll have the connections and wiring in place though, so if someone chooses a save or load screen I will say it is 'under construction' and give them the option to quit or go back to the game screen for now.

One 'must do' when this is finished is to compare the code to my highlighted notes in POODR.

___
26th July

EXCELLENT progress today!

- v1 complete: a working standalone game. No save or load functions working, but you can play a single functioning game of hangman
- v2 in progress: save function working and operational, load screen can list the saved files. Just need to implement where the user presses the number of the file they want to load. Find a way to use an array to select the saved file somehow. Also need to display a little hang man. Not much. Just simple. To satisfy the hardcore hangman fanbase

___
27th July

Wahey!

v2 is complete! Save and load functions now working very well, as are all rescues and logic checks.
I could spend more time displaying the hangman but it's not a requirement, and I would just be putsing another graphic if @guesses_remaining = n.
What I will do, however, is refactor my code according to what I've learned from POODR. There are 2 methods longer than 10 lines, plus I need to see how I can make the parts more independent. But overall happy with it!



