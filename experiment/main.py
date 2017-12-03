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
        self.height = 768
        self.initUI()

    def initUI(self):
        #add combobox
        testcases_label = QLabel("Test case: ", self)
        testcases_label.move(GLOBAL_PADDING, GLOBAL_PADDING+3)
        self.testcases = QComboBox(self)
        self.testcases.addItem("SAP Hana Express: IMDb")
        self.testcases.addItem("SAP Hana Express: TPC-DS")
        self.testcases.addItem("MariaDB: IMDb")
        self.testcases.addItem("MariaDB: TPC-DS")
        self.testcases.addItem("PostgreSQL: IMDb")
        self.testcases.addItem("PostgreSQL: TPC-DS")
        self.testcases.currentIndexChanged.connect(self.onComboboxChanged)
        self.testcases.move(GLOBAL_PADDING+70, GLOBAL_PADDING)

        #add text field
        self.txt1 = QTextBrowser(self)
        self.txt1.insertPlainText("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin viverra luctus accumsan. Ut volutpat neque ac suscipit cursus. Nam sollicitudin facilisis magna at laoreet. Integer fermentum dui quis odio vulputate consectetur. Sed quis tristique erat. Integer et hendrerit massa. Duis leo tortor, tincidunt vitae diam ac, tempor semper augue. Nam iaculis placerat justo, eget suscipit erat facilisis eu. Aenean venenatis rhoncus viverra. Mauris id placerat magna. Nullam gravida ex ut risus ullamcorper, vitae interdum lacus cursus. Suspendisse maximus nisi in quam sodales iaculis. Cras dictum posuere quam. Suspendisse sit amet diam in lacus congue ultricies vitae non eros. Vivamus ut dolor a libero tristique commodo quis vel tortor.\nQuisque vitae urna vel nulla blandit auctor eget sed neque. Maecenas vitae scelerisque ante, nec ornare ipsum. Aenean gravida tincidunt neque, ac finibus metus. Curabitur sagittis, ex sed sollicitudin luctus, massa purus vehicula quam, a pulvinar est dolor ac nunc. Proin mollis tincidunt facilisis. Praesent in ipsum in lacus maximus vehicula vitae sed odio. Ut non orci dapibus, consectetur orci ut, posuere nulla. Pellentesque sollicitudin pellentesque tristique. Donec facilisis, lectus a sagittis porttitor, nisi orci ornare erat, at viverra mauris nisi at diam. In tristique risus vitae dolor dictum, ut pellentesque elit lobortis. Morbi eu sodales sapien, ut tincidunt odio. Etiam varius enim id tortor ultrices, eget commodo nibh semper. Sed purus magna, placerat at ligula non, interdum blandit tortor. Pellentesque ante tortor, eleifend non neque id, sodales semper ipsum. Duis sed enim nec arcu viverra venenatis. Integer at porttitor nisl, eu elementum nisi.")
        self.txt1.move(GLOBAL_PADDING, 30)
        self.txt1.resize(TEXT_AREA_WIDTH, TEXT_AREA_HEIGHT)

        self.txt2 = QTextBrowser(self)
        self.txt2.insertPlainText(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin viverra luctus accumsan. Ut volutpat neque ac suscipit cursus. Nam sollicitudin facilisis magna at laoreet. Integer fermentum dui quis odio vulputate consectetur. Sed quis tristique erat. Integer et hendrerit massa. Duis leo tortor, tincidunt vitae diam ac, tempor semper augue. Nam iaculis placerat justo, eget suscipit erat facilisis eu. Aenean venenatis rhoncus viverra. Mauris id placerat magna. Nullam gravida ex ut risus ullamcorper, vitae interdum lacus cursus. Suspendisse maximus nisi in quam sodales iaculis. Cras dictum posuere quam. Suspendisse sit amet diam in lacus congue ultricies vitae non eros. Vivamus ut dolor a libero tristique commodo quis vel tortor.\nQuisque vitae urna vel nulla blandit auctor eget sed neque. Maecenas vitae scelerisque ante, nec ornare ipsum. Aenean gravida tincidunt neque, ac finibus metus. Curabitur sagittis, ex sed sollicitudin luctus, massa purus vehicula quam, a pulvinar est dolor ac nunc. Proin mollis tincidunt facilisis. Praesent in ipsum in lacus maximus vehicula vitae sed odio. Ut non orci dapibus, consectetur orci ut, posuere nulla. Pellentesque sollicitudin pellentesque tristique. Donec facilisis, lectus a sagittis porttitor, nisi orci ornare erat, at viverra mauris nisi at diam. In tristique risus vitae dolor dictum, ut pellentesque elit lobortis. Morbi eu sodales sapien, ut tincidunt odio. Etiam varius enim id tortor ultrices, eget commodo nibh semper. Sed purus magna, placerat at ligula non, interdum blandit tortor. Pellentesque ante tortor, eleifend non neque id, sodales semper ipsum. Duis sed enim nec arcu viverra venenatis. Integer at porttitor nisl, eu elementum nisi.")
        self.txt2.move(TEXT_AREA_WIDTH+GLOBAL_PADDING*3+32, 30)
        self.txt2.resize(TEXT_AREA_WIDTH, TEXT_AREA_HEIGHT)

        #add img
        self.arrow_label = QLabel(self)
        arrow_img = QPixmap('arrow.png')
        self.arrow_label.setPixmap(arrow_img)
        self.arrow_label.move(TEXT_AREA_WIDTH+GLOBAL_PADDING*2, TEXT_AREA_HEIGHT/2+30)

        #set size, title
        self.setFixedSize(self.width, self.height)
        self.setWindowTitle(self.title)
        self.show()

    def onComboboxChanged(self, index):
        # print("Items in the list are :")
        # for count in range(self.testcases.count()):
        #     print(self.testcases.itemText(count))
        print("Current index", index, "selection changed ", self.testcases.currentText())

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = App()
    sys.exit(app.exec_())