import mysql.connector as msc
from mysql.connector import Error
import pandas as pd
import tkinter as tk
from tkinter import ttk

def server_connection(hostName, userName, userPassword, database):
    connection = None
    try:
        connection = msc.connect(
            host = hostName,
            user = userName,
            password = userPassword,
            db = database
        )
        print("connection successful")
    except Error as error:
        print(f"Error: '{error}'")
    return connection 

frameList = []
connection = server_connection("localhost", "root", "050901", "travel_reservation_service") # need to start server first - 3rd parameter is your password

def main():
    root = tk.Tk()
    root.geometry("500x500")
    root.title("Login")
    root.resizable(height = False, width = False)
    connection = server_connection("localhost", "root", "050901", "travel_reservation_service")

    loginSetUp(root)

    root.mainloop()

def login(root, email, password):
    print(email)

    cursor = connection.cursor()
    cursor.execute("select * from Accounts natural join Admins")
    for row in cursor.fetchall():
        if (email == row[0] and password == row[3]):
            frameList[0].pack_forget()
            del frameList[0]
            adminHomeSetUp(root)
            break
    cursor.close()
    
    cursor = connection.cursor()
    cursor.execute("select * from Accounts natural join Clients")
    for row in cursor.fetchall():
        if (email == row[0] and password == row[3]):
            frameList[0].pack_forget()
            del frameList[0]
            customerHomeSetUp(root)
            break
    cursor.close()
    
def logout(root):
    frameList[0].pack_forget()
    del frameList[0]
    loginSetUp(root)

def backAdmin(root):
    frameList[0].pack_forget()
    del frameList[0]
    adminHomeSetUp(root)
    
### VIEWS ###

def viewAirlines(root):
    root.title("View Airlines")
    frameList[0].pack_forget()
    del frameList[0]
    
    frame = tk.Frame(root, height = 500, width = 500)
    frameList.append(frame)
    
    label = tk.Label(frame, text = "View Airlines", font = ("Comic Sans MS", 20))
    label.place(x = 250, y = 60, anchor = tk.CENTER)
    
    backButton = tk.Button(frame, text = "Back", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 7,
                          command = lambda : backAdmin(root))
    backButton.place(x = 465, y = 20, anchor = tk.CENTER)
    
    cursor = connection.cursor()
    cursor.execute("select * from view_airlines")
    
    data = []
    for row in cursor.fetchall():
        data.append(row)
    cursor.close()
    
    columns = ["Name", "Rating", "Total Flights", "Minimum Flight Cost"]
    df = pd.DataFrame(data, columns = columns)
    
    tree = ttk.Treeview(frame, height = 400)
    tree.place(y = 100)
    
    displayTable(frame, tree, df, columns, 120)
    
    frame.pack()

def viewAirports(root):
    root.title("View Airports")
    frameList[0].pack_forget()
    del frameList[0]
    
    frame = tk.Frame(root, height = 500, width = 500)
    frameList.append(frame)
    
    label = tk.Label(frame, text = "View Airports", font = ("Comic Sans MS", 20))
    label.place(x = 250, y = 60, anchor = tk.CENTER)
    
    backButton = tk.Button(frame, text = "Back", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 7,
                          command = lambda : backAdmin(root))
    backButton.place(x = 465, y = 20, anchor = tk.CENTER)
    
    cursor = connection.cursor()
    cursor.execute("select Airport_Id, Airport_Name, Time_Zone, concat(Street, ', ', City, ', ', State, ' ', Zip) as 'Address' from Airport")
    
    data = []
    for row in cursor.fetchall():
        data.append(row)
    cursor.close()
    
    columns = ["ID", "Name", "Time Zone", "Address"]
    df = pd.DataFrame(data, columns = columns)
    
    tree = ttk.Treeview(frame, height = 400)
    tree.place(y = 100)
    
    displayTable(frame, tree, df, columns, 120)
    
    frame.pack()
    
def viewCustomers(root):
    root.title("View Customers")
    frameList[0].pack_forget()
    del frameList[0]
    
    frame = tk.Frame(root, height = 500, width = 500)
    frameList.append(frame)
    
    label = tk.Label(frame, text = "View Customers", font = ("Comic Sans MS", 20))
    label.place(x = 250, y = 60, anchor = tk.CENTER)
    
    backButton = tk.Button(frame, text = "Back", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 7,
                          command = lambda : backAdmin(root))
    backButton.place(x = 465, y = 20, anchor = tk.CENTER)
    
    cursor = connection.cursor()
    cursor.execute("select * from view_customers")
    
    data = []
    for row in cursor.fetchall():
        data.append(row)
    cursor.close()
    
    columns = ["Name", "Average Rating", "Location", "is Owner", "Total Seats Purchased"]
    df = pd.DataFrame(data, columns = columns)
    
    tree = ttk.Treeview(frame, height = 400)
    tree.place(y = 100)
    
    displayTable(frame, tree, df, columns, 96)
    
    frame.pack()
    
def viewOwners(root):
    root.title("View Owners")
    frameList[0].pack_forget()
    del frameList[0]
    
    frame = tk.Frame(root, height = 500, width = 500)
    frameList.append(frame)
    
    label = tk.Label(frame, text = "View Owners", font = ("Comic Sans MS", 20))
    label.place(x = 250, y = 60, anchor = tk.CENTER)
    
    backButton = tk.Button(frame, text = "Back", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 7,
                          command = lambda : backAdmin(root))
    backButton.place(x = 465, y = 20, anchor = tk.CENTER)
    
    cursor = connection.cursor()
    cursor.execute("select * from view_owners")
    
    data = []
    for row in cursor.fetchall():
        data.append(row)
    cursor.close()
    
    columns = ["Name", "Average Rating", "Number of Properties Ownered", "Average Property Rating"]
    df = pd.DataFrame(data, columns = columns)
    
    tree = ttk.Treeview(frame, height = 400)
    tree.place(y = 100)
    
    displayTable(frame, tree, df, columns, 120)
    
    frame.pack()

def processDate(root):
    root.title("Process Date")
    frameList[0].pack_forget()
    del frameList[0]
    
    frame = tk.Frame(root, height = 500, width = 500)
    frameList.append(frame)
    
    label = tk.Label(frame, text = "Process Date", font = ("Comic Sans MS", 20))
    label.place(x = 250, y = 60, anchor = tk.CENTER)
    
    backButton = tk.Button(frame, text = "Back", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 7,
                          command = lambda : backAdmin(root))
    backButton.place(x = 465, y = 20, anchor = tk.CENTER)
    
    label = tk.Label(frame, text = "Set Current\nSystem Date:", font = ("Comic Sans MS", 14))
    label.place(x = 170, y = 170, anchor = tk.E)
    
    entry = tk.Entry(frame, font = ("Comic Sans MS", 14), width = 20)
    entry.place(x = 180, y = 155)
    
    setButton = tk.Button(frame, text = "Set Date", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 7,
                          command = lambda : setDateButton(entry.get()))
    setButton.place(x = 390, y = 210, anchor = tk.CENTER)
    
    frame.pack()

def setDateButton(date):
    cursor = connection.cursor()
    cursor.callproc('process_date', [date])
    cursor.close()
    
    
### HELPER FUNCTION ###

def displayTable(frame, tree, df, columns, size):
    tree["column"] = columns
    tree["show"] = "headings"
    
    scroll = ttk.Scrollbar(orient = "vertical", command = tree.yview)
    tree.configure(yscrollcommand = scroll.set)
    scroll.place(x = 483, y = 100, height = 400)
    
    for column in tree["column"]:
        tree.heading(column, text = column)
        tree.column(column, width = size)

    df_rows = df.to_numpy().tolist()
    for row in df_rows:
        tree.insert("", "end", values = row)
    
    
### FRAME SET UP BELOW ###

def loginSetUp(root):
        root.title("Login")
        frame = tk.Frame(root, height = 500, width = 500)
        frameList.append(frame)

        logLabel = tk.Label(frame, text = "Login", font = ("Comic Sans MS", 20))
        logLabel.place(x = 250, y = 100, anchor = tk.CENTER)

        emailLabel = tk.Label(frame, text = "Email:", font = ("Comic Sans MS", 14))
        emailLabel.place(x = 170, y = 170, anchor = tk.E)

        passLabel = tk.Label(frame, text = "Password:", font = ("Comic Sans MS", 14))
        passLabel.place(x = 170, y = 220, anchor = tk.E)

        emailEntry = tk.Entry(frame, font = ("Comic Sans MS", 14), width = 20)
        emailEntry.place(x = 180, y = 155)

        passEntry = tk.Entry(frame, font = ("Comic Sans MS", 14), width = 20)
        passEntry.place(x = 180, y = 205)

        loginButton = tk.Button(frame, text = "Login", font = ("Comic Sans MS", 12), fg = "white", bg = "black", width = 8,
                               command = lambda : login(root, emailEntry.get(), passEntry.get()))
        loginButton.place(x = 250, y = 280, anchor = tk.CENTER)

        registerLabel = tk.Label(frame, text = "Not signed up?", font = ("Comic Sans MS", 10))
        registerLabel.place(x = 250, y = 320, anchor = tk.CENTER)

        registerButton = tk.Button(frame, text = "Register", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 7)
        registerButton.place(x = 250, y = 350, anchor = tk.CENTER)

        frame.pack()

def adminHomeSetUp(root):
    root.title("Admin Home")
    frame = tk.Frame(root, height = 500, width = 500)
    frameList.append(frame)

    homeLabel = tk.Label(frame, text = "Admin Home", font = ("Comic Sans MS", 20))
    homeLabel.place(x = 250, y = 100, anchor = tk.CENTER)

    scheduleFlightButton = tk.Button(frame, text = "Schedule\nFlight", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8)
    scheduleFlightButton.place(x = 125, y = 180, anchor = tk.CENTER)

    removeFlightButton = tk.Button(frame, text = "Remove\nFlight", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8)
    removeFlightButton.place(x = 250, y = 180, anchor = tk.CENTER)

    processDateButton = tk.Button(frame, text = "Process\nDate", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8,
                                 command = lambda : processDate(root))
    processDateButton.place(x = 375, y = 180, anchor = tk.CENTER)

    viewAirportsButton = tk.Button(frame, text = "View\nAirports", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8,
                                  command = lambda : viewAirports(root))
    viewAirportsButton.place(x = 187.5, y = 270, anchor = tk.CENTER)

    viewAirlinesButton = tk.Button(frame, text = "View\nAirlines", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8,
                                  command = lambda : viewAirlines(root))
    viewAirlinesButton.place(x = 312.5, y = 270, anchor = tk.CENTER)

    viewCustomersButton = tk.Button(frame, text = "View\nCustomers", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8,
                                   command = lambda : viewCustomers(root))
    viewCustomersButton.place(x = 187.5, y = 360, anchor = tk.CENTER)

    viewOwnersButton = tk.Button(frame, text = "View\nOwners", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8,
                                command = lambda : viewOwners(root))
    viewOwnersButton.place(x = 312.5, y = 360, anchor = tk.CENTER)
    
    logoutButton = tk.Button(frame, text = "Logout", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8,
                            command = lambda : logout(root))
    logoutButton.place(x = 250, y = 450, anchor = tk.CENTER)

    frame.pack()
    
def customerHomeSetUp(root):
    root.title("Customer Home")
    frame = tk.Frame(root, height = 500, width = 500)
    frameList.append(frame)

    homeLabel = tk.Label(frame, text = "Customer Home", font = ("Comic Sans MS", 20))
    homeLabel.place(x = 250, y = 100, anchor = tk.CENTER)

    bookFlightButton = tk.Button(frame, text = "Book\nFlight", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8)
    bookFlightButton.place(x = 187.5, y = 180, anchor = tk.CENTER)

    cancelFlightButton = tk.Button(frame, text = "Cancel\nFlight", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8)
    cancelFlightButton.place(x = 312.5, y = 180, anchor = tk.CENTER)

    viewPropertiesButton = tk.Button(frame, text = "View\nProperties", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8)
    viewPropertiesButton.place(x = 125, y = 250, anchor = tk.CENTER)

    reservePropertyButton = tk.Button(frame, text = "Reserve\nProperty", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8)
    reservePropertyButton.place(x = 250, y = 250, anchor = tk.CENTER)

    cancelReservationButton = tk.Button(frame, text = "Cancel\nReservation", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8)
    cancelReservationButton.place(x = 375, y = 250, anchor = tk.CENTER)

    reviewPropertyButton = tk.Button(frame, text = "Review\nProperty", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8)
    reviewPropertyButton.place(x = 125, y = 320, anchor = tk.CENTER)

    viewReservationButton = tk.Button(frame, text = "View\nReservation", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8)
    viewReservationButton.place(x = 250, y = 320, anchor = tk.CENTER)
    
    rateOwnerButton = tk.Button(frame, text = "View\nReservation", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8)
    rateOwnerButton.place(x = 375, y = 320, anchor = tk.CENTER)
    
    logoutButton = tk.Button(frame, text = "Logout", font = ("Comic Sans MS", 10), fg = "white", bg = "black", width = 8,
                            command = lambda : logout(root))
    logoutButton.place(x = 250, y = 390, anchor = tk.CENTER)

    frame.pack()

main()