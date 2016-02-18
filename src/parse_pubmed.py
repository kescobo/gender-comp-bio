#!/usr/local/bin/ptyhon3

import xml.etree.ElementTree as ET


def get_authors(xml_file):
    tree = ET.parse(xml_file)
    print(tree.getroot())

if __name__ == '__main__':
    import sys
    get_authors(sys.argv[1])
