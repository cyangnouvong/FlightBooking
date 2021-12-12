### APP SETUP AND EXECUTION INSTRUCTIONS ### 
1) Ensure all dependencies (mysql.connector, pandas, tkinter, datetime) are on computer
2) Ensure that you have some way of running Jupyter Notebook files (whether through Jupyter itself or through an IDE extension)
3) Open the Jupyter Notebook file (phase4.ipynb). In the third cell (labeled Main Method), there is a connection string. 
	Change the password attribute to YOUR password to access your localhost. Do not change anything else.
4) Run every cell. Ensure that after the third cell (containing the main method) you see a "connection successful" message.
5) If you do not see the application popup after running each cell, go into the last cell, type main(), and run that.


### TECHNOLOGIES USED ###
This application is Python-based, and uses:
	- mysql.connector: this connects the application to the database and allows for the database to be read and updated
	- tkinter: this is used to create the GUI that the user interacts with in the application
Each procedure/view is connected to a button on the appropriate home screen (Owner, Customer, Admin). The button determines
which procedure/view is going to be executed, and the database itself determines if the appropriate command can be executed
(e.g. if a user attempts to add a property, they click the "add property" button if it's available to them. If the button is
not present on their home screen, they lack the authority to add a property. If the user attempts to add a property but doesn't
add a required component, the database will not execute the function.)

### WORK DISTRUBUTION ###
Work was distributed evenly among all group members. All group members had access to a private Github repository where they
pushed any changes made such that work could be done efficiently, without anyone working on the same component at the same time.