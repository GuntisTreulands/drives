# Import openyxl module
import openpyxl
import os

# Define variable to load the wookbook
wookbook = openpyxl.load_workbook("gpstracker_languages.xlsx", data_only=True, read_only=True)

# Define variable to read the active sheet:
worksheet = wookbook.active

if not os.path.isdir("GPSTracker"):
    os.mkdir("GPSTracker")

if not os.path.isdir("GPSTracker/Localization"):
    os.mkdir("GPSTracker/Localization")

names = ["en", "lv", "ru"]

columnIndex = 2

for name in names :
    print("language2: " + name)

    title = ""
    fileContents = "\n\n//\tPLEASE DON'T EDIT THIS FILE!! EDIT gpstracker_languages.xlsx\n//\tThis file will be automatically generated upon project build.\n\n\n//\tLocalizable.strings"
    language = ""
    rowIndex = 0
    for row in worksheet.rows:
        firstCell = row[1]
        secondCell = row[columnIndex]
        if rowIndex == 0 :
            if not os.path.isdir("GPSTracker/Localization/" + name + ".lproj"):
                os.mkdir("GPSTracker/Localization/" + name + ".lproj")
        elif firstCell.value and secondCell.value : # Case, when it is code=text
            fileContents += "\"" + firstCell.value + "\" = "
            fileContents += "\"" + secondCell.value + "\";\n"
        elif firstCell.value :  # Separator part.
            if len(title) > 0:
                 fileContents += "//=== " + title + "\n"

            title = firstCell.value.replace("#", "")   
            fileContents += "\n\n//--- " + title + "\n"
        else :
            fileContents += "\n"

        rowIndex += 1
    
    columnIndex += 1
    
    fileContents += "//--- " + title + "\n"
    with open("GPSTracker/Localization/" + name + '.lproj/Localizable.strings', 'w') as f:
        f.write(fileContents)
