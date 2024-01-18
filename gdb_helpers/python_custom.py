class ArrayViewIterator:
    def __init__ (self, val):
        self.cursor = 0
        self.count = val['count'] 
        self.data = val['data'];

    def __iter__(self):
        return self

    def __next__(self):
        if self.cursor >= self.count:
            raise StopIteration
        result = (self.data + self.cursor).dereference()
        self.cursor += 1
        return f'{self.cursor-1}', result


class JaiArrayViewPrinter:
    def __init__(self, val):
        self.val = val

    # Looks like it's not used
    def child(self, n):
         return (self.val['data'] + n).dereference()

    # Looks like it's not used
    def num_children(self):
        return self.val['count']

    def children(self):
        return ArrayViewIterator(self.val)

    def to_string(self):
        return f'[{self.val["count"]}]'

    def display_hint(self):
        return 'array'

class JaiStringPrinter:
    def __init__(self, val):
        self.val = val

    # Unicode will break on the edge of the max length
    def to_string(self):
        count = min(self.val['count'], 500)
        return bytearray((self.val['data']+i).dereference() for i in range(count)).decode('utf-8')

    def display_hint(self):
        return 'string'

def project_type_lookups(val):
    type_tag = val.type.tag
    if type_tag is None:
        return None
    if type_tag == 'string':
        return JaiStringPrinter(val)
    if type_tag.startswith('[]'):
        return JaiArrayViewPrinter(val)

gdb.pretty_printers.append(project_type_lookups)
