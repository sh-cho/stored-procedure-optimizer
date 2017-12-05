import sys
from PyQt5 import QtCore
from PyQt5.QtWidgets import *
from PyQt5.QtGui import QIcon, QPixmap

TEXT_AREA_WIDTH = 400
TEXT_AREA_HEIGHT = 300
GLOBAL_PADDING = 5

class App(QWidget):
    def __init__(self):
        super().__init__()
        self.title = 'Enhancing parallelism of stored procedure'
        # self.left = 10
        # self.top = 10
        self.width = 852
        self.height = 380
        self.initUI()

    def initUI(self):
        #add combobox
        testcases_label = QLabel("Test case: ", self)
        testcases_label.move(GLOBAL_PADDING, GLOBAL_PADDING+3)
        self.testcases = QComboBox(self)
        self.testcases.addItem("-- select --")
        self.testcases.addItem("SAP Hana Express: IMDb")
        self.testcases.addItem("SAP Hana Express: TPC-DS")
        self.testcases.addItem("MariaDB: IMDb")
        self.testcases.addItem("MariaDB: TPC-DS")
        #self.testcases.addItem("PostgreSQL: IMDb")
        #self.testcases.addItem("PostgreSQL: TPC-DS")
        self.testcases.currentIndexChanged.connect(self.onComboboxChanged)
        self.testcases.move(GLOBAL_PADDING+70, GLOBAL_PADDING)

        #add text field
        self.txt1 = QTextBrowser(self)
        self.txt1.insertPlainText("<select test case>")
        self.txt1.move(GLOBAL_PADDING, 30)
        self.txt1.resize(TEXT_AREA_WIDTH, TEXT_AREA_HEIGHT)

        self.txt2 = QTextBrowser(self)
        self.txt2.insertPlainText("<select test case>")
        self.txt2.move(TEXT_AREA_WIDTH+GLOBAL_PADDING*3+32, 30)
        self.txt2.resize(TEXT_AREA_WIDTH, TEXT_AREA_HEIGHT)

        #add img
        self.arrow_label = QLabel(self)
        arrow_img = QPixmap('arrow.png')
        self.arrow_label.setPixmap(arrow_img)
        self.arrow_label.move(TEXT_AREA_WIDTH+GLOBAL_PADDING*2, TEXT_AREA_HEIGHT/2+30)

        #execute time field
        self.exec1 = QLabel("<execution_time1>", self)
        self.exec1.move(GLOBAL_PADDING+TEXT_AREA_WIDTH/2, 30+TEXT_AREA_HEIGHT+GLOBAL_PADDING*2)
        self.exec2 = QLabel("<execution_time2>", self)
        self.exec2.move(TEXT_AREA_WIDTH+GLOBAL_PADDING*2+TEXT_AREA_WIDTH/2, 30+TEXT_AREA_HEIGHT+GLOBAL_PADDING*2)

        #set size, title
        self.setFixedSize(self.width, self.height)
        self.setWindowTitle(self.title)
        self.show()

    def onComboboxChanged(self, index):
        # print("Items in the list are :")
        # for count in range(self.testcases.count()):
        #     print(self.testcases.itemText(count))
        print("Current index", index, "selection changed ", self.testcases.currentText())
        if index is 0:  #select
            self.txt1.setPlainText("<select test case>")
            self.txt2.setPlainText("<select test case>")
            self.exec1.setText("<execution_time1>")
            self.exec2.setText("<execution_time2>")
        elif index is 1:    #saphana-imdb
            with open("./procedures/saphana-imdb-before.sql", 'rb') as f1:
                s1 = f1.read().decode("UTF-8")
                self.txt1.setPlainText(s1)
            with open("./procedures/saphana-imdb-after.sql", 'rb') as f2:
                s2 = f2.read().decode("UTF-8")
                self.txt2.setPlainText(s2)
            self.exec1.setText("4.179s")
            self.exec2.setText("3.69s")
        elif index is 2:    #saphana-tpcds
            with open("./procedures/saphana-tpcds-before.sql", 'rb') as f1:
                s1 = f1.read().decode("UTF-8")
                self.txt1.setPlainText(s1)
            with open("./procedures/saphana-tpcds-after.sql", 'rb') as f2:
                s2 = f2.read().decode("UTF-8")
                self.txt2.setPlainText(s2)
            self.exec1.setText("4.685s")
            self.exec2.setText("3.489s")
        elif index is 3:    #mariadb-imdb
            with open("./procedures/mariadb-imdb-before.sql", 'r') as f1:
                s1 = f1.read()
                self.txt1.setPlainText(s1)
            with open("./procedures/mariadb-imdb-after.sql", 'r') as f2:
                s2 = f2.read()
                self.txt2.setPlainText(s2)
            self.exec1.setText("117.401s")
            self.exec2.setText("101.512s")
        elif index is 4:    #mariadb-tpcds
            with open("./procedures/mariadb-tpcds-before.sql", 'r') as f1:
                s1 = f1.read()
                self.txt1.setPlainText(s1)
            with open("./procedures/mariadb-tpcds-after.sql", 'r') as f2:
                s2 = f2.read()
                self.txt2.setPlainText(s2)
            self.exec1.setText("128.576s")
            self.exec2.setText("99.288s")
        elif index is 5:    #posgresql-imdb
            with open("./procedures/postgresql-imdb-before.sql", 'r') as f1:
                s1 = f1.read()
                self.txt1.setPlainText(s1)
            with open("./procedures/postgresql-imdb-after.sql", 'r') as f2:
                s2 = f2.read()
                self.txt2.setPlainText(s2)
            self.exec1.setText("72.316s")
            self.exec2.setText("61.412s")
        else: #index is 6:  #postgresql-tpcds
            with open("./procedures/postgresql-tpcds-before.sql", 'r') as f1:
                s1 = f1.read()
                self.txt1.setPlainText(s1)
            with open("./procedures/postgresql-tpcds-after.sql", 'r') as f2:
                s2 = f2.read()
                self.txt2.setPlainText(s2)
            self.exec1.setText("87.615s")
            self.exec2.setText("77.149s")

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = App()
    sys.exit(app.exec_())