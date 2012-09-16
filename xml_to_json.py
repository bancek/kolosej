import json
from collections import OrderedDict

def xml_to_py(el):
    if len(set([x.tag for x in el.getchildren()])) == 1:
        return [xml_to_py(x) for x in el.getchildren()]

    if hasattr(el, 'pyval'):
        return el.pyval

    data = OrderedDict()

    for key, value in el.attrib.items():
        data[key] = value

    for child in el.getchildren():
        data[child.tag] = xml_to_py(child)

    return data
