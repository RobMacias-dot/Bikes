"""OOXML boundary tests; mutate temporary copies, never the editorial master."""
import copy
import hashlib
from pathlib import Path
import tempfile
import unittest
import zipfile
import xml.etree.ElementTree as ET
from xlsx_master import read_workbook, MasterError, NS

MASTER = Path(__file__).resolve().parents[1] / 'knowledge/master/BiciFirme_Componentes_Master.xlsx'
S = '{' + NS['s'] + '}'

class MasterReaderTests(unittest.TestCase):
    def mutated(self, change):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'copy.xlsx'
            with zipfile.ZipFile(MASTER) as source, zipfile.ZipFile(path,'w') as target:
                for item in source.infolist():
                    data = source.read(item.filename)
                    if item.filename == 'xl/worksheets/sheet2.xml':
                        root = ET.fromstring(data); change(root); data=ET.tostring(root)
                    target.writestr(item,data)
            return read_workbook(path)
    def test_full_master_and_dates(self):
        data=read_workbook(MASTER)
        self.assertEqual(len(data['SPECIFICATIONS']['rows']),409)
        self.assertEqual(data['SOURCES']['rows'][0]['reviewed_at'],'2026-09-06')
        self.assertEqual(hashlib.sha256(MASTER.read_bytes()).hexdigest(),'e3b4510f378b70c6e2758b24b1301124b49806b3299ad70612758fbdce706b1d')
    def test_formula_rejected_even_with_cached_value(self):
        with self.assertRaisesRegex(MasterError,'formula'):
            self.mutated(lambda root: ET.SubElement(root.find('.//s:row[@r="2"]/s:c',NS),S+'f'))
    def test_error_cell(self):
        with self.assertRaisesRegex(MasterError,'Excel error'):
            self.mutated(lambda root: root.find('.//s:row[@r="2"]/s:c',NS).set('t','e'))
    def test_duplicate_cell(self):
        def change(root):
            row=root.find('.//s:row[@r="2"]',NS);row.append(copy.deepcopy(row[0]))
        with self.assertRaisesRegex(MasterError,'duplicate cell'): self.mutated(change)
    def test_duplicate_row(self):
        def change(root):
            rows=root.find('s:sheetData',NS);rows.append(copy.deepcopy(rows[1]))
        with self.assertRaisesRegex(MasterError,'duplicate row'): self.mutated(change)
    def test_duplicate_column(self):
        def change(root):
            row=root.find('.//s:row[@r="1"]',NS)
            replacement=copy.deepcopy(row[0]);replacement.set('r',row[1].get('r'));row.remove(row[1]);row.append(replacement)
        with self.assertRaisesRegex(MasterError,'duplicate columns'): self.mutated(change)
    def test_header_missing_but_column_has_values(self):
        def change(root):
            row=root.find('.//s:row[@r="1"]',NS);row.remove(row[0])
        with self.assertRaisesRegex(MasterError,'without column header'): self.mutated(change)
    def test_invalid_shared_string(self):
        def change(root):
            cell=root.find('.//s:row[@r="2"]/s:c',NS);cell.clear();cell.set('r','A2');cell.set('t','s');ET.SubElement(cell,S+'v').text='-1'
        with self.assertRaisesRegex(MasterError,'shared string'): self.mutated(change)

if __name__=='__main__': unittest.main()
