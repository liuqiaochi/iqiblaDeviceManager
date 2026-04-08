#!/usr/bin/env python3
import json

# 读取旧数据
with open('data/devices.json', 'r', encoding='utf-8') as f:
    old_data = json.load(f)

# 转换为新格式
new_data = {
    'projects': {
        'life': {
            'id': 'life',
            'name': 'iQibla Life',
            'description': 'iQibla Life 产品线设备管理',
            'devices': old_data.get('devices', [])
        },
        'health': {
            'id': 'health',
            'name': 'iQibla Health',
            'description': 'iQibla Health 产品线设备管理',
            'devices': []
        }
    },
    'functions': old_data.get('functions', []),
    'versionNumbers': old_data.get('versionNumbers', ['0'])
}

# 备份旧文件
import shutil
shutil.copy('data/devices.json', 'data/devices.json.backup')

# 写入新数据
with open('data/devices.json', 'w', encoding='utf-8') as f:
    json.dump(new_data, f, ensure_ascii=False, indent=2)

print('转换完成！已备份原文件到 devices.json.backup')