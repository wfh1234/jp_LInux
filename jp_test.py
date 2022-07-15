# -*- coding: utf-8 -*-
import openpyxl
from datetime import datetime
import pytz
import psutil
import os
import time
import json
import re
from scp import SCPClient
import paramiko
import socket
import argparse

# import xlsxwriter
# df.to_excel('./质检留档/{}/{}.xlsx', engine='xlsxwriter', index=False)
parser = argparse.ArgumentParser(description='jp script')
parser.add_argument('-o', '--order_no', default="test", type=str, help='订单号', required=True)
args = parser.parse_args()


class Config(object):
    @staticmethod
    def get_config_data():
        with open('./config.json', 'r') as f:
            return json.load(f)

class JPServerDetection(object):
    def __init__(self):
        config = Config()
        config_data = config.get_config_data()
        self.server_password = config_data.get('server_password', '')
        self.remote_path = config_data.get('remote_path', '')
        self.remote_host = config_data.get('remote_host', '0.0.0.0')
        self.remote_port = config_data.get('remote_port', 22)
        self.remote_username = config_data.get('remote_username', 'root')
        self.remote_password = config_data.get('remote_password', '111111')

        base_path = config_data.get('shell_path', '/')
        self.cpu_shell = '{}{}'.format(base_path, config_data.get('cpu_shell', 'cpu_info.sh'))
        self.ipmi_shell = '{}{}'.format(base_path, config_data.get('ipmi_shell', 'ipmi_info.sh'))
        self.mem_shell = '{}{}'.format(base_path, config_data.get('mem_shell', 'mem_info.sh'))
        self.raid1_shell = '{}{}'.format(base_path, config_data.get('raid1_shell', 'raid_info1.sh'))
        self.raid2_shell = '{}{}'.format(base_path, config_data.get('raid2_shell', 'raid_info2.sh'))
        self.disk_shell = '{}{}'.format(base_path, config_data.get('disk_shell', 'disk_info.sh'))
        self.disk2_shell = '{}{}'.format(base_path, config_data.get('disk2_shell', 'disk_info2.sh'))
        self.fan_shell = '{}{}'.format(base_path, config_data.get('fan_shell', 'fan_info.sh'))
        self.power_shell = '{}{}'.format(base_path, config_data.get('power_shell', 'power_info.sh'))
        self.bios_shell = '{}{}'.format(base_path, config_data.get('bios_shell', 'bios_info.sh'))
        self.motherboard_shell = '{}{}'.format(base_path, config_data.get('motherboard_shell', 'motherboard_info.sh'))
        self.network1_shell = '{}{}'.format(base_path, config_data.get('network1_shell', 'network_info1.sh'))
        self.usb_shell = '{}{}'.format(base_path, config_data.get('usb_shell', 'usb_info.sh'))
        self.nvidia_shell = '{}{}'.format(base_path, config_data.get('nvidia_shell', 'nvidia_info.sh'))
        self.network_test_shell = '{}{}'.format(base_path, config_data.get('network_test_shell', 'network_info3.sh'))
        self.fc_hba_shell = '{}{}'.format(base_path, config_data.get('fc_hba_shell', 'fc_hba_info.sh'))
        self.system_shell = '{}{}'.format(base_path, config_data.get('system_shell', 'system_info.sh'))
        self.cdrom_shell = '{}{}'.format(base_path, config_data.get('cdrom_shell', 'cdrom_info.sh'))
        self.init_software_shell = '{}{}'.format(base_path, config_data.get('init_software_shell', 'jp_info.sh'))
        self.graphics_shell = '{}{}'.format(base_path, config_data.get('graphics_shell', 'graphics_info.sh'))
        self.nvidia2_shell = '{}{}'.format(base_path, config_data.get('nvidia2_shell', 'nvidia_info2.sh'))
        self.network4_shell = '{}{}'.format(base_path, config_data.get('network4_shell', 'network_info4.sh'))
        self.audio_shell = '{}{}'.format(base_path, config_data.get('audio_shell', 'audio_info.sh'))
        self.fc_hba_info2_shell = '{}{}'.format(base_path, config_data.get('fc_hba_info2_shell', 'fc_hba_info2.sh'))
        self.hba_info1_shell = '{}{}'.format(base_path, config_data.get('hba_info1_shell', 'hba_info1.sh'))
        self.hba_info2_shell = '{}{}'.format(base_path, config_data.get('hba_info2_shell', 'hba_info2.sh'))
        self.hba_info1_2_shell = '{}{}'.format(base_path, config_data.get('hba_info1_2_shell', 'hba_info1_2.sh'))
        self.hba_info2_2_shell = '{}{}'.format(base_path, config_data.get('hba_info2_2_shell', 'hba_info2_2.sh'))
        self.fan_mode_shell='{}{}'.format(base_path,config_data.get('fan_mode_shell','fan_mode.sh'))

    @staticmethod
    def os_popen(command):
        """运行linux命令"""
        return os.popen(command)

    def init_software(self):
        """预安装软件"""
        # ubantu_command = 'sh {}'.format(self.server_password, self.init_software_shell)
        #
        # if self.system_name == 'ubantu':
        #
        self.os_popen('echo {} | sudo -S sh {}'.format(self.server_password, self.init_software_shell))

    def get_sys_info(self):
        """获取操作系统信息"""
        #操作系统名称
        # sys_info = self.os_popen('{}'.format(self.system_shell))
        sys_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.system_shell))
        sys_data = sys_info.read().strip()
        #print("1",sys_data)
        return [i.strip() for i in sys_data.split('*')]

    def get_cpu_info(self):
        """获取cpu信息"""
        cpu_info = self.os_popen('echo {} | sudo -S {} | grep "cpu_info:"'.format(self.server_password, self.cpu_shell))
        cpu_data = cpu_info.read().strip()

        res = [i.split('cpu_info:')[1].strip() for i in cpu_data.split('\n')]
        cpu_str = ''
        for i in res:
            cpu_data = [j.strip() for j in i.split('*')]
            cpu_str += '名称：{}，版本：{}，核心数：{}，针脚数：{}\n'.format(*cpu_data)

        return cpu_str.strip()

    def get_ipmi_info(self):
        """获取ipmi信息"""
        ipmi_info = self.os_popen('echo {} | sudo -S {} | grep "ipmi_info:"'.format(
            self.server_password, self.ipmi_shell))
        ipmi_data = ipmi_info.read().strip()
        try:
            ipmi_list = [i.strip() for i in ipmi_data.split('ipmi_info:')[1].split('*')]
        except Exception as e:
            print('获取ipmi信息失败')
            # print(e)
            return None
        if len(ipmi_list) != 4:
            return None
        return ipmi_list

    def get_mem_info(self):
        """获取内存信息"""
        # global sys_data
        # print(sys_data)
        # if "Ubuntu" in sys_data:
        #     mem_info=self.os_popen('{}'.format(self.mem_shell))
        # else:
        mem_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.mem_shell))
        mem_data = mem_info.read().strip()
        mem_list = mem_data.split('\n')
        mem_str = ''
        mem_sum = 0
        # mem_str1=''
        unit = 'GB'
        for mem in mem_list:
            single_mem = [i.strip() for i in mem.split("*")]
            if len(single_mem) != 6:
                return None
            mem_str += '制造商：{}，内存条：{}，容量：{}，速度：{}， 规格：{}，PN号：{}\n'.format(*single_mem)
            mem_sum += int(single_mem[2].strip()[:-2])
            unit = single_mem[2].strip()[-2:]
        # if '-e' in mem_str:
        #     mem_str1=mem_str.replace('-e','')
        # if '-e' not in mem_str:
        #     mem_str1=mem_str
        return {
            'mem_detail': mem_str.strip(),
            'mem_sum': '{} {}'.format(round(float(mem_sum), 1), unit),
            'mem_num': len(mem_list)
        }

    def get_raid_info(self):
        """获取raid信息"""
        raid_info = self.os_popen('echo {} | sudo -S {} | grep "raid_info:"'.format(
            self.server_password, self.raid1_shell))
        raid_data = raid_info.read().strip()
        # print("raid_data:为",raid_data)
        # print("sss:",raid_data.split('raid_info:'))
        # print("www:",raid_data.split('raid_info:')[-1])
        # print('ddd',raid_data.split('raid_info:')[-1].split('*'))
        raid_list = [i.strip() for i in raid_data.split('raid_info:')[-1].split('*')]
        # print("raid_list:为",raid_list)
        if len(raid_list) != 12:
            return list('无' * 12)
        new_list = list()
        for i in raid_list:
            if not i:
                i = '无'
            new_list.append(i)
        # print('new_list:',new_list)
        return new_list

    def get_raid_disk_info(self):
        """接RAID卡物理磁盘"""
        raid_disk_info = self.os_popen('echo {} | sudo -S {}'.format(
            self.server_password, self.raid2_shell))
        raid_disk_data = raid_disk_info.read().strip()
        raid_data = raid_disk_data.split('\n')
        disk_str = ''
        for i in raid_disk_data.split('\n'):
            disk_list = [j.strip() for j in i.replace('\t', ' ').split(' ') if j.strip()]
            if len(disk_list) != 5:
                return {'disk': '无'}
            disk_str += 'slot位置：{}，硬盘型号：{}，接口类型：{}，容量：{}，硬盘状态：{}\n'.format(*disk_list)

        return {'disk': disk_str.strip() or '无', 'raid_data': len(raid_data)}

    def get_disk_info(self):
        """硬盘信息"""
        disk_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.disk_shell))
        disk_data = disk_info.read().strip()
        disk_data1 = disk_data.split('\n')
        disk_str = ''
        for i in disk_data.split('\n'):
            disk_list = [j.strip() for j in i.replace('\t', ' ').split(' ') if j.strip()]
            if len(disk_list) == 4:
                disk_list.append('无')
            else:
                if len(disk_list) != 5:
                    return {'disk': '无'}
            disk_str += '型号：{}，固件版本：{}，盘符：{}，容量：{}，序列号：{}\n'.format(*disk_list)
        return {'disk': disk_str.strip() or '无', 'data1': len(disk_data1)}

    def get_disk2_info(self):
        disk2_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.disk2_shell))
        disk2_data = disk2_info.read().strip()
        if not disk2_data:
            return '无'
        disk_str = ''
        for i in disk2_data.split('\n'):
            disk_list = [j.strip() for j in i.replace('\t', ' ').split(' ') if j.strip()]
            while len(disk_list) < 4:
                disk_list.append('无')
            if len(disk_list) > 4:
                return '无'
            new_disk_list = [disk_list[1], disk_list[0], disk_list[2], disk_list[3]]
            disk_str += '盘符：{:<20}大小：{:<20}文件系统：{:<20}挂载点：{}\n'.format(*new_disk_list)

        return disk_str.strip() or '无'

    def get_fan_info(self, fan_str1=''):
        """获取风扇信息"""

        fan_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.fan_shell))
        fan_data = fan_info.read().strip()
        
        fan_mode = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.fan_mode_shell))
        fan_mode_info = fan_mode.read().strip()
        

        if not fan_data:
            print('---please input fan info---')
            while True:
                print('please input fan amount, require positive integer')
                fan_amount = input('fan amount:')
                try:
                    fan_amount = int(fan_amount)
                except ValueError:
                    print('fan amount require positive integer')
                    continue
                if fan_amount <= 0:
                    print('fan amount require positive integer')
                    continue
                break
            while True:
                print('please input fan status: 0 or 1，0 is ok, 1 is fail')
                fan_status = input('fan status:')
                if fan_status not in ['0', '1']:
                    print('please input 0 or 1，0 is ok, 1 is fail')
                    continue
                break
            return {'fan_info':'风扇总数量：{}，状态：{}\n'.format(fan_amount, {'0': '合格', '1': '不合格'}.get(fan_status)) or '无'}

        fan_list = fan_data.split('\n')
        fan_str = len(fan_list)
        for i in fan_list:
            fan_list = [j.strip() for j in i.replace('\t', ' ').split('  ') if j.strip()]
            fan_str1 += '风扇：{}，转速：{}，状态：{}\n'.format(*fan_list)

        return {'fan_info': fan_str1.strip() or "无", 'fandata': fan_str,'fan_mode':fan_mode_info}

    def get_power_info(self):
        power_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.power_shell))
        power_data = power_info.read().strip()
        if not power_data:
            print('---please input power info---')
            while True:
                print('please input power amount, require positive integer')
                power_amount = input('power amount:')
                try:
                    power_amount = int(power_amount)
                except ValueError:
                    print('fan amount require positive integer')
                    continue
                if power_amount <= 0:
                    print('fan amount require positive integer')
                    continue
                break

            while True:
                print(
                    'please input power manufacturer: [0][1][2][3][4][5][6][7][8]，0 is Supermicro, 1 is DELTA, 2 is AcBel, 3 is Great Wall,4 is  3Y,5 is  gooxi,6 is FSP, 7 is Huntkey,8 is gooxi,')
                power_manufacturer = input('power manufacturer:')
                if power_manufacturer not in ['0', '1', '2', '3', '4', '5', '6', '7', '8']:
                    continue
                break

            while True:
                print('please input power capacity, require positive integer, from 100 to 2200')
                power_capacity = input('power capacity:')
                try:
                    power_capacity = int(power_capacity)
                except ValueError:
                    print('power capacity require positive integer')
                    continue
                if power_capacity > 2200 or power_capacity < 100:
                    print('power capacity require positive integer, from 200 to 2200')
                    continue
                break

            while True:
                print('please input power status: 0 or 1，0 is ok, 1 is fail')
                fan_status = input('power status:')
                if fan_status not in ['0', '1']:
                    print('please input 0 or 1，0 is ok, 1 is fail')
                    continue
                break

            power_dict = {'0': 'Supermicro', '1': 'DELTA', '2': 'AcBel', '3': 'Great Wall', '4': '3Y', '5': 'gooxi',
                          '6': 'FSP', '7': 'Huntkey', '8': 'gooxi'}
            return '电源总数量：{}，品牌：{}，功率：{} W，状态：{}'.format(
                power_amount,
                power_dict.get(power_manufacturer),
                power_capacity,
                {'0': '合格', '1': '不合格'}.get(fan_status)
            )

        power_list = power_data.split('\n\t')
        man_list, revision_list, capacity_list, status_list = list(), list(), list(), list()
        for i in power_list:
            if i.startswith('Manufacturer:'):
                man_list.append(i.split('Manufacturer:')[-1].strip())
            elif i.startswith('Revision:'):
                revision_list.append(i.split('Revision:')[-1].strip())
            elif i.startswith('Max Power Capacity:'):
                capacity_list.append(i.split('Max Power Capacity:')[-1].strip())
            elif i.startswith('Status:'):
                status_list.append(i.split('Status:')[-1].strip())

        power_str = ''
        for value in zip(man_list, revision_list, capacity_list, status_list):
            value = [j.split(':')[-1].strip() for j in value]
            power_str += '品牌：{}，版本：{}，功率：{}，状态：{}\n'.format(*value)
        return power_str.strip()

    def get_bios_info(self):
        bios_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.bios_shell))
        bios_data = bios_info.read().strip()
        bios_list = bios_data.split('*')
        return {
            'version': bios_list[0].split(':')[-1].strip(),
            'AHCI': bios_list[1].split(':')[-1].strip(),
            'release_date': bios_list[2].split(':')[-1].strip(),
            'current_time': bios_list[3].strip()
        }

    def get_motherboard_info(self):
        board_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.motherboard_shell))
        board_data = board_info.read().strip()
        board_list = board_data.split('*')
        return {
            'manufacturer': board_list[0].split(':')[-1].strip(),
            'product_name': board_list[1].split(':')[-1].strip(),
            'serial_number': board_list[2].split(':')[-1].strip()
        }

    def get_network_info(self):
        network_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.network1_shell))
        network_data = network_info.read().strip().split('\n')
        new_network_data = [i for i in network_data if i]
        network_str = ''
        for i in new_network_data:
            new_list = [j.strip() for j in i.split('*') if j.strip()]
            network_str += '速度：{}，MAC地址：{}，网口名称：{}，网口芯片：{}\n'.format(*new_list)

        return {'net_work': network_str.strip() or '无', 'net_data': len(network_data)}

    def get_independent_network_info(self):
        """获取独立网卡信息"""
        network_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.network4_shell))
        network_data = network_info.read().strip().split('\n')
        new_network_data = [i for i in network_data if i]
        network_str = ''
        for i in new_network_data:
            network_list = [j.strip() for j in i.split('*') if j.strip()]
            network_str += 'PCI-E插槽信息：{}，型号：{}\n'.format(*network_list)

        return {'independent_net': network_str.strip() or '无', 'net_data': len(network_data)}

    def get_usb_info(self):
        usb_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.usb_shell))
        usb_data = usb_info.read().strip()
        usb_data1 = usb_data.split('\n')
        usb_list = [i for i in usb_data.split('\n') if i]

        usb_str = ''
        for i in usb_list:
            usb_str += 'USB接口：{}，测试结果：{}\n'.format(*[j.strip() for j in i.split('*')])

        return {'usb': usb_str.strip() or '无', 'data': len(usb_data1)}

    def get_nvidia_info(self):
        """独立显卡"""
        nvidia_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.nvidia_shell))
        data = nvidia_info.read().strip().split('\n')
        new_data = [i for i in data if i]
        model_list, pci_e_list, vbios_list, image_list = list(), list(), list(), list()
        for i in new_data:
            values = i.split(':')
            if values[0].strip() == 'model':
                model_list.append(values[1].strip())
            elif values[0].strip() == 'pci-e':
                pci_e_list.append(values[1].strip())
            elif values[0].strip() == 'vbios':
                vbios_list.append(values[1].strip())
            elif values[0].strip() == 'image':
                image_list.append(values[1].strip())

        data_str = ''
        for i in zip(model_list, pci_e_list, vbios_list, image_list):
            data_str += '型号：{}，PCI-E位置：{}，VBIOS版本：{}，Image版本：{}\n'.format(*i)
        data1=len(data_str.split('\n'))-1
        return {'nvidia': data_str.strip() or '无', 'data': data1}

    def get_nvidia_info2(self):
        """nvidia-smi信息"""
        nvidia_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.nvidia2_shell))
        return nvidia_info.read().strip() or '无'

    def get_graphics_info(self):
        """集成显卡"""
        graphics_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.graphics_shell))
        return graphics_info.read().strip() or '无'

    def get_network_test_info(self):
        network_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.network_test_shell))
        network_data = network_info.read().strip().split('\n')
        new_network_data = [i for i in network_data if i]
        data_str = ''
        for i in new_network_data:
            single_data = [j for j in i.strip().split(' ') if j]
            data_str += '网口名称：{}，链接速度：{}，测试结果：{}\n'.format(*single_data)

        return data_str.strip() or '无'

    # def get_fc_hba_info(self):
    #     """hba卡信息"""
    #     hba_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.fc_hba_shell))
    #     hba_data = hba_info.read().strip().split('\n')
    #     print(hba_data)
    #     new_hba_data = [i for i in hba_data if i]
    #     print(new_hba_data)
    #     hba_data_str = ''
    #     for i in new_hba_data:
    #         single_data = [j.strip() for j in i.strip().split('*') if j]
    #         print(single_data)
    #         #hba_data_str += '型号：{}，规格: {}，序列号：{}\n'.format(*single_data)
    #         hba_data_str += single_data
    #
    #     return hba_data_str.strip() or '无'
    def get_fc_hba_info(self):
        hba_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.fc_hba_shell))
        hba_data = hba_info.read().strip()
        return hba_data or '无'

    def get_cdrom_info(self):
        """光驱"""
        cdrom_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.cdrom_shell))
        return cdrom_info.read().strip() or '无'

    def get_audio_info(self):
        """声卡"""
        audio_info = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.audio_shell))
        return audio_info.read().strip() or '无'

    def get_fc_hba_info2(self):
        "PCI-E插槽信息"
        fc_hba_info2 = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.fc_hba_info2_shell))
        return fc_hba_info2.read().strip() or '无'

    def get_hba_info1(self):
        hba_info1 = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.hba_info1_shell))
        raid_data = hba_info1.read().strip()
        raid_list = [i.strip() for i in raid_data.split('hba_info:')[-1].split('*')]
        if len(raid_list) != 8:
            return list('无' * 8)
        new_list = list()
        for i in raid_list:
            if not i:
                i = '无'
            new_list.append(i)
        return new_list

    def get_hba_info2(self):
        hba_info2 = self.os_popen('echo {} | sudo -S {}'.format(self.server_password, self.hba_info2_shell))
        raid_data = hba_info2.read().strip()
        raid_list = [i.strip() for i in raid_data.split('hba_info:')[-1].split('*')]
        if len(raid_list) != 8:
            return list('无' * 8)
        new_list = list()
        for i in raid_list:
            if not i:
                i = '无'
            new_list.append(i)
        return new_list

    def get_hba_info1_2(self):
        """接RAID卡物理磁盘"""
        raid_disk_info = self.os_popen('echo {} | sudo -S {}'.format(
            self.server_password, self.hba_info1_2_shell))
        raid_disk_data = raid_disk_info.read().strip()
        raid_data = raid_disk_data.split('\n')
        disk_str = ''
        for i in raid_disk_data.split('\n'):
            disk_list = [j.strip() for j in i.replace('\t', ' ').split(' ') if j.strip()]
            if len(disk_list) != 5:
                return {'disk': '无'}
            disk_str += 'slot位置：{}，硬盘型号：{}，接口类型：{}，容量：{}，硬盘状态：{}\n'.format(*disk_list)

        return {'disk': disk_str.strip() or '无', 'raid_data': len(raid_data)}

    def get_hba_info2_2(self):
        """接RAID卡物理磁盘"""
        raid_disk_info = self.os_popen('echo {} | sudo -S {}'.format(
            self.server_password, self.hba_info2_2_shell))
        raid_disk_data = raid_disk_info.read().strip()
        raid_data = raid_disk_data.split('\n')
        disk_str = ''
        for i in raid_disk_data.split('\n'):
            disk_list = [j.strip() for j in i.replace('\t', ' ').split(' ') if j.strip()]
            if len(disk_list) != 5:
                return {'disk': '无'}
            disk_str += 'slot位置：{}，硬盘型号：{}，接口类型：{}，容量：{}，硬盘状态：{}\n'.format(*disk_list)

        return {'disk': disk_str.strip() or '无', 'raid_data': len(raid_data)}

    def scp_report(self, local_path, target_path):
        """拷贝报告到远程服务器"""
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy)

        try:
            ssh_client.connect(self.remote_host, self.remote_port, self.remote_username, self.remote_password,
                               timeout=5)
        except socket.gaierror:
            print(u'ssh连接{}:{}服务器失败，请确认服务器可以连通或者参数配置是否正确'.format(self.remote_host, self.remote_port))
            return
        except paramiko.ssh_exception.NoValidConnectionsError:
            print(u'ssh无法连接服务器：{}的端口：{}，请检查服务器端口或者参数配置是否正确'.format(self.remote_host, self.remote_port))
            return
        except paramiko.ssh_exception.AuthenticationException:
            print(u'ssh连接服务器{}:{}的用户名或密码错误，请检查参数配置是否正确'.format(self.remote_host, self.remote_port))
            return
        except Exception as e:
            print(u'ssh连接服务器的其他错误：{}'.format(e))
            return
        scp_client = SCPClient(ssh_client.get_transport(), socket_timeout=15.0)

        try:
            scp_client.put(local_path, target_path)
        except FileNotFoundError as e:
            # print(e)
            print("系统找不到指定的报告文件：" + local_path)
        ssh_client.close()

    def run(self):
        args_list = list(args.order_no)
        list1 = []
        for i in args_list[4:]:
            if 'A' <= i <= 'Z':
                list1.append(i)
        dir_name = ''
        for j in range(len(list1)):
            dir_name += list1[j]
        os.makedirs('./质检留档/{}'.format(dir_name), exist_ok=True)
        wb = openpyxl.load_workbook('report_template.xlsx')
        sheet = wb['Sheet1']

        # 预安装软件
        self.init_software()

        # 订单号
        sheet['C3'].value = args.order_no

        # 操作系统
        # 操作系统名称及版本号/内核版本/计算机类型/计算机的网络名称/操作系统内核
        sys_info = self.get_sys_info()
        if len(sys_info) == 1 and sys_info[0] == '':
            sheet['C4'].value = '无'
            sheet['C5'].value = '无'
        else:
            #for i, value in enumerate(sys_info):
                #if i == 1:
                    #sheet['C4'].value = '系统版本：' + value or '无'
                #kernel = sys_info[0] or '无'
                #data_time = sys_info[2] or '无'
                #sheet['C5'].value = '内核：{}{}系统时间日期：{}'.format(kernel, ' ' * 53, data_time) or '无'
            kernel=sys_info[0] or '无'
            boot=sys_info[1] or '无'
            version=sys_info[2] or '无'
            time=sys_info[3] or '无'
            sheet['C4'].value='系统版本:{}{}系统引导方式:{}'.format(version,' ' * 10,boot) or '无'
            sheet['C5'].value='内核:{}{}系统时间日期:{}'.format(kernel,' ' * 10,time) or '无'
        # 主板信息
        motherboard_info = self.get_motherboard_info()
        # 主板品牌
        manufacture = motherboard_info.get("manufacturer", '无')
        # 主板型号
        product_name = motherboard_info.get("product_name", '无')
        # 主板序列号
        serial_list = motherboard_info.get("serial_number", '无')

        sheet['C6'].value = '主板品牌:{}{}主板型号：{}{}主板序列号：{}'.format(manufacture, ' ' * 10, product_name, ' ' * 10,
                                                                serial_list)
        # # bios信息
        bios_info = self.get_bios_info()
        version = bios_info.get('version', '无')
        ahci = bios_info.get('AHCI', '无')
        release_date = bios_info.get('release_date', '无')
        current_time = bios_info.get('current_time', '无')

        sheet['C7'].value = 'BIOS版本：{}{}硬盘模式：{}{}BIOS创建日期：{}{}BIOS时间日期：{}'.format(version, ' ' * 10, ahci, ' ' * 10,
                                                                                  release_date, ' ' * 10,
                                                                                  current_time)
        # ipmi
        ipmi_info = self.get_ipmi_info()
        if ipmi_info:
            for i, j in enumerate(ipmi_info):
                ipmi_address = ipmi_info[0]
                get_ipmi_address = ipmi_info[1]
                mac = ipmi_info[2]
                firmware = ipmi_info[3]
                sheet['C8'].value = 'IPMI地址：{}{}IPMI地址获取方式：{}{}MAC地址：{}{}固件版本:{}'.format(ipmi_address, ' ' * 10,
                                                                                         get_ipmi_address, ' ' * 10,
                                                                                         mac,
                                                                                         ' ' * 10, firmware)
        # # cpu型号
        sheet['C9'].value = self.get_cpu_info()
        # 内存信息
        mem_info = self.get_mem_info()
        # print(mem_info)
        if not mem_info:
            print('获取内存信息失败，请检验shell脚本配置')
        else:
            # 内存总容量
            mem_sum = mem_info.get('mem_sum', '无')
            # 内存条数量
            mem_num = mem_info.get("mem_num", '无')
            # 内存条详情
            mem_detail = mem_info.get("mem_detail", '无')
            # print(mem_detail)
            sheet['C10'].value = '{}\n\n总容量：{}{}内存条数量：{}'.format(mem_detail, mem_sum, ' ' * 10, mem_num)
            if '无' in sheet['C10'].value:
                sheet['C10'].value = '{}'.format(mem_detail)
        # 硬盘信息
        disk_info = self.get_disk_info()
        disk = disk_info.get('disk', '无')
        data1 = disk_info.get('data1', '无')
        sheet['C11'].value = '{}\n\n磁盘总数量：{}'.format(disk, data1)
        if '无' in sheet['C11'].value:
            sheet['C11'].value = '{}'.format(disk)

        # # 分区信息
        sheet['C12'].value = self.get_disk2_info()

        # 显卡
        # 集显信息
        # str=''
        # str_graphics=self.get_graphics_info()
        # if '-e' in str_graphics:
        #     str=str_graphics.replace('-e','')
        # if '-e' not in str_graphics:
        #     str=str_graphics
        sheet['C13'].value = self.get_graphics_info()
        # print(self.get_graphics_info())
        # 独立显卡信息
        # sheet['C14'].value = self.get_nvidia_info()
        get_nvidia = self.get_nvidia_info()
        nvidia = get_nvidia.get('nvidia')
        data2 = get_nvidia.get('data')

        sheet['C14'].value = '{}\n\n独立显卡总数量：{}'.format(nvidia, data2)
        if '无' in sheet['C14'].value:
            sheet['C14'].value = '{}'.format(nvidia)
        # nvidia-smi信息
        sheet['C15'].value = self.get_nvidia_info2()

        # 电源信息
        sheet['C16'].value = self.get_power_info()

        # usb信息
        get_usb = self.get_usb_info()
        usb = get_usb.get('usb')
        data = get_usb.get('data')
        sheet['C17'].value = '{}\n\nusb接口总数量：{}'.format(usb, data)
        if '无' in sheet['C17'].value:
            sheet['C17'].value = '{}'.format(usb)
        # 网口信息
        net_info = self.get_network_info()
        net_work = net_info.get('net_work')
        net_data = net_info.get('net_data')
        sheet['C18'].value = '{}\n\n网口总数量:{}'.format(net_work, net_data)
        # 网卡信息
        independent_network = self.get_independent_network_info()
        independent_net = independent_network.get('independent_net')
        net_data = independent_network.get('net_data')
        sheet['C19'].value = '{}\n\n独立网卡总数量：{}'.format(independent_net, net_data)
        if '无' in sheet['C19'].value:
            sheet['C19'].value = '{}'.format(independent_net)
        sheet['C20'].value = self.get_network_test_info()

        # raid信息
        # Firmware 版本/RAID 状态/RAID 级别/RAID 容量/RAID卡插PCI-E槽信息/RAID卡序列号/RAID卡型号/缓存容量/BBU电池状态/写入模式/接RAID卡物理磁盘
        raid_info = self.get_raid_info()
        # print(raid_info)
        for i, value in enumerate(raid_info):
            sheet['C{}'.format(i + 21)].value = value
        # 物理磁盘
        get_raid = self.get_raid_disk_info()
        disk = get_raid.get('disk')
        data = get_raid.get('raid_data')
        sheet['C33'].value = '{}\n\n物理磁盘总数量:{}'.format(disk, data)
        if '无' in sheet['C33'].value:
            sheet['C33'].value = '无'

        # FC HBA卡信息
        sheet['C35'].value = self.get_fc_hba_info()

        # 风扇信息
        fan = self.get_fan_info()
        fan_info = fan.get('fan_info')
        fan_data = fan.get('fandata')
        fan_mode = fan.get('fan_mode')
        sheet['C34'].value = '{}\n\n风扇总数量:{}            风扇模式:{}'.format(fan_info, fan_data,fan_mode)
        if '无' in sheet['C34'].value:
            sheet['C34'].value = '{}'.format(fan_info)
        # PCI-E插槽信息
        sheet['C36'].value = self.get_fc_hba_info2()
        # 光驱
        sheet['C39'].value = self.get_cdrom_info()
        # 声卡
        # str_audio=''
        # audio=self.get_audio_info()
        # if '-e' in audio:
        #     str_audio=audio.replace('-e','')
        # if '-e' not in audio:
        #     str_audio=audio
        sheet['C40'].value = self.get_audio_info()
        # 第一个hba卡
        hba_info1 = self.get_hba_info1()
        # print(raid_info)
        for i, value in enumerate(hba_info1):
            sheet['C{}'.format(i + 42)].value = value
        # 物理磁盘
        get_info1_2 = self.get_hba_info1_2()
        disk = get_info1_2.get('disk')
        data = get_info1_2.get('raid_data')
        sheet['C50'].value = '{}\n\n物理磁盘总数量:{}'.format(disk, data)
        if '无' in sheet['C50'].value:
            sheet['C50'].value = '无'
        # 第二个hba卡
        hba_info2 = self.get_hba_info2()
        for i, value in enumerate(hba_info2):
            sheet['C{}'.format(i + 51)].value = value
        # 物理磁盘
        hba_info2_2 = self.get_hba_info2_2()
        disk = hba_info2_2.get('disk')
        data = hba_info2_2.get('raid_data')
        sheet['C59'].value = '{}\n\n物理磁盘总数量:{}'.format(disk, data)
        if '无' in sheet['C59'].value:
            sheet['C59'].value = '无'
        file_path = u'./质检留档/{}/{}整机检验报告(信息与功能项).xlsx'.format(dir_name, args.order_no)
        wb.save(file_path)
        # remote_path=u'./home/jp/data/质检留档/{}'.format(dir_name)
        # 远程服务器
        self.scp_report(local_path=file_path, target_path=self.remote_path)



if __name__ == '__main__':
    jp = JPServerDetection()
    jp.run()
