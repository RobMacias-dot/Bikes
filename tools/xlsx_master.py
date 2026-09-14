"""Read-only OOXML reader for the audited BiciFirme editorial master (no Excel runtime)."""
from __future__ import annotations
import datetime as dt
import json
import posixpath
import re
import zipfile
from pathlib import Path
import xml.etree.ElementTree as ET

NS = {'s': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
RID = '{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id'

class MasterError(ValueError):
    pass

def read_workbook(path):
    with zipfile.ZipFile(path) as archive:
        names = archive.namelist()
        if len(names) != len(set(names)) or sum(i.file_size for i in archive.infolist()) > 40_000_000:
            raise MasterError('Duplicate ZIP entries or workbook exceeds 40 MB expanded limit')
        def xml(name):
            raw = archive.read(name)
            if b'<!DOCTYPE' in raw or b'<!ENTITY' in raw:
                raise MasterError('XML entities are not supported')
            return ET.fromstring(raw)
        book = xml('xl/workbook.xml')
        props = book.find('s:workbookPr', NS)
        epoch = dt.datetime(1904, 1, 1) if props is not None and props.get('date1904') in ('1','true') else dt.datetime(1899, 12, 30)
        shared = []
        if 'xl/sharedStrings.xml' in names:
            shared = [''.join(t.text or '' for t in si.findall('.//s:t', NS)) for si in xml('xl/sharedStrings.xml').findall('s:si', NS)]
        relation_rows = list(xml('xl/_rels/workbook.xml.rels'))
        relations = {r.get('Id'): r for r in relation_rows}
        if len(relations) != len(relation_rows): raise MasterError('Duplicate relationship IDs')
        result = {}
        for sheet in book.findall('s:sheets/s:sheet', NS):
            name = sheet.get('name')
            if name in result: raise MasterError(f'Duplicate sheet {name}')
            relation = relations[sheet.get(RID)]
            if relation.get('TargetMode') == 'External': raise MasterError('External worksheet not allowed')
            target = relation.get('Target')
            target = posixpath.normpath(target.lstrip('/') if target.startswith('/') else 'xl/' + target)
            if not target.startswith('xl/'): raise MasterError('Worksheet path outside workbook')
            rows, headers, row_ids = [], None, set()
            for row in xml(target).findall('s:sheetData/s:row', NS):
                row_id = row.get('r', '')
                if not re.fullmatch(r'[1-9][0-9]*', row_id) or row_id in row_ids: raise MasterError(f'{name}: invalid or duplicate row')
                row_ids.add(row_id)
                cells = {}
                for cell in row.findall('s:c', NS):
                    address = cell.get('r', '')
                    if not re.fullmatch(r'[A-Z]{1,3}' + row_id, address): raise MasterError(f'{name}!{address}: invalid cell address')
                    col = re.sub(r'\d', '', address)
                    if col in cells: raise MasterError(f'{name}!{address}: duplicate cell')
                    if cell.find('s:f', NS) is not None: raise MasterError(f'{name}!{address}: formula not allowed in editorial source')
                    if cell.get('t') == 'e': raise MasterError(f'{name}!{address}: Excel error')
                    value = cell.findtext('s:v', '', NS)
                    if cell.get('t') == 's':
                        if not re.fullmatch(r'[0-9]+', value) or int(value) >= len(shared): raise MasterError('Invalid shared string reference')
                        value = shared[int(value)]
                    if cell.get('t') == 'inlineStr': value = ''.join(t.text or '' for t in cell.findall('.//s:t', NS))
                    cells[col] = value
                if not any(v.strip() for v in cells.values()): continue
                if headers is None:
                    headers = {col: value for col, value in cells.items() if value}
                    if len(headers.values()) != len(set(headers.values())): raise MasterError(f'{name}: duplicate columns')
                    continue
                if any(value and col not in headers for col, value in cells.items()): raise MasterError(f'{name}: value without column header')
                record = {header: cells.get(col, '') for col, header in headers.items()}
                for key in ('reviewed_at',):
                    if record.get(key) and re.fullmatch(r'\d+(\.\d+)?', record[key]):
                        serial = float(record[key])
                        if not serial.is_integer() or serial < 61 and epoch.year == 1899: raise MasterError(f'{name}: invalid editorial date')
                        record[key] = (epoch + dt.timedelta(days=serial)).date().isoformat()
                rows.append(record)
            result[name] = {'columns': list((headers or {}).values()), 'rows': rows}
        return result

if __name__ == '__main__':
    import sys, hashlib
    print(json.dumps({'sha256': hashlib.sha256(Path(sys.argv[1]).read_bytes()).hexdigest(),
                      'sheets': read_workbook(sys.argv[1])}, ensure_ascii=True))
