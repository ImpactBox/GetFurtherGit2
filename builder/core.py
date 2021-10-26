import os
import xml.etree.ElementTree as ET

from shutil import copytree, ignore_patterns, rmtree

ET.register_namespace('', "http://soap.sforce.com/2006/04/metadata")

class BuildDirectory:

    def __init__(self, dir_path):
        self.path = dir_path

    def remove_active_flows(self, flows_path):
        if not os.path.exists(flows_path):
            return

        target_flows = os.listdir(flows_path)
        flows_with_version = {}


        ## Remove active versions from build/flows
        BUILD_FLOWS_PATH = os.path.join(self.path, 'flows')
        flows = os.listdir(BUILD_FLOWS_PATH)
        print(flows)

        flows_to_remove_from_package = []

        for flow in flows:
            if flow in target_flows:
                print("removing flow")
                os.remove(os.path.join(BUILD_FLOWS_PATH, flow))
                flows_to_remove_from_package.append(flow.split('.')[0])

        ## Remove reference to active flows in build/package.xml
        PACKAGE_PATH = os.path.join(self.path, 'package.xml')
        package_file = MetadataFile(PACKAGE_PATH)
        print("removing flows")
        print(flows_to_remove_from_package)
        package_file.remove_from_package('types', 'name', 'Flow', flows_to_remove_from_package)
        package_file.update()

    def remove_file(self, fp):
        if os.path.exists(fp):
            os.remove(fp)

    def remove_elements(self, dir, element, attrib, attrib_value):
        files = os.listdir(dir)
        for f in files:
            file = MetadataFile(dir + '/' + f)
            file.remove_by_attribute(element, attrib, attrib_value)
            file.update()

    def remove_element(self, fp, element, attrib, attrib_value):
        file = MetadataFile(fp)
        file.remove_by_attribute(element, attrib, attrib_value)
        file.update()

class MetadataFile:

    def __init__(self, file):
        self.ns = "{http://soap.sforce.com/2006/04/metadata}"
        self.file = file
        self.hasChanged = False
        self.tree = ET.parse(self.file)
        self.root = self.tree.getroot()

    def remove_by_attribute(self, element, attrib, attrib_value):

        for el in self.root.iter(self.ns + element):

            if el.find(self.ns + attrib) != None:   
            
                if el.find(self.ns + attrib).text == attrib_value:
                    self.root.remove(el)
                    self.hasChanged = True
                
    def remove_from_package(self, element, attrib, attrib_value, to_remove):
        for el in self.root.iter(self.ns + element):

            if el.find(self.ns + attrib).text == attrib_value:
                for child_el in el.findall(self.ns + "members"):
                    if child_el.text in to_remove:
                        el.remove(child_el)
                        self.hasChanged = True

    def find_by_root_index(self, index):
       return self.root[index].text

    def update(self):
        if self.hasChanged:
            self.tree.write(self.file, encoding="utf-8", xml_declaration=True)